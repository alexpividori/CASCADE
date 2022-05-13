#!/bin/bash

module load cdo

while read file
do

cdo  -setmissval,1e+20 ${file}  n_${file}

rm ${file}
mv n_${file} ${file}

done < initialization_file.txt
