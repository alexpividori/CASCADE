#!/bin/bash

#******************************************************************************
#
# DESCRIPTION:       This bash script is used to create a CSV output file
#                    containing the delta sea surface temperature, salinity
#                    and height for future scenario decades. The files is used 
#                    by SHYFEM model to simulate the pilot area. Each line
#                    contains the value for one month: from January to December.
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
# CREATION DATE:    11/03/2022
#
# MODIFICATIONS:    11/03/2022 --> Creation date 
#
# VERSION:          0.1.
#
#******************************************************************************

#=============================================================================
#                              MEAN VERSION
#=============================================================================

#****** Module loading ********

module load cdo/1.9.8/intel/19.1.1.217-prtc7xl

# WARNING: The following lat/lon indexes starts from 0
# but the cdo -selindexbox operator instead starts from 1, so it is necessary
# to subtract 1 to have the corresponding index value

for point in B01 B02 B03
do

case $point in 
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


IFS='_'  read  -a f_field <<< "$file_name"
f_field[0]="dmm"                                 # the monthly mean value changes the prefix from dme to dmm

echo -e "\tI'm executing ${input_dir}/${f_field[0]}_tos_${f_field[2]}_${f_field[3]}_${f_field[4]}_${f_field[5]}_${f_field[6]}_${f_field[7]}_${f_field[8]}_${f_field[9]}_${f_field[10]}"

input_dir="${input_root_dir}/${dir_name}"
output_dir="${output_root_dir}/${dir_name}"

#******** Months file *********

months_file="${output_dir}/months_file.txt"
if [[ ! -f $months_file ]]; then

cat << EOF > $months_file
01
02
03
04
05
06
07
08
09
10
11
12
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

#******** Input files ( temp, sal and zos ) *******
file_t="${input_dir}/${f_field[0]}_tos_${f_field[2]}_${f_field[3]}_${f_field[4]}_${f_field[5]}_${f_field[6]}_${f_field[7]}_${f_field[8]}_${f_field[9]}_${f_field[10]}"
file_s="$( find ${input_dir} -name ${f_field[0]}_sos_*_${f_field[3]}_${f_field[4]}_*_${f_field[6]}_${f_field[7]}_${f_field[8]}_${f_field[9]}_${f_field[10]} )"
file_z="$( find ${input_dir} -name ${f_field[0]}_zos_*_${f_field[3]}_${f_field[4]}_*_${f_field[6]}_${f_field[7]}_${f_field[8]}_${f_field[9]}_${f_field[10]} )"

#====== POINT is B01, B02 or B03
file_out="${output_dir}/${f_field[0]}_${point}_${f_field[2]}_${f_field[3]}_${f_field[4]}_${f_field[5]}_\
${f_field[6]}_${f_field[7]}_${f_field[8]}_${f_field[9]}_${f_field[10]:0:6}.csv"

#mkdir ${output_root_dir}/${dir_name} || echo "Directory already exists"

#******** Head CSV file creation **********

echo  "# grid point= $point ( $lat_p N, $lon_p E )"                             >  $file_out
echo  "# Simulation= ${f_field[3]}_${f_field[4]}_${f_field[6]}_${f_field[7]}"   >> $file_out
echo  "# Statistical Estimator= Delta Mean"                                     >> $file_out
echo  "# Missing value= 1e+20"                                                  >> $file_out
echo  "# Decade= ${f_field[9]:0:4}-${f_field[10]:0:4}"                          >> $file_out
echo  "# Month ; delta T [°C] ; delta S [PSU] ; delta z [m]"                    >> $file_out

#******************************************

tmp_temp=$( mktemp ${output_dir}/temp.XXXXX )
tmp_sal=$(  mktemp ${output_dir}/sal.XXXXX  )
tmp_zos=$(  mktemp ${output_dir}/zos.XXXXX  )

#=============== Data extraction from netCDF files ========================

# Two models has to be excluded for sea surface level. The reason is that they 
# foresee a reduction of sea surface height.
# The models are: AdriaClim-IPSL-CM5A-MR_LMD-LMDZ4NEMOMED8 and EC-EARTH_CLMcom-GUF-CCLM5-0-9-NEMOMED12-3-6

if [[ -f $file_t ]]; then
	cdo -outputf,%2.4g,1  -selindexbox,$(( ind_x + 1 )),$(( ind_x + 1 )),$(( ind_y + 1 )),$(( ind_y + 1 ))  -selname,tos_mean  $file_t > $tmp_temp  
else
	cat $missing_file  > $tmp_temp
fi

if [[ -f $file_s ]]; then
	cdo -outputf,%2.4g,1  -selindexbox,$(( ind_x + 1 )),$(( ind_x + 1 )),$(( ind_y + 1 )),$(( ind_y + 1 ))  -selname,sos_mean  $file_s > $tmp_sal  
else
	cat $missing_file  > $tmp_sal
fi

if [[ -f $file_z &&  $file_z != */AdriaClim-IPSL-CM5A-MR_LMD-LMDZ4NEMOMED8/*_zos_*rcp85*  &&  $file_z != */EC-EARTH_CLMcom-GUF-CCLM5-0-9-NEMOMED12-3-6/*_zos_*rcp85*  ]]; then
	cdo -outputf,%2.4g,1  -selindexbox,$(( ind_x + 1 )),$(( ind_x + 1 )),$(( ind_y + 1 )),$(( ind_y + 1 ))  -selname,zos_mean  $file_z > $tmp_zos   
else
	cat $missing_file  > $tmp_zos
fi

#==========================================================================

paste -d ";"  $months_file   $tmp_temp  $tmp_sal  $tmp_zos  >> $file_out   # output file already contains header

rm  $tmp_temp  $tmp_sal  $tmp_zos $months_file $missing_file

done < initialization_file.txt

done    # end of loop on grid points (B01, B02 ecc)






