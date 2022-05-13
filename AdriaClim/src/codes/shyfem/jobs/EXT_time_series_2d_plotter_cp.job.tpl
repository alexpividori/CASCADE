#!/bin/bash

# ******************************************************************************
#
#  DESCRIPTION:    this job template is aimed at creating and running a
#                  Python 3 script, the aim of which is described in the
#                  following.
#                  The Python 3 script created through this job template is
#                  aimed at plotting, on the same graph, the time series of a
#                  certain variable, for a set of EXT nodes (namely nodes of
#                  SHYFEM's computational mesh, for which outputs are produced
#                  with higher frequency).
#
#  EXTERNAL CALLS: none.
#
#  EXTERNAL FILES: - set of EXT ASCII files (2D), namely files obtained by
#                    splitting/unpacking SHYFEM's EXT (.ext) file (vertically
#                    averaged files). These time series files are characterized
#                    by a top line of metadata (starting with "#") and are
#                    arranged in the two following columns:
#                     1) date and time (YYYY-MM-DD::hh:mm:ss);
#                     2) floating point variable.
#
#  DEVELOPER:      Alessandro Minigher (alessandro.minigher@arpa.fvg.it)
#                  ARPA FVG - S.O.C. Stato dell'Ambiente - CRMA
#                  "AdriaClim" Interreg IT-HR project
#
#  CREATION DATE:  2021-01-13.
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
echo -e "\tChange directory: moving to ${PBS_O_WORKDIR}..."; cd $PBS_O_WORKDIR
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
py_script="EXT_time_series_2d_plotter_cp.py"

# Create the desired Python script through a "here document"
cat <<EOF > ./$py_script

# ------------------------
#  START OF PYTHON SCRIPT
# ------------------------

#  --- START OF FUNCTIONS ---

# Get the data (time series) to be plotted from a given file, where metadata
# lines start with the "#" character and data are arranged in two columns (1.
# date and time, YYYY-MM-DD::hh:mm:ss; 2. variable)
def get_data (filename):
    # Define two empty lists to be used to store the data to be plotted
    dt_list = []
    var_list = []
    # Open the file and remove comments (metadata) by the use of Bash-like
    # commands
    cat = subprocess.Popen(['cat', filename], close_fds=True, stdout=subprocess.PIPE)
    grep = subprocess.Popen('grep -v "^#"', shell=True, stdin=cat.stdout, stdout=subprocess.PIPE)
    # For each line of the file (data only)
    for line in grep.stdout:
        # Decode the line (required due to the previous use of Bash-like
        # commands) and remove the "new line"
        line = line.decode("utf-8")
        line = line.rstrip("\n")
        # Get the desired data
        dt = line.split()[0]
        dt = datetime.strptime(dt, "%Y-%m-%d::%H:%M:%S")
        var = float(line.split()[1])
        # Append the data to the lists
        dt_list.append(dt)
        var_list.append(var)
    # Close the file
    grep.stdout.close()
    # Define a list of lists, containing the data, and return it
    data = [dt_list, var_list]
    return data

# Plot the time series of a certain variable, for all the desired EXT nodes, on
# the same graph
def plot_data (ext_nodes_2_plot, var_2_plot, title, xaxis_name, yaxis_name, figname):
    # Define the font size of the title
    title_size = 11
    # Define the font size of the axes
    axes_name_size = 9
    # Define the size of ticks labels
    axes_labels_size = 9
    # Define the type and size of the points to be plotted
    point_size = 1.
    point_type = "."
    # Define the width of the line connecting points
    line_size = 1.
    # Define the size of the legend and its marker scale
    legend_size = "x-small"
    legend_markerscale = 3.

    # Draw the figure
    fig, ax = plt.subplots()
    # Set the title
    plt.title(title, fontsize = title_size)

    # For each EXT node to be considered
    for node in ext_nodes_2_plot:
        # Define the basename of the data (time series) file, by knowing that
        # this is of the type "what.dim.node", where "what" is the abbreviation
        # of the variable to be plotted (e.g. "temp", "salt", "zeta"), "dim" is
        # its dimensionality (e.g. "2d", "3d") and "node" is the ID of the EXT
        # node for which the variable is generated
        filename = var_2_plot + str(node)
        # If the data file does not exist, inform the user and skip to the next
        # one (if present)
        if (os.path.isfile(filename) != True):
            print("\tWARNING! File: %s does not exist. Please check. Skip to the next file...\n", filename)
            continue
        # Function calling: get the data to be plotted
        dt = get_data(filename)[0]
        var = get_data(filename)[1]

        # Define the legend label
        label = "EXT node " + str(node)
        # Plot the data
        plt.plot(dt, var, marker = point_type, markersize = point_size, linewidth = line_size, label = label)

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
    plt.savefig(figname, bbox_inches = "tight")
    plt.close(fig)
    return

#  --- END OF FUNCTIONS ---

#  --- START OF MAIN ---

# Import the desired modules
import subprocess
import os
import numpy as np
import matplotlib.pyplot as plt
from datetime import datetime
from matplotlib.ticker import AutoMinorLocator

# Function calling: plot the desired data (template variables are employed, to
# be replaced through a "sedfile") for
#  - temperature
plot_data(%%EXT_NODES_2_PLOT%%, "%%VAR_EXT_T%%", "%%TITLE_EXT%%", "%%XAXIS_EXT%%", "%%YAXIS_EXT_T%%", "%%FIGNAME_EXT_T%%")
#  - salinity
plot_data(%%EXT_NODES_2_PLOT%%, "%%VAR_EXT_S%%", "%%TITLE_EXT%%", "%%XAXIS_EXT%%", "%%YAXIS_EXT_S%%", "%%FIGNAME_EXT_S%%")
#  - water level
plot_data(%%EXT_NODES_2_PLOT%%, "%%VAR_EXT_Z%%", "%%TITLE_EXT%%", "%%XAXIS_EXT%%", "%%YAXIS_EXT_Z%%", "%%FIGNAME_EXT_Z%%")

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
#  - if something went KO
else
    # Inform the user and exit with an error
    echo -e "\tERROR! Script: ${py_script} unsuccessfully run. EXIT...\n"
    EXIT_STATUS=1; exit $EXIT_STATUS
fi

# ************
#  END OF JOB
# ************
