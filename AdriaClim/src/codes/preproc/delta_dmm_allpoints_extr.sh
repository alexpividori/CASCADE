#!/bin/bash

#******************************************************************************
#
# DESCRIPTION:       This bash script is used to create a CSV output file
#                    containing the delta sea surface temperature, salinity
#                    and height for future scenario decades. Each line
#                    contains the value for one month: from January to December.
#                    The files realized are 6: temperature, salinity and surface
#                    height for averages and medians.
#
# EXTERNAL CALLS:   none.
#
# EXTERNAL FILES:   - input NetCDF downloaded from Med_CORDEX official site and 
#                     edited by cdo command line operators.
#                   - The initialization txt file contains the whole set of dmm or
#                     dme edited files only for Temperatures. The salinity and 
#                     zos ones will be obtained from the temperature ones
#
# DEVELOPER:         Alex Pividori (alex.pividori@arpa.fvg.it)
#                    ARPA FVG - S.O.C. Stato dell'Ambiente - CRMA
#                   "AdriaClim" Interreg IT-HR project
#
# SOFTWARE VERSION: Bash
#                   CDO version 1.9.8
#
# CREATION DATE:    14/03/2022
#
# MODIFICATIONS:    14/03/2022 --> Creation date 
#
# VERSION:          0.1.
#
#******************************************************************************

#=============================================================================
#                                 MEAN VERSION
#=============================================================================

#****** Module loading ********

module load cdo/1.9.8/intel/19.1.1.217-prtc7xl  || { echo "cdo module can't be loaded" ; exit 1 ; }

# WARNING: The following lat/lon indexes starts from 0
# but the cdo -selindexbox operator instead starts from 1, so it is necessary
# to subtract 1 to have the corresponding index value

# ==================== LOOPS on physical variable =========================
for var in tos sos zos
do

#***** varibale denomination **********
case $var in
tos)
var_den="Temperature [°C]"
var_field="Temperature"
;;
sos)
var_den="Salinity [PSU]"
var_field="Salinity"
;;
zos)
var_den="Surface Height [m]"
var_field="Sea Surface Height"
;;
esac
#**************************************

i=0

for point in B01 B02 B03 P01 P02 P03 P04 P05 P06 P07 P08 P09 P10 P11 P12
do

case $point in 
#=========== Boundary points ===========
#=== B01 ===
B01)
point="B01"
ind_x=15          # lon/lat indexes strarting from 0 (ncview convention)
ind_y=94
lat_p=45.44
lon_p=12.80
;;
#=== B02 ===
B02)
point="B02"
ind_x=19
ind_y=90
lat_p=45.20
lon_p=13.04
;;
#=== B03 ===
B03)
point="B03"
ind_x=24
ind_y=89
lat_p=45.14
lon_p=13.34
;;
#======== Internal points ==========
P01)
point="P01"
ind_x=19
ind_y=85
lat_p=45.50
lon_p=13.04
;;
P02)
point="P02"
ind_x=22
ind_y=94
lat_p=45.44
lon_p=13.22
;;
P03)
point="P03"
ind_x=25
ind_y=93
lat_p=45.38
lon_p=13.40
;;
P04)
point="P04"
ind_x=20
ind_y=97
lat_p=45.62
lon_p=13.10
;;
P05)
point="P05"
ind_x=21
ind_y=97
lat_p=45.62
lon_p=13.16
;;
P06)
point="P06"
ind_x=23
ind_y=98
lat_p=45.68
lon_p=13.28
;;
P07)
point="P07"
ind_x=25
ind_y=97
lat_p=45.62
lon_p=13.40
;;
P08)
point="P08"
ind_x=28
ind_y=99
lat_p=45.74
lon_p=13.58
;;
P09)
point="P09"
ind_x=28
ind_y=98
lat_p=45.68
lon_p=13.58
;;
P10)
point="P10"
ind_x=30
ind_y=97
lat_p=45.62
lon_p=13.70
;;
P11)
point="P11"
ind_x=29
ind_y=97
lat_p=45.62
lon_p=13.64
;;
P12)
point="P12"
ind_x=22
ind_y=98
lat_p=45.68
lon_p=13.22
;;
*)
     echo "Desired point $point is not in the list. Please insert another point label."
     continue
;;
esac

#******* Root directory of the netCDF input files 
input_root_dir="/lustre/arpa/AdriaClim/data/Med_CORDEX_files"
output_root_dir="/lustre/arpa/AdriaClim/data/Med_CORDEX_files"

#==============================================================================
# the initialization file contains by default the names of the dme edited files
# so the files containing the median differences
#==============================================================================

while  IFS='/'  read   dir_name  file_name
do

(( i++ ))

IFS='_'  read  -a f_field <<< "$file_name"
f_field[0]="dmm"                                       # this is the Mean value version so i have to change the file name prefix

echo -e "\tI'm executing $dir_name/${f_field[0]}_${var}_${f_field[2]}_${f_field[3]}_${f_field[4]}_${f_field[5]}_${f_field[6]}_${f_field[7]}_${f_field[8]}_${f_field[9]}_${f_field[10]}"

input_dir="${input_root_dir}/${dir_name}"
output_dir="${output_root_dir}"

#******** Months file *********

months_file="${output_dir}/months_file.txt"
if [[ ! -f $months_file ]]; then

cat << EOF > $months_file
$point;$lat_p;$lon_p;${dir_name}_${f_field[7]};${f_field[4]};$(( ${f_field[9]:0:4} + 5 ));01
$point;$lat_p;$lon_p;${dir_name}_${f_field[7]};${f_field[4]};$(( ${f_field[9]:0:4} + 5 ));02
$point;$lat_p;$lon_p;${dir_name}_${f_field[7]};${f_field[4]};$(( ${f_field[9]:0:4} + 5 ));03
$point;$lat_p;$lon_p;${dir_name}_${f_field[7]};${f_field[4]};$(( ${f_field[9]:0:4} + 5 ));04
$point;$lat_p;$lon_p;${dir_name}_${f_field[7]};${f_field[4]};$(( ${f_field[9]:0:4} + 5 ));05
$point;$lat_p;$lon_p;${dir_name}_${f_field[7]};${f_field[4]};$(( ${f_field[9]:0:4} + 5 ));06
$point;$lat_p;$lon_p;${dir_name}_${f_field[7]};${f_field[4]};$(( ${f_field[9]:0:4} + 5 ));07
$point;$lat_p;$lon_p;${dir_name}_${f_field[7]};${f_field[4]};$(( ${f_field[9]:0:4} + 5 ));08
$point;$lat_p;$lon_p;${dir_name}_${f_field[7]};${f_field[4]};$(( ${f_field[9]:0:4} + 5 ));09
$point;$lat_p;$lon_p;${dir_name}_${f_field[7]};${f_field[4]};$(( ${f_field[9]:0:4} + 5 ));10
$point;$lat_p;$lon_p;${dir_name}_${f_field[7]};${f_field[4]};$(( ${f_field[9]:0:4} + 5 ));11
$point;$lat_p;$lon_p;${dir_name}_${f_field[7]};${f_field[4]};$(( ${f_field[9]:0:4} + 5 ));12
EOF

fi

#********** Missing file *********

missing_file="${output_dir}/missing_file.txt"
if [[ ! -f $missing_file ]]; then

cat << EOF > $missing_file
1e+20
1e+20
1e+20
1e+20
1e+20
1e+20
1e+20
1e+20
1e+20
1e+20
1e+20
1e+20
EOF

fi

#******** Input files ( var=sos, sal or zos ) *******

case $var in
tos)
file_t="${input_dir}/${f_field[0]}_${var}_${f_field[2]}_${f_field[3]}_${f_field[4]}_${f_field[5]}_${f_field[6]}_${f_field[7]}_${f_field[8]}_${f_field[9]}_${f_field[10]}"
;;
sos)
file_t="$( find ${input_dir} -name ${f_field[0]}_sos_*_${f_field[3]}_${f_field[4]}_*_${f_field[6]}_${f_field[7]}_${f_field[8]}_${f_field[9]}_${f_field[10]} )"
;;
zos)
file_t="$( find ${input_dir} -name ${f_field[0]}_zos_*_${f_field[3]}_${f_field[4]}_*_${f_field[6]}_${f_field[7]}_${f_field[8]}_${f_field[9]}_${f_field[10]} )"
;;
esac

#====== POINT is B01, B02, B03, P01, P02, P03 ... ==========
file_out="${output_dir}/${f_field[0]}_${var}_alldecades_allmodels_allpoints.csv"

#mkdir ${output_root_dir}/${dir_name} || echo "Directory already exists"

#******** Head CSV file creation **********

if [[ $i -eq 1 ]]; then
	echo  "# Statistical Estimator= Delta Mean"                                                                                 >  $file_out
	echo  "# Statistical time range= monthly"                                                                                   >> $file_out
	echo  "# Field= $var_field"                                                                                                 >> $file_out
	echo  "# Missing value= 1e+20"                                                                                              >> $file_out
	echo  "# Grid point ; latitude (°N) ; longitude (°E) ; simulation ; RCP ; Decade (center year) ; Month ; delta $var_den"    >> $file_out
fi

#******************************************

tmp_var=$( mktemp ${output_dir}/var.XXXXX )

#=============== Data extraction from netCDF files ========================

# Two models has to be excluded for sea surface level. The reason is that they 
# foresee a reduction of sea surface height.
# The models are: AdriaClim-IPSL-CM5A-MR_LMD-LMDZ4NEMOMED8 and EC-EARTH_CLMcom-GUF-CCLM5-0-9-NEMOMED12-3-6


if [[ -f $file_t &&  $file_t != */AdriaClim-IPSL-CM5A-MR_LMD-LMDZ4NEMOMED8/*_zos_*rcp85*  &&  $file_t != */EC-EARTH_CLMcom-GUF-CCLM5-0-9-NEMOMED12-3-6/*_zos_*rcp85*  ]]; then
	cdo -outputf,%2.4g,1  -selindexbox,$(( ind_x + 1 )),$(( ind_x + 1 )),$(( ind_y + 1 )),$(( ind_y + 1 ))  -selname,${var}_mean  $file_t > $tmp_var  
else
	cat $missing_file  > $tmp_var
fi

#==========================================================================

paste -d ";"  $months_file    $tmp_var  >> $file_out   # output file already contains header

rm  $tmp_var $months_file $missing_file

done < initialization_file.txt

done    # end of loop on grid points (B01, B02 ecc)

done
