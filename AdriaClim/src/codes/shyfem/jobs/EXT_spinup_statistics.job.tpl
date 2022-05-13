#!/bin/bash

# ******************************************************************************
#
#  DESCRIPTION:    this job template is aimed at creating and running a
#                  Python 3 script, the aim of which is described in the
#                  following.
#                  The Python 3 script created through this job template is
#                  aimed at computing some of the main statistical parameters
#                  (minimum, 5th percentile, median, mean, 95th percentile
#                  and maximum) of a certain dataset of spin-up times,
#                  retrieved in an input ASCII file (see the EXTERNAL FILES
#                  comment section).
#                  Spin-up time statistics is printed in an output ASCII file
#                  (see the EXTERNAL FILES comment section).
#
#  EXTERNAL CALLS: none.
#
#  EXTERNAL FILES: - input ASCII file containing estimates of the spin-up time,
#                    formatted in tab-separated columns, as shown below:
#
#                    # Lines of metadata (preceded by a "#")
#                    column1    column2    column3    column4    column5    column6
#
#                    with
#
#                     -- "column1" dedicated to EXT nodes;
#                     -- "column2" dedicated to vertical layers (3D variables);
#                     -- "column3" dedicated to spin-up time estimates;
#                     -- "column4" dedicated to R²;
#                     -- "column5" dedicated to EXT node's longitude (°E);
#                     -- "column6" dedicated to EXT node's latitude (°N).
#
#                  - output ASCII file, containing information on spin-up
#                    time statistics (sample size, minimum, 5th percentile,
#                    25th percentile, median, mean, 75th percentile, 95th
#                    percentile and maximum), arranged in columns (separated by
#                    "white" spaces) along a single line.
#
#  DEVELOPER:      Alessandro Minigher (alessandro.minigher@arpa.fvg.it)
#                  ARPA FVG - S.O.C. Stato dell'Ambiente - CRMA
#                  "AdriaClim" Interreg IT-HR project
#
#  CREATION DATE:  2021-10-21.
#
#  MODIFICATIONS:  2021-10-25 -> improvement in the description of the job
#                                template;
#                             -> improvement in some details;
#                             -> introduction of the variables named
#                                SHY_POSTPROC_SPINUP_SIMS_VAR_DIR and
#                                SPINUP_STATISTICS_FILENAME.
#                  2021-10-27 -> introduction of a new function: "remove_inf";
#                             -> avoid to consider "inf" values in calculating
#                                the mean.
#                  2021-10-29 -> job directives are now assigned through
#                                template variables.
#                  2021-11-08 -> adjustment of the job template to a different
#                                type of input files (version 1.0).
#                  2021-11-09 -> addition of the computation and printing of
#                                the size of the sample for which statistics is
#                                computed.
#                  2021-11-10 -> addition of the computation and printing of R²
#                                statistics.
#                  2021-11-12 -> bug fixing in printing R² statistics.
#                  2021-11-15 -> addition of the computation and printing of
#                                25th and 75th percentiles of spin-up time and
#                                R² distributions.
#                  2021-11-16 -> change of the information and layout of the
#                                output file dedicated to spin-up time
#                                statistics.
#
#  VERSION:        1.5.
#
# ******************************************************************************

# *************************
#  START OF JOB DIRECTIVES
# *************************

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

# ***********************
#  END OF JOB DIRECTIVES
# ***********************

# **************
#  START OF JOB
# **************

# Move to the directory where the job was run, informing the user
echo -e "\n\tMoving to ${PBS_O_WORKDIR}.\n"; cd ${PBS_O_WORKDIR}
echo -e "\n\tCurrent directory: $(pwd).\n"

# Purge, load and list the desired environmental modules (template variables,
# to be replaced through a "sedfile")
module purge
module load %%PY_MOD%%
module load %%MINICONDA3_MOD%%
module list

# Define the default status for the execution of the desired Python script:
# - OKKO=0 -> all went OK
# - OKKO=1 -> something went KO
OKKO=0
# Define the default status for the creation of directories:
# - OKKO_mkdir=0 -> all went OK
# - OKKO_mkdir=1 -> something went KO
OKKO_mkdir=0
# Define the name of the directory aimed at storing post-processing files
# related to spin-up tests, for a given variable (template variable, to be
# replaced through a "sedfile")
SHY_POSTPROC_SPINUP_SIMS_VAR_DIR=%%SHY_POSTPROC_SPINUP_SIMS_VAR_DIR%%
# Define the basename of the output file aimed at containing information on
# spin-up time statistics (template variable, to be replaced through a
# "sedfile")
SPINUP_STATISTICS_FILENAME=%%SPINUP_STATISTICS_FILENAME%%
# Define the name of the desired Python script to create
py_script="EXT_spinup_statistics.py"

# Create the desired Python script through a "here document"
cat <<EOF > ./$py_script

# ------------------------
#  START OF PYTHON SCRIPT
# ------------------------

#  --- START OF FUNCTIONS ---

# Collect the desired column of a file (arranged in columns separated by a
# certain delimiter), sorting (descending order) its content on the basis of
# the numerical values contained in a given column (not necessarily that
# collected) of the same file
def get_file_column(filename, column_2_extract, column_4_sort, delimiter):
    # Open the input file and remove possible comments (metadata) by the use
    # of Bash-like commands (comments are lines starting with "#")
    cat = subprocess.Popen(['cat', filename], close_fds=True, stdout=subprocess.PIPE)
    grep = subprocess.Popen('grep -v "^#"', shell=True, stdin=cat.stdout, stdout=subprocess.PIPE)
    # Read all the lines of the input file (without comments)
    lines = grep.stdout.readlines()
    # Define an empty list to be used to collect the desired column of the
    # file, sorted on the basis of the numerical values contained in a given
    # column (not necessarily that collected) of the same file
    column_content = []
    # For each sorted line of the file (sorting is performed on numerical
    # values, not on strings; decoding is required due to the use of Bash-like
    # commands)
    for line in sorted(lines, key = lambda line: float(line.decode("utf-8").split(delimiter)[column_4_sort - 1]), reverse = True):
        # Decode the line (required due to the use of Bash-like commands),
        # remove the "new line", extract the desired column and append the
        # latter to the list
        line = line.decode("utf-8")
        line = line.rstrip("\n")
        column = line.split(delimiter)[column_2_extract - 1]
        column_content.append(column)
    # Close the input file
    grep.stdout.close()
    # Return the list containing the desired column
    return column_content

#  --- END OF FUNCTIONS ---

#  --- START OF MAIN ---

# Import the desired modules
import subprocess
import numpy as np
import math

# Define the name (full path) of the file to process (template variable, to be
# replaced through a "sedfile")
FILE2PROC = "%%FILE2PROC%%"
# Define the column number to be used for data sorting and the column
# delimiter, separating columns in the file to process
column_4_sort = 3
delimiter = "\t"
# Define the identification code of the simulations under comparison (template
# variables, to be replaced through a "sedfile")
SIMA = "%%SIMA%%"
SIMB = "%%SIMB%%"
# Get the variable, and its dimensionality (2D or 3D), under analysis (e.g.
# temp.3d. -> temp, 3d; zeta.2d. -> zeta, 2d), from a template variable, to be
# replaced through a "sedfile"
TOPROC = "%%TOPROC%%"
VAR = TOPROC.split(".")[0]
DIM = TOPROC.split(".")[1]

# Function calling: collect the desired, sorted (descending order) columns of
# the file to process:
EXT_node_list = get_file_column(FILE2PROC, 1, column_4_sort, delimiter)
layer_list = get_file_column(FILE2PROC, 2, column_4_sort, delimiter)
spinup_time_list = [float(i) for i in get_file_column(FILE2PROC, 3, column_4_sort, delimiter)]
rSquared_list = [float(i) for i in get_file_column(FILE2PROC, 4, column_4_sort, delimiter)]
#lon_list = get_file_column(FILE2PROC, 5, column_4_sort, delimiter)
#lat_list = get_file_column(FILE2PROC, 6, column_4_sort, delimiter)

# Define the number of seconds in a day
s_in_day = 3600. * 24.
# Compute some of the main statistical parameters (minimum, 5th percentile,
# median, mean, 95th percentile and maximum) of a dataset of spin-up times (in
# seconds)
sample_size = len(spinup_time_list)
minimum_s = min(spinup_time_list)
percentile_5_s = np.percentile(spinup_time_list, 5)
percentile_25_s = np.percentile(spinup_time_list, 25)
median_s = np.percentile(spinup_time_list, 50)
mean_s = np.mean(spinup_time_list)
percentile_75_s = np.percentile(spinup_time_list, 75)
percentile_95_s = np.percentile(spinup_time_list, 95)
maximum_s = max(spinup_time_list)
# Convert the statistical parameters from seconds to days
minimum_d = minimum_s / s_in_day
percentile_5_d = percentile_5_s / s_in_day
percentile_25_d = percentile_25_s / s_in_day
median_d = median_s / s_in_day
mean_d = mean_s / s_in_day
percentile_75_d = percentile_75_s / s_in_day
percentile_95_d = percentile_95_s / s_in_day
maximum_d = maximum_s / s_in_day
# Round the statistical parameters to the desired number of decimal digits
digits_4_round_s = 0
digits_4_round_d = 2
minimum_s = int(round(minimum_s, digits_4_round_s))
minimum_d = round(minimum_d, digits_4_round_d)
percentile_5_s = int(round(percentile_5_s, digits_4_round_s))
percentile_5_d = round(percentile_5_d, digits_4_round_d)
percentile_25_s = int(round(percentile_25_s, digits_4_round_s))
percentile_25_d = round(percentile_25_d, digits_4_round_d)
median_s = int(round(median_s, digits_4_round_s))
median_d = round(median_d, digits_4_round_d)
mean_s = int(round(mean_s, digits_4_round_s))
mean_d = round(mean_d, digits_4_round_d)
percentile_75_s = int(round(percentile_75_s, digits_4_round_s))
percentile_75_d = round(percentile_75_d, digits_4_round_d)
percentile_95_s = int(round(percentile_95_s, digits_4_round_s))
percentile_95_d = round(percentile_95_d, digits_4_round_d)
maximum_s = int(round(maximum_s, digits_4_round_s))
maximum_d = round(maximum_d, digits_4_round_d)

# Open the output file aimed at containing information on spin-up time
# statistics, in writing mode (the name of the output file is a template
# variable, to be replaced through a "sedfile")
FILEOUT = open("%%SPINUP_STATISTICS_FILENAME%%", "w")
# Print the desired content to the output file
print("# ***************************", file = FILEOUT)
print("# * SPIN-UP TIME STATISTICS *", file = FILEOUT)
print("# ***************************", file = FILEOUT)
print("# %s %s" % ("SIMA: ", SIMA), file = FILEOUT)
print("# %s %s" % ("SIMB: ", SIMB), file = FILEOUT)
print("# %s %s" % ("VAR:  ", VAR), file = FILEOUT)
print("# %s %s" % ("DIM:  ", DIM), file = FILEOUT)
print("#", file = FILEOUT)
print("# Columns description:", file = FILEOUT)
print("# 1) Sample size", file = FILEOUT)
print("# 2) Minimum [d]", file = FILEOUT)
print("# 3) 5th percentile [d]", file = FILEOUT)
print("# 4) 25th percentile [d]", file = FILEOUT)
print("# 5) Median [d]", file = FILEOUT)
print("# 6) Mean [d]", file = FILEOUT)
print("# 7) 75th percentile [d]", file = FILEOUT)
print("# 8) 95th percentile [d]", file = FILEOUT)
print("# 9) Maximum [d]", file = FILEOUT)
print("%10s%10s%10s%10s%10s%10s%10s%10s%10s" % (str(sample_size), str(minimum_d), str(percentile_5_d), str(percentile_25_d), str(median_d), str(mean_d), str(percentile_75_d), str(percentile_95_d), str(maximum_d)), file = FILEOUT)
# Close the file
FILEOUT.close()

#  --- END OF MAIN ---

# ----------------------
#  END OF PYTHON SCRIPT
# ----------------------

EOF

# Check the outcome of the preparation of the Python script:
#  - if all went OK
if [[ $? -eq 0 ]]; then
    # Inform the user
    echo -e "\n\tScript: ${py_script} successfully created.\n"
#  - if something went KO
else
    # Inform the user and exit with an error
    echo -e "\n\tERROR! Script: ${py_script} unsuccessfully created. EXIT...\n"
    EXIT_STATUS=1; exit $EXIT_STATUS
fi

# Run the Python script created through the "here document"
python ./$py_script || OKKO=1

# Check the outcome of the execution of the Python script:
#  - if all went OK
if [[ $OKKO -eq 0 ]]; then
    # Inform the user and remove the Python script
    echo -e "\tScript: ${py_script} successfully run.\n"
    rm $py_script
    echo -e "\tScript: ${py_script} removed.\n"
#  - if something went KO
else
    # Inform the user and exit with an error
    echo -e "\tERROR! Script: ${py_script} unsuccessfully run. EXIT...\n"
    EXIT_STATUS=1; exit $EXIT_STATUS
fi

# Check if the directory aimed at storing post-processing files related to
# spin-up tests exists:
#  - if it exists
if [[ -e $SHY_POSTPROC_SPINUP_SIMS_VAR_DIR ]]; then
    # Inform the user
    echo -e "\n\tDirectory: ${SHY_POSTPROC_SPINUP_SIMS_VAR_DIR} exists.\n"
#  - if it does not exist
else
    # Inform the user and create it
    echo -e "\n\tDirectory: ${SHY_POSTPROC_SPINUP_SIMS_VAR_DIR} does not exist. Creating it...\n"
    mkdir -p $SHY_POSTPROC_SPINUP_SIMS_VAR_DIR || OKKO_mkdir=1
fi
# Check the outcome of the creation of the directory:
#  - if all went OK
if [[ $OKKO_mkdir -eq 0 ]]; then
    # Inform the user
    echo -e "\tDirectory: ${SHY_POSTPROC_SPINUP_SIMS_VAR_DIR} successfully created.\n"
    # Move the desired content (post-processing file) to the directory,
    # informing the user
    mv $SPINUP_STATISTICS_FILENAME $SHY_POSTPROC_SPINUP_SIMS_VAR_DIR
    echo -e "\n\tFile: ${SPINUP_STATISTICS_FILENAME} moved to ${SHY_POSTPROC_SPINUP_SIMS_VAR_DIR}.\n"
#  - if something went KO
else
    # Inform the user and exit with an error
    echo -e "\tERROR! Directory: ${SHY_POSTPROC_SPINUP_SIMS_VAR_DIR} unsuccessfully created. EXIT...\n"
    EXIT_STATUS=1; exit $EXIT_STATUS
fi

# ************
#  END OF JOB
# ************
