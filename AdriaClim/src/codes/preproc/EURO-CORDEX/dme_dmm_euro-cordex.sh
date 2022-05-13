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
# CREATION DATE:    28/03/2022
#
# MODIFICATIONS:    
#
# VERSION:          0.1.
#
#******************************************************************************

# load module
module load cdo/1.9.8/intel/19.1.1.217-prtc7xl

CDO_RESET_HISTORY=1
export CDO_RESET_HISTORY

for model_dir in  "2_MPI-ESM-LR_REMO2009" "3_EC-EARTH_CCLM4-8-17" "4_EC-EARTH_RACMO22E" "5_EC-EARTH_RCA4" # "1_HadGEM2-ES_RACMO22E"
do

#===== In this case the input and output directories are the same ======
input_dir_name="/lustre/arpa/AdriaClim/data/EURO-CORDEX/FVG/${model_dir}/postproc/monthly"
  out_dir_name="/lustre/arpa/AdriaClim/data/EURO-CORDEX/FVG/${model_dir}/postproc/monthly"
      init_tmp="initialization_file.txt"

#****** exclude the historical files 
ls -p $input_dir_name | grep -v '/' | grep  -v 'edm_' | grep  -v 'edmub_' | grep  -e "_future.nc"  > $init_tmp \
 || { echo "Something is gone wrong in the grep process OR the file list is void."; exit 1 ; }

echo "The initialization file containing file list has been created."

while read file_name
do

IFS='_' read  -a f_field <<< "$file_name"


   for year_in in 2025 2035 2045 2055 2065 2075 2085        # inferior limits of the decades considered
   do
             year_fin=$(( year_in + 10 ))   # we take one decade in count to realize the mean
             year_middle=$(( year_in + 5 ))

             field=`   cdo -showname    $input_dir_name/$file_name 2> /dev/null`
             field=${field#' '}                                              # the returned word by cdo is prefixed by a space " "
             std_name=`cdo -showstdname $input_dir_name/$file_name 2> /dev/null`    # standard name will be modified. The stderr contains cdo informations
             std_name=${std_name#' '}                                        # the returned word by cdo is prefixed by a space " "

     
   if [ -f $input_dir_name/$file_name ]; then
                     echo "The file \"$file_name\" exists and the process for ${year_in}-${year_fin} decade will be launched right now:"

        #**** file names ****
        #                 
	file_dmm_name="dmm_${file_name%'.nc'}"
        file_dme_name="dme_${file_name%'.nc'}"

        CDO_RESET_HISTORY=1
        #**** dme (delta monthly median) file creation ****
        cdo --no_history   -setattribute,product="Differences between monthly medians respect to 2010-2020 decade"                                                             \
                     -chname,${field},${field}_med    -setattribute,${field}@standard_name="difference_between_${std_name}_monthly_median"  -setyear,$year_middle  -ymonsub    \
                     -ymonpctl,50  -selyear,${year_in}/${year_fin}  $input_dir_name/$file_name -ymonmin -selyear,${year_in}/${year_fin}  $input_dir_name/$file_name            \
                                                                                                     -ymonmax -selyear,${year_in}/${year_fin}  $input_dir_name/$file_name      \
                     -ymonpctl,50  -selyear,2010/2020            $input_dir_name/$file_name -ymonmin -selyear,2010/2020            $input_dir_name/$file_name                  \
                                                                                            -ymonmax -selyear,2010/2020            $input_dir_name/$file_name                  \
                     $out_dir_name/${file_dme_name}_${year_in}01_${year_fin}12.nc  2>/dev/null ||                                                                              \
                     { echo "WARNING: Something has gone wrong with the cdo median operation processes with ${file_name} in the period from $year_in to $year_fin."; continue ; }

         CDO_RESET_HISTORY=1
         #**** dmm (delta monthly means) file creation ****
         cdo --no_history   -setattribute,product="Differences between monthly means respect to 2010-2020 decade"                                                             \
                     -chname,${field},${field}_mean   -setattribute,${field}@standard_name="difference_between_${std_name}_monthly_means"    -setyear,$year_middle            \
                     -ymonsub                                                                                                                                                 \
                     -ymonmean     -selyear,${year_in}/${year_fin}     $input_dir_name/$file_name                                                                             \
                     -ymonmean     -selyear,2010/2020               $input_dir_name/$file_name                                                                                \
                      $out_dir_name/${file_dmm_name}_${year_in}01_${year_fin}12.nc  2>/dev/null ||                                                                            \
                      { echo "WARNING: Something has gone wrong with the cdo median operation processes with ${file_name} in the period from $year_in to $year_fin."; continue ; } 
 


   else
	continue
   fi

done               # decade loop end

done < $init_tmp   # future file end

echo "Monthly mean file creation for $model_dir has been finished"
rm $init_tmp

done
