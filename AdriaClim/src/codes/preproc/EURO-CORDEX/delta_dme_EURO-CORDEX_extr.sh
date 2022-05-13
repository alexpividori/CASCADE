#!/bin/bash

#******************************************************************************
#
# DESCRIPTION:       This bash script is used to create a series of CSV (semicolon separated) output files
#                    containing the median of the 5 model EURO-CORDEX monthly median-differences
#                    for the desired atmospheric physical dimensions. 
#                    WARNING: Due to some corrupted original netDCF file (listed inside 'corrupted_files' text document),
#                    the data could be not available for some specidic models and/or decades.
#                    In that case the median has been calculated with the only not-missing values.  
#
# EXTERNAL CALLS:   none.
#
# EXTERNAL FILES:   - input NetCDF downloaded from EURO-CORDEX official site and 
#                     edited by cdo command line operators.
#                   - The initialization txt file contains the whole set of dmm or
#                     dme edited files only for Temperatures. The salinity and 
#                     zos ones will be obtained from the temperature ones
#
# DEVELOPER:         Alex Pividori (alex.pividori@arpa.fvg.it)
#                    ARPA FVG - S.O.C. Stato dell'Ambiente - CRMA
#                    "AdriaClim" Interreg IT-HR project
#
# SOFTWARE VERSION: Bash 4.2.46(2)-release
#                   CDO version 1.9.8
#
# CREATION DATE:    29/03/2022
#
# MODIFICATIONS:    29/03/2022 --> Creation date 
#                   30/03/2022 --> Working version
#                   31/03/2022 --> Missing value handle version
#
# VERSION:          0.1.
#
#******************************************************************************

#=============================================================================
#                              MEDIAN VERSION
#=============================================================================


Help()
{
   # Display Help
   echo -e "\nHelp flags description:"
   echo
   echo "Syntax: scriptTemplate [-g|h|t|v|V]"
   echo "options:"
   echo "g     Print the developer credits"
   echo "h     Print this Help."
   echo "i     Print software description"
   echo "v     Print variables description"
   echo
}

Developer()
{
   # Display developer credits
   echo -e "\nDEVELOPER:         Alex Pividori (alex.pividori@arpa.fvg.it)"
   echo    "                   ARPA FVG - S.O.C. Stato dell'Ambiente - CRMA"
   echo -e "                   \"AdriaClim\" Interreg IT-HR project\n"
}

software_description()
{
   # Display software_description
echo -e "\n\tThis bash script is used to create a series of CSV (semicolon separated) output files
\tcontaining the median of the 5 model EURO-CORDEX monthly median-differences
\tfor the desired atmospheric physical dimensions.
\tWARNING: Due to some corrupted original netDCF file (listed inside 'corrupted_files' text document),
\tthe data could be not available for some specidic models and/or decades.
\tIn that case the median has been calculated with the only not-missing values.\n"

}

physical_fields()
{

echo -e "\tuas= Eastward Near- Surface Wind Velocity               
\tvas= Northward Near- Surface Wind Velocity              
\tps= Surface Air Pressure              
\trsds= Surface Downwelling Shortwave Radiation          
\ttas= Near-Surface Air Temperature                         
\thuss= Near-Surface Specific Humidity                         
\tcc= Cloud Cover                                              
\tpr= Precipitation"                                             

echo -e "************************************************\n
The 'cc' field is setted equal to 0 cause that variable is not available on the OSMER web-page ('https://www.osmer.fvg.it/')\n
WARNING: Due to the presence of some corrupted original netCDF files (listed in 'corrupted_files' text document), some median
could be calculated with a number of models less that the total ensamble (5).\n"

}

#=============================== Help and information console ================================

while getopts ":ghiv" option; do
   case $option in
      g) # display developer credits
         Developer
         exit;;
      h) # display Help
         Help
         exit;;
      i) # Print software description
         echo -e "\nSoftware description:\n"
	 software_description
         exit;;
      v) # Print variables description
         echo -e "\nThe physical fields analyzed are the following:\n"
         physical_fields
         exit;;
      *) # incorrect option
         echo -e "\nError: Invalid option\n"
         Help
         exit;;
   esac
done

#****** Module loading ********

module load cdo/1.9.8/intel/19.1.1.217-prtc7xl

# WARNING: The following lat/lon indexes starts from 0 (like ncview convention)
# but the cdo -selindexbox operator instead starts from 1, so it is necessary
# to subtract 1 to have the corresponding index value

point="E01"
ind_x=12          # lon/lat indexes strarting from 0 (ncview convention)
ind_y=1
lat_p=45.65
lon_p=13.50

for RCP in "26" "45" "85"
do


    for year_middle in  2030 2040 2050 2060 2070 2080 2090
    do

#for model_dir in  "1_HadGEM2-ES_RACMO22E" "2_MPI-ESM-LR_REMO2009" "3_EC-EARTH_CCLM4-8-17" "4_EC-EARTH_RACMO22E" "5_EC-EARTH_RCA4" 
year_in=$(( year_middle - 5  ))
year_fin=$(( year_middle + 5  ))

#******* Root directory of the netCDF input files 
 input_root_dir="/lustre/arpa/AdriaClim/data/EURO-CORDEX/FVG"
output_root_dir="/lustre/arpa/AdriaClim/data/EURO-CORDEX/FVG"    # for simplicity I decide to put the output files in the  
													 # first model directory
#==============================================================================
# the initialization file contains by default the names of the dme edited files
# so the files containing the median differences
#==============================================================================


output_dir="${output_root_dir}/1_HadGEM2-ES_RACMO22E/postproc/monthly"

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

#********************* cc data 0 ***************

cc_file="${output_dir}/cc_file.txt"
cat << EOF > $cc_file
0
0
0
0
0
0
0
0
0
0
0
0
EOF

#******** Input files ( uas, vas, ps, rsds, tas, huss, cc, pr ) *******

for var in "uas" "vas" "ps" "rsds" "tas" "huss" "cc" "pr" 
do


        tmp_var=$(  mktemp ${output_dir}/${var}_${RCP}_${year_in}_${year_fin}_XXXXX.csv )
        tmp_file=$(   mktemp ${output_dir}/tmp_file_XXXXX.csv )
   
	for model_dir in "1_HadGEM2-ES_RACMO22E" "2_MPI-ESM-LR_REMO2009" "3_EC-EARTH_CCLM4-8-17" "4_EC-EARTH_RACMO22E" "5_EC-EARTH_RCA4" 
	do

	file_name="dme_${var}_${model_dir#?_}_rcp${RCP}_mon_future_${year_in}01_${year_fin}12.nc"
	input_dir="${input_root_dir}/${model_dir}/postproc/monthly"

	file_in="${input_dir}/${file_name}"
             
	if [[ -f $file_in ]] && [[ ! "$var" == "cc" ]]; then
        cdo -outputf,%2.4g,1  -selindexbox,$(( ind_x + 1 )),$(( ind_x + 1 )),$(( ind_y + 1 )),$(( ind_y + 1 ))  -selname,${var}_med  $file_in > $tmp_file

	elif [[ "$var" == "cc" ]]; then
        cat $cc_file > $tmp_var
        break

	else
        cat "$missing_file"  > "$tmp_file"
	fi

#********************** Pasting on the right the new column ****************************

        if [[ -s $tmp_var ]]; then
        paste -d ";"  $tmp_var  $tmp_file > ${output_dir}/tmp.txt ; cat ${output_dir}/tmp.txt > $tmp_var ; rm ${output_dir}/tmp.txt
        else
	cat $tmp_file > $tmp_var
        fi

#***************************************************************************************

	done  # end of cycle on models

#==================== Median Calculus =========================

med_var="${output_dir}/median_${var}.csv"

while IFS=$'\n' read line
do
     
	IFS=';' read -a array <<< "$line"

               n_mod=${#array[@]}
	       # before the median calculus, I remove the missing values because sort -n is not able to handle 1e+20
               for (( i=0; i < $n_mod ; i++ )); do
		         if [[ "${array[$i]}" == "1e+20"  ]]; then unset array[$i]  ; fi        
               done

        IFS=$'\n'
        sorted=( $( printf "%s\n" "${array[@]}" | sort -n  ) );
	median=$(awk '{arr[NR]=$1} END {if (NR%2==1) print arr[(NR+1)/2]; else print (arr[NR/2]+arr[NR/2+1])/2}'  <<< "${sorted[*]}")
        echo $median >> $med_var
        unset array IFS sorted

done < $tmp_var

#============== Temporary files remotion =======================

rm $tmp_var $tmp_file || { echo "Is not possible to remove tmp files"; exit ;}

done          # end of cycle on variables

#====== POINT is E01

file_out="${output_dir}/dme_${point}_rcp${RCP}_mon_${year_in}01_${year_fin}12.csv"

#******** Head CSV file creation **********

echo  "# grid point= $point ( $lat_p N, $lon_p E )"                             >  $file_out
echo  "# rcp= $RCP"                                                             >> $file_out
echo  "# Statistical Estimator= Median of Delta Medians"                        >> $file_out
echo  "# Missing value= 1e+20"                                                  >> $file_out
echo  "# Decade= $(( year_middle - 5 ))-$(( year_middle + 5 ))"                 >> $file_out
echo  "#"                                                                       >> $file_out
echo  "# Description of fields:"                                                >> $file_out
echo  "# uas= Eastward Near- Surface Wind Velocity"                             >> $file_out
echo  "# vas= Northward Near- Surface Wind Velocity"                            >> $file_out
echo  "# ps= Surface Air Pressure"                                              >> $file_out
echo  "# rsds= Surface Downwelling Shortwave Radiation"                         >> $file_out
echo  "# tas= Near-Surface Air Temperature"                                     >> $file_out
echo  "# huss= Near-Surface Specific Humidity"                                  >> $file_out
echo  "# cc= Cloud Cover"                                                       >> $file_out
echo  "# pr= Precipitation"                                                     >> $file_out
echo  "#"                                                                       >> $file_out
echo  "# Month ; delta uas [m s-1] ; delta vas [m s-1] ; delta ps [Pa] ; delta rsds [W m-2] ; delta tas [°C] ; delta huss [kg kg-1] ; delta cc [0-1] ; delta pr [mm day-1]" >> $file_out

#==========================================================================

paste -d ";"  $months_file  ${output_dir}/median_uas.csv ${output_dir}/median_vas.csv                \
              ${output_dir}/median_ps.csv ${output_dir}/median_rsds.csv ${output_dir}/median_tas.csv \
              ${output_dir}/median_huss.csv ${output_dir}/median_cc.csv ${output_dir}/median_pr.csv      >> $file_out   # output file already contains header

rm  $months_file $missing_file $cc_file  ${output_dir}/median_uas.csv ${output_dir}/median_vas.csv   \
    ${output_dir}/median_ps.csv ${output_dir}/median_rsds.csv ${output_dir}/median_tas.csv           \
    ${output_dir}/median_huss.csv ${output_dir}/median_cc.csv ${output_dir}/median_pr.csv 


done   # end of cycle on different decades (2030, 2040 etc.)
done   # end of cycle on different RCP's
