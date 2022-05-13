#!/bin/bash

#================================================
#     This is the boxplot monthly graph part
#================================================

# point;physical_variable

module purge
module load  python/3.8.1/gcc/8.2.0-mbzms7w
module load  miniconda3/4.7.12.1/gcc/8.2.0-5g55eu6 

i=1

while IFS=";" read point_n  RCP year_middle
do

echo "I'm executing initilization file line number:$i"
case $point_n in 

E01)
lat_p="45.65"
lon_p="13.50"
;;
E02)
lat_p="46.05"
lon_p="13.10"
;;
E03)
lat_p="46.35"
lon_p="13.10"
;;
E04)
lat_p="46.25"
lon_p="13.80"
;;
*)
echo -e "\tPoint not found"
exit
;;
esac

#======== pr =========

    echo "\"boxplot_cumulative_pr.py\" will be launched right now for \"pr\" field"
    python  boxplot_cumulative_pr.py  $point_n  $lat_p  $lon_p  $RCP $year_middle

#======================================

(( i++ ))

done < initialization_file.txt
