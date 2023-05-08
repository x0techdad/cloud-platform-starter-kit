# Setup-winDevEnv.ps1

This script sets up a Public Cloud or PowerShell (Pwsh) dev environment on Windows OS, installs commonly used dev tools, applies recommended environment settings and clones a specified git code repository.

## Tools installed:

    'microsoft.visualstudiocode'  = '1.76.0'
    'git.git'                     = '2.39.2'
    'microsoft.powershell'        = '7.3.3.0'
    'microsoft.azurecli'          = '2.47.0'
    'amazon.awscli'               = '2.11.9'
    'google.cloudsdk'             = '424.0.0'
    'hashicorp.terraform'         = '1.4.4'
    'terraformlinters.tflint'     = '0.45.0'

> **To Do:** automatically update above list when the script package hashtable $winGetPackages is updated. 

## Requirements

### Software

* [PowerShell](https://learn.microsoft.com/en-us/powershell/)
* [Windows package manager (Winget)](https://learn.microsoft.com/en-us/windows/package-manager/)
* Internet connectivity

### Access

* 3rd-party app installs may require local admin privileges, you will be prompted for credentials during environment build.

## Testing

Manual functional and acceptance testing of this script was performed using PowerShell 5.1.19041 and 7.3.3 on Windows 10.

## Invoke script
* Download zip archive `setup-winDevEnv.ps1.zip` from the latest [project release](https://github.com/x0techdad/cloud-platform-starter-kit/releases)
* Run in local PowerShell CLI:
  * Uncompress zip archive
  * Navigate to: `.\cloud-platform-starter-kit\scripts\`
  * Invoke script: `.\setup-winDevEnv.ps1 -gitEmail [email] -gitName [git display name] -type cloud`
* Run in Docker: TODO