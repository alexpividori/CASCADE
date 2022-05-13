#!/bin/bash

# ******************************************************************************
#
#  DESCRIPTION:    this job template is aimed at converting the desired SHY
#                  file (see the EXTERNAL FILES comment section) to NetCDF,
#                  by the use of the "shyelab" SHYFEM's intrinsic routine
#                  (see the EXTERNAL CALLS comment section).
#
#  EXTERNAL CALLS: - "shyelab" SHYFEM's intrinsic routine: tool of SHYFEM
#                    model, aimed at processing SHY (.shy) files.
#
#  EXTERNAL FILES: - SHY (.shy) file to be converted to NetCDF (.nc).
#                    SHY files are binary files storing SHYFEM's simulation
#                    outputs.
#
#  DEVELOPER:      Alessandro Minigher (alessandro.minigher@arpa.fvg.it)
#                  ARPA FVG - S.O.C. Stato dell'Ambiente - CRMA
#                  "AdriaClim" Interreg IT-HR project
#
#  CREATION DATE:  2022-03-16.
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
#PBS -l nodes=%%JOB_l_nodes%%:ppn=%%JOB_l_ppn%%
#PBS -l walltime=%%JOB_l_walltime%%
##PBS -m %%JOB_m%%
##PBS -M %%JOB_M%%

# **************
#  START OF JOB
# **************

#  --- START OF FUNCTIONS ---

# Convert the desired SHY file to NetCDF through the "shyelab" SHYFEM's
# intrinsic routine, and rename the resulting "out.nc" file properly
shy2nc () {

    # Define the name of the SHY file to be converted to NetCDF (it is provided
    # to the function as input parameter)
    FILE2CONVERT="$1"

    # Define the basename to be given to the NetCDF file
    NC_FILE_NAME="${FILE2CONVERT##*/}"
    NC_FILE_NAME="${NC_FILE_NAME//.shy/}.nc"

    # Define the default status for the SHY to NetCDF conversion (OKKO=0 -> all
    # went OK; OKKO=1 -> something went KO)
    OKKO=0

    # If the SHY file does not exist
    if [[ ! -f $FILE2CONVERT ]]; then
        # Inform the user and exit with an error
        echo -e "\n\tERROR! File: ${FILE2CONVERT} does not exist. Exit...\n"
        EXIT_STATUS=1; exit $EXIT_STATUS
    fi

    # Convert the SHY file to NetCDF, through the "shyelab" SHYFEM's intrinsic
    # routine (this will produce an "out.nc" file)
    shyelab -outformat nc $FILE2CONVERT || OKKO=1

    # Check the outcome of the SHY to NetCDF conversion:
    #  - if all went OK
    if [[ $OKKO -eq 0 ]]; then
        # Rename the "out.nc" file produced by the "shyelab" SHYFEM's intrinsic
        # routine as desired, and inform the user
        mv "out.nc" $NC_FILE_NAME
        echo -e "\n\tFile: ${FILE2CONVERT} successfully converted to NetCDF -> ${NC_FILE_NAME}.\n"
    #  - if something went KO
    else
        # Inform the user and exit with an error
        echo -e "\n\tERROR! File: ${FILE2CONVERT} unsuccessfully converted to NetCDF. Exit...\n"
        EXIT_STATUS=1; exit $EXIT_STATUS
    fi

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

# Function calling: convert the desired SHY file to NetCDF through the
# "shyelab" SHYFEM's intrinsic routine, and rename the resulting "out.nc" file
# properly (a template variable is employed, to be replaced by the use of a
# "sedfile")
shy2nc %%FILE2PROC%%

# ************
#  END OF JOB
# ************
