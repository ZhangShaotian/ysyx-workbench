#!/usr/bin/env python3
"""Run the four memory-instruction tests and the original mem/sum images on RTL."""
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile

NPC = Path(__file__).resolve().parents[1]
MODULE = "ysyx_v3_TopProc_minirv"
BUILD = NPC / "build" / MODULE
EXPECTED = {
    "lw": {0: 0, 1: 0x80000104, 2: 0x12345678, 3: 0x89abcdef,
           4: 0xfedcba98, 5: 7, 6: 9},
    "lbu": {0: 0, 1: 0x80000104, 2: 0, 3: 127, 4: 255,
            5: 128, 6: 120, 7: 128, 8: 1},
    "sw": {0: 0, 1: 0x80000104, 2: 0xffffffff, 3: 0x12345678,
           4: 0x66, 5: 0xffffffff, 7: 0, 8: 0xdeadbeef, 28: 0x55},
    "sb": {0: 0, 1: 0x80000104, 2: 0x2468a0ef,
           3: 0x90345678, 4: 0x90ab5678, 5: 0x90abcd78,
           6: 0x90abcdef, 7: 0xdeadbeef, 8: 0xdead00ef,
           28: 28, 29: 29, 30: 30, 31: 31},
}
COUNTS = {"lw": 9, "lbu": 12, "sw": 15, "sb": 26}
HALT = {"mem": (0x1218, 5763), "sum": (0x224, 5883)}


def state(output):
    lines = [line for line in output.splitlines() if line.startswith("[STATE]")]
    assert len(lines) == 1, output
    return {key: int(value, 10 if key == "cycles" else 16)
            for key, value in re.findall(r"(cycles|pc|x\d+)=([0-9a-f]+)", lines[0])}


def main():
    results = []
    binary_time = None
    for name in [*EXPECTED, *HALT]:
        image = f"hex/program_{name}.hex" if name in EXPECTED else f"hex/logisim/{name}.hex"
        command = ["make", f"MODULENAME={MODULE}", f"HEX={image}", "sim", "WAVE=0"]
        print(f"RUN {name}: {' '.join(command)}", flush=True)
        run = subprocess.run(command, cwd=NPC, text=True, stdout=subprocess.PIPE,
                             stderr=subprocess.STDOUT, timeout=180)
        BUILD.mkdir(parents=True, exist_ok=True)
        (BUILD / f"test-{name}.log").write_text(run.stdout)
        assert run.returncode == 0, run.stdout
        actual = state(run.stdout)
        if name in EXPECTED:
            assert "ebreak detected" in run.stdout, run.stdout
            assert actual["cycles"] == COUNTS[name], actual
            for reg, value in EXPECTED[name].items():
                assert actual[f"x{reg}"] == value, (name, reg, value, actual)
        else:
            halt_pc, count = HALT[name]
            assert actual["cycles"] == count, actual
            assert actual["pc"] == halt_pc + 4, actual
            assert actual["x10"] == 0, actual
            assert f"[RESULT] PASS: halt_pc={halt_pc:08x} a0=00000000" in run.stdout
        # Program changes must not rebuild the CPU model.
        timestamp = (BUILD / "obj_dir" / f"V{MODULE}").stat().st_mtime_ns
        if binary_time is not None:
            assert timestamp == binary_time, "Switching HEX rebuilt the binary"
        binary_time = timestamp
        shutil.copyfile(BUILD / "waveform.fst", BUILD / f"test-{name}.fst")
        results.append({"test": name, "hex": image, "passed": True, **actual})
        print(f"PASS {name}: cycles={actual['cycles']} pc=0x{actual['pc']:08x} "
              f"a0=0x{actual['x10']:08x}", flush=True)
    (BUILD / "test_results.json").write_text(json.dumps(results, indent=2) + "\n")
    print(f"PASS all six RTL tests. Logs, waves and test_results.json: {BUILD}")
    # Verify that stopping is not mistaken for success: inspect exit status too.
    with tempfile.TemporaryDirectory(prefix="npc-halt-") as directory:
        image = Path(directory) / "halt.hex"
        for name, first, cycles, expected in [
            ("success", "00000513", 10, "PASS"),
            ("nonzero-a0", "00100513", 10, "FAIL"),
            ("timeout", "00000513", 1, "TIMEOUT"),
            ("wrong-ebreak", "00100073", 10, "FAIL"),
        ]:
            image.write_text(f"{first}\n00000013\n00000067\n")
            output = subprocess.run([
                sys.executable, str(NPC / "scripts/run_image.py"),
                "--module", MODULE, "--hex", str(image),
                "--binary", str(BUILD / "obj_dir" / f"V{MODULE}"),
                "--wave", str(Path(directory) / "wave.fst"),
                "--halt", "0x80000008", "--cycles", str(cycles),
            ], text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=30)
            assert (output.returncode == 0) == (expected == "PASS"), output.stdout
            assert f"[RESULT] {expected}:" in output.stdout, output.stdout
            assert image.read_text() == f"{first}\n00000013\n00000067\n"
            print(f"PASS halt handling: {name}")


if __name__ == "__main__":
    main()
