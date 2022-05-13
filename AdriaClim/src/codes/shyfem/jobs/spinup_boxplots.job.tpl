#!/bin/bash

# ******************************************************************************
#
#  DESCRIPTION:    this job template is aimed at creating and running a
#                  Python 3 script, the aim of which is described in the
#                  following.
#                  The Python 3 script created through this job template is
#                  aimed at providing, in an output file (see the EXTERNAL
#                  FILES comment section), the summary of spin-up time
#                  statistics of all the variables under analysis, which is
#                  also depicted through a box and whiskers plot (whiskers
#                  extend from minimum to maximum, boxes extend from 25th
#                  to 75th percentile and medians are depicted with horizontal,
#                  orange lines).
#
#  EXTERNAL CALLS: none.
#
#  EXTERNAL FILES: - input ASCII file containing the list of files (full
#                    paths), carrying the information to be used to draw box
#                    and whiskers plots; it is arranged row by row, as shown
#                    below:
#
#                    file_1
#                    file_2
#                    ...
#
#                    where "file_1", "file_2", etc. are input ASCII files,
#                    containing information on spin-up time statistics
#                    (sample size, minimum, 5th percentile, 25th percentile,
#                    median, mean, 75th percentile, 95th percentile and
#                    maximum), arranged in columns (separated by "white"
#                    spaces) along a single line.
#
#                  - output ASCII file containing the summary of spin-up time
#                    statistics, for all the variables under analysis, arranged
#                    in columns (separated by "white" spaces).
#
#  DEVELOPER:      Alessandro Minigher (alessandro.minigher@arpa.fvg.it)
#                  ARPA FVG - S.O.C. Stato dell'Ambiente - CRMA
#                  "AdriaClim" Interreg IT-HR project
#
#  CREATION DATE:  2021-11-16.
#
#  MODIFICATIONS:  none.
#
#  VERSION:        0.1.
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
# related to spin-up tests (template variable, to be replaced through a
# "sedfile")
SHY_POSTPROC_SPINUP_SIMS_DIR=%%SHY_POSTPROC_SPINUP_SIMS_DIR%%
# Define the name (full path) of the file containing the list of files to be
# processed by the Python script
FILELIST2PROC="%%FILELIST2PROC%%"
# Define the basename of the output file aimed at containing the summary of
# spin-up time statistics (template variable, to be replaced through a
# "sedfile")
SPINUP_STATISTICS_SUMMARY_FILENAME=%%SPINUP_STATISTICS_SUMMARY_FILENAME%%

# Define the name of the desired Python script to create
py_script="spinup_boxplots.py"

# Create the desired Python script through a "here document"
cat <<EOF > ./$py_script

# ------------------------
#  START OF PYTHON SCRIPT
# ------------------------

#  --- START OF FUNCTIONS ---

# Build the header of the file aimed at containing the summary of spin-up time
# statistics
def file_header(filename, simA, simB):
    # Open the file in writing mode
    f = open(filename, "w")
    # Print the desired content in the output file
    print("# ************************************", file = f)
    print("# * SPIN-UP TIME STATISTICS: SUMMARY *", file = f)
    print("# ************************************", file = f)
    print("# %s %s" % ("SIMA: ", simA), file = f)
    print("# %s %s" % ("SIMB: ", simB), file = f)
    print("#", file = f)
    print("# Columns description:", file = f)
    print("# 1)  Variable", file = f)
    print("# 2)  Sample size", file = f)
    print("# 3)  Minimum [d]", file = f)
    print("# 4)  5th percentile [d]", file = f)
    print("# 5)  25th percentile [d]", file = f)
    print("# 6)  Median [d]", file = f)
    print("# 7)  Mean [d]", file = f)
    print("# 8)  75th percentile [d]", file = f)
    print("# 9)  95th percentile [d]", file = f)
    print("# 10) Maximum [d]", file = f)
    # Close the file
    f.close()
    return

# Print the summary of spin-up time statistics in a file
def stats_summary(filename_in, filename_out, simA, simB):
    # Function calling: build the header of the file aimed at containing the
    # summary of spin-up time statistics
    file_header(filename_out, simA, simB)
    # Open the input and output files in reading and appending modes,
    # respectively
    f_in = open(filename_in, "r")
    f_out = open(filename_out, "a")
    # For each line of the input file, hence for each file to be processed
    for filename in f_in:
        # Remove the "new line"
        filename = filename.rstrip("\n")
        # Extract the first part of the name of the file, by knowing that it is
        # the abbreviation of the variable for which statistics is provided
        # (e.g. zeta_1995F500A1_A001-1995F500A1_A002_spinup_statistics.txt)
        var = os.path.basename(filename).split("_")[0]
        # Open the file and remove possible comments (metadata) by the use of
        # Bash-like commands (comments are lines starting with "#")
        cat = subprocess.Popen(['cat', filename], close_fds=True, stdout=subprocess.PIPE)
        grep = subprocess.Popen('grep -v "^#"', shell=True, stdin=cat.stdout, stdout=subprocess.PIPE)
        # Read the first and only line of the file, decode it (required due to
        # the previous use of Bash-like commands) and remove the "new line"
        line = grep.stdout.readline()
        line = line.decode("utf-8")
        line = line.rstrip("\n")
        # Close the file
        grep.stdout.close()
        # Print the desired content in the output file
        print("%s%s" % (var, line), file = f_out)
    # Close input and output files
    f_in.close()
    f_out.close()
    return

# Draw box and whiskers plots starting from the summary of spin-up time
# statistics
def draw_boxplots(filename, title, fig_name):
    # Define the font size of the title of the figure (template variables are
    # employed, to be replaced through a "sedfile")
    title_size = 9
    # Define the x- and y-axis names (template variables, to be replaced
    # through a "sedfile") and their font size
    xaxis_name = "%%XAXIS_BXP%%"
    yaxis_name = "%%YAXIS_BXP%%"
    axes_fontsize = 9
    # Define empty lists to be filled with x-axis labels and ticks
    xaxis_labels = []
    xaxis_ticks = []
    # Define the size and color of the points to be plotted
    point_size = 20.
    point_color = "red"
    # Define the size of the legend of the plot and its marker scale
    legend_size = "x-small"
    legend_markerscale = 1.
    # Draw the figure
    fig, ax = plt.subplots()

    # Open the input file and remove possible comments (metadata) by the
    # use of Bash-like commands (comments are lines starting with "#")
    cat = subprocess.Popen(['cat', filename], close_fds=True, stdout=subprocess.PIPE)
    grep = subprocess.Popen('grep -v "^#"', shell=True, stdin=cat.stdout, stdout=subprocess.PIPE)
    # For each line of the file
    for line in grep.stdout:
        # Decode the line (required due to the previous use of Bash-like
        # commands) and remove the "new line"
        line = line.decode("utf-8")
        line = line.rstrip("\n")
        # Extract the desired content from the current line of the file
        var = line.split()[0]
        sample_size = int(line.split()[1])
        minimum = float(line.split()[2])
        percentile_5 = float(line.split()[3])
        percentile_25 = float(line.split()[4])
        median = float(line.split()[5])
        mean = float(line.split()[6])
        percentile_75 = float(line.split()[7])
        percentile_95 = float(line.split()[8])
        maximum = float(line.split()[9])
        # Fill the lists aimed at containing x-axis labels and ticks
        xaxis_labels.append(var)
        xaxis_ticks.append(xaxis_labels.index(var) + 1)
        # Define a list containing the position of the boxplot to be drawn,
        # with respect to the x-axis
        x_pos = [xaxis_labels.index(var) + 1]
        # Build a summary of spin-up time statistics, to be used to draw box
        # and whiskers plots
        stats = [{"mean":  mean, "med": median, "q1": percentile_25, "q3": percentile_75, "whislo": minimum, "whishi": maximum, "fliers": []}]
        # Draw the desired boxplot
        ax.bxp(stats, positions = x_pos)
        # If the first boxplot was just drawn
        if (xaxis_labels.index(var) == 0):
            # Draw some additional statistical parameters with attached legend
            plt.scatter(xaxis_labels.index(var) + 1, percentile_95, marker = "D", s = point_size, color = point_color, label = "95th perc.")
            plt.scatter(xaxis_labels.index(var) + 1, mean, marker = "o", s = point_size, color = point_color, label = "mean")
            plt.scatter(xaxis_labels.index(var) + 1, percentile_5, marker = "s", s = point_size, color = point_color, label = "5th perc.")
        # Otherwise
        else:
            # Draw some additional statistical parameters with no legend
            plt.scatter(xaxis_labels.index(var) + 1, percentile_95, marker = "D", s = point_size, color = point_color)
            plt.scatter(xaxis_labels.index(var) + 1, mean, marker = "o", s = point_size, color = point_color)
            plt.scatter(xaxis_labels.index(var) + 1, percentile_5, marker = "s", s = point_size, color = point_color)

    # Set the title of the figure
    plt.title(title, fontsize = title_size)
    # Set the x- and y-axis names
    plt.xlabel(xaxis_name, fontsize = axes_fontsize)
    plt.ylabel(yaxis_name, fontsize = axes_fontsize)
    # Plot x-axis ticks
    plt.xticks(xaxis_ticks, xaxis_labels)
    # Draw the grid
    ax.grid()
    # Set the legend
    ax.legend(fontsize = legend_size, markerscale = legend_markerscale)
    # Save and close the figure
    plt.savefig(fig_name, bbox_inches = "tight")
    plt.close(fig)
    return

#  --- END OF FUNCTIONS ---

#  --- START OF MAIN ---

# Import the desired modules
import subprocess
import os
import matplotlib.pyplot as plt
from matplotlib.ticker import AutoMinorLocator

# Define the name (full path) of the file containing the list of files to be
# processed
FILELIST2PROC="%%FILELIST2PROC%%"
# Define the basename of the file containing the summary of spin-up time
# statistics
SPINUP_STATISTICS_SUMMARY_FILENAME="%%SPINUP_STATISTICS_SUMMARY_FILENAME%%"
# Function calling: print the summary of spin-up time statistics in a file
stats_summary(FILELIST2PROC, SPINUP_STATISTICS_SUMMARY_FILENAME, "%%SIMA%%", "%%SIMB%%")
# Function calling: draw box and whiskers plots starting from the summary of
# spin-up time statistics
draw_boxplots(SPINUP_STATISTICS_SUMMARY_FILENAME, "%%TITLE_BXP%%", "%%FIGNAME_BXP%%")

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
if [[ -e $SHY_POSTPROC_SPINUP_SIMS_DIR ]]; then
    # Inform the user
    echo -e "\n\tDirectory: ${SHY_POSTPROC_SPINUP_SIMS_DIR} exists.\n"
#  - if it does not exist
else
    # Inform the user and create it
    echo -e "\n\tDirectory: ${SHY_POSTPROC_SPINUP_SIMS_DIR} does not exist. Creating it...\n"
    mkdir -p $SHY_POSTPROC_SPINUP_SIMS_DIR || OKKO_mkdir=1
fi
# Check the outcome of the creation of the directory:
#  - if all went OK
if [[ $OKKO_mkdir -eq 0 ]]; then
    # Inform the user
    echo -e "\tDirectory: ${SHY_POSTPROC_SPINUP_SIMS_DIR} successfully created.\n"
    # Move the desired content (post-processing file) to the directory,
    # informing the user (a template variable is employed, to be replaced
    # through a "sedfile")
    mv *"%%FIG_FORMAT%%" $SHY_POSTPROC_SPINUP_SIMS_DIR
    mv $SPINUP_STATISTICS_SUMMARY_FILENAME $SHY_POSTPROC_SPINUP_SIMS_DIR 
    echo -e "\n\tDirectory: $(pwd), post-processing files moved to ${SHY_POSTPROC_SPINUP_SIMS_DIR}.\n"
#  - if something went KO
else
    # Inform the user and exit with an error
    echo -e "\tERROR! Directory: ${SHY_POSTPROC_SPINUP_SIMS_DIR} unsuccessfully created. EXIT...\n"
    EXIT_STATUS=1; exit $EXIT_STATUS
fi

# ************
#  END OF JOB
# ************
