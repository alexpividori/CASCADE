#!/usr/bin/env bash
#
#******************************************************************************
#
# DESCRIPTION:       This bash script is used to use external netCDF files
#                    contained in a particular directory, cut a particular region
#                    defined by "initialization_file.txt" and save the cutted file
#                    inside an output directory.  
#                    The cut the Mediterranean region only from Otranto to Monfalcone,
#                    the lat/lon region used is: 39.8;46.0;11.9;19.8
# EXTERNAL CALLS:   none.
#
# EXTERNAL FILES:   - input NetCDF data file (currents);
#                     Containing Temperature, Salinity, Currents or whatever
#                   - Initialization_file.txt in the usual format:
#                     serial_code,lat_min,lat_max,lon_min,lon_max,denomination_name,type,time_step,depth  
#           
#
# DEVELOPER:         Alex Pividori (alex.pividori@arpa.fvg.it)
#                    ARPA FVG - S.O.C. Stato dell'Ambiente - CRMA
#                   "AdriaClim" Interreg IT-HR project
#
# SOFTWARE VERSION: Bash 
#                   CDO version 1.9.8
#
# CREATION DATE:    23/04/2021.
#
# MODIFICATIONS:    23/04/2021 --> 
#
# VERSION:          0.1.
#
#******************************************************************************

a=0

input_dir="/lustre/arpa/scratch/COPERNICUSMarine_dowload/2020/12/TEMP"
output_dir="/u/arpa/pividoria/Bash_scripting/cutted_files"

# cdo module have to be charged

ls $input_dir > file_list_1.txt   # file_list_1.txt contains only the name files, not the path

  if [ -f file_list.txt ]; then   # because we want an empty file_list.txt
  rm file_list.txt
  fi

for i in $( cat initialization_file.txt ); do   # cycle on the initialization_file lines. Each line can identificate a particular region

   while read line; do
    echo   $input_dir"/;"$line   >> file_list.txt   # we use CSV format
   done < file_list_1.txt

   rm file_list_1.txt     

exit
  IFS=";"
  read -a parameters <<< "$i"   #create a vector called parameters containing the initialization_file.txt info

index=1 

  while IFS=";" read -r  dir_input  file_name    # the number of lines present in date_time.txt determinate the number of graphs
  do                                             # time-steps to be represented. In "s" modality the will be only one line. 
 
    cdo sellonlatbox,${parameters[3]},${parameters[4]},${parameters[1]},${parameters[2]} \
                     $dir_input$file_name  $output_dir"/"$file_name"_"$index
    ((index ++))                                 # index span over the whole group of files contained in input_dir

  done < file_list.txt                                          

  (( a++ ))        # a indicate the line of the initialization_file.txt used
  
done  

