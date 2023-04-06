# Setup-winDevEnv.ps1

Installs and configures commonly used cloud platform engineering/dev tools and OS settings on a local Windows system. 

---

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

### Identity and access

* 3rd-party app installs may require local admin privilege, you will be prompted for credentials during environment build.

## Testing

Manual functional and acceptance testing of this script was perfmored using PowerShell 5.1.19041 and 7.3.3 on Windows 10.

## Build:
* Download or clone this source code repo
* Run in Local PowerShell CLI:
  * Navigate to: `.\cloud-platform-dev-ux\scripts\`
  * Invoke script: `.\setup-winDevEnv.ps1`
* Run in Docker: TODO