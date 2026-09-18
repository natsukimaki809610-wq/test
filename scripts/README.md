# LINEスタンプ 一括リサイズ

`1`〜`40` 番の画像を、LINEスタンプの上限サイズ **370×320** に一括変換します。

- 縦横比はそのまま保持（絵が歪みません）
- 370×320 に収まるまで縮小し、余った部分は**透明**で埋めて、ちょうど 370×320 の PNG にします
- 元のファイルは変更しません。出力先フォルダに新しく作られます

## 使い方（Windows / PowerShell）

追加インストールは不要です。

1. `resize-line-stamps.ps1` を画像の入ったフォルダに置く
2. そのフォルダで右クリック →「ターミナルで開く」（または PowerShell を開く）
3. 次を実行:

```powershell
powershell -ExecutionPolicy Bypass -File .\resize-line-stamps.ps1
```

変換結果は同じフォルダ内の `resized` フォルダに `01.png` 〜 `40.png` として出力されます。

フォルダを指定して実行する場合:

```powershell
powershell -ExecutionPolicy Bypass -File .\resize-line-stamps.ps1 -SourceDir "C:\Users\user\ChatGPT\99_その他\LINE\看護師40"
```

## 使い方（Python）

```bash
pip install Pillow
python resize_line_stamps.py --source "C:\Users\user\ChatGPT\99_その他\LINE\看護師40"
```

## オプション

| PowerShell | Python | 説明 |
| --- | --- | --- |
| `-SourceDir <path>` | `--source <path>` | 変換元フォルダ（既定: カレント） |
| `-OutputDir <path>` | `--output <path>` | 出力先フォルダ（既定: `変換元/resized`） |
| `-Width` / `-Height` | `--width` / `--height` | 出力サイズ（既定: 370 / 320） |
| `-From` / `-To` | `--from` / `--to` | 処理する番号の範囲（既定: 1〜40） |
| `-NoUpscale` | `--no-upscale` | 元画像が370×320より小さいとき拡大しない |

## 対応ファイル名

番号ごとに、次の名前を順に探します（最初に見つかったもの1つを使用）。

`1.png` / `01.png` / `001.png` — 拡張子は `.png` `.jpg` `.jpeg` `.webp` `.bmp`

見つからない番号はスキップされ、最後にまとめて表示されます。

## LINEスタンプの申請要件（参考）

| 種類 | サイズ | 枚数 |
| --- | --- | --- |
| スタンプ画像 | 最大 370×320 px | 8, 16, 24, 32, 40 のいずれか |
| メイン画像 | 240×240 px | 1 |
| トークルームタブ画像 | 96×74 px | 1 |

- 形式: PNG（背景は透過）
- 1ファイルあたり 1MB 以下
- 余白は上下左右に10px程度空けることが推奨されています

メイン画像・タブ画像も必要な場合は、同じスクリプトでサイズを指定して作れます:

```powershell
# メイン画像 (No.1 を使う場合)
powershell -ExecutionPolicy Bypass -File .\resize-line-stamps.ps1 -Width 240 -Height 240 -From 1 -To 1 -OutputDir .\main

# タブ画像
powershell -ExecutionPolicy Bypass -File .\resize-line-stamps.ps1 -Width 96 -Height 74 -From 1 -To 1 -OutputDir .\tab
```
