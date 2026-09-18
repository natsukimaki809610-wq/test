#!/usr/bin/env python3
"""LINEスタンプ用に画像を 370x320 へ一括リサイズする。

縦横比を保ったまま 370x320 に収まるよう縮小し、余った部分は透明で埋めて
ちょうど 370x320 の PNG として出力する。元のファイルは変更しない。

事前準備:
    pip install Pillow

使い方:
    python resize_line_stamps.py
    python resize_line_stamps.py --source "C:\\Users\\user\\ChatGPT\\99_その他\\LINE\\看護師40"
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

try:
    from PIL import Image
except ImportError:
    sys.exit("Pillow が必要です。先に `pip install Pillow` を実行してください。")

EXTENSIONS = (".png", ".jpg", ".jpeg", ".webp", ".bmp")


def find_source(number: int, source_dir: Path) -> Path | None:
    """番号 N に対応するファイルを探す (1.png / 01.png / 001.png など)。"""
    for stem in (str(number), f"{number:02d}", f"{number:03d}"):
        for ext in EXTENSIONS:
            candidate = source_dir / f"{stem}{ext}"
            if candidate.is_file():
                return candidate
    return None


def resize_one(
    src_path: Path, out_path: Path, width: int, height: int, no_upscale: bool = False
) -> tuple[int, int, int, int]:
    with Image.open(src_path) as im:
        im = im.convert("RGBA")
        original = im.size

        scale = min(width / im.width, height / im.height)
        if no_upscale:
            scale = min(scale, 1.0)
        draw_w = max(1, round(im.width * scale))
        draw_h = max(1, round(im.height * scale))

        resized = im.resize((draw_w, draw_h), Image.LANCZOS)

        canvas = Image.new("RGBA", (width, height), (0, 0, 0, 0))
        canvas.paste(resized, ((width - draw_w) // 2, (height - draw_h) // 2))
        canvas.save(out_path, "PNG", optimize=True)

    return (*original, draw_w, draw_h)


def main() -> int:
    parser = argparse.ArgumentParser(description="LINEスタンプ用の一括リサイズ")
    parser.add_argument("--source", default=".", help="変換元フォルダ（既定: カレントフォルダ）")
    parser.add_argument("--output", default=None, help="出力先フォルダ（既定: 変換元/resized）")
    parser.add_argument("--width", type=int, default=370)
    parser.add_argument("--height", type=int, default=320)
    parser.add_argument("--from", dest="start", type=int, default=1)
    parser.add_argument("--to", dest="end", type=int, default=40)
    parser.add_argument(
        "--output-name",
        default=None,
        help="出力ファイル名。1枚だけ変換するとき用（例: main / tab）",
    )
    parser.add_argument(
        "--no-upscale",
        action="store_true",
        help="元画像が370x320より小さい場合は拡大せず、そのまま中央に配置する",
    )
    args = parser.parse_args()

    source_dir = Path(args.source).expanduser().resolve()
    if not source_dir.is_dir():
        sys.exit(f"変換元フォルダが見つかりません: {source_dir}")

    output_dir = Path(args.output).expanduser().resolve() if args.output else source_dir / "resized"
    output_dir.mkdir(parents=True, exist_ok=True)

    print(f"変換元 : {source_dir}")
    print(f"出力先 : {output_dir}")
    print(f"サイズ : {args.width}x{args.height} (縦横比を保持し、余白は透明)\n")

    converted = 0
    missing: list[int] = []

    for number in range(args.start, args.end + 1):
        src_path = find_source(number, source_dir)
        if src_path is None:
            missing.append(number)
            print(f"No.{number} の画像が見つかりません（スキップ）")
            continue

        if args.output_name:
            leaf = args.output_name
            if not leaf.lower().endswith(".png"):
                leaf += ".png"
        else:
            leaf = f"{number:02d}.png"
        out_path = output_dir / leaf
        orig_w, orig_h, draw_w, draw_h = resize_one(
            src_path, out_path, args.width, args.height, args.no_upscale
        )
        size_kb = out_path.stat().st_size / 1024

        print(
            f"No.{number:<3}{orig_w:>5}x{orig_h:<5} -> {leaf:<12} "
            f"{args.width}x{args.height} (中身 {draw_w}x{draw_h}, {size_kb:.1f} KB)"
        )
        converted += 1

    print(f"\n完了: {converted} 枚を変換しました -> {output_dir}")
    if missing:
        print("見つからなかった番号: " + ", ".join(str(n) for n in missing))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
