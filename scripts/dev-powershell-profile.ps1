# Get aliases for any command
function get-cmdletAlias ($cmdletName) {
  get-alias |
    where-object -filterScript {$_.definition -like "$cmdletName"} |
      format-table -Property definition, name -autoSize
}


function test-admin {
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    (new-object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}


function edit-path ([string] $path) {
   $loc = $path.replace($home, '~')
   $loc = $loc -replace '^[^:]+::', ''
   return ($loc -replace '\\(\.?)([^\\])[^\\]*(?=\\)','\$1$2')
}


# Customize console prompt
function prompt {
   $colorhost = [ConsoleColor]::magenta
   $coloruser = [ConsoleColor]::yellow
   $colorbraces = [ConsoleColor]::darkCyan
   $colorlocation = [ConsoleColor]::cyan

   $char = $([char]0x0A7)
   $loc = edit-path (get-location).path
   
   write-host "$char " -n -f $colorlocation
   write-host  "$env:username@" -n -f $coloruser
   write-host  "$env:computername" -n -f $colorhost
   write-host ' {' -n -f $colorbraces
   write-host $loc -n -f $colorlocation
   write-host '}' -n -f $colorbraces
   if (test-admin) {
       write-host "(ELEVATED)" -n -f red
   }
   write-host '>' -n -f $colorbraces
   return ' '
}

# Set console window title
$hostVersion = "$($host.Version.Major)`.$($host.Version.Minor)`.$($host.Version.Build)"
$host.UI.RawUI.WindowTitle = "PowerShell $hostVersion"