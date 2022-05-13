#!/bin/bash

#===============================================================
#                       Monthly version 
#===============================================================

#==== Module laod ====
module purge
module load  cdo/1.9.8/intel/19.1.1.217-prtc7xl      &>/dev/null	
module load  python/3.8.1/gcc/8.2.0-mbzms7w          &>/dev/null
module load  miniconda3/4.7.12.1/gcc/8.2.0-5g55eu6   &>/dev/null

field="pr"

while IFS=";"  read   point_n RCP year_middle_in
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
output_arc_dir="/lustre/arpa/AdriaClim/src/codes/plotters/euro-cordex_scenario_plotters/histogram_diff_pr"

#============= Cycle on months ============== from 1 to 12 =========
for month in $( seq 1 12 )
do

for year_middle in 2015 $year_middle_in       # the first cycle is necessary to extract the reference data decade, the second the future projection decade
do

year_in=$((  year_middle - 5 ))
year_fin=$(( year_middle + 5 ))

#============= Cycle on models ==============================
for model_dir in "1_HadGEM2-ES_RACMO22E" "2_MPI-ESM-LR_REMO2009" "3_EC-EARTH_CCLM4-8-17" "4_EC-EARTH_RACMO22E" "5_EC-EARTH_RCA4"
do

model_name="${model_dir#?_}"
file_name="pr_${model_name}_rcp${RCP}_future.nc"
input_file="$input_arc_dir/$model_dir/$file_name"

read -a hist_count <<< $( cdo  --no_history -outputf,%2.4g,1  -histcount$( printf ',%s' ${bin_range[@]} )  \
                          -selmonth,$month   -selyear,${year_in}/${year_fin} -selindexbox,$(( lon_i + 1 )),$(( lon_i + 1 )),$(( lat_i + 1 )),$(( lat_i + 1 ))  $input_file || \
                                   { echo "WARNING: corrupted or inesistent file"; continue; } )


		for i in $( seq 0 $(( n_bin -1 )) ) 
		do
	      		let hist_tot_count[$i]+=${hist_count[$i]}
		done

done # end of model  cycle

	# data file name
	if [[ $year_middle -eq 2015 ]]; then data_file_name="histogram_tmp_data_ref.txt" ; else data_file_name="histogram_tmp_data.txt" ;fi

	printf "%s\n" ${bin_range[@]}      > ${output_arc_dir}/histogram_tmp_bins.txt
	printf "%s\n" ${hist_tot_count[@]} > ${output_arc_dir}/histogram_tmp_file.txt

	paste -d ";"  ${output_arc_dir}/histogram_tmp_bins.txt  ${output_arc_dir}/histogram_tmp_file.txt > ${output_arc_dir}/${data_file_name}

	rm ${output_arc_dir}/histogram_tmp_bins.txt  ${output_arc_dir}/histogram_tmp_file.txt 
	unset hist_tot_count

done # end of two decade cycles (2010/2020 and future decade)

python  histogram_month_diff_pr.py  $point_n ${output_arc_dir}/histogram_tmp_data.txt ${output_arc_dir}/histogram_tmp_data_ref.txt  $RCP $year_in $year_fin $month $field
rm  ${output_arc_dir}/histogram_tmp_data_ref.txt ${output_arc_dir}/histogram_tmp_data.txt

done  # end of cycle on months

done < initialization_file.txt
