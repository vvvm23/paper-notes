#!/usr/bin/bash
n=$(ls -l notes/*.md | wc -l)
count=0
tab=$'\t'
for f in notes/*.md; do
    count=$(($count+1))
    echo "> ($count/$n) compiling $f to pdf"
    ./compile.sh $f
done
echo "> done"
