#!/bin/bash

base_path=./t/test_data
echo "creating any needed dirs..."
for dataset in foo bar; do
    for y in 2015; do
        for m in $(seq -w 6 10); do
            days=30
            if [ $m -eq 2 ]; then
                days=28
            elif [[ "1 3 5 7 8 10 12" =~ $m ]]; then
                days=31
            fi
            for d in $(seq -w 1 $days); do
                    dir=$base_path/$dataset/$y/$m/$d/00
                    mkdir -pv $dir
                    touch $dir/${dataset}1
            done
        done
    done
done
echo "done."
