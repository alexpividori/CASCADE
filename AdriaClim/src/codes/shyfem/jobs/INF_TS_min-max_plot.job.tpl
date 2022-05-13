#!/bin/bash

# ******************************************************************************
#
#  DESCRIPTION:    this job template is aimed at creating and running a
#                  Python 3 script, the aim of which is described in the
#                  following.
#                  The Python 3 script created through this job template is
#                  aimed at plotting the time series of the minimum and maximum
#                  values of sea temperature (1st plot) and salinity (2nd plot),
#                  of the entire domain of a SHYFEM's simulation.
#                  Time series data of sea temperature and salinity are
#                  retrieved in two input files (see the EXTERNAL FILES comment
#                  section).
#
#  EXTERNAL CALLS: none.
#
#  EXTERNAL FILES: - time series data file for minimum and maximum sea
#                    temperature: ASCII file obtained by "grepping" SHYFEM's
#                    log INF (.inf) file (e.g. grep " temp: " nadri-mg.inf);
#                  - time series data file for minimum and maximum salinity:
#                    ASCII file obtained by "grepping" SHYFEM's log INF (.inf)
#                    file (e.g. grep " salt: " nadri-mg.inf).
#
#                  The two files described above are formatted in 5 columns:
#                  the 2nd contains date and time (YYYY-MM-DD::hh:mm:ss), the
#                  4th contains minimum sea temperature or salinity and the 5th
#                  contains maximum sea temperature or salinity. Columns are
#                  separated by "white" spaces.
#
#  DEVELOPER:      Alessandro Minigher (alessandro.minigher@arpa.fvg.it)
#                  ARPA FVG - S.O.C. Stato dell'Ambiente - CRMA
#                  "AdriaClim" Interreg IT-HR project
#
#  CREATION DATE:  2021-12-23.
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
echo -e "\tChange directory: moving to ${PBS_O_WORKDIR}.\n"; cd $PBS_O_WORKDIR
echo -e "\tCurrent directory: $(pwd).\n"

# Purge, load and list the desired environmental modules (template variables,
# to be replaced through a "sedfile")
module purge
module load %%PY_MOD%%
module load %%MINICONDA3_MOD%%
module list

# Define the default status for the execution of the desired Python script:
#  - OKKO=0 -> all went OK
#  - OKKO=1 -> something went KO
OKKO=0

# Define the name of the desired Python script to create
py_script="INF_TS_min-max_plot.py"

# Create the desired Python script through a "here document"
cat <<EOF > ./$py_script

# ------------------------
#  START OF PYTHON SCRIPT
# ------------------------

#  --- START OF FUNCTIONS ---

# Collect the desired data from the given file
def data_collect(filename):
    # Define empty lists to be filled with the desired data
    dt_list = []
    min_value_list = []
    max_value_list = []
    # Open the input data file in reading mode
    f = open(filename, "r")
    # For each line in the file
    for line in f:
        # Remove the "new line"
        line = line.rstrip("\n")
        # Get the desired data
        dt = line.split()[1]
        dt = datetime.strptime(dt, "%Y-%m-%d::%H:%M:%S")
        min_value = float(line.split()[3])
        max_value = float(line.split()[4])
        # Append the desired data to the lists
        dt_list.append(dt)
        min_value_list.append(min_value)
        max_value_list.append(max_value)
    # Close the file
    f.close()
    # Define a list of lists, containing the desired data, and return it
    data = [dt_list, min_value_list, max_value_list]
    return data

# Plot the desired data
def data_plot(dt, min_value, max_value, title, xaxis_name, yaxis_name, fig_name):
    # Define the font size of the title
    title_size = 11
    # Define the font size of the axes
    axes_name_size = 9
    # Define the size of ticks labels
    axes_labels_size = 9
    # Define the colors for minimum and maximum data
    color_min = "blue"
    color_max = "red"
    # Define the type and size of the points to be plotted, and their outline
    point_size = 10
    point_type = "."
    point_outline = 0
    # Define the legend labels
    label_min = "Min."
    label_max = "Max."
    # Define the size of the legend and its marker scale
    legend_size = "x-small"
    legend_markerscale = 3.

    # Draw the figure
    fig, ax = plt.subplots()
    # Set the title
    plt.title(title, fontsize = title_size)
    # Plot the desired data
    plt.scatter(dt, min_value, marker = point_type, s = point_size, color = color_min, label = label_min, linewidths = point_outline)
    plt.scatter(dt, max_value, marker = point_type, s = point_size, color = color_max, label = label_max, linewidths = point_outline)
    # Set axes names
    plt.xlabel(xaxis_name, fontsize = axes_name_size)
    plt.ylabel(yaxis_name, fontsize = axes_name_size)
    # Set the x- and y-axis labels
    plt.setp(ax.get_xticklabels(), ha = "right", rotation = 30, fontsize = axes_labels_size)
    plt.setp(ax.get_yticklabels(), fontsize = axes_labels_size)
    # Set minor ticks on axes
    ax.xaxis.set_minor_locator(AutoMinorLocator())
    ax.yaxis.set_minor_locator(AutoMinorLocator())
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
from datetime import datetime
import matplotlib.pyplot as plt
from matplotlib.ticker import AutoMinorLocator

# Define the name of the data file containing the minimum and maximum value of
# sea temperature, of the whole domain (template variable, to be replaced
# through a "sedfile")
filename_T = "%%INF_FILE_GREP_T%%"
# Define the name of the data file containing the minimum and maximum value of
# salinity, of the whole domain (template variable, to be replaced through a
# "sedfile")
filename_S = "%%INF_FILE_GREP_S%%"

# Function calling: collect the desired data from the given file (for sea
# temperature)
dt_T = data_collect(filename_T)[0]
min_T = data_collect(filename_T)[1]
max_T = data_collect(filename_T)[2]
# Function calling: collect the desired data from the given file (for salinity)
dt_S = data_collect(filename_S)[0]
min_S = data_collect(filename_S)[1]
max_S = data_collect(filename_S)[2]

# Function calling: plot the desired data (for sea temperature); template
# variables are employed, to be replaced through a "sedfile"
data_plot(dt_T, min_T, max_T, "%%TITLE_INF%%", "%%XAXIS_INF%%", "%%YAXIS_INF_T%%", "%%FIGNAME_INF_T%%")
# Function calling: plot the desired data (for salinity); template variables
# are employed, to be replaced through a "sedfile"
data_plot(dt_S, min_S, max_S, "%%TITLE_INF%%", "%%XAXIS_INF%%", "%%YAXIS_INF_S%%", "%%FIGNAME_INF_S%%")

#  --- END OF MAIN ---

# ----------------------
#  END OF PYTHON SCRIPT
# ----------------------

EOF

# Check the outcome of the preparation of the Python script:
#  - if all went OK
if [[ $? -eq 0 ]]; then
    # Inform the user
    echo -e "\tScript: ${py_script} successfully created.\n"
#  - if something went KO
else
    # Inform the user and exit with an error
    echo -e "\tERROR! Script: ${py_script} unsuccessfully created. EXIT...\n"
    EXIT_STATUS=1; exit $EXIT_STATUS
fi

# Run the Python script created through the "here document"
python ./$py_script || OKKO=1

# Check the outcome of the execution of the Python script:
#  - if all went OK
if [[ $OKKO -eq 0 ]]; then
    # Inform the user and remove the Python script
    echo -e "\tScript: ${py_script} successfully run.\n"
    rm $py_script; echo -e "\tScript: ${py_script} removed.\n"
    echo -e "\tScript: ${py_script} removed.\n"
#  - if something went KO
else
    # Inform the user and exit with an error
    echo -e "\tERROR! Script: ${py_script} unsuccessfully run. EXIT...\n"
    EXIT_STATUS=1; exit $EXIT_STATUS
fi

# ************
#  END OF JOB
# ************
