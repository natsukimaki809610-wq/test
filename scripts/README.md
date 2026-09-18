# LINEスタンプ 一括リサイズ

`1`〜`40` 番の画像を、LINEスタンプの上限サイズ **370×320** に一括変換します。

- 縦横比はそのまま保持（絵が歪みません）
- 370×320 に収まるまで縮小し、余った部分は**透明**で埋めて、ちょうど 370×320 の PNG にします
- 元のファイルは変更しません。出力先フォルダに新しく作られます

## 使い方（Windows / いちばん簡単）

追加インストールは不要です。コマンド入力もいりません。

1. `resize.bat` `main-tab.bat` `resize-line-stamps.ps1` を画像の入ったフォルダに置く
2. **`resize.bat`** をダブルクリック → スタンプ40枚（370×320）ができる
3. **`main-tab.bat`** をダブルクリック → メイン用・タブ用の番号を順に聞かれるので入力
   （別々の絵を指定できます。タブ用をそのままEnterするとメインと同じ絵になります）

どちらも出力先は同じ `resized` フォルダです。黒い画面が開いて処理が進み、
終わったら何かキーを押して閉じます。

`resized` フォルダの中身がそのまま申請用の一式になります。

```
resized/
  01.png 〜 40.png   スタンプ    370x320
  main.png           メイン画像  240x240
  tab.png            タブ画像    96x74
```

## 使い方（PowerShell から直接）

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
| `-OutputName <名前>` | `--output-name <名前>` | 出力ファイル名を指定（1枚だけ変換するとき用） |
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

メイン画像・タブ画像は `main-tab.bat` をダブルクリックすれば作れます。
コマンドで直接指定する場合は次の通りです（No.1 の絵を使う例）:

```powershell
# メイン画像 -> resized\main.png
powershell -ExecutionPolicy Bypass -File .\resize-line-stamps.ps1 -Width 240 -Height 240 -From 1 -To 1 -OutputName main

# タブ画像 -> resized\tab.png
powershell -ExecutionPolicy Bypass -File .\resize-line-stamps.ps1 -Width 96 -Height 74 -From 1 -To 1 -OutputName tab
```

## 文字コードについて（開発者向けメモ）

`resize-line-stamps.ps1` は **BOM付き UTF-8 + CRLF** で保存する必要があります。
Windows PowerShell 5.1 は BOM の無い `.ps1` をシステムの ANSI コードページ
（日本語環境では CP932）として読むため、BOM が無いと日本語部分が文字化けし、
スクリプト全体が構文エラーになります。`.gitattributes` で維持しています。
