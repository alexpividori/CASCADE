#!/bin/bash

# ******************************************************************************
#
#  DESCRIPTION:    this job template is aimed at processing FEM (.fem) files
#                  containing not perturbed meteorological forcing for zonal
#                  and meridional wind components, surface atmospheric
#                  pressure, precipitation, solar radiation, air temperature at
#                  2 m, specific humidity at 2 m and cloud cover, by summing -
#                  for each month - an addend to each field, which is field-
#                  and month- specific (that is, for each month - 01, 02, ...,
#                  12 - and for each field, a "delta" is provided). "Deltas"
#                  (addends) are retrieved in an ASCII file (see the EXTERNAL
#                  FILES comment section).
#
#  EXTERNAL CALLS: - "sumelab" SHYFEM's intrinsic routine: tool of SHYFEM
#                    model, aimed at processing FEM (.fem) files. This routine
#                    is not part of the SHYFEM distribution, but has been
#                    developed by Alessandro Minigher (Arpa FVG), in
#                    analogy with the "femelab" SHYFEM's intrinsic tool.
#                    ("sumelab" and "femelab" are identical, except when used
#                    with the "-facts" option; the former sums addends to data,
#                    while the latter multiplies data by factors).
#
#  EXTERNAL FILES: - input FEM (.fem) files containing not perturbed
#                    meteorological forcing for:
#                     a) wind -> zonal and meridional wind components at 10 m
#                                [m s-1], and surface atmospheric pressure [Pa]
#                     b) heat -> solar radiation [W m-2], air temperature at 2
#                                m [°C], specific humidity at 2 m [kg kg-1] and
#                                cloud cover [0-1]
#                     c) rain -> precipitation [mm day-1]
#
#                  - ASCII file containing zonal and meridional wind
#                    components, surface atmospheric pressure, precipitation,
#                    solar radiation, air temperature at 2 m, specific humidity
#                    at 2 m and cloud cover's monthly "deltas" (variations with
#                    respect to a reference), for a certain scenario, decade,
#                    geographic point and statistical estimator (mean or
#                    median). This file is characterized by metadata (lines
#                    starting with the "#" character) and it is arranged in 9
#                    columns, as shown below:
#
#                    # Some lines of metadata
#                    # Month;delta uas[m s-1];delta vas[m s-1];delta ps[Pa];delta rsds [W m-2];delta tas [°C];delta huss [kg kg-1];delta cc [0-1];delta pr [mm day-1]
#                    01;deltaUAS_01;deltaVAS_01;...;deltaPR_01
#                    02;deltaUAS_02;deltaVAS_02;...;deltaPR_02
#                    ...
#                    12;deltaUAS_12;deltaVAS_12;...;deltaPR_12
#
#                  - output FEM (.fem) files containing perturbed
#                    meteorological forcing, obtained from the not perturbed
#                    ones by the addition of "deltas".
#
#  DEVELOPER:      Alessandro Minigher (alessandro.minigher@arpa.fvg.it)
#                  ARPA FVG - S.O.C. Stato dell'Ambiente - CRMA
#                  "AdriaClim" Interreg IT-HR project
#
#  CREATION DATE:  2022-03-29.
#
#  MODIFICATIONS:  none.
#
#  VERSION:        0.1.
#
# ******************************************************************************

# ******************
#  JOB'S DIRECTIVES
# ******************

#PBS -P %%JOB_P%%
#PBS -W umask=%%JOB_W_umask%%
#PBS -W block=%%JOB_W_block%%
#PBS -N %%JOB_N%%
#PBS -o %%JOB_o%%
#PBS -e %%JOB_e%%
#PBS -q %%JOB_q%%
#PBS -J 1-3
#PBS -l nodes=%%JOB_l_nodes%%:ppn=%%JOB_l_ppn%%
#PBS -l walltime=%%JOB_l_walltime%%
##PBS -m %%JOB_m%%
##PBS -M %%JOB_M%%

# **************
#  START OF JOB
# **************

#  --- START OF FUNCTIONS ---

# Remove the "out.fem" file if it is empty, otherwise process it through the
# "sumelab" tool ("-facts" option) and move it into the desired subdirectory
# with a proper name
outfem_rm_or_sumelab () {

    # Attribute the parameters provided in input to the function to variables
    # with more human readable names
    subdir=$1    # subdirectory where moving the processed file
    addends=$2   # comma separated addends to be summed to the data fields

    # Define the default status for processing FEM files through the "sumelab"
    # tool with the "-facts" option (OKKO_sum=0 -> all went OK; OKKO_sum=1 ->
    # something went KO):
    OKKO_sum=0

    # Define the name of the file to remove or process ("out.fem")
    outfem_file="out.fem"

    # Define the name to be attributed to the "out.fem" file after its
    # (possible) processing. The new name is not a basename only, but a
    # relative path with respect to the current directory (subdirectory +
    # basename)
    outfem_file_new_name="${subdir}/${year}-${month}.fem"

    # Get the memory size (kB) of the "out.fem" file
    file_size_kb=`du -k ${outfem_file} | cut -f1`

    # Check if the file is empty or not:
    #  - if it is empty
    if [[ $file_size_kb -eq 0 ]]; then
        # Remove the file
        rm $outfem_file
    #  - if it is not empty
    else
        # Rename the "out.fem" file as desired
        mv $outfem_file $outfem_file_new_name

        # Process the file through the "sumelab" tool, with the "-facts"
        # option, which sums addends to the data fields (this will produce an
        # "out.fem" file)
        sumelab -out -facts $addends $outfem_file_new_name || OKKO_sum=1

        # Check the outcome of the processing:
        #  - if all went OK
        if [[ $OKKO_sum -eq 0 ]]; then
            # Rename the "out.fem" file produced by the "sumelab" tool as
            # desired (i.e. move it into the desired subdirectory of the
            # current directory and rename it properly)
            mv $outfem_file $outfem_file_new_name
            # Inform the user
            echo -e "\n\tFile: ${outfem_file_new_name} successfully created by the 'sumelab' tool.\n"
        #  - if something went KO
        else
            # Inform the user and exit with an error
            echo -e "\n\tERROR! File: ${outfem_file_new_name} unsuccessfully created by the 'sumelab' tool. Please check. Exit...\n"
            EXIT_STATUS=1; exit $EXIT_STATUS
        fi
    fi
}

# Check if there is any unavailable "delta" (missing value, 1e+20)
check_nans () {
    # Define the "delta" to be checked (first parameter provided to the
    # function) and the name of the file containing it (second parameter
    # provided to the function)
    delta=$1
    delta_file=$2
    # Define the identifier for missing values
    nan=1e+20
    # If the "delta" is unavailable (missing value, 1e+20)
    if [[ "${delta}" == "${nan}" ]]; then
        # Inform the user and exit with an error
        echo -e "\n\tERROR! File: $2 has missing values (${nan}). Please check. Exit...\n"
        EXIT_STATUS=1; exit $EXIT_STATUS
    fi
}

# Remove the given file or directory, if existent
rm_filedir () {
    # If the file or directory provided to the function exists
    if [[ -e $1 ]]; then
        # Remove it and inform the user
        rm -r $1; echo -e "\tFile/directory: $1 removed.\n"
    fi
}

# Move the given file into the desired directory
mv_file () {
    # Move the given file (first parameter provided to the function) into the
    # desired directory (second parameter provided to the function), and inform
    # the user
    mv $1 $2
    echo -e "\n\tFile: $1 moved into $2.\n"
}

#  --- END OF FUNCTIONS ---

# Purge, load and list environmental modules (template variables, to be
# replaced through a "sedfile")
module purge
module load %%SHY_MOD%%
module list

# Move to the directory where the job was run, informing the user
echo -e "\n\tChange directory: moving to ${PBS_O_WORKDIR}...\n"; cd $PBS_O_WORKDIR
echo -e "\tCurrent directory: $(pwd).\n"

# Define the default status (OKKO=0 -> all went OK; OKKO=1 -> something went
# KO) for:
#  - processing FEM files (time range selection, through the "sumelab" tool
#    with "-tmin" and "-tmax" options)
OKKO_tsel=0
#  - creating directories
OKKO_mkdir=0
#  - making symbolic links
OKKO_mklink=0
#  - "grep" operations
OKKO_grep=0
#  - "cat" operations
OKKO_cat=0

# Define the name of a temporary directory, where carrying out the work
# about perturbation of meteorological forcing
TMPDIR_METEO=$(mktemp -u meteo_workdir.XXXXX)
# Define the name of temporary directories, to be used to store processed FEM
# files for the given fields
TMPDIR_WIND=$(mktemp -u wind.XXXXX)   # wind
TMPDIR_HEAT=$(mktemp -u heat.XXXXX)   # heat
TMPDIR_RAIN=$(mktemp -u rain.XXXXX)   # rain
# Define the name of temporary links, to be used to point to the FEM files
# containing not perturbed boundary conditions, for the given fields
LINK_WIND=$(mktemp -u wind_data.XXXXX)   # wind
LINK_HEAT=$(mktemp -u heat_data.XXXXX)   # heat
LINK_RAIN=$(mktemp -u rain_data.XXXXX)   # rain
# Define the name of a temporary file, aimed at hosting the content of the
# "deltas" file, but deprived of metadata (lines starting with the "#"
# character)
METEO_DELTAS_FILE_TMP=$(mktemp -u deltas_meteo.XXXXX)

# Move to the directory where the job was run, informing the user
mkdir $TMPDIR_METEO || OKKO_mkdir=1
echo -e "\n\tChange directory: moving to ${TMPDIR_METEO}...\n"; cd $TMPDIR_METEO
echo -e "\tCurrent directory: $(pwd).\n"

# Make (temporary) symbolic links to the FEM files containing not perturbed
# meteorological forcing (template variables, to be replaced through a
# "sedfile")
ln -sv %%WIND_FILE%% ./$LINK_WIND || OKKO_mklink=1
ln -sv %%QFLUX_FILE%% ./$LINK_HEAT || OKKO_mklink=1
ln -sv %%RAIN_FILE%% ./$LINK_RAIN || OKKO_mklink=1
# Check the outcome of the symbolic linking operation:
#  - if all went OK (all links was successfully created)
if [[ $OKKO_mklink -eq 0 ]]; then
    # Inform the user
    echo -e "\n\tLinks: all went OK.\n"
#  - if something went KO (at least one link was unsuccessfully created)
else
    # Inform the user and exit with an error
    echo -e "\n\tERROR! Links: something went wrong. Please check. Exit...\n"
    EXIT_STATUS=1; exit $EXIT_STATUS
fi

# Create the desired (temporary) directories
mkdir $TMPDIR_WIND || OKKO_mkdir=1
mkdir $TMPDIR_HEAT || OKKO_mkdir=1
mkdir $TMPDIR_RAIN || OKKO_mkdir=1
# Check the outcome of the creation of directories:
#  - if all went OK (all directories were successfully created)
if [[ $OKKO_mkdir -eq 0 ]]; then
    # Inform the user
    echo -e "\n\tDirectories (temporary): all went OK.\n"
#  - if something went KO (at least one directory was unsuccessfully created)
else
    # Inform the user and exit with an error
    echo -e "\n\tERROR! Directories (temporary): something went wrong. Please check. Exit...\n"
    EXIT_STATUS=1; exit $EXIT_STATUS
fi

# Get the starting and ending year of the specific simulation to be run
# (template variables are employed, to be replaced through a "sedfile"):
#  - split the starting date and time (YYYY-MM-DD::hh:mm:ss -> YYYY-MM-DD,
#    hh:mm:ss)
IFS="::" read -r -a dt_start_array <<< %%SHY_ITANF%%
#  - get the starting date (YYYY-MM-DD)
date_start="${dt_start_array[0]}"
#  - split the starting date in its elements (YYYY-MM-DD -> YYYY, MM, DD)
IFS="-" read -r -a date_start_array <<< $date_start
#  - get the starting year (YYYY)
year_start="${date_start_array[0]}"
#  - split the ending date and time (YYYY-MM-DD::hh:mm:ss -> YYYY-MM-DD,
#    hh:mm:ss)
IFS="::" read -r -a dt_end_array <<< %%SHY_ITEND%%
#  - get the ending date (YYYY-MM-DD)
date_end="${dt_end_array[0]}"
#  - split the ending date in its elements (YYYY-MM-DD -> YYYY, MM, DD)
IFS="-" read -r -a date_end_array <<< $date_end
#  - get the ending year (YYYY)
year_end="${date_end_array[0]}"

# Remove metadata from the "deltas" file (template variable, to be replaced
# through a "sedfile"), by knowing that these are lines starting with the "#"
# character, and redirect the output to a temporary file
grep -v "^#" %%METEO_DELTAS_FILE%% > $METEO_DELTAS_FILE_TMP || OKKO_grep=1
# Check the outcome of the "grep" operation:
#  - if all went OK
if [[ $OKKO_grep -eq 0 ]]; then
    # Inform the user
    echo -e "\n\tFile: %%METEO_DELTAS_FILE%% successfully deprived of metadata. 'Grep' went OK.\n"
#  - if something went KO
else
    # Inform the user and exit with an error
    echo -e "\n\tERROR! File: %%METEO_DELTAS_FILE%% unsuccessfully deprived of metadata. 'Grep' went KO. Please check. Exit...\n"
    EXIT_STATUS=1; exit $EXIT_STATUS
fi

# From the starting to the ending year of the specific simulation to be run
for year in $(seq $year_start $year_end); do
    # For each line of the "deltas" file deprived of metadata
    while read line; do

        # Split data by columns, which are separated by ";" characters
        IFS=";" read -r -a data <<< $line
        # Get the content of each column
        month="${data[0]}"      # Month (MM)
        velx_delta=${data[1]}   # Eastward Near- Surface Wind Velocity "delta"
        vely_delta=${data[2]}   # Northward Near- Surface Wind Velocity "delta"
        airp_delta=${data[3]}   # Surface Air Pressure "delta"
        srad_delta=${data[4]}   # Surface Downwelling Shortwave Radiation "delta"
        airt_delta=${data[5]}   # Near-Surface Air Temperature "delta"
        shum_delta=${data[6]}   # Near-Surface Specific Humidity "delta"
        ccov_delta=${data[7]}   # Cloud Cover "delta"
        rain_delta=${data[8]}   # Precipitation "delta"

        # Function calling: check if there is any unavailable "delta" (missing
        # value, 1e+20); a template variable is employed, to be replaced
        # through a "sedfile"
        check_nans $velx_delta %%METEO_DELTAS_FILE%%
        check_nans $vely_delta %%METEO_DELTAS_FILE%%
        check_nans $airp_delta %%METEO_DELTAS_FILE%%
        check_nans $srad_delta %%METEO_DELTAS_FILE%%
        check_nans $airt_delta %%METEO_DELTAS_FILE%%
        check_nans $shum_delta %%METEO_DELTAS_FILE%%
        check_nans $ccov_delta %%METEO_DELTAS_FILE%%
        check_nans $rain_delta %%METEO_DELTAS_FILE%%

        # Define the starting date and time of the monthly time interval to
        # select, in a "Bash-readable" way (YYYY-MM-DD hh:mm:ss)
        tmin_u="${year}-${month}-01 00:00:00"

        # Define the starting and ending date and time (YYYY-MM-DD::hh:mm:ss)
        # of the monthly interval to be selected through the use of the
        # "sumelab" tool with "-tmin" and "-tmax" options
        tmin=$(date -u -d "${tmin_u}" +%Y-%m-%d"::"%H:%M:%S)
        tmax=$(date -u -d "${tmin_u} + 1 month" +%Y-%m-%d"::"%H:%M:%S)

        # Extract the desired time interval from the given FEM file, through
        # the "sumelab" tool (an "out.fem" file will be produced) and call the
        # function aimed at removing the "out.fem" file if it is empty, or at
        # processing (adding "deltas" to the data) it if it is not empty:
        #  - wind
        if [[ $PBS_ARRAY_INDEX -eq 1 ]]; then
            sumelab -out -tmin $tmin -tmax $tmax $LINK_WIND
            wind_delta="${velx_delta},${vely_delta},${airp_delta}"
            outfem_rm_or_sumelab $TMPDIR_WIND $wind_delta
        fi
        #  - heat
        if [[ $PBS_ARRAY_INDEX -eq 2 ]]; then
            sumelab -out -tmin $tmin -tmax $tmax $LINK_HEAT
            heat_delta="${srad_delta},${airt_delta},${shum_delta},${ccov_delta}"
            outfem_rm_or_sumelab $TMPDIR_HEAT $heat_delta
        fi
        #  - rain
        if [[ $PBS_ARRAY_INDEX -eq 3 ]]; then
            sumelab -out -tmin $tmin -tmax $tmax $LINK_RAIN
            outfem_rm_or_sumelab $TMPDIR_RAIN $rain_delta
        fi

    done < $METEO_DELTAS_FILE_TMP
done

# Concatenate (merge in time) processed FEM files, redirecting the output to
# the desired file (template variable, to be replaced through a "sedfile")
#  - wind
if [[ $PBS_ARRAY_INDEX -eq 1 ]]; then cat $TMPDIR_WIND/* > %%WIND_FILE_PERT%% || OKKO_cat=1; fi
#  - heat
if [[ $PBS_ARRAY_INDEX -eq 2 ]]; then cat $TMPDIR_HEAT/* > %%QFLUX_FILE_PERT%% || OKKO_cat=1; fi
#  - rain
if [[ $PBS_ARRAY_INDEX -eq 3 ]]; then cat $TMPDIR_RAIN/* > %%RAIN_FILE_PERT%% || OKKO_cat=1; fi
# Check the outcome of the concatenation:
#  - if all went OK
if [[ $OKKO_cat -eq 0 ]]; then
    # Inform the user
    echo -e "\n\tPerturbed meteo forcing: successfully created.\n"
#  - if something went KO
else
    # Inform the user and exit with an error
    echo -e "\n\tPerturbed meteo forcing: unsuccessfully created. Please check. Exit...\n"
    EXIT_STATUS=1; exit $EXIT_STATUS
fi

# Function calling: move the given file into the desired directory (template
# variables are employed, to be replaced through a "sedfile")
if [[ $PBS_ARRAY_INDEX -eq 1 ]]; then mv_file %%WIND_FILE_PERT%% %%SCRATCH_SIM_ID_INPUT_METEO_DIR%%; fi
if [[ $PBS_ARRAY_INDEX -eq 2 ]]; then mv_file %%QFLUX_FILE_PERT%% %%SCRATCH_SIM_ID_INPUT_METEO_DIR%%; fi
if [[ $PBS_ARRAY_INDEX -eq 3 ]]; then mv_file %%RAIN_FILE_PERT%% %%SCRATCH_SIM_ID_INPUT_METEO_DIR%%; fi

# Function calling: remove the given file or directory, if existent:
#  - temporary directories
rm_filedir $TMPDIR_METEO
rm_filedir $TMPDIR_WIND
rm_filedir $TMPDIR_HEAT
rm_filedir $TMPDIR_RAIN
#  - temporary files
rm_filedir $LINK_WIND
rm_filedir $LINK_HEAT
rm_filedir $LINK_RAIN
rm_filedir $METEO_DELTAS_FILE_TMP

# ************
#  END OF JOB
# ************
