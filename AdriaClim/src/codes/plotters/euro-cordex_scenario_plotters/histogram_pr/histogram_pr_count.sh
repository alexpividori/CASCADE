#!/bin/bash

#==== Module laod ====

module purge
module load  cdo/1.9.8/intel/19.1.1.217-prtc7xl      &>/dev/null	
module load  python/3.8.1/gcc/8.2.0-mbzms7w          &>/dev/null
module load  miniconda3/4.7.12.1/gcc/8.2.0-5g55eu6   &>/dev/null

field="pr"

while read  point_n
do

case $point_n in
E01)
lat_i=1
lon_i=12
;;
E02)
lat_i=5
lon_i=8
;;
E03)
lat_i=8
lon_i=8
;;
E04)
lat_i=7
lon_i=15
;;
*)
echo -e "\tPoint not found"
exit
;;
esac


bin_range=( 0 1 3 5 10 20 30 50 70 100 150 200 250 )

n_bin=$(( ${#bin_range[@]} - 1 ))


declare -a hist_tot_count

input_arc_dir="/lustre/arpa/AdriaClim/data/EURO-CORDEX/FVG"
output_arc_dir="/lustre/arpa/AdriaClim/src/codes/plotters/euro-cordex_scenario_plotters/histogram_pr"

#=============== Cycles on RCP =================

for RCP in "26" "45" "85"
do

for year_middle in 2015 2030 2040 2050 2060 2070 2080 2090
do

year_in=$((  year_middle - 5 ))
year_fin=$(( year_middle + 5 ))

for model_dir in "1_HadGEM2-ES_RACMO22E" "2_MPI-ESM-LR_REMO2009" "3_EC-EARTH_CCLM4-8-17" "4_EC-EARTH_RACMO22E" "5_EC-EARTH_RCA4"
do

model_name="${model_dir#?_}"
file_name="pr_${model_name}_rcp${RCP}_future.nc"
input_file="$input_arc_dir/$model_dir/$file_name"

read -a hist_count <<< $( cdo  --no_history -outputf,%2.4g,1  -histcount$( printf ',%s' ${bin_range[@]} )  \
                                   -selyear,${year_in}/${year_fin} -selindexbox,$(( lon_i + 1 )),$(( lon_i + 1 )),$(( lat_i + 1 )),$(( lat_i + 1 ))  $input_file || \
                                   { echo "WARNING: corrupted or inesistent file"; continue; } )


for i in $( seq 0 $(( n_bin -1 )) ) 
do
      let hist_tot_count[$i]+=${hist_count[$i]}
done

done # end of model  cycle

	printf "%s\n" ${bin_range[@]}      > ${output_arc_dir}/histogram_tmp_bins.txt
	printf "%s\n" ${hist_tot_count[@]} > ${output_arc_dir}/histogram_tmp_file.txt

	paste -d ";"  ${output_arc_dir}/histogram_tmp_bins.txt  ${output_arc_dir}/histogram_tmp_file.txt > ${output_arc_dir}/histogram_tmp_data.txt

	python  histogram_pr.py  $point_n ${output_arc_dir}/histogram_tmp_data.txt   $RCP $year_in $year_fin $field

	rm ${output_arc_dir}/histogram_tmp_bins.txt  ${output_arc_dir}/histogram_tmp_file.txt ${output_arc_dir}/histogram_tmp_data.txt
	unset hist_tot_count

done # end of decade cycle 

done # end of RCP cyle

done < initialization_file.txt
