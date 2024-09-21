#!/bin/bash

cp text.original _text_0

python ./main.py

cat -n text.original

cat -n _text_0

