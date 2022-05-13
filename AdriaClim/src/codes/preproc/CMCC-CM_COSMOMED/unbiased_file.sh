#!/bin/bash

file_name="$1" # whitout prefix


cdo  -timselmean,120,612,10000  edm_$file_name  tmp_file.nc 
cdo  -sub                       edm_$file_name  tmp_file.nc   edmub_$file_name  
rm tmp_file.nc
