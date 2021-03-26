# テストプログラム

Import-Module $PSScriptRoot\wlx202 -Verbose -Force

$ap = "wlx202"
$pw = "01234567890"

if( -not (Confirm-WLX202Auth -host $ap -password $pw -Verbose )){
    "Authentication was not successful. Check if host and password are valid."
    break
}

$config = (Backup-WLX202Config -host $ap -password $pw -saveAs "$PSScriptRoot\config.txt" ) 
$config
#    | Restore-WLX202Config -host $ap -password $pw




