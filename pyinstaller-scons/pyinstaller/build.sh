#!/bin/bash

# Exit on error.
set -e

rm -rf _dist _build

name="myapp-installer"

pyinstaller \
  --distpath _dist \
  --workpath _build \
  ./myapp.spec

mv _dist/main _dist/$name

cd _dist

cat > $name/activate <<EOL
# run 'source activate' to enable the myapp executable.
#
echo "Please wait"
echo "Removing quarantine flags in this directory."
sudo find . -exec xattr -d com.apple.quarantine {} 2> /dev/null \;
echo "Done"
EOL

cat > $name/README.txt <<EOL
1. Run 'source activate' once to enable the executables.
2. Add this directory to your PATH.
3. Use the 'apio' command. For example, 'apio -h' for help.
EOL

zip -r $name.zip $name

echo
echo `pwd`:
echo
ls -ld myapp*
