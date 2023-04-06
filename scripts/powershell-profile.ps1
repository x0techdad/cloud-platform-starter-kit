<# 
.SYNOPSIS
    PowerShell profile template

.DESCRIPTION 
    PowerShell profiles are loaded on every session started and customize the shell environment.
    To use this profile, copy the contents into the profile path ($PROFILE).
 
.NOTES 
    Name:   powershell-profile.ps1
    Author: @x0techdad (GitHub)
    Requires: PowerShell (5 or 7)
    Testing: Manual functional and acceptance testing of this profile was perfmored using PowerShell 5.1.19041/7.3.3 on Windows 10.

.COMPONENT 
    Microsoft.PowerShell.Management

.COMPONENT
    Microsoft.PowerShell.Utility

.LINK 
    Source code: https://github.com/common-cloud/platform-dev-ux
#>

function get-cmdletAlias ( $cmdletName ) {
  
  get-alias | `
  where-object -filterScript { $_.definition -like "$cmdletName" } | `
  format-table -Property definition, name -autoSize

}

# test if user is admin

function test-adminContext {
    
    $user = [security.principal.windowsIdentity]::getCurrent();
    (new-object security.principal.windowsPrincipal $user).isInRole([security.principal.windowsBuiltinRole]::administrator)

}

# edit path string

function edit-path ([string] $path) {

   $out = $path.replace($home, '~')
   $out = $path -replace '^[^:]+::', ''
   return ($out -replace '\\(\.?)([^\\])[^\\]*(?=\\)','\$1$2')

}


# customize console prompt

function prompt {

   $colorHost = [ConsoleColor]::magenta
   $colorUser = [ConsoleColor]::yellow
   $colorBraces = [ConsoleColor]::darkCyan
   $colorPath = [ConsoleColor]::cyan

   $lineChar = $([char]0x0A7)
   $path = edit-path (get-location).path
   
   write-host "$lineChar " -n -f $colorPath
   write-host  "$env:username@" -n -f $colorUser
   write-host  "$env:computername" -n -f $colorHost
   write-host ' {' -n -f $colorBraces
   write-host $path -n -f $colorPath
   write-host '}' -n -f $colorBraces
   if (test-adminContext) {
       write-host "(ELEVATED)" -n -f red
   }
   write-host '>' -n -f $colorBraces
   return ' '

}


# start script
## set console window title

$hostVersion = "$($host.version.major)`.$($host.version.minor)`.$($host.version.build)"
$host.ui.rawUi.windowTitle = "PowerShell $hostVersion"