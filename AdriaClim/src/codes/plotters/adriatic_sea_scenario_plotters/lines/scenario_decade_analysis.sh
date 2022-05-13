#!/bin/bash

#================================================
#     This is the boxplot monthly graph part
#================================================

# point;physical_variable

module load ncl/6.6.2  &>/dev/null 

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

#======== Temperature boxplots =========

if [[ "$p_var" == "temp" ]]; then
ncl -Q <   edmub_temp.ncl  point_name=$point_n_s lat_ref=$lat_p lon_ref=$lon_p
fi

#======== Salinity boxplots =========

if [[ "$p_var" == "sal" ]]; then
ncl -Q <   edmub_sal.ncl   point_name=$point_n_s lat_ref=$lat_p lon_ref=$lon_p
fi

#======== Sea water height boxplots =========

if [[ "$p_var" == "zos" ]]; then
ncl -Q <   edmub_zos.ncl   point_name=$point_n_s lat_ref=$lat_p lon_ref=$lon_p
fi

#====================================

(( i++ ))

done < edmub_initialization_file.txt
