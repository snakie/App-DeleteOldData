#!/bin/bash

base_path=./test_data
rm -rf $base_path
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
               # for h in $(seq -w 0 23); do
                    #dir=$base_path/$dataset/$y/$m/$d/$h
                    dir=$base_path/$dataset/$y/$m/$d/0
                    echo $dir
                    mkdir -pv $dir
                    #touch $dir/${dataset}{1,2,3}
                    touch $dir/${dataset}1
               # done
            done
        done
    done
done
