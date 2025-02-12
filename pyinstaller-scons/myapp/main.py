from pathlib import Path
import subprocess
import sys
import re
import SCons.Platform.darwin
import SCons.Tool.default
import SCons.Tool.gcc
# from myapp.my_lib import lib_func
# from PyInstaller.utils.hooks import collect_submodules



def myapp_main():
    print("Main started")
    # lib_func('From main, before dispatching')

    # -- If invoked as the scons subprocess, dispatch to the scons lib.
    if sys.argv[1:3] == ["-m", "SCons"]:
       sys.argv[1:] = sys.argv[3:]
    #    lib_func("From child main")
       # We import and initialize scons only when running the scons subprocess.
       from SCons.Script.Main import main
       # This is a logic is taken from the scons startup 'binary' on darwin.
       sys.argv[0] = re.sub(r'(-script\.pyw|\.exe)?$', '', sys.argv[0])
       val = main()
       sys.exit(val)

    # -- Here when running the parent process.

    # lib_func("From parent main")
    # -- Get the path of the current file.
    current_python_file = Path(__file__)
    print(f"*** Main():  {current_python_file=}")

    # -- Compute the path of the sibling sconstruct file
    sconstruct_path = current_python_file.parent / "sconstruct"
    print(f"*** Main(): {sconstruct_path=}")

    # -- Construct the command to the scons subprocess.
    cmd = []
    cmd += [sys.executable, "-m", "SCons"]
    cmd += ["-f", str(sconstruct_path)]
    cmd += ["--include-dir", str(current_python_file.parent.parent)]
    print(f"*** Main(): {cmd=}")
   
    # -- Invoke the scons subprocess.
    result = subprocess.run(cmd)
    print(f"*** Main(): {result.returncode=}")

if __name__ == "__main__":
    myapp_main()
