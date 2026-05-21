# PowerShell モジュール for YAMAHA WLX202 Wi-Fi アクセスポイント

アクセスポイント単体ではSHELLなどからオートメーションな設定などができません。
WebGUIをハッキングすることで、スクリプトから設定ファイルのダウンロード、アップロードを行うためのライブラリです。

## 互換性

YAMAHA WLX202 Rev.16.00.19

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

# 接続確認（任意）
# Confirm-WLX202Auth は疎通確認用途です。
# Backup/Restore はそれぞれ単独でも認証付きで実行できます。

# 設定ファイルをダウンロード

$config = (Backup-WLX202Config -host $ap -password $pw -saveAs "$PSScriptRoot\config.txt" )

# 設定ファイルをアップロード

$config | Restore-WLX202Config -host $ap -password $pw

```

## メソッド

### Confirm-WLX202Auth

WebGUI への認証/疎通を確認するためのメソッドです（任意）。

| パラメーター名 | 内容 | オプション |
|---------------|------|------------|
| -host | APのホスト名 | 必須 
| -user | ログインユーザー名（既定値: admin） | オプション
| -password | admin ログインのパスワード | 必須
| -response | 参照渡しレスポンス（現在未使用） | オプション
| 戻り値 | 成功時は WebResponseObject、失敗時は $null |  |

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
| -user | ログインユーザー名（既定値: admin） | オプション
| -password | admin ログインのパスワード | 必須
| -saveAs | 保存ファイル名 | オプション
| 戻り値 | 成功時は config ファイルの内容（文字列） |  |



#### 例

```PowerShell
$config = Backup-WLX202Config -host $ap -password $pw -saveAs "$PSScriptRoot\config.txt"
```

### Restore-WLX202Config

設定ファイルをアクセスポイントへアップロードします。

| パラメーター名 | 内容 | オプション |
|---------------|------|------------|
| -config | アップロードする設定内容（パイプライン入力可） | 必須
| -host | APのホスト名 | 必須 
| -user | ログインユーザー名（既定値: admin） | オプション
| -password | admin ログインのパスワード | 必須
| -pass | -password のエイリアス | オプション
| 戻り値 | 成功時は Invoke-WebRequest のレスポンス。入力不正時はエラー出力して終了 | |

#### 例

```PowerShell
$config | Restore-WLX202Config -host $ap -password $pw
```

## ライセンス

パブリックドメイン


