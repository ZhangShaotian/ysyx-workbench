#!/usr/bin/env python3
"""Convert an AM binary to word HEX and run it with its ELF halt address."""

import argparse
from pathlib import Path
import struct
import subprocess
import sys


BASE = 0x80000000
MEM_SIZE = 512 * 1024
NPC = Path(__file__).resolve().parents[1]


def prepare_image(binary, elf, nm):
    header = elf.read_bytes()[:52]
    if (len(header) != 52 or header[:7] != b"\x7fELF\x01\x01\x01"
            or struct.unpack_from("<H", header, 18)[0] != 243):
        raise ValueError("expected a little-endian ELF32 RISC-V executable")
    entry = struct.unpack_from("<I", header, 24)[0]
    if entry != BASE:
        raise ValueError(f"AM entry must be 0x{BASE:08x}, got 0x{entry:08x}")
    data = binary.read_bytes()
    if not data or len(data) > MEM_SIZE:
        raise ValueError("AM binary must fit in the v3 512 KiB memory")
    symbols = subprocess.check_output([nm, "--defined-only", str(elf)], text=True)
    halts = [int(fields[0], 16) for line in symbols.splitlines()
             if len(fields := line.split()) == 3 and fields[2] == "halt"
             and fields[1] in ("t", "T")]
    if len(halts) != 1 or halts[0] % 4 or not BASE <= halts[0] <= BASE + len(data) - 4:
        raise ValueError("ELF must contain one aligned halt function inside the binary")
    image = binary.with_suffix(".hex")
    if image.resolve() in (binary.resolve(), elf.resolve()):
        raise ValueError("output HEX must not overwrite binary or ELF input")
    data += bytes((-len(data)) % 4)
    image.write_text("".join(f"{word[0]:08x}\n" for word in struct.iter_unpack("<I", data)),
                     encoding="ascii")
    return image, halts[0]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--bin", required=True, type=Path)
    parser.add_argument("--elf", required=True, type=Path)
    parser.add_argument("--nm", default="riscv64-linux-gnu-nm")
    parser.add_argument("--module", default="ysyx_v3_TopProc_minirv")
    parser.add_argument("--cycles", default="1000000")
    parser.add_argument("--wave", choices=("0", "1"), default="0")
    args = parser.parse_args()
    try:
        if args.module != "ysyx_v3_TopProc_minirv":
            raise ValueError("AM minirv programs currently require the v3 processor")
        image, halt = prepare_image(args.bin.resolve(), args.elf.resolve(), args.nm)
        print(f"[AM] entry=0x{BASE:08x} halt=0x{halt:08x} HEX={image}", flush=True)
        return subprocess.call([
            "make", "-C", str(NPC), "sim", f"MODULENAME={args.module}",
            f"HEX={image}", f"BASE=0x{BASE:08x}", f"HALT=0x{halt:08x}",
            f"CYCLES={args.cycles}", f"WAVE={args.wave}",
        ])
    except (OSError, ValueError, subprocess.CalledProcessError) as error:
        print(f"run_am: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
