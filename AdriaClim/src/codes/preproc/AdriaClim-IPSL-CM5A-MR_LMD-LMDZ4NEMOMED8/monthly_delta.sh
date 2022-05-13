#!/bin/bash

#****************************************************************************
#
# DEVELOPER:      Alex Pividori (alex.pividori@arpa.fvg.it)
#                 ARPA FVG - S.O.C. Stato dell'Ambiente
#                 "AdriaClim" Interreg IT-HR project
#
# CREATION DATE:  28/01/2022
#
#
# cdo Version:    1.9.8
# bash Version:   4.2.46(2)-release  
#
#*****************************************************************************
#                                 DESCRIPTION
#******************************************************************************
#
# This bash script is used to realize the delta field between two decades.
# The month mean of a multi year file is subtracted from another month multi year mean.
# 
#   output = decade(2025-2035) - decade(2010-2020)
#
# Where decade() are netCDF files obtained after a monhtly multiyear mean. For example:
# the january time step of decade() contains the result of the mean of all Januaries 
# months from 2010 to 2020 etc. The decade interval of the first file goes from -5 years 
# to +5 years of the year we are dealing with.
#
#
#  output= ( month mean 2025-2035 ) - ( month mean 2010-2020 ) 
#
# cdo realize these by the two operators: -ymonsub  and  -ymonmean 
#
#  output= ( -ymonmean file_2025-2035 ) - ( -ymonmean file_2010-2020 )
#
# Using cdo chaining sintax it becomes:
#
# cdo -ymonsub -ymonmean file_2025-2035 -ymonmean file_2010-2020  output 
#
# The files have to be selected from a starting year to an ending one with the command
# 
#      -selyear   and in our case it becomes -selyear,2010/2020   
#
#==================================================================================
#
# the resulting precess becomes:
#
#     cdo -ymonsub -ymonmean -selyear,2025/2035 input1 -ymonmean -selyear,2010/2020 input1 output
# 
# The same is realized with the median
#
#==================================================================================
#
# With cdo some important statistical values like: minimum, maximum, 25th and 75th percentile
# has been calculated and merged in a single .nc file indicated with the sdim prefix
# that mean 'statistical dimensions'.
#
#**********************************************************************************

  module list 2>&1 | grep "cdo" 1>/dev/null ; cdo_load=$?
  if [[ $cdo_load -ne 0 ]]; then     # if the module is not loaded, it will be loaded
        	module load cdo/1.9.8/intel/19.1.1.217-prtc7xl   &>/dev/null 
  fi

file_list_name="scenario_file_list.txt"

file_N=`sed '/^$/d' $file_list_name  | wc -l`  # eliminate void lines
i=1

#================================ Files cicle =====================================

while read scenario_file
do
     sub_scenario_file=${scenario_file%_??????_??????.nc}  # file name without starting and ending dates. The substring removed is: '_YYYYMM_YYYYMM.nc'
                                                           # scenario_file file name without prefix
     
     printf "File: ($i/$file_N)"

     #*************** Decades cycle ***************
     for year in 2025 2035         # inferior limits of the decades considered
     do
             year_fin=$(( year + 10 ))   # we take one decade in count to realize the mean
             year_middle=$(( year + 5 ))             
      
             field=`   cdo -showname    edit_$scenario_file 2> /dev/null`
             field=${field#' '}                                              # the returned word by cdo is prefixed by a space " "
             std_name=`cdo -showstdname edit_$scenario_file 2> /dev/null`    # standard name will be modified. The stderr contains cdo informations             
             std_name=${std_name#' '}                                        # the returned word by cdo is prefixed by a space " "                              

             if [ -f edit_$scenario_file ]; then
                     echo "The file \"edit_$scenario_file\" exists and the process will be launched right now:"

#=========================================================================================================
#                          DELTA between scenario decade and 2010/2020 decade
#=========================================================================================================

                     #************** Mean ************
                 cdo -chname,${field},${field}_mean -setmissval,1.e+20  -setattribute,$field@standard_name="difference_between_${std_name}_monthly_means"    -setyear,$year_middle              \
                     -ymonsub                                                                                                                                                 \
                     -ymonmean     -selyear,${year}/${year_fin}     edit_${scenario_file}                                                                                     \
                     -ymonmean     -selyear,2010/2020               edit_${scenario_file}                                                                                     \
                      dmm_${sub_scenario_file}_${year}01_${year_fin}12.nc 2>/dev/null ||                                                                                          \
                      { echo "WARNING: Something has gone wrong in the cdo mean operation process with edit_${scenario_file} in the period from $year to $year_fin."; continue ; }
            
                     #************* Median (50th percentile) ***********
                 cdo -chname,${field},${field}_med  -setmissval,1.e+20   -setattribute,$field@standard_name="difference_between_${std_name}_monthly_medians"  -setyear,$year_middle  -ymonsub    \
                     -ymonpctl,50  -selyear,${year}/${year_fin}  edit_${scenario_file} -ymonmin -selyear,${year}/${year_fin} edit_${scenario_file} \
                                                                                       -ymonmax -selyear,${year}/${year_fin} edit_${scenario_file} \
                     -ymonpctl,50  -selyear,2010/2020            edit_${scenario_file} -ymonmin -selyear,2010/2020           edit_${scenario_file} \
                                                                                       -ymonmax -selyear,2010/2020           edit_${scenario_file} \
                     dme_${sub_scenario_file}_${year}01_${year_fin}12.nc  2>/dev/null ||                                                               \
                     { echo "WARNING: Something has gone wrong with the cdo median operation processes with edit_${scenario_file} in the period from $year to $year_fin."; continue ; }


#=================================================================================================================================================
#                   Statistical indicators of scanario selected decade: Min, Max, Standard Deviation1, 25th and 75th percentiles
#=================================================================================================================================================

                     #*********** Min ************  
                 cdo -chname,${field},${field}_min    -setattribute,$field@standard_name="minimum_${std_name}"  -setyear,$year_middle                                          \
                     -ymonmin                         -selyear,${year}/${year_fin}  edit_${scenario_file}                                                                      \
                      min_${sub_scenario_file}_${year}01_${year_fin}12.nc 2>/dev/null ||                                                                                       \
                      { echo "WARNING: Something has gone wrong in the cdo mean operation process with edit_${scenario_file} in the period from $year to $year_fin."; continue ; }

                     #*********** Max ************
                 cdo -chname,${field},${field}_max    -setattribute,$field@standard_name="maximum_${std_name}"            -setyear,$year_middle                                \
                     -ymonmax                         -selyear,${year}/${year_fin}  edit_${scenario_file}                                                                      \
                      max_${sub_scenario_file}_${year}01_${year_fin}12.nc 2>/dev/null ||                                                                                       \
                     { echo "WARNING: Something has gone wrong in the cdo median operations process with edit_${scenario_file} in the period from $year to $year_fin."; continue ; }

                     #*********** Mean ************
                 cdo -chname,${field},${field}_mean   -setattribute,$field@standard_name="mean_${std_name}"            -setyear,$year_middle                                   \
                     -ymonmean                        -selyear,${year}/${year_fin}  edit_${scenario_file}                                                                      \
                      mean_${sub_scenario_file}_${year}01_${year_fin}12.nc 2>/dev/null ||                                                                                      \
                     { echo "WARNING: Something has gone wrong in the cdo median operations process with edit_${scenario_file} in the period from $year to $year_fin."; continue ; }

                     #*********** Median ************
                 cdo -chname,${field},${field}_med    -setattribute,$field@standard_name="median_of_${std_name}"   -setyear,$year_middle                                       \
                     -ymonpctl,50                     -selyear,${year}/${year_fin}  edit_${scenario_file}     -ymonmin    -selyear,${year}/${year_fin} edit_${scenario_file}   \
                                                                                                              -ymonmax    -selyear,${year}/${year_fin} edit_${scenario_file}   \
                      p50_${sub_scenario_file}_${year}01_${year_fin}12.nc 2>/dev/null ||                                                                                       \
                     { echo "WARNING: Something has gone wrong in the cdo p25 operation process with edit_${scenario_file} in the period from $year to $year_fin."; continue ; }

                     #*********** p25 ************
                 cdo -chname,${field},${field}_p25    -setattribute,$field@standard_name="25_percentile_of_${std_name}"   -setyear,$year_middle                                \
                     -ymonpctl,25                     -selyear,${year}/${year_fin}  edit_${scenario_file}     -ymonmin    -selyear,${year}/${year_fin} edit_${scenario_file}   \
                                                                                                              -ymonmax    -selyear,${year}/${year_fin} edit_${scenario_file}   \
                      p25_${sub_scenario_file}_${year}01_${year_fin}12.nc 2>/dev/null ||                                                                                       \
                     { echo "WARNING: Something has gone wrong in the cdo p25 operation process with edit_${scenario_file} in the period from $year to $year_fin."; continue ; }
                    
                     #*********** p75 ************
                 cdo -chname,${field},${field}_p75    -setattribute,$field@standard_name="75_percentile_of_${std_name}"   -setyear,$year_middle                                \
                     -ymonpctl,75                     -selyear,${year}/${year_fin}  edit_${scenario_file}     -ymonmin    -selyear,${year}/${year_fin} edit_${scenario_file}   \
                                                                                                              -ymonmax    -selyear,${year}/${year_fin} edit_${scenario_file}   \
                      p75_${sub_scenario_file}_${year}01_${year_fin}12.nc 2>/dev/null ||                                                                                       \
                     { echo "WARNING: Something has gone wrong in the cdo p75 operation process with edit_${scenario_file} in the period from $year to $year_fin."; continue ; }

#=================================================================================================================================================
#                                                   Merging statistical dimensions
#=================================================================================================================================================

                 cdo -setmissval,1.e+20   -merge       min_${sub_scenario_file}_${year}01_${year_fin}12.nc  max_${sub_scenario_file}_${year}01_${year_fin}12.nc  \
                                  p25_${sub_scenario_file}_${year}01_${year_fin}12.nc  p75_${sub_scenario_file}_${year}01_${year_fin}12.nc  \
                                  p50_${sub_scenario_file}_${year}01_${year_fin}12.nc  mean_${sub_scenario_file}_${year}01_${year_fin}12.nc \
                                  sdim_${sub_scenario_file}_${year}01_${year_fin}12.nc   2>/dev/null  &&                                \
                                                                                                                                    \
                 rm               min_${sub_scenario_file}_${year}01_${year_fin}12.nc  max_${sub_scenario_file}_${year}01_${year_fin}12.nc  \
                                  p25_${sub_scenario_file}_${year}01_${year_fin}12.nc  p75_${sub_scenario_file}_${year}01_${year_fin}12.nc  \
                                  p50_${sub_scenario_file}_${year}01_${year_fin}12.nc  mean_${sub_scenario_file}_${year}01_${year_fin}12.nc \
                                  || { echo "WARNING: Something has gone wrong in cdo merging process or remotion with ###_${sub_scenario_file}_${year}01_${year_fin}12.nc"; continue ; }
 
#=================================================================================================================================================

	             echo -e "\tThe process ended correctly"
	             echo -e "\tThe output files are:\"dmm_${sub_scenario_file}_${year}01_${year_fin}12.nc\""
                     echo -e "\t                     \"dme_${sub_scenario_file}_${year}01_${year_fin}12.nc\""
                     echo -e "\t                     \"sdim_${sub_scenario_file}_${year}01_${year_fin}12.nc\""

             else
                     echo "The file \"edit_$scenario_file\" doesn't exist"
       
             fi

     done
(( i++ ))
done < $file_list_name

