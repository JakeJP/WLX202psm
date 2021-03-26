#
# PowerShell module for WebGUI access YAMAHA WLX202
# 
# Last update: 2021-3-26
# created by Jake.Y.Yoshimura
#    https://github.com/JakeJP

$backupConfig = 'backup.cgi'
$manageConfig = 'manage-config.html'
$restoreConfig = 'restore.cgi?manage-config.html'

#
function CreateAuthHeader ( [string] $user = "admin", [Parameter(Mandatory)][string]$password ){
    $Headers = @{
        Authorization = "Basic $([System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("$($user):$($password)")))"
    }
    return $Headers
}

function Confirm-WLX202Auth {
    [CmdletBinding()]
    param( 
        [Parameter(Mandatory=$true)][Alias("host")] [string] $remoteHost,
        [string] $user = 'admin',
        [Parameter(Mandatory=$true)] [string] $password,
        [ref] $response
    )
    $attempt = 6
    do {
        try {
            $res = Invoke-WebRequest -Uri "http://$remoteHost/"  -Headers (CreateAuthHeader -password $password) -ErrorAction SilentlyContinue
        } catch {
            $res = $_.Exception.Response
        }
        if ( $res.StatusCode -eq 200 ){
            break
        } elseif( $res.StatusCode -eq 401 ){
            Write-Verbose "Retrying connection attemp in 5 seconds..."
            Start-Sleep 5
        } else {
            break
        }
        $attempt--
    } while( $attempt -gt 0 )
    if ($res.StatusCode -ne 200) { $res = $null }
    return $res
}

function Backup-WLX202Config {
    param( 
        [Parameter(Mandatory=$true)][Alias("host")] [string] $remoteHost,
        [string] $user = 'admin',
        [Parameter(Mandatory=$true)] [string] $password,
        [string] $saveAs = $null
    )

    $Headers = CreateAuthHeader -Password $password
    $fields = (Invoke-WebRequest -Uri ("http://$remoteHost/$manageConfig") -Headers $Headers).Forms["form_main"].Fields
    $fields['submit_flag'] = ""
    $config = $null
    $config = [System.Text.Encoding]::UTF8.GetString( (Invoke-WebRequest -Uri "http://$remoteHost/$backupConfig" -Headers $Headers -Method Post -Body $fields -UseBasicParsing ).Content )
    if ( $config -and $saveAs ){
        $config | Out-File -FilePath $saveAs -Encoding utf8
    }
    return $config
}

function Restore-WLX202Config {
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline)] [string] $config,
        [Parameter(Mandatory=$true)][Alias("host")] [string] $remoteHost,
        [string] $user = 'admin',
        [Parameter(Mandatory=$true)][Alias("pass")] [string] $password 
    )

    if( -not $config ){
        Write-Error "Skipping process due to empty $config."
        return
    }
    if( -not ( $config -match "^#\s+WLX202\s+Rev") ){
        Write-Error "config file header does not seem valid."
        return
    }
    ## LOAD manage-config.html
    $fields = (Invoke-WebRequest -Uri ("http://$remoteHost/$manageConfig") -Headers $Headers).Forms["form_main"].Fields
    if( -not $fields["time_stamp"] ){
        return 
    }
    $timestamp = $fields["time_stamp"]

    ## UPLOAD CONTENT
    $LF = "`n"
    $boundary = "---------------------------" + [System.Guid]::NewGuid().ToString().Replace("-","").SubString(0,13)
    $bodyLines = (
        "--$boundary",
        "Content-Disposition: form-data; name=`"uploadfile`"; filename=`"config.txt`"",   # filename= is optional
        "Content-Type: text/plain$LF",
        $config,
        "--$boundary",
        "Content-Disposition: form-data; name=`"submit_flag`"$LF",
        "",
        "--$boundary",
        "Content-Disposition: form-data; name=`"time_stamp`"$LF",
        $timestamp,
        "--$boundary--$LF"
        ) -join $LF
    #$bodyLines

    ## RESTORE.CGI
    $Headers = CreateAuthHeader -Password $password
    $Byte = [System.Text.Encoding]::UTF8.GetBytes($bodyLines)
    $res = Invoke-WebRequest -Uri "http://$remoteHost/$restoreConfig timestamp=$timestamp" -Method Post -ContentType "multipart/form-data; boundary=`"$boundary`"" -Body $Byte -ErrorAction Stop
    #$res.StatusCode
    #$res.StatusDescription
    return $res
}

Export-ModuleMember Confirm-WLX202Auth
Export-ModuleMember Backup-WLX202Config
Export-ModuleMember Restore-WLX202Config