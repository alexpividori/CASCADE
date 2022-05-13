#!/bin/bash

# l'unico scopo di questo script di prova è di veridicare che utilizzare gli edmub_ o gli edm_ o semplicemente gli *_mon_* originali
# è del tutto indifferent a causa dell'unica differenza dovuta ad una costante addizionata

module load cdo

 input_dir_name="./"
output_dir_name="./"

year_in=2025
year_middle=2030
year_fin=2035

field="evspsbl"
    

file_name="evspsbl_HadGEM2-ES_RACMO22E_rcp26_mon_future.nc"
file_dme_name="$file_name"

std_name=`cdo -showstdname $input_dir_name/$file_name 2> /dev/null`    # standard name will be modified. The stderr contains cdo informations
std_name=${std_name#' '}                                        # the returned word by cdo is prefixed by a space " "
echo $std_name
#========================================================================================================================================================================================

cdo   --no_history   -setattribute,product="Differences between monthly medians respect to 2010-2020 decade"                                                                   \
                     -chname,${field},${field}_med    -setattribute,${field}@standard_name="difference_between_${std_name}_monthly_median"  -setyear,$year_middle  -ymonsub    \
                     -ymonpctl,50  -selyear,${year_in}/${year_fin}  $input_dir_name/$file_name -ymonmin -selyear,${year_in}/${year_fin}  $input_dir_name/$file_name            \
                                                                                                     -ymonmax -selyear,${year_in}/${year_fin}  $input_dir_name/$file_name      \
                     -ymonpctl,50  -selyear,2010/2020            $input_dir_name/$file_name -ymonmin -selyear,2010/2020            $input_dir_name/$file_name                  \
                                                                                            -ymonmax -selyear,2010/2020            $input_dir_name/$file_name                  \
                     $output_dir_name/tmp_not-edmub_ciao.nc   ||                                                                          \
                     { echo "WARNING: Something has gone wrong with the cdo median operation processes with ${file_name} in the period from $year_in to $year_fin.";exit 1; }

