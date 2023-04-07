<# 
.SYNOPSIS
  Setup local Windows dev environment.

.DESCRIPTION 
  Installs and configures commonly used cloud dev tools and OS settings on a local Windows system. 

.NOTES 
  Name:   setup-winDevEnv.ps1
  Author: @x0techdad (GitHub)
  Requires:
    PowerShell (5 or 7)
    WinGet
    Internet connectivity
  Testing: Manual functional and acceptance testing of this script was performed using PowerShell 5.1.19041 and 7.3.3 on Windows 10.

.COMPONENT 
  Microsoft.PowerShell.Management

.COMPONENT
  Microsoft.PowerShell.Utility

.COMPONENT 
  Winget.exe (included in Windows 10/11)

.LINK 
  Source code: https://github.com/x0techdad/cloud-platform-dev-ux/blob/main/scripts/setup-winDevEnv.ps1
#>


[CmdletBinding()]

# parameters

param (
    
    [parameter( mandatory )]
    [validatescript( { resolve-dnsName -name $_.host -Type 'mx' } )]
    [mailaddress]
    $gitEmail,

    [parameter( mandatory )]
    [string]
    $gitName

)

# variables

$winGetPackages = @{
  'microsoft.visualstudiocode'  = '1.76.0'
  'git.git'                     = '2.39.2'
  'microsoft.powershell'        = '7.3.3.0'
  'microsoft.azurecli'          = '2.47.0'
  'amazon.awscli'               = '2.11.9'
  'google.cloudsdk'             = '424.0.0'
  'hashicorp.terraform'         = '1.4.4'
  'terraformlinters.tflint'     = '0.45.0'
}

$sourceProfilePath = ".\powershell-profile.ps1"
$fileRegistryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
$wingGetLogPath = "$env:USERPROFILE\AppData\Local\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\DiagOutputDir"
$wingetErrorRgx = '^.*Terminating\scontext:\s(0x\S*).*$'
$wingetMsiErrorRgx = '^.*Installation\sfailed.$'


# functions

## update system environment PATH variable

function update-envPath
{
  $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") `
  + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

## show folders and files with "hidden" attribute in windows Explorer

function update-explorerConfig {
    
  push-location
  set-location $fileRegistryPath
  write-output "Enabling the ability to view hidden files in Explorer"
  set-itemProperty . hidden "1"
  write-output "Enabling the ability to view file extensions in Explorer"
  set-itemProperty . hideFileExt "0"
  pop-location
  stop-process -name explorer -force

}

## confirms package manager is installed and functional

function confirm-winget {
    
  write-output "Confirming Winget is installed and functional..."

  try {

    $out = & winget list --disable-interactivity --verbose-logs
    
    $latestLog = get-childItem -path $wingGetLogPath -filter *.log | sort-object creationTimeUtc -descending | `
    select-object -first 1
    
    $wingetError = select-string -pattern $wingetErrorRgx -path $latestLog.pspath

    if ( $wingetError ) {
        
        write-error "Error occurred when validating Winget installation: $out" -errorAction stop
    
    } else {
        
        write-output "Winget is installed and functional"
    
    }

  } catch [System.Management.Automation.CommandNotFoundException] {

    throw "Winget is not found, please install then re-run script. $PSItem"
      
  } catch {

    throw "$PSItem"
  
  }

}

## iterate through package hashtable and install listed packages

function install-packages {

  write-output "Installing packages..."
  
  confirm-winget

  foreach ( $app in $winGetPackages.keys) {
      
    write-output "Installing $app version $($winGetPackages[$app]) via Winget"

    install-package -packageID $app -version $winGetPackages[$app]
    
    start-sleep -Seconds 2
  
  }

}

## install or update specified Winget package

function install-package ( $packageId, $version ){

  try { 
      
    $out = & winget list --id $packageId --disable-interactivity --verbose-logs
      
    if ( $out -match "No installed package" ) {
        
      winget install --id $packageId --version $version --disable-interactivity --verbose-logs | `
      tee-object -variable out
        
      update-envPath
      
      } elseif ( $out -match $version ) { 
        
        write-output "$packageId version $version is already installed"
      
      } else {

        if ( $upgradePackages ) {
        
          winget upgrade --id $packageId --disable-interactivity --verbose-logs | `
          tee-object -Variable out
        
          update-envPath

        } else {

          write-warning "$packageId $version is already installed. A new version is available, update the package hashtable `$winGetPackages and re-run script."
          ## TODO: add -upgrade switch to allow for dynamic package upgrades. 
          
        }
      
      }
    
    $latestLog = get-childItem -path $wingGetLogPath -filter *.log | sort-object creationTimeUtc -descending | `
    select-object -First 1
    
    $wingetError = select-string -pattern $wingetErrorRgx, $wingetMsiErrorRgx `
    -path $latestLog.pspath

    if ( $wingetError ) {
        
      write-error "Error occured when installing $packageId version $version : $out" -errorAction stop
    
    }

  } catch {
      
    throw "$PSItem"
  
  }

}

## create posh profiles from template file

function import-psProfile ( $sourcePath ){

  write-output "Importing posh profile..."

  try {
      
    new-item -itemType file -path $profile -force | out-null
    
    get-content -path $sourcePath | set-content $profile -force
      
    . $profile
  
  } catch {
      
    throw "$PSItem" 
  
  }

  write-output "Successfully imported profile, run '. `$profile' to reload profile in current session"

}

## install and configure git

function install-git {

  write-output "Setting up Git..."

  try {

    ### install git

    install-package -packageID git.git -version $winGetPackages['git.git']
  
    ### apply git configs

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

  write-output "Successfully setup Git"

}


# start script

## show file extensions and hidden files in Explorer

update-explorerConfig


## install app packages

install-packages


## import posh profile

import-psProfile -sourcePath $sourceProfilePath

## install and configure git

install-git

# end script

write-output "Successfully setup Windows dev environment!"
