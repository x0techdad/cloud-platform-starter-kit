<#
.SYNOPSIS
  Creates a Public Cloud or PowerShell (Pwsh) dev environment on Windows OS.

.DESCRIPTION 
  This script creates a Public Cloud or PowerShell (Pwsh) dev environment on Windows OS, installs specified tools, applies recommended environment settings and clones a specified git code repository. Tools to install with this script are specified in JSON format, please see the README for expected schema.

.NOTES 
  Name        : setup-winSbx.ps1
  Author      : @x0techdad (GitHub)
  Requires    :
    PowerShell (5 or 7)
    WinGet
    Internet connectivity
  Testing     : Manual functional and acceptance testing of this script was performed using PowerShell 5.1.19041 and 7.3.3 on Windows 10.

.COMPONENT 
  Microsoft.PowerShell.Management

.COMPONENT
  Microsoft.PowerShell.Utility

.COMPONENT 
  Winget.exe (included in Windows 10/11)

.LINK 
  Source code : https://github.com/x0techdad/cloud-platform-starter-kit/blob/main/scripts/setup-winSbx.ps1
#>


[CmdletBinding()]

# parameters

param (

  [parameter( 
    mandatory, 
    helpMessage = "Email address associated with git commits, global setting." 
  )] 
  [validatescript( 
    { resolve-dnsName -name $_.host -Type 'mx' },
    errorMessage = "Email address is not valid."  
  )]
  [mailaddress]
  $gitEmail,

  [parameter(
    mandatory, 
    helpMessage = "Name associated with git commits, global setting." 
  )] 
  [string]
  $gitName,

  [parameter(
    mandatory, 
    helpMessage = "Environment type, valid arguments are 'cloud' or 'pwsh'." 
  )]
  [validateSet("cloud", "pwsh", ignoreCase, errorMessage = "
    Specify 'cloud' or 'pwsh'.")]
  #[validatePattern("/^pwsh|cloud$/gmi")] 
  [string]
  $type = "cloud",

  [parameter( 
    mandatory, 
    helpMessage = "Path to a tools manifest file in JSON, view project README for expected schema." 
  )] 
  [validatescript( 
    { test-path $_ },
    errorMessage = "Specified file path is invalid."  
  )]
  [string]
  $toolManifestPath,

  [parameter( 
    mandatory, 
    helpMessage = "Path to a temmplate PowerShell profile (.ps1)." 
  )] 
  [validatescript( 
    { test-path $_ },
    errorMessage = "Specified file path is invalid."  
  )]
  [string]
  $pwshProfileTemplatePath

)

# variables

<#
$winGetPackages                 = @{

  'microsoft.visualstudiocode'  = '1.76.0'
  #'git.git'                     = '2.39.2'
  'microsoft.powershell'        = '7.3.3.0'
  #'microsoft.azurecli'          = '2.47.0'
  #'amazon.awscli'               = '2.11.9'
  #'google.cloudsdk'             = '424.0.0'
  #'hashicorp.terraform'         = '1.4.4'
  #'terraformlinters.tflint'     = '0.45.0'

}
#>

$fileRegistryPath         = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
$wingGetLogPath           = "$env:USERPROFILE\AppData\Local\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\DiagOutputDir"
$wingetErrorRgx           = '^.*Terminating\scontext:\s(0x\S*).*$'
$wingetMsiErrorRgx        = '^.*Installation\sfailed.$'

$toolManifestJson = get-content -path $toolManifestPath -Raw | convertFrom-json | where-object platform -match $type

# update system environment PATH variable function

function update-envPath {

  $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") `
  + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

}

# set windows explorer settings function

function update-explorerConfig {

  push-location
  set-location $fileRegistryPath
  write-output "Enabling the ability to view hidden files in Explorer."
  set-itemProperty . hidden "1"
  write-output "Enabling the ability to view file extensions in Explorer."
  set-itemProperty . hideFileExt "0"
  pop-location
  stop-process -name explorer -force

}

# confirm windows package manager is installed function

function confirm-winget {

  write-output "Confirming Winget is installed and functional..."

  try {

    $out = & winget list --disable-interactivity --verbose-logs
    
    $latestLog = get-childItem -path $wingGetLogPath -filter *.log | sort-object creationTimeUtc -descending | `
    select-object -first 1
    
    $wingetError = select-string -pattern $wingetErrorRgx -path $latestLog.pspath

    if ( $wingetError ) {
        
        write-error "Error occurred when validating Winget installation: $out." -errorAction stop
    
    } else {
        
        write-output "Winget is installed and functional!"
    
    }

  } catch [System.Management.Automation.CommandNotFoundException] {

    throw "Winget is not found, please install then re-run script $PSItem."
      
  } catch {

    throw "$PSItem"
  
  }

}

# invoke the installation of packages defined in hash table function

function install-winGetApp {

  write-output "Installing apps..."
  confirm-winget

  foreach ( $app in $winGetPackages.keys) {
      
    write-output "Installing $app version $($winGetPackages[$app]) via Winget."
    install-package -packageID $app -version $winGetPackages[$app]
    start-sleep -Seconds 2
  
  }

}

# install Winget package function

function install-package ( $packageId, $version ){

  try { 
      
    $out = & winget list --id $packageId --disable-interactivity --verbose-logs
      
    if ( $out -match "No installed package" ) {
        
      winget install --id $packageId --version $version --disable-interactivity --verbose-logs | `
      tee-object -variable out
        
      update-envPath
      
      } elseif ( $out -match $version ) { 
        
        write-output "$packageId version $version is already installed!"
      
      } else {

        if ( $upgradePackages ) {
        
          winget upgrade --id $packageId --disable-interactivity --verbose-logs | `
          tee-object -Variable out
        
          update-envPath

        } else {

          write-warning "$packageId $version is already installed. A new version is available, update the package hashtable `$winGetPackages and re-run script."
          ##TODO: add -upgrade switch to allow for dynamic package upgrades. 
          
        }
      
      }
    
    $latestLog = get-childItem -path $wingGetLogPath -filter *.log | sort-object creationTimeUtc -descending | `
    select-object -First 1
    
    $wingetError = select-string -pattern $wingetErrorRgx, $wingetMsiErrorRgx `
    -path $latestLog.pspath

    if ( $wingetError ) {
        
      write-error "Error occured when installing $packageId version $version : $out." -errorAction stop
    
    }

  } catch {
      
    throw "$PSItem"
  
  }

}

# create posh profile from template function

function new-pwshProfile ( $templatePath ){

  write-output "Creating new posh profile for the local user..."

  try {
      
    new-item -itemType file -path $profile -force | out-null
    get-content -path $templatePath | set-content $profile -force
  
  } catch {
      
    throw "$PSItem" 
  
  }

  write-output "Successfully created posh profile. Restart posh or invoke the command: `. `$profile' to load the  new profile in this current session."

}

# install and apply git global configs function

function install-git {

  write-output "Setting up Git..."

  try {

    install-package -packageID git.git -version $winGetPackages['git.git']

    write-output "Applying specified Git configs..."

    git config --global core.editor "code --wait"
    git config --global init.defaultBranch main
    git config --global user.name $gitName
    git config --global user.email $gitEmail

    git config --global alias.pom 'pull origin main'
    git config --global alias.last 'log -1 HEAD'
    git config --global alias.ls "log --pretty=format:'%C(yellow)%h %ad%Cred%d %Creset%s%Cblue [%cn]' --decorate --date=short --graph"
    git config --global alias.standup "log --since yesterday --author $(git config user.email) --pretty=short"
    git config --global alias.ammend "commit -a --amend"
    git config --global alias.everything "! git pull && git submodule update --init --recursive"
    git config --global alias.aliases "config --get-regexp alias"

  } catch {
      
      throw "$PSItem" 
  
  }

  write-output "Successfully setup Git."

}

# new cloud dev environment function

function new-cloudDevEnv {

  write-output "Creating a cloud dev environmnet..."

  try {

    write-warning "You are creating a cloud dev environment on Windows OS, there are larger cloud engineering communities and more tooling supports Linux. "
    write-output "Enabling Windows Subsytem for Linux.."

    $wslDistro   = get-content -path $toolManifestPath -Raw | convertFrom-json | where-object platform -match "wsl" 
    $wslDistroId = [string]::concat($wslDistro.name, '-', $wslDistro.version)

    $out = & wsl --install -d $wslDistroId 2>&1 

    if ( $out -match "Successfully*" ) {
    } else {
      write-error "Error occured when enabling WSL and deploying $wslDistroId : $out." -errorAction stop
    }
    
  } catch {
    
    throw "$PSItem"
  
  }

  write-output "Successfully created cloud dev environment."

}

# new posh dev environment function

function new-poshDevEnv {
  
  write-output "Creating a Pwsh dev environmnet..."

  try {

  } catch {
    
    throw "$PSItem"
  
  }

  write-output "Successfully created Pwsh dev environment."

}

# start script

update-explorerConfig

new-pwshProfile -templatePath $pwshProfileTemplatePath

switch ( $type ) {

  cloud { new-cloudDevEnv  }
  posh  { new-poshDevEnv   }

}

# end script