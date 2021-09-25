#!/usr/bin/bash
base=$(basename "$1")
pandoc -H resources/head.tex -V geometry:margin=1in $1 --resource-path=notes -o "out/${base%.md}.pdf"
