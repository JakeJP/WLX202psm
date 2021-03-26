# PowerShell モジュール for YAMAHA WLX202 Wi-Fi アクセスポイント

アクセスポイント単体ではSHELLなどからオートメーションな設定などができません。
WebGUIをハッキングすることで、スクリプトから設定ファイルのダウンロード、アップロードを行うためのライブラリです。

## 互換性

YAMAHA WLX202 Rev.16.00.18

※ファームウェアのリビジョンでWebGUIの構造が変わることがあります。このスクリプトは現在の最新のリビジョンで確認しています。

## 使い方

```PowerShell
Import-Module $PSScriptRoot\wlx202 -Verbose -Force

$ap = "wlx202" # アクセスポイントへのホスト名またはIPアドレス
$pw = "1234567890" # アクセスポイント admin のパスワード

if( -not ($res = (Confirm-WLX202Auth -host $ap -password $pw -Verbose ))){
    "Authentication was not successful. Check if password is valid."
    break
}

# 設定ファイルをダウンロード

$config = (Backup-WLX202Config -host $ap -password $pw -saveAs "$PSScriptRoot\config.txt" )

# 設定ファイルをアップロード

$config | Restore-WLX202Config -host $ap -password $pw

```

## メソッド

### Confirm-WLX202Auth

WebGUI への操作を開始するために必ず最初に呼び出す必要があります。ログインの試行。

| パラメーター名 | 内容 | オプション |
|---------------|------|------------|
| -host | APのホスト名 | 必須 
| -password | admin ログインのパスワード | 必須
| 戻り値 | 成功すると $true エラーの場合 $false |  |

#### 例

```PowerShell
if( -not ($res = (Confirm-WLX202Auth -host $ap -password $pw -Verbose ))){
    "Authentication was not successful. Check if password is valid."
    break
}
```

### Backup-WLX202Config

設定ファイルを取得します。ファイルとして保存するか、戻り値から文字列として取得します。

| パラメーター名 | 内容 | オプション |
|---------------|------|------------|
| -host | APのホスト名 | 必須 
| -password | admin ログインのパスワード | 必須
| -saveAs | 保存ファイル名 | オプション
| 戻り値 | config ファイルの内容を文字列 エラーの場合 $null |  |



#### 例

```PowerShell
$config = Backup-WLX202Config -host $ap -password $pw -saveAs "$PSScriptRoot\config.txt"
```

### Restore-WLX202Config

設定ファイルをアクセスポイントへアップロードします。

| パラメーター名 | 内容 | オプション |
|---------------|------|------------|
| -host | APのホスト名 | 必須 
| -password | admin ログインのパスワード | 必須
| 戻り値 | Invoke-WebRequest のレスポンス | |

#### 例

```PowerShell
$config | Restore-WLX202Config -host $ap -password $pw
```

## ライセンス

パブリックドメイン


