#!/bin/bash

# ******************************************************************************
#
#  DESCRIPTION:    this job template is aimed at extracting the fields
#                  contained in a NetCDF file (see the EXTERNAL FILES comment
#                  section), at each "extra" (EXT) node of the specific
#                  SHYFEM simulation.
#                  Extraction is carried out through CDO (Climate Data
#                  Operators) and job arrays are employed (each job array
#                  extracts one specific node).
#
#  EXTERNAL CALLS: none.
#
#  EXTERNAL FILES: - NetCDF file containing the results of the specific SHYFEM
#                    simulation, for some fields, obtained from the conversion
#                    of the related SHY file, through the "shyelab" SHYFEM's
#                    intrinsic routine;
#                  - ASCII file containing the content of the "$extra" section
#                    of the STR file peculiar to the specific simulation;
#                  - CSV file containing the correspondence between the SHY and
#                    related NetCDF nodes' numbering, without metadata (NetCDF
#                    files obtained from SHY ones, through the "shyelab"
#                    SHYFEM's intrinsic routine, are characterized by a
#                    different nodes' numbering convention). This file is
#                    formatted as follows:
#
#                    SHY_node_1;NetCDF_node_ID-1
#                    SHY_node_2;NetCDF_node_ID-2
#                    ...
#                    SHY_node_N;NetCDF_node_ID-N
#
#                    where
#
#                       SHY_node_i       = ID of i-th node in SHY files;
#                       NetCDF_node_ID-i = ID of the node in NetCDF files
#                                          corresponding to i-th node in the
#                                          related SHY files.
#
#  DEVELOPER:      Alessandro Minigher (alessandro.minigher@arpa.fvg.it)
#                  ARPA FVG - S.O.C. Stato dell'Ambiente - CRMA
#                  "AdriaClim" Interreg IT-HR project
#
#  CREATION DATE:  2022-03-18.
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
#PBS -j oe
#PBS -q %%JOB_q%%
#PBS -J 1-%%JOB_ARRAY_INDEX_MAX%%
#PBS -l nodes=%%JOB_l_nodes%%:ppn=%%JOB_l_ppn%%
#PBS -l walltime=%%JOB_l_walltime%%
##PBS -m %%JOB_m%%
##PBS -M %%JOB_M%%

# **************
#  START OF JOB
# **************

# Purge, load and list environmental modules (template variables, to be
# replaced through a "sedfile")
module purge
module load %%CDO_MOD%%
module list

# Move to the directory where the job was run, informing the user
echo -e "\n\tChange directory: moving to ${PBS_O_WORKDIR}...\n"; cd $PBS_O_WORKDIR
echo -e "\tCurrent directory: $(pwd).\n"

# Define the name of the NetCDF file to be processed (template variable, to be
# replaced through a "sedfile"), and get its basename, basename without
# extension and extension
FILE2PROC="%%FILE2PROC%%"
FILE2PROC_BASENAME="${FILE2PROC##*/}"
FILE2PROC_BASENAME_NO_EXTENSION="${FILE2PROC_BASENAME%%.*}"
FILE2PROC_EXTENSION="${FILE2PROC_BASENAME#*.}"

# Define the name of the file containing the content of the "$extra" section of
# the STR file, for the specific simulation (template variable, to be replaced
# through a "sedfile")
STR_FILE_EXTRA_TMP="%%STR_FILE_EXTRA_TMP%%"

# Define the name of the CSV file containing the correspondence between the SHY
# and related NetCDF nodes' numbering, without metadata (NetCDF files obtained
# from SHY ones, through the "shyelab" SHYFEM's intrinsic routine, are
# characterized by a different nodes' numbering convention); a template
# variable is employed, to be replaced through a "sedfile"
SHY_NETCDF_NODES_CFR_TMP="%%SHY_NETCDF_NODES_CFR_TMP%%"

# Define the full path of the directory where moving NetCDF output files
# (template variable, to be replaced through a "sedfile")
SCRATCH_SIM_ID_NETCDF_DIR="%%SCRATCH_SIM_ID_NETCDF_DIR%%"

# Define a "line's number index"
i=1
# For each line in the file containing the content of the "$extra" section of
# the STR file, for the specific simulation, namely for each EXT node to
# consider
while read line; do

    # If the ID of the job array is not equal to the current line of the file,
    # increase the "line's number index" and skip to the next line
    if [[ $PBS_ARRAY_INDEX -ne $i ]]; then i=$(($i+1)); continue; fi

    # Read the content of the line, storing its columns (separated by "white"
    # spaces) in an array
    IFS=" " read -r -a EXT_nodes_array <<< $line
    # Get the ID of the computational mesh corresponding to the current EXT
    # node and its description
    SHY_node="${EXT_nodes_array[0]}"   # e.g. 12538
    desc="${EXT_nodes_array[1]}"       # e.g. 'Point_1'
    desc="${desc:1}"
    desc="${desc::-1}"

    # Define the ID of the current EXT node (e.g. 001, 010, 100)
    if [[ $i -lt 10 ]]; then EXT_node_ID="00${i}"; fi
    if [[ $i -ge 10 ]] && [[ $i -lt 100 ]]; then EXT_node_ID="0${i}"; fi
    if [[ $i -ge 100 ]]; then EXT_node_ID="${i}"; fi

    # For each line of the CSV file containing the correspondence between the
    # SHY and related NetCDF nodes numbering, without metadata
    while read nodes_cfr; do

        # Read the content of the line, storing its columns (separated by ";")
        # in an array
        IFS=";" read -r -a nodes_array_cfr <<< $nodes_cfr
        # Get the ID of the computational mesh corresponding to the current EXT
        # node, in both SHY and NetCDF conventions
        SHY_node_cfr="${nodes_array_cfr[0]}"
        NetCDF_node_cfr="${nodes_array_cfr[1]}"

        # If the node in the SHY convention is equal to that corresponding to
        # the current EXT
        if [[ $SHY_node_cfr -eq $SHY_node ]]; then

            # Define the name (full path) to be attributed to the NetCDF output
            # file
            fileout="${SCRATCH_SIM_ID_NETCDF_DIR}/${FILE2PROC_BASENAME_NO_EXTENSION}-EXTnode${EXT_node_ID}-${desc}-SHYnode${SHY_node}-NetCDFnode${NetCDF_node_cfr}.${FILE2PROC_EXTENSION}"
            # Extract the desired node from the NetCDF file to be processed,
            # storing the output in the file defined above
            cdo selgridcell,$NetCDF_node_cfr $FILE2PROC $fileout

            break

        fi

    done < $SHY_NETCDF_NODES_CFR_TMP

    break

done < $STR_FILE_EXTRA_TMP

# ************
#  END OF JOB
# ************
