#!/usr/bin/env python3
"""Prepare a program image, select its address layout, and run the simulator."""

import argparse
import hashlib
from pathlib import Path
import re
import subprocess
import sys


LOGISIM_HEADER = "v3.0 hex words addressed"
V3_MODULE = "ysyx_v3_TopProc_minirv"
HEX_TOKEN = re.compile(r"[0-9a-fA-F]+\Z")
# Exact supplied images only: never guess halt locations from filenames.
KNOWN_HALTS = {
    "da4a0c602cef3d6a76f5f9c6913e84279de130d51f01143712af29cbd46208ce": 0x1218,
    "003ef068a9f1ee88bea3196c19102bfb43dc4ee83da3edb1cfdaef9f1c46032e": 0x224,
}


def convert_logisim(text):
    """Keep Logisim WORD addresses unchanged as readmemh @word directives."""
    output = []
    written = set()
    for line_number, raw_line in enumerate(text.splitlines()[1:], start=2):
        line = raw_line.split("#", 1)[0].split("//", 1)[0].strip()
        if not line:
            continue
        address, separator, contents = line.partition(":")
        address = address.strip()
        words = contents.split()
        if not separator or not HEX_TOKEN.fullmatch(address) or not words:
            raise ValueError(f"invalid Logisim address/data at line {line_number}")
        index = int(address, 16)
        if index + len(words) > 0x40000000:
            raise ValueError(f"word address exceeds the 32-bit byte address space at line {line_number}")
        normalized = []
        for offset, word in enumerate(words):
            if not HEX_TOKEN.fullmatch(word) or int(word, 16) > 0xFFFFFFFF:
                raise ValueError(f"invalid 32-bit word at line {line_number}: {word}")
            if index + offset in written:
                raise ValueError(f"overlapping word address at line {line_number}")
            written.add(index + offset)
            normalized.append(f"{int(word, 16):08x}")
        output.append(f"@{index:08x}\n{' '.join(normalized)}\n")
    if not output:
        raise ValueError("Logisim image contains no words")
    return "".join(output)


def run(args):
    source = Path(args.hex)
    if not source.is_file():
        raise ValueError(f"HEX must name a readable file: {source}")
    text = source.read_text(encoding="utf-8-sig")
    lines = text.splitlines()
    header = lines[0].strip() if lines else ""
    is_logisim = header == LOGISIM_HEADER
    if header.startswith("v") and not is_logisim:
        raise ValueError(f"unsupported image header: {header}")

    base = (0 if is_logisim else 0x80000000) if args.base == "auto" else int(args.base, 0)
    cycles = (6000 if is_logisim else 1000) if args.cycles == "auto" else int(args.cycles, 10)
    if not 0 <= base <= 0xFFFFFFFF or base % 4:
        raise ValueError("BASE must be a 32-bit address aligned to four bytes")
    if not 0 < cycles <= 0xFFFFFFFFFFFFFFFF:
        raise ValueError("CYCLES must be a positive 64-bit integer")
    if args.module != V3_MODULE and (is_logisim or base != 0x80000000):
        raise ValueError("Logisim images and alternate BASE addresses require the v3 processor")

    if args.halt == "auto":
        halt = KNOWN_HALTS.get(hashlib.sha256(source.read_bytes()).hexdigest())
        if halt is not None and base != 0:
            raise ValueError("known mem/sum images require BASE=0 for automatic HALT")
    else:
        halt = None if args.halt == "none" else int(args.halt, 0)
    if halt is not None:
        if args.module != V3_MODULE:
            raise ValueError("HALT patching requires the v3 processor")
        if not base <= halt < min(base + 512 * 1024, 0x100000000) or halt % 4:
            raise ValueError("HALT must be a word-aligned byte address inside instruction ROM")

    wave = Path(args.wave)
    wave.parent.mkdir(parents=True, exist_ok=True)
    image = args.hex
    if is_logisim:
        target = wave.parent / "image.readmemh.hex"
        if target.resolve() == source.resolve():
            raise ValueError("converted image path must differ from the original image")
        target.write_text(convert_logisim(text), encoding="ascii")
        image = str(target)
    print(f"[IMAGE] {'Logisim' if is_logisim else 'readmemh'}: {args.hex}, "
          f"BASE=0x{base:08x}, CYCLES={cycles}", flush=True)
    halt_args = [] if halt is None else [f"+halt={halt:08x}"]
    result = subprocess.run([
        str(Path(args.binary).absolute()), args.wave,
        f"+hex={image}", f"+base={base:08x}", f"+cycles={cycles}",
    ] + halt_args)
    return result.returncode if result.returncode >= 0 else 128 - result.returncode


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--module", required=True)
    parser.add_argument("--hex", required=True)
    parser.add_argument("--wave", required=True)
    parser.add_argument("--binary", required=True)
    parser.add_argument("--base", default="auto", help="auto, or an address such as 0x80000000")
    parser.add_argument("--cycles", default="auto", help="auto, or a positive decimal cycle limit")
    parser.add_argument("--halt", default="auto", help="auto for supplied mem/sum, none, or halt byte address")
    args = parser.parse_args()
    try:
        return run(args)
    except (OSError, ValueError) as error:
        print(f"run_image: {error}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
