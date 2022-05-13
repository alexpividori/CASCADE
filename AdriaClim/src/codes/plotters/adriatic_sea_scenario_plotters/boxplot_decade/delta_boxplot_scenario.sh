#!/bin/bash

#================================================
#     This is the boxplot monthly graph part
#================================================

# point;physical_variable

module purge
module load  python/3.8.1/gcc/8.2.0-mbzms7w
module load  miniconda3/4.7.12.1/gcc/8.2.0-5g55eu6 

i=1

while IFS=";" read point_n  p_var
do

echo "I'm executing initilization file line number:$i"
case $point_n in 

B01)
lat_p="45.44"
lon_p="12.80"
;;
B02)
lat_p="45.20"
lon_p="13.04"
;;
B03)
lat_p="45.14"
lon_p="13.34"
;;
P01)
lat_p="45.50"
lon_p="13.04"
;;
P02)
lat_p="45.44"
lon_p="13.22"
;;
P03)
lat_p="45.38"
lon_p="13.40"
;;
P04)
lat_p="45.62"
lon_p="13.10"
;;
P05)
lat_p="45.62"
lon_p="13.16"
;;
P06)
lat_p="45.68"
lon_p="13.28"
;;
P07)
lat_p="45.62"
lon_p="13.40"
;;
P08)
lat_p="45.74"
lon_p="13.58"
;;
P09)
lat_p="45.68"
lon_p="13.58"
;;
P10)
lat_p="45.62"
lon_p="13.70"
;;
P11)
lat_p="45.62"
lon_p="13.64"
;;
P12)
lat_p="45.68"
lon_p="13.22"
;;
esac

point_n_s="\"$point_n\""

#======== Temperature  =========

if [[ "$p_var" == "temp" ]]; then
    python  boxplot_scenario_temp.py  $point_n  $lat_p  $lon_p
fi

#======== Salinity  =========

if [[ "$p_var" == "sal" ]]; then
    python  boxplot_scenario_sal.py  $point_n  $lat_p  $lon_p
fi

#======== Sea surface height  =========

if [[ "$p_var" == "zos" ]]; then
    python  boxplot_scenario_zos.py  $point_n  $lat_p  $lon_p
fi

#======== Temperature  =========

if [[ "$p_var" == "temp_dmm" ]]; then
    python  boxplot_scenario_temp_dmm.py  $point_n  $lat_p  $lon_p
fi

#======== Salinity  =========

if [[ "$p_var" == "sal_dmm" ]]; then
    python  boxplot_scenario_sal_dmm.py  $point_n  $lat_p  $lon_p
fi

#======== Sea surface height  =========

if [[ "$p_var" == "zos_dmm" ]]; then
    python  boxplot_scenario_zos_dmm.py  $point_n  $lat_p  $lon_p
fi

#======================================

(( i++ ))

done < initialization_file.txt
