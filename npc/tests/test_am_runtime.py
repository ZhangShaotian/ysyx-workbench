#!/usr/bin/env python3
"""Exercise real AM compilation and RTL exit-status handling end to end."""

import os
from pathlib import Path
import subprocess
import tempfile


ROOT = Path(__file__).resolve().parents[2]
AM = ROOT / "abstract-machine"
NPC = ROOT / "npc"


def main():
    env = {**os.environ, "AM_HOME": str(AM), "NPC_HOME": str(NPC)}
    log_dir = NPC / "build" / "am-runtime-tests"
    log_dir.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="npc-am-test-") as directory:
        work = Path(directory)
        # Use separate names so switching fixtures never reuses stale objects.
        cases = [
            ("dummy", (ROOT / "am-kernels/tests/cpu-tests/tests/dummy.c").read_text(), "PASS"),
            ("fail", "int main(void) { return 1; }\n", "FAIL"),
            ("timeout", "int main(void) { while (1) {} }\n", "TIMEOUT"),
        ]
        for name, source, expected in cases:
            (work / f"{name}.c").write_text(source)
            (work / "Makefile").write_text(
                f"NAME = {name}\nSRCS = {name}.c\ninclude $(AM_HOME)/Makefile\n")
            run = subprocess.run(
                ["make", "ARCH=minirv-npc", "run", "WAVE=0", "CYCLES=1000"],
                cwd=work, env=env, text=True, stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT, timeout=180,
            )
            (log_dir / f"{name}.log").write_text(run.stdout)
            assert (run.returncode == 0) == (expected == "PASS"), run.stdout
            assert f"[RESULT] {expected}:" in run.stdout, run.stdout
            assert "[AM] entry=0x80000000" in run.stdout, run.stdout
            if expected != "TIMEOUT":
                code = 0 if expected == "PASS" else 1
                assert f"a0={code:08x}" in run.stdout, run.stdout
            print(f"PASS AM runtime {name}: reported {expected}", flush=True)
    print(f"Logs: {log_dir}")


if __name__ == "__main__":
    main()
