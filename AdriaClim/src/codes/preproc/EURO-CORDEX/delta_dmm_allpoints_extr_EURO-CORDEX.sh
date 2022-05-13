#!/bin/bash

#******************************************************************************
#
# DESCRIPTION:       This bash script is used to create a CSV output file
#                    containing the delta almospheric uas,vas,ps,rsds,tas,huss,cc,pr
#                    hfls,hfss,ps,rlds,ts for future scenario decades. Each line
#                    contains the value for one month: from January to December.
#                    The files realized are in two versions: averages and medians.
#
# EXTERNAL CALLS:   none.
#
# EXTERNAL FILES: - input NetCDF downloaded from EURO-CORDEX official site
#
# DEVELOPER:         Alex Pividori (alex.pividori@arpa.fvg.it)
#                    ARPA FVG - S.O.C. Stato dell'Ambiente - CRMA
#                   "AdriaClim" Interreg IT-HR project
#
# SOFTWARE VERSION: Bash
#                   CDO version 1.9.8
#
# CREATION DATE:    22/04/2022
#
# MODIFICATIONS:    22/04/2022 --> Creation date 
#
# VERSION:          0.1.
#
#******************************************************************************

#=============================================================================
#                                 MEAN VERSION
#=============================================================================

#****** Module loading ********
module load cdo/1.9.8/intel/19.1.1.217-prtc7xl || { echo "cdo module can't be loaded" ; exit 1 ; }

# WARNING: The following lat/lon indexes starts from 0
# but the cdo -selindexbox operator instead starts from 1, so it is necessary
# to sum 1 to have the corresponding index value

# ==================== LOOPS on physical variable =========================
for var in uas vas ts tas rsds rlds ps pr huss hfss hfls tasmax tasmin evspsbl
do

#***** varibale denomination **********
case $var in
uas)
var_den="Eastward Near-Surface Wind Velocity [m s-1]"
;;
vas)
var_den="Northward Near-Surface Wind Velocity [m s-1]"
;;
ts)
var_den="Surface Temperature [K]"
;;
tas)
var_den="Near-Surface Air Temperature [K]"
;;
rsds)
var_den="Surface Downwelling Shortwave Radiation [W m-2]"
;;
rlds)
var_den="Surface Downwelling Longwave Radiation [W m-2]"
;;
ps)
var_den="Surface Air Pressure [Pa]"
;;
pr)
var_den="Precipitation [mm day-1]"
;;
huss)
var_den="Near-Surface Specific Humidity [kg kg-1]"
;;
hfss)
var_den="Surface Upward Sensible Heat Flux [W m-2]"
;;
hfls)
var_den="Surface Upward Latent Heat Flux [W m-2]"
;;
evspsbl)
var_den="Evaporation [kg m-2 s-1]"
;;
tasmax)
var_den="Daily Maximum Near-Surface Air Temperature [K]"
;;
tasmin)
var_den="Daily Minimum Near-Surface Air Temperature [K]"
;;
esac
#**************************************

i=0

for point in E01 E02 E03 E04
do

case $point in 
E01)
point="E01"
ind_x=12
ind_y=1
lat_p=45.65
lon_p=13.50
;;
E02)
point="E02"
ind_x=8
ind_y=5
lat_p=46.05
lon_p=13.10
;;
E03)
point="E03"
ind_x=8
ind_y=8
lat_p=46.35
lon_p=13.10
;;
E04)
point="E04"
ind_x=15
ind_y=7
lat_p=46.25
lon_p=13.80
;;
*)
     echo "Desired point $point is not in the list. Please insert another point label."
     continue
;;
esac

#******* Root directory of the netCDF input files 
input_root_dir="/lustre/arpa/AdriaClim/data/EURO-CORDEX/FVG"
output_root_dir="/lustre/arpa/AdriaClim/data/EURO-CORDEX/FVG"

#==============================================================================
# the initialization file contains by default the names of the dme edited files
# so the files containing the median differences
#==============================================================================

while  IFS='/'  read   dir_name  file_name
do

(( i++ ))

IFS='_'  read  -a f_field <<< "$file_name"
f_field[0]="dmm"                                       # this is the Mean value version so i have to change the file name prefix

echo -e "\tI'm executing $dir_name/${f_field[0]}_${var}_${f_field[2]}_${f_field[3]}_${f_field[4]}_${f_field[5]}_${f_field[6]}_${f_field[7]}_${f_field[8]} for $point point"

input_dir="${input_root_dir}/${dir_name}/postproc/monthly"
output_dir="${output_root_dir}"

#******** Months file *********
months_file="${output_dir}/months_file.txt"

if [[ ! -f $months_file ]]; then
cat << EOF > $months_file
$point;$lat_p;$lon_p;${dir_name#?_};${f_field[4]};$(( ${f_field[8]:0:4} - 5 ));01
$point;$lat_p;$lon_p;${dir_name#?_};${f_field[4]};$(( ${f_field[8]:0:4} - 5 ));02
$point;$lat_p;$lon_p;${dir_name#?_};${f_field[4]};$(( ${f_field[8]:0:4} - 5 ));03
$point;$lat_p;$lon_p;${dir_name#?_};${f_field[4]};$(( ${f_field[8]:0:4} - 5 ));04
$point;$lat_p;$lon_p;${dir_name#?_};${f_field[4]};$(( ${f_field[8]:0:4} - 5 ));05
$point;$lat_p;$lon_p;${dir_name#?_};${f_field[4]};$(( ${f_field[8]:0:4} - 5 ));06
$point;$lat_p;$lon_p;${dir_name#?_};${f_field[4]};$(( ${f_field[8]:0:4} - 5 ));07
$point;$lat_p;$lon_p;${dir_name#?_};${f_field[4]};$(( ${f_field[8]:0:4} - 5 ));08
$point;$lat_p;$lon_p;${dir_name#?_};${f_field[4]};$(( ${f_field[8]:0:4} - 5 ));09
$point;$lat_p;$lon_p;${dir_name#?_};${f_field[4]};$(( ${f_field[8]:0:4} - 5 ));10
$point;$lat_p;$lon_p;${dir_name#?_};${f_field[4]};$(( ${f_field[8]:0:4} - 5 ));11
$point;$lat_p;$lon_p;${dir_name#?_};${f_field[4]};$(( ${f_field[8]:0:4} - 5 ));12
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

#******** Input file *******

file_t="$( find ${input_dir} -name  ${f_field[0]}_${var}_*_${f_field[4]}_${f_field[5]}_${f_field[6]}_${f_field[7]}_${f_field[8]} )"

#====== POINTS are E01, E02, E03 and E04  ==========
file_out="${output_dir}/AdriaClim_GoT_allscenario_mean_${var}.csv"
echo "The file_t is: \"$file_t\""
#mkdir ${output_root_dir}/${dir_name} || echo "Directory already exists"

#******** Head CSV file creation **********

if [[ $i -eq 1 ]]; then
	echo  "# Statistical Estimator= Delta Mean"                                                                                          >  $file_out
	echo  "# Statistical time range= monthly"                                                                                            >> $file_out
	echo  "# Field= $var_den"                                                                                                            >> $file_out
	echo  "# Missing value= 1e+20"                                                                                                       >> $file_out
	echo  "# Grid point ; latitude (°N) ; longitude (°E) ; simulation ; RCP ; Decade (center year) ; Month ; delta $var [${var_den#*[}"  >> $file_out
fi

#******************************************

tmp_var=$( mktemp ${output_dir}/var.XXXXX )

#=============== Data extraction from netCDF files ========================

# Two models has to be excluded for sea surface level. The reason is that they 
# foresee a reduction of sea surface height.

if [[ -f $file_t  ]]; then
	cdo -outputf,%2.4g,1  -selindexbox,$(( ind_x + 1 )),$(( ind_x + 1 )),$(( ind_y + 1 )),$(( ind_y + 1 ))  -selname,${var}_mean  $file_t > $tmp_var  
else
	cat $missing_file  > $tmp_var
fi

#==========================================================================

paste -d ";"  $months_file    $tmp_var  >> $file_out   # output file already contains header

rm  $tmp_var $months_file 

done < initialization_file.txt

done    # end of loop on grid points (B01, B02 ecc)

done

rm $missing_file
