from pathlib import Path
import subprocess


def main():
    print("Main started")

    current_python_file = Path(__file__)
    print(f"{current_python_file=}")

    sconstruct_path = current_python_file.parent / "sconstruct.py"
    print(f"{sconstruct_path=}")

    cmd = ["scons"]
    cmd += ["-f", str(sconstruct_path)]
    cmd += ["--include-dir", str(current_python_file.parent.parent)]
    print(cmd)

    result = subprocess.run(cmd)
    print(f"{result.returncode=}")

if __name__ == "__main__":
    main()
