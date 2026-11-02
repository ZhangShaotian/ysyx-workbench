#!/usr/bin/env python3
"""Exercise real RTL with runtime HEX selection; run from any directory."""

from pathlib import Path
import shutil
import subprocess
import tempfile


NPC = Path(__file__).resolve().parents[1]
MODULES = (
    "ysyx_v1_TopProcAddi",
    "ysyx_v2_TopProc_Addi_Jalr",
    "ysyx_v3_TopProc_minirv",
)
EBREAK = "hex/program_ebreak.hex"
LUI = "hex/program_addi_jalr_lui.hex"
BUILD_TIMES = {}


def make_sim(module, image=None):
    args = ["make", f"MODULENAME={module}", "sim", "WAVE=0"]
    if image is not None:
        args.append(f"HEX={image}")
    return subprocess.run(
        args, cwd=NPC, text=True, stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT, timeout=180,
    )


def waveform(module):
    path = NPC / "build" / module / "waveform.fst"
    vcd = subprocess.check_output(["fst2vcd", str(path)], text=True)
    scopes, names, values, history = [], {}, {}, {}
    for line in vcd.splitlines():
        parts = line.split()
        if not parts:
            continue
        if parts[0] == "$scope":
            scopes.append(parts[2])
        elif parts[0] == "$upscope":
            scopes.pop()
        elif parts[0] == "$var":
            names[".".join(scopes + [parts[4]])] = parts[3]
        elif line.startswith("b"):
            bits, key = line[1:].split()
            if set(bits) <= {"0", "1"}:
                values[key] = int(bits, 2)
                history.setdefault(key, []).append(values[key])
    prefix = f"TOP.{module}."
    return (
        {name.removeprefix(prefix): values[key]
         for name, key in names.items() if name.startswith(prefix) and key in values},
        {name.removeprefix(prefix): history[key]
         for name, key in names.items() if name.startswith(prefix) and key in history},
    )


def check(module, image, kind):
    print(f"RUN {module}: {image if image is not None else '(default HEX)'}", flush=True)
    result = make_sim(module, image)
    assert result.returncode == 0, result.stdout
    expected_image = image if image is not None else (EBREAK if module == MODULES[0] else LUI)
    assert f"[ROM] Loading {expected_image}" in result.stdout, result.stdout

    executable = NPC / "build" / module / "obj_dir" / f"V{module}"
    timestamp = executable.stat().st_mtime_ns
    if module in BUILD_TIMES:
        assert timestamp == BUILD_TIMES[module], "Changing HEX rebuilt the executable"
    BUILD_TIMES[module] = timestamp

    values, history = waveform(module)
    rf = "RegFile" if module == MODULES[0] else "u_prf"
    if kind == "ebreak":
        for index in range(32):
            assert values[f"{rf}.rf[{index}]"] == index, (module, index, values)
    elif kind == "raw":
        assert values[f"{rf}.rf[1]"] == 1
        assert values[f"{rf}.rf[2]"] == 3
    elif kind == "lui":
        assert values[f"{rf}.rf[1]"] == 0x8000000C
        assert values[f"{rf}.rf[2]"] == 0x80000018
        assert values[f"{rf}.rf[5]"] == 10
        assert 0x80000000 in history[f"{rf}.rf[2]"]
        assert 255 not in history[f"{rf}.rf[5]"]
        assert 0x80000018 in history["pc_out"]
        assert 0x8000001C in history["pc_out"]
        assert 0x8000000C not in history["pc_out"]
    else:
        raise AssertionError(kind)
    if kind != "raw":
        assert "ebreak detected" in result.stdout, result.stdout
    print("PASS: register results and image selection", flush=True)


def main():
    for tool in ("make", "verilator", "g++", "fst2vcd"):
        if not shutil.which(tool):
            raise SystemExit(f"Required tool not found: {tool}")

    for module in MODULES:
        check(module, EBREAK, "ebreak")
        check(module, "hex/program_raw.hex", "raw")
        if module != MODULES[0]:
            check(module, LUI, "lui")
            check(module, EBREAK, "ebreak")
        check(module, None, "ebreak" if module == MODULES[0] else "lui")

    # Absolute paths with spaces and apostrophes must survive make and the shell.
    with tempfile.TemporaryDirectory(prefix="npc hex ") as directory:
        image = Path(directory) / "test's image.hex"
        shutil.copyfile(NPC / EBREAK, image)
        check(MODULES[2], str(image), "ebreak")

        missing = Path(directory) / "does not exist.hex"
        for invalid in ("", str(missing), directory):
            result = make_sim(MODULES[2], invalid)
            assert result.returncode != 0, result.stdout
            assert "HEX is empty" in result.stdout or "readable file" in result.stdout
            assert "[ROM] Loading" not in result.stdout
    result = make_sim("unknown_processor", EBREAK)
    assert result.returncode != 0 and "Unknown MODULENAME" in result.stdout
    print("PASS: invalid HEX and MODULENAME rejected before simulation", flush=True)
    print("PASS: all processor/image cases; HEX switches reused the binaries", flush=True)


if __name__ == "__main__":
    main()
