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

#======== Temperature rcp85  =========

if [[ "$p_var" == "temp85" ]]; then
    python  fill_lines_temp85.py  $point_n  $lat_p  $lon_p
fi

#======== Temperature rcp45  =========

if [[ "$p_var" == "temp45" ]]; then
    python  fill_lines_temp45.py  $point_n  $lat_p  $lon_p
fi

#======== Temperature rcp26  =========

if [[ "$p_var" == "temp26" ]]; then
    python  fill_lines_temp26.py  $point_n  $lat_p  $lon_p
fi

#======== Salinity rcp85 =========

if [[ "$p_var" == "sal85" ]]; then
    python  fill_lines_sal85.py  $point_n  $lat_p  $lon_p
fi

#======== Salinity rcp45 =========

if [[ "$p_var" == "sal45" ]]; then
    python  fill_lines_sal45.py  $point_n  $lat_p  $lon_p
fi

#======== Salinity rcp45 =========

if [[ "$p_var" == "sal26" ]]; then
    python  fill_lines_sal26.py  $point_n  $lat_p  $lon_p
fi

#======== Sea water height rcp85 =========

if [[ "$p_var" == "zos85" ]]; then
    python  fill_lines_zos85.py  $point_n  $lat_p  $lon_p
fi

#======== Sea water height rcp45 =========

if [[ "$p_var" == "zos45" ]]; then
    python  fill_lines_zos45.py  $point_n  $lat_p  $lon_p
fi

#======== Sea water height rcp26 =========

if [[ "$p_var" == "zos26" ]]; then
    python  fill_lines_zos26.py  $point_n  $lat_p  $lon_p
fi

#========================================
#                  ALL RCP'S
#=========================================

#======== Temperature ALL  =========

if [[ "$p_var" == "tempall" ]]; then
    python  fill_lines_tempall.py  $point_n  $lat_p  $lon_p
fi

#======== Salinity ALL  =========

if [[ "$p_var" == "salall" ]]; then
    python  fill_lines_salall.py  $point_n  $lat_p  $lon_p
fi

#======== zos ALL  =========

if [[ "$p_var" == "zosall" ]]; then
    python  fill_lines_zosall.py  $point_n  $lat_p  $lon_p
fi

#======================================

(( i++ ))

done < edmub_initialization_file.txt
