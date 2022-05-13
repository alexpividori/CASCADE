#!/bin/bash

#******************************************************************************
#
# DESCRIPTION:      This bash script has the aim to modify a daily input
#                   netCDF file and produce as an output the monthly version
#                   of the same
#
# EXTERNAL CALLS:   none.
#
# EXTERNAL FILES:   - input NetCDF data file 
#                    
#                     
# DEVELOPER:        Alex Pividori (alex.pividori@arpa.fvg.it)
#                   ARPA FVG - S.O.C. Stato dell'Ambiente - CRMA
#                   "AdriaClim" Interreg IT-HR project
#
# SOFTWARE VERSION: bash 4.2.46(2)-release
#                   cdo/1.9.8/intel/19.1.1.217-prtc7xl
#
# CREATION DATE:    17/03/2022
#
# MODIFICATIONS:    
#
# VERSION:          0.1.
#
#******************************************************************************

# load module
module load cdo/1.9.8/intel/19.1.1.217-prtc7xl
CDO_RESET_HISTORY=1
export CDO_RESET_HISTORY=1

for model_dir in "1_HadGEM2-ES_RACMO22E" "2_MPI-ESM-LR_REMO2009" "3_EC-EARTH_CCLM4-8-17" "4_EC-EARTH_RACMO22E" "5_EC-EARTH_RCA4"
do

input_dir_name="/lustre/arpa/AdriaClim/data/EURO-CORDEX/FVG/${model_dir}"
out_dir_name="/lustre/arpa/AdriaClim/data/EURO-CORDEX/FVG/${model_dir}/postproc/monthly"
init_tmp="initialization_file.txt"

# historical and future have different number field name
ls -p $input_dir_name | grep -v '/' | grep  -e "pr_"   > $init_tmp \
 || { echo "Something is gone wrong in the grep process OR the file list is void."; exit 1 ; }

echo "The initialization file containing file list has been created."

while read file_name
do

IFS='_' read  -a f_field <<< "$file_name"

if [[ "${f_field[3]}" == "historical.nc" ]]; then
	file_name_out="${f_field[0]}_${f_field[1]}_${f_field[2]}_mon_${f_field[3]}"
else
	file_name_out="${f_field[0]}_${f_field[1]}_${f_field[2]}_${f_field[3]}_mon_${f_field[4]}"
fi

	echo "I'm editating file: $file_name"
	
	CDO_RESET_HISTORY=1	

	cdo  --no_history  -setattribute,product="Monthly mean of model daily outputs" \
                           -setattribute,post_processing="INTERREG IT-HR AdriaClim by Regional Center for Environmental Modelling of ARPA FVG (PP11)" \
                            -monmean   $input_dir_name/$file_name    $out_dir_name/$file_name_out  || { echo "ERROR in cdo operation"; continue ; }


unset f_field

done < $init_tmp

echo "Monthly mean file creation for $model_dir has been finished"
rm $init_tmp

done
