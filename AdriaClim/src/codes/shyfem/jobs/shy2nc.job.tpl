#!/bin/bash

# ******************************************************************************
#
#  DESCRIPTION:    this job template is aimed at converting a desired SHY
#                  file (see the EXTERNAL FILES comment section) to NetCDF,
#                  by the use of the "shyelab" SHYFEM's intrinsic routine
#                  (see the EXTERNAL CALLS comment section).
#
#  EXTERNAL CALLS: - "Shyelab" SHYFEM's intrinsic routine: tool of SHYFEM
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
#  CREATION DATE:  2021-09-30.
#
#  MODIFICATIONS:  2021-10-04 -> introduction of an EXIT_STATUS=1 in case of
#                                errors in the SHY to NetCDF conversion.
#                  2021-10-22 -> improvement in some details.
#                  2021-10-29 -> job directives are now assigned through
#                                template variables.
#
#  VERSION:        0.4.
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

# Move to the directory where the job was run, informing the user
echo -e "\n\tChange directory: moving to ${PBS_O_WORKDIR}...\n"; cd $PBS_O_WORKDIR
echo -e "\tCurrent directory: $(pwd).\n"

# Purge, load and list environmental modules (template variables, to be
# replaced through a "sedfile")
module purge
module load %%SHY_MOD%%
module list

# Define the full path of the "shyelab" SHYFEM's intrinsic routine (template
# variable, to be replaced through a "sedfile")
SHY_SHYELAB=%%SHY_SHYELAB%%
# Define the full path of the SHY file to be converted to NetCDF (template
# variable, to be replaced through a "sedfile")
FILE2CONVERT=%%FILE2CONVERT%%
# Define the default status for the SHY to NetCDF conversion:
#  - OKKO=0 -> all went OK
#  - OKKO=1 -> something went KO
OKKO=0

# Convert the SHY file to NetCDF, through the "shyelab" SHYFEM's intrinsic
# routine
$SHY_SHYELAB -outformat nc $FILE2CONVERT || OKKO=1
# Check the outcome of the SHY to NetCDF conversion:
#  - if all went OK
if [[ $OKKO -eq 0 ]]; then
    # Inform the user
    echo -e "\n\tFile: ${FILE2CONVERT} successfully converted to NetCDF.\n"
#  - if something went KO
else
    # Inform the user and exit with an error
    echo -e "\n\tERROR! File: ${FILE2CONVERT} unsuccessfully converted to NetCDF. Exit...\n"
    EXIT_STATUS=1; exit $EXIT_STATUS
fi

# ************
#  END OF JOB
# ************
