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
module purge
module load cdo/1.9.8/intel/19.1.1.217-prtc7xl

CDO_RESET_HISTORY=1
export CDO_RESET_HISTORY

for model_dir in "1_HadGEM2-ES_RACMO22E" # "2_MPI-ESM-LR_REMO2009" "3_EC-EARTH_CCLM4-8-17" "4_EC-EARTH_RACMO22E" "5_EC-EARTH_RCA4"
do

#===== In this case the input and output directories are the same ======
input_dir_name="/lustre/arpa/AdriaClim/data/EURO-CORDEX/FVG/${model_dir}/postproc/monthly"
  out_dir_name="/lustre/arpa/AdriaClim/data/EURO-CORDEX/FVG/${model_dir}/postproc/monthly"
      init_tmp="initialization_file.txt"

#****** exclude the historical files 
ls -p $input_dir_name | grep -v '/' | grep  -e "^pr_"  | grep "rcp"  > $init_tmp \
 || { echo "Something is gone wrong in the grep process OR the file list is void."; exit 1 ; }

echo "The initialization file containing file list has been created."

while read file_name
do

IFS='_' read  -a f_field <<< "$file_name"

	echo "I'm editating file: $file_name"

IFS='"' read  -a  old_std <<< $( cdo -showattribute,${f_field[0]}@standard_name  $input_dir_name/$file_name )
     
        #**** file names ****
        #              var_name     G_model       R_model          mon    
        hist_name="${f_field[0]}_${f_field[1]}_${f_field[2]}_${f_field[4]}_historical.nc"
	file_edm_name="edm_${file_name}"
        file_edmub_name="edmub_${file_name}"

	CDO_RESET_HISTORY=1	

        #**** Merged time creation: the output file will go from 1971-2100  
        cdo  --no_history  -mergetime  $input_dir_name/$hist_name  $input_dir_name/$file_name   $out_dir_name/$file_edm_name 

        CDO_RESET_HISTORY=1
        #**** The temporary file is necessary due to a bug into some chaining cdo commands 
        cdo  --no_history  -timselmean,150,0  -seldate,2010-01-01,2020-12-31  $input_dir_name/$file_name  $out_dir_name/tmp_$file_name

        CDO_RESET_HISTORY=1
        #**** Creation of edmub files by subtracting the 2010-2020 total mean
	cdo  --no_history  -setattribute,product="Monthly mean differences respect to 2010-2020 decade"                                                  \
                           -setattribute,${f_field[0]}@standard_name=delta_${old_std[1]}                                                                 \
                           -sub              $out_dir_name/$file_edm_name    $out_dir_name/tmp_$file_name    $out_dir_name/$file_edmub_name 
        
rm $out_dir_name/tmp_$file_name || { echo "Impossible to remore tmp_$file_name" ; exit 1 ; }

done < $init_tmp

echo "Monthly mean file creation for $model_dir has been finished"
rm $init_tmp

done
