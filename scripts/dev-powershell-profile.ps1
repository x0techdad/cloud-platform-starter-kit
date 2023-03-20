# Get aliases for any command
function Get-CmdletAlias ($cmdletname) {
  Get-Alias |
    Where-Object -FilterScript {$_.Definition -like "$cmdletname"} |
      Format-Table -Property Definition, Name -AutoSize
}


function test-admin {
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}


function shorten-path([string] $path) {
   $loc = $path.replace($home, '~')
   $loc = $loc -replace '^[^:]+::', ''
   return ($loc -replace '\\(\.?)([^\\])[^\\]*(?=\\)','\$1$2')
}


# Customize console prompt
function prompt {
   $colorhost = [ConsoleColor]::Magenta
   $coloruser = [ConsoleColor]::Yellow
   $colorbraces = [ConsoleColor]::DarkCyan
   $colorlocation = [ConsoleColor]::Cyan

   $char = $([char]0x0A7)
   $loc = shorten-path (pwd).path
   
   write-host "$char " -n -f $colorlocation
   write-host  "$env:username@" -n -f $coloruser
   write-host  "$env:computername" -n -f $colorhost
   write-host ' {' -n -f $colorbraces
   write-host $loc -n -f $colorlocation
   write-host '}' -n -f $colorbraces
   if (test-admin) {
       write-host "(ELEVATED)" -n -f Red
   }
   write-host '>' -n -f $colorbraces
   return ' '
}

# Set console window title
$hostversion = "$($Host.Version.Major)`.$($Host.Version.Minor)`.$($Host.Version.Build)"
$Host.UI.RawUI.WindowTitle = "PowerShell $hostversion"