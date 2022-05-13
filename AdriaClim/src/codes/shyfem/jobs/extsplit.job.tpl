#!/bin/bash

# ******************************************************************************
#
#  DESCRIPTION:    this job template is aimed at splitting (unpacking) the
#                  desired EXT file (see the EXTERNAL FILES comment section),
#                  by the use of the "shyelab" SHYFEM's intrinsic routine
#                  (see the EXTERNAL CALLS comment section).
#
#  EXTERNAL CALLS: - "shyelab" SHYFEM's intrinsic routine: tool of SHYFEM
#                    model, aimed at processing SHY (.shy) or EXT (.ext)
#                    files.
#
#  EXTERNAL FILES: - EXT (.ext) file to be splitted (unpacked).
#                    EXT files are binary files storing SHYFEM's simulation
#                    outputs for "extra" (EXT) nodes.
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

# Split (unpack) the desired EXT file through the "shyelab" SHYFEM's intrinsic
# routine
extsplit () {

    # Define the name of the EXT file to be splitted (it is provided to the
    # function as input parameter)
    FILE2SPLIT="$1"

    # Define the default status for the splitting operation (OKKO=0 -> all went
    # OK; OKKO=1 -> something went KO)
    OKKO=0

    # If the EXT file does not exist
    if [[ ! -f $FILE2SPLIT ]]; then
        # Inform the user and exit with an error
        echo -e "\n\tERROR! File: ${FILE2SPLIT} does not exist. Exit...\n"
        EXIT_STATUS=1; exit $EXIT_STATUS
    fi

    # Split (unpack) the EXT file through the "shyelab" SHYFEM's intrinsic
    # routine
    shyelab -split $FILE2SPLIT || OKKO=1

    # Check the outcome of the splitting operation:
    #  - if all went OK
    if [[ $OKKO -eq 0 ]]; then
        # Inform the user
        echo -e "\n\tFile: ${FILE2SPLIT} successfully splitted (unpacked).\n"
    #  - if something went KO
    else
        # Inform the user and exit with an error
        echo -e "\n\tERROR! File: ${FILE2SPLIT} unsuccessfully splitted (unpacked). Exit...\n"
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

# Function calling: split (unpack) the desired EXT file through the "shyelab"
# SHYFEM's intrinsic routine (a template variable is employed, to be replaced
# by the use of a "sedfile")
extsplit %%FILE2SPLIT%%

# ************
#  END OF JOB
# ************
