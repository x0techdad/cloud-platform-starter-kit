# Local Windows dev environment setup script

[CmdletBinding()]

$gitEmail = "archsamur@gmail.com"
$gitName = "x0techdad"

$winGetPackages = @{
    'Microsoft.VisualStudioCode' = '1.76.0'
    'Git.Git' = '2.39.2'
    'Microsoft.PowerShell' = '7.3.3.0'
}
$vsCodeExtensions = @{
    'ms-vscode.powershell' = '2023.2.1'
    'hashicorp.terraform' = '2.25.4'
}

$sourceProfilePath = ".\dev-powershell-profile.ps1"
$psV7PofilePath = "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
$fileRegistryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"




#Refresh system enviornment PATH variable
function update-envPath
{
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") `
        + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

# Install package with Winget function
function install-wingetPackage ( $packageID, $version ){
    $out = & winget list --id $packageID
    if ( $out -match "No installed package" ) {
        winget install --id $packageID --version $version
        Refresh-EnvPath
    } elseif ( $out -match $version ) { 
        write-host "$packageID $ps7Version already installed."
    } else {
        winget upgrade --id $packageID --version $version
    }
}

# Create PS profile function
function new-PSProfile ( $destinationPath, $sourcePath ){
    new-item -itemType file -path $destinationPath -force
    get-content -path $sourcePath | set-content $destinationPath -force
}




# Show file extensions and hidden files
push-location
set-location $fileRegistryPath
set-itemProperty . HideFileExt "0"
set-itemProperty . Hidden "1"
pop-location
stop-process -processName: explorer -force



# Install apps using Winget
foreach($app in $winGetPackages.keys)
{
    write-host "Install $app version $($winGetPackages[$app])"
    install-wingetPackage -packageID $app -version $winGetPackages[$app]
}

#Install VS Code extensions
foreach($extension in $vsCodeExtensions.keys)
{
    write-host "install $extension version $($vsCodeExtensions[$extension])"
    code --install-extension $extension@$($vsCodeExtensions[$extension])
}



# Create and import PowerShell profiles
#PSv5
new-PSProfile -destinationPath $PROFILE -sourcePath $sourceProfilePath
#PSv7
new-PSProfile -destinationPath $psV7PofilePath -sourcePath $sourceProfilePath



#Git global config
git config --global core.editor "code --wait"
git config --global init.defaultBranch main
git config --global user.name $gitName
git config --global user.email $gitEmail

#Git global aliases
git config --global alias.pom 'pull origin main'
git config --global alias.last 'log -1 HEAD'
git config --global alias.ls "log --pretty=format:'%C(yellow)%h %ad%Cred%d %Creset%s%Cblue [%cn]' --decorate --date=short --graph"
git config --global alias.standup "log --since yesterday --author $(git config user.email) --pretty=short"
git config --global alias.ammend "commit -a --amend"
git config --global alias.everything "! git pull && git submodule update --init --recursive"
git config --global alias.aliases "config --get-regexp alias"