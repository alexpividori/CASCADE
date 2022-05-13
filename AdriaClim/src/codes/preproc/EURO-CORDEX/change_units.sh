#!/bin/bash

#******************************************************************************
#
# DESCRIPTION:      This bash script has the aim to modify the global 
#                   attributes, remove history etc.
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

#********************************************************************

for model_dir in   "2_MPI-ESM-LR_REMO2009" "3_EC-EARTH_CCLM4-8-17" "4_EC-EARTH_RACMO22E" "5_EC-EARTH_RCA4"  # "1_HadGEM2-ES_RACMO22E"
do

dir_name="/lustre/arpa/AdriaClim/data/EURO-CORDEX/FVG/${model_dir}"
init_tmp="initialization_file.txt"

ls $dir_name -p | grep -v '/' |  grep  -e "pr_"  > $init_tmp || { echo "Something has gone wrong during the file list creation."; exit 1 ; }

echo "The initialization file containing file list has been created."

while read file_name
do


echo "I'm editating file: $file_name"

file_name_out="new_$file_name"

        CDO_RESET_HISTORY=1

	cdo  --no_history -setattribute,pr@units="mm day-1"  -mulc,86400   $dir_name/$file_name   $dir_name/$file_name_out        \
                           || { echo "ERROR in cdo operation"; continue ; }
	
	rm $dir_name/$file_name || { echo "Something has gone wrong in the deleting file phase"; continue ; }
	mv $dir_name/$file_name_out    $dir_name/$file_name	

done < $init_tmp

echo "$0 script is finished"
rm $init_tmp

done
