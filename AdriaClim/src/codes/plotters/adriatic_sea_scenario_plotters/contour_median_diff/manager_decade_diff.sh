#!/bin/bash


#================================================
#     This is the boxplot monthly graph part
#================================================

# point;physical_variable

module load gmt/6.0.0/intel/19.1.1.217-clpimwl  &>/dev/null

i=1

while IFS=";" read  p_var
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


#======== Temperature contours =========

if [[ "$p_var" == "temp" ]]; then
   ./cnt_diff_temp.gmt    
fi

#======== Salinity contours  =========

if [[ "$p_var" == "sal" ]]; then
   ./cnt_diff_sal.gmt
fi

#======== Sea water height contours =========

if [[ "$p_var" == "zos" ]]; then
   ./cnt_diff_zos.gmt
fi

#====================================

(( i++ ))

done < cnt_initialization_file.txt
