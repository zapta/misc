#!/bin/bash

rm _*
cp text.original _text.in

python ./main.py

echo
echo "_text.in"
cat -n text.original

echo
echo "_text.out"
cat -n _text.out

