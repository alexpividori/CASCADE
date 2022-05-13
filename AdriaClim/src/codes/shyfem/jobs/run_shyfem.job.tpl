#!/bin/bash

# ******************************************************************************
#
#  DESCRIPTION:      this job template is aimed at running the SHYFEM model
#                    (see the EXTERNAL CALLS comment section).
#
#  EXTERNAL CALLS:   - "shyfem" SHYFEM's main routine: it is the command to
#                      type, together with the parameter input file (see the
#                      EXTERNAL FILES comment section), for running the model.
#
#  EXTERNAL FILES:   - parameter input file (STR): ASCII file that guides the
#                      performance of SHYFEM.
#
#  DEVELOPER:        Alessandro Minigher (alessandro.minigher@arpa.fvg.it)
#                    ARPA FVG - S.O.C. Stato dell'Ambiente - CRMA
#                    "AdriaClim" Interreg IT-HR project
#
#  CREATION DATE:    2021-12-20.
#
#  MODIFICATIONS:    none.
#
#  VERSION:          0.1.
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
#PBS -k do 
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

# Define the default status for the execution of SHYFEM:
#  - OKKO=0 -> all went OK
#  - OKKO=1 -> something went wrong
OKKO=0

# Define the basename of the parameter input file (STR) that guides the
# performance of SHYFEM (template variable, to be replaced through a "sedfile")
SHY_STR_FILENAME="%%SHY_STR_FILENAME%%"

# Define the full path of SHYFEM's main routine ("shyfem"), namely the command
# to type (together with the parameter input file) for running the model
# (template variable, to be replaced through a "sedfile")
SHY_SHYFEM="%%SHY_SHYFEM%%"

# Run SHYFEM
$SHY_SHYFEM $SHY_STR_FILENAME

# Check if the simulation reached the end successfully (if everything went OK,
# the string "simulation end:" appears once in the standard output of the job)
flag_end=$(grep -c "simulation end:" %%JOB_o%%)
# Check the outcome of the run:
#  - if all went OK
if [[ $flag_end -eq 1 ]]; then
    # Inform the user
    echo -e "\n\tSHYFEM run: all went OK."
#  - if something went KO
else
    # Inform the user and exit with an error
    echo -e "\n\tERROR! SHYFEM run: something went KO. Please check."
    EXIT_STATUS=1; exit $EXIT_STATUS
fi

# ************
#  END OF JOB
# ************
