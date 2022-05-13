#!/bin/bash

# ******************************************************************************
#
#  DESCRIPTION:    this job template is aimed at creating and running a
#                  Python 3 script, the aim of which is described in the
#                  following.
#                  The Python 3 script created through this job template is
#                  aimed at comparing two simulations of the same oceanographic
#                  variable, collected at the same geographic points (EXT nodes)
#                  and depths, by overlapping the two datasets on the same time
#                  series plot. Specifically, a time series plot is drawn for
#                  each geographic point to be analysed and for each depth
#                  (layer, in case of 3D variables) at which the desired
#                  variable is referred.
#                  Moreover, the Python 3 script is aimed at computing and
#                  printing in an output file (see the EXTERNAL FILES comment
#                  section), the time series of the differences between the two
#                  simulations to be compared and of the sums of the differences
#                  themselves, computed from each time step onwards.
#                  Specifically, this is carried out for a certain variable and
#                  for each EXT node and vertical layer (3D variables) to be
#                  analysed.
#                  Files providing the two simulations to be compared have to
#                  be formatted as explained in the EXTERNAL FILES comment
#                  section.
#
#  EXTERNAL CALLS: none.
#
#  EXTERNAL FILES: - couples of SHYFEM simulations, time series ASCII files
#                    (splitted/unpacked EXT files) arranged in two or more
#                    columns, the first containing date and time (formatted as
#                    YYYY-MM-DD::hh:mm:ss), while the others containing actual
#                    oceanographic data, referred to a specific vertical layer
#                    (2nd column -> layer 1, 3rd column -> layer 2, etc.).
#                    Columns are separated by "white" spaces.
#                    It is worth noting that for 2D variables, there are only
#                    two columns and a reference layer can not be specified
#                    (for the water level, the reference is the sea surface).
#                    The basename of these files has to be of the following
#                    type:
#
#                    "what.dim.node", where
#
#                     -- "what" is the abbreviation of the variable (e.g.
#                        "temp", "salt", "velx", "vely", "zeta");
#                     -- "dim" is the dimensionality ("2d" or "3d");
#                     -- "node" is consecutive EXT node numbering (e.g. "1" for
#                        EXT node 1, "2" for EXT node 2, etc.).
#                        EXT nodes are those specified in the "$extra" section
#                        of the STR parameter input file of the SHYFEM model.
#
#                  - input file containing information about EXT nodes (it is
#                    the standard output of the splitting/unpacking process of
#                    EXT files, through the "shyelab" SHYFEM model's intrinsic
#                    routine).
#
#                  - output ASCII file containing the time series of the
#                    differences between the two simulations to be compared
#                    (for a certain variable and for each EXT node and vertical
#                    layer to be analysed) and of the sums of the differences
#                    themselves, computed from each time step onwards; this
#                    file is formatted in tab-separated columns, as shown
#                    below:
#
#                    # Lines of metadata (preceded by a "#")
#                    column1    column2    column3    column4    column5
#
#                    with
#
#                     -- "column1" dedicated to EXT nodes;
#                     -- "column2" dedicated to vertical layers (3D variables);
#                     -- "column3" dedicated to the time step t (date and time,
#                        in the format YYYY-MM-DD hh:mm:ss)
#                     -- "column4" dedicated to the difference between the two
#                        simulations at time step t;
#                     -- "column5" dedicated to the sum of the differences
#                         between the two simulations, computed from time step
#                         t onwards.
#
#  DEVELOPER:      Alessandro Minigher (alessandro.minigher@arpa.fvg.it)
#                  ARPA FVG - S.O.C. Stato dell'Ambiente - CRMA
#                  "AdriaClim" Interreg IT-HR project
#
#  CREATION DATE:  2021-10-18.
#
#  MODIFICATIONS:  2021-10-19 -> post-processing files (e.g. plots) moved to
#                                a dedicated directory.
#                  2021-10-22 -> bug fixing in the estimation of the spin-up
#                                time through the double "while" cycle (the
#                                external one could be endless).
#                  2021-10-25 -> improvement in the description of the job
#                                template;
#                             -> improvement in some details;
#                             -> introduction of the variable named
#                                SHY_POSTPROC_SPINUP_SIMS_VAR_DIR;
#                             -> removal of the function named
#                                "spinup_file_name_form".
#                  2021-10-27 -> if there is no spin-up, set it to "inf"
#                                (infinite), instead of "nan" (Not a Number).
#                  2021-10-28 -> introduction of three new functions, named
#                                "get_var_dim", "column_index_4_2D_var" and
#                                "sum_diff_file_header" (version 1.0).
#                  2021-10-29 -> job directives are now assigned through
#                                template variables;
#                             -> introduction of new functions and important
#                                improvements in some of the older ones
#                                (version 2.0).
#                  2021-11-05 -> removal of all the stuff related to the
#                                estimation of the spin-up time according to a
#                                given threshold (version 3.0);
#                             -> improvement in some details and in the
#                                description of the job template.
#                  2021-11-10 -> introduction of the new functions named
#                                "get_EXTnodes_file" and "get_EXTnode_info";
#                             -> modification of the function named
#                                "fig_title_form".
#                  2021-11-21 -> compression of figures in a "tar.gz" archive.
#
#  VERSION:        3.2.
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
echo -e "\n\tChange directory: moving to ${PBS_O_WORKDIR}.\n"; cd $PBS_O_WORKDIR
echo -e "\tCurrent directory: $(pwd).\n"

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
# Define the name of the desired Python script to create
py_script="EXT_time_series_plotter_cp.py"

# Create the desired Python script through a "here document"
cat <<EOF > ./$py_script

# ------------------------
#  START OF PYTHON SCRIPT
# ------------------------

#  --- START OF FUNCTIONS ---

# Get the number of columns of a file (columns are separated by "white" spaces)
def get_columns(filename):
    # Open the desired file and remove possible comments (metadata) by the use
    # of Bash-like commands (comments are lines starting with "#")
    cat = subprocess.Popen(['cat', filename], close_fds=True, stdout=subprocess.PIPE)
    grep = subprocess.Popen('grep -v "^#"', shell=True, stdin=cat.stdout, stdout=subprocess.PIPE)
    # Read and decode the first line of the file, splitting its content in
    # columns (decoding is required due to the previous use of Bash-like
    # commands)
    line = grep.stdout.readline().decode("utf-8").split()
    # Close the file
    grep.stdout.close()
    # Get the number of columns and return it
    N_columns = len(line)
    return N_columns

# Get the desired data from a file: first (date and time) and i-th (actual
# data) column (columns are separated by "white" spaces)
def get_data(filename, ith_column_index):
    # Open the desired file and remove possible comments (metadata) by the use
    # of Bash-like commands (comments are lines starting with "#")
    cat = subprocess.Popen(['cat', filename], close_fds=True, stdout=subprocess.PIPE)
    grep = subprocess.Popen('grep -v "^#"', shell=True, stdin=cat.stdout, stdout=subprocess.PIPE)
    # Read all the lines of the file (without comments)
    lines = grep.stdout.readlines()
    # Create two empty lists to be used to collect the desired data
    first_column = []
    ith_column = []
    # For each line of the file (without comments)
    for data in lines:
        # Append the data arranged in the first (date and time) and i-th
        # (actual data) column (decoding is required due to the previous use of
        # Bash-like commands)
        first_column.append(data.decode("utf-8").split()[0])
        ith_column.append(float(data.decode("utf-8").split()[ith_column_index - 1]))
    # Close the file
    grep.stdout.close()
    # Define a list of lists, containing all the desired data, and return it
    data = [first_column, ith_column]
    return data

# Format the date and time by building "datetime" objects, starting from
# strings ("YYYY-MM-DD::hh:mm:ss")
def dt_format(dt_list):
    # Define an empty list to be filled with formatted date and time
    dt_form_list = []
    # For each element in the list to be formatted
    for dt in dt_list:
        # Build a "datetime" object (from a string formatted as
        # YYYY-MM-DD::hh:mm:ss) and append it to the list
        dt_form = datetime.strptime(dt, "%Y-%m-%d::%H:%M:%S")
        dt_form_list.append(dt_form)
    # Return the list containing formatted date and time
    return dt_form_list

# Get the overlapping time period of the simulations to be compared
def get_dt_range(xA, xB):
    # Get the starting and ending date and time of the overlapping time period
    # of the simulations to be compared
    dt_start = max(xA[0], xB[0])
    dt_end = min(xA[len(xA) - 1], xB[len(xB) - 1])
    # Define a list containing the starting and ending date and time, and
    # return it
    dt_range = [dt_start, dt_end]
    return dt_range

# Check if the simulations to be compared overlap in time
def check_overlapping(dt_start, dt_end):
    # If there is no overlapping
    if (dt_start > dt_end):
        # Inform the user and exit
        print("\n\tWARNING! Comparison cannot be performed: simulations do not overlap in time.\n")
        exit()
    return

# Get the desired data (time series) in a given time period (overlapping time
# period of the simulations to be compared)
def get_data_in_dt_range(x, y, dt_start, dt_end):
    # Define two empty lists to be filled with the desired data (time series)
    # belonging to a given time period
    x_new = []   # date and time
    y_new = []   # actual data
    # For each time step
    for i in range(0, len(x)):
        # If it belongs to the given time period
        if (x[i] >= dt_start and x[i] <= dt_end):
            # Fill the lists
            x_new.append(x[i])
            y_new.append(y[i])
    # Define a list of lists, containing all the desired data, and return it
    xy_new = [x_new, y_new]
    return xy_new

# Format the desired index
def index_form(index):
    # If the index is smaller than 10
    if (index < 10):
        # Format it properly and convert it to a string
        index = "0" + str(index)
    # If the index is larger or equal than 10
    else:
        # Convert it to a string
        index = str(index)
    # Return the formatted index
    return index

# Get the variable, and its dimensionality (2D or 3D), under analysis (e.g.
# temp.3d. -> temp, 3d; zeta.2d. -> zeta, 2d)
def get_var_dim(var_dim):
    # Get the variable and its dimensionality
    var = var_dim.split(".")[0]
    dim = var_dim.split(".")[1]
    # Define a list containing the variable and its dimensionality, and return
    # it
    var_dim_out = [var, dim]
    return var_dim_out

# Set a dummy vertical layer number ("--"), if the variable under analysis is
# 2D
def column_index_4_2D_var(dim, layer):
    # If the variable is 2D
    if (dim == "2d"):
        # There is no vertical layer, hence set its number to a dummy value
        layer = "--"
    return layer

# Get the EXT nodes list and associated information only from an input file
# containing them, printing the desired content to an output file
def get_EXTnodes_file(filename_in, string_start, string_end):
    # Define the name of an output file, in which storing the desired
    # information retrieved in the input file
    filename_out = "nodes_info.txt"
    # Open the input file in reading mode and the output file in writing mode
    f_in = open(filename_in, "r")
    f_out = open(filename_out, "w")
    # Define a logic variable to be used for driving the research of the
    # desired lines of the input file:
    #  - False -> do not consider the line
    #  - True  -> consider the line
    sel_line = False
    # For each line in the input file
    for line in f_in:
        # Remove the "new line"
        line = line.rstrip("\n")
        # If the current line is the first to be considered
        if (line == string_start):
            # Switch the logic variable and continue
            sel_line = True
            continue
        # If the current line is the first not to be considered
        elif (line == string_end):
            # Switch the logic variable and break the research
            sel_line = False
            break
        # If the current line lies between the first to be considered and the
        # first not to be considered
        elif sel_line:
            # Print the line in the temporary file
            print(line, file = f_out)
    # Close the files
    f_in.close()
    f_out.close()
    # Return the name of the output file
    return filename_out

# Get the desired information about EXT nodes from an input file
def get_EXTnode_info(filename, extnode_index):
    # Open the input file in reading mode
    f = open(filename, "r")
    # Read the line of the file corresponding to the desired EXT node, removing
    # the "new line"
    line = f.readlines()[extnode_index]
    line = line.rstrip("\n")
    # Get the desired content from the line
    i_EXT = line.split()[0]        # index of the EXT node
    i_mesh = line.split()[1]       # index of the node of the computational
                                   # mesh corresponding to the EXT node
    n_layers = line.split()[2]     # number of vertival layers
    bathymetry = line.split()[3]   # bathymetry
    lon = line.split()[4]          # longitude
    lat = line.split()[5]          # latitude
    node_name = line.split()[6]    # name of the EXT node
    # Define a list containing all the desired information and return it
    info_list = [i_EXT, i_mesh, n_layers, bathymetry, lon, lat, node_name]
    return info_list

# Format the title of the figure
def fig_title_form(dim, file_index, column_index, lon, lat, node_name):
    # If the variable to be plotted is 2D
    if (dim == "2d"):
        # Create the desired title properly
        title = "EXT node " + str(file_index) + " (" + node_name + "; " + lon + " °E, " + lat + " °N)"
    # Otherwise (if the variable to be plotted is 3D)
    else:
        # Create the desired title properly
        title = "EXT node " + str(file_index) + " (" + node_name + "; " + lon + " °E, " + lat + " °N)" + ", layer " + str(column_index - 1)
    # Return the desired title
    return title

# Format the basename of the figure
def fig_name_form(var, dim, file_index, column_index, simA, simB, fig_format):
    # If the variable to be plotted is 2D
    if (dim == "2d"):
        # Build the basename of the figure properly
        fig_name = var + "_" + simA + "-" + simB + "_EXTnode" + index_form(file_index) + fig_format
    # Otherwise (if the variable to be plotted is 3D)
    else:
        # Build the basename of the figure properly
        fig_name = var + "_" + simA + "-" + simB + "_EXTnode" + index_form(file_index) + "-layer" + index_form(column_index - 1) + fig_format
    # Return the desired basename
    return fig_name

# Build a time series plot, overlapping two datasets on the same graph
def plot_time_series(xA, yA, xB, yB, var, dim, file_index, column_index, EXT_nodes_filename):
    # Function calling: get the desired information about EXT nodes from an
    # input file
    lon = get_EXTnode_info(EXT_nodes_filename, file_index)[4]
    lat = get_EXTnode_info(EXT_nodes_filename, file_index)[5]
    node_name = get_EXTnode_info(EXT_nodes_filename, file_index)[6]
    # Define the size of the figure to be plotted
    fig_length = 16
    fig_height = 12
    # Define the title (function calling, with a template variable, to be
    # replaced through a "sedfile") of the figure and its font size
    title = fig_title_form(dim, file_index, column_index, lon, lat, node_name)
    title_size = 21
    # Define the x- and y-axis names (template variables, to be replaced
    # through a "sedfile") and their font size
    xaxis_name = "%%XAXIS%%"
    yaxis_name = "%%YAXIS%%"
    axes_fontsize = 19
    # Define the x- and y-axis labels fontsize
    axes_labels_fontsize = 15
    # Define the size of the points to be plotted
    point_size = 1
    # Define the legend labels (template variables, to be replaced through a
    # "sedfile")
    simulationA = "%%SIMA%%"
    simulationB = "%%SIMB%%"
    # Define the size of the legend of the plot and its marker scale
    legend_size = "x-large"
    legend_markerscale = 5.
    # Define the name of the figure (function calling, with template variables,
    # to be replaced through a "sedfile")
    fig_name = fig_name_form(var, dim, file_index, column_index, "%%SIMA%%", "%%SIMB%%", "%%FIG_FORMAT%%")

    # Draw the figure
    fig, ax = plt.subplots(figsize = (fig_length, fig_height))
    # Set the title of the figure
    plt.title(title, fontsize = title_size)
    # Plot the desired data (scatter plot)
    plt.scatter(xA, yA, s = point_size, color = "red", label = simulationA)
    plt.scatter(xB, yB, s = point_size, color = "blue", label = simulationB)
    # Set the x- and y-axis names
    plt.xlabel(xaxis_name, fontsize = axes_fontsize)
    plt.ylabel(yaxis_name, fontsize = axes_fontsize)
    # Set the x- and y-axis labels
    plt.setp(ax.get_xticklabels(), ha = "right", rotation = 30, fontsize = axes_labels_fontsize)
    plt.setp(ax.get_yticklabels(), fontsize = axes_labels_fontsize)
    # Set minor axes ticks
    ax.xaxis.set_minor_locator(AutoMinorLocator())
    # Draw the grid
    ax.grid()
    # Set the legend
    ax.legend(fontsize = legend_size, markerscale = legend_markerscale)
    # Save and close the figure
    plt.savefig(fig_name, bbox_inches = "tight")
    plt.close(fig)
    return

# Get the time series of the differences between the two simulations to be
# compared and of the sums of the differences themselves, computed from each
# time step onwards (the two simulations have to be provided in the overlapping
# time period only)
def get_diff_sum_diff(xA, yA, xB, yB):
    # Check if the two simulations are provided in the overlapping time period
    # only:
    #  -if not
    if (xA[0] != xB[0] or xA[len(xA) - 1] != xB[len(xB) - 1] or len(xA) != len(xB)):
        # Inform the user and exit with an error
        print("\n\tERROR! Simulations must be provided for the overlapping time period only. Please check.\n")
        exit(1)
    # Define the decimal place at which rounding the results
    dec_4_round = 3
    # Define two empty list to be filled with the differences (subtractions) of
    # the two time series to be compared and the sums of the differences
    # themselves, computed from each time step onwards
    diff_list = []
    sum_diff_list = []
    # For each time step
    for i in range(0, len(xA)):
        # Compute the difference (subtraction) of the two time series to be
        # compared (in absolute value), rounding the result, and fill the list
        diff = round(abs(yB[i] - yA[i]), dec_4_round)
        diff_list.append(diff)
    # Compute the sum of the differences of the two time series to be compared,
    # rounding the result, and fill the list
    sum_diff = round(sum(diff_list), dec_4_round)
    sum_diff_list.append(sum_diff)
    # For each time step, except from the first
    for i in range (1, len(xA)):
        # Compute the sum of the differences of the two time series to be
        # compared, from this time step onwards, rounding the result, and fill
        # the list
        sum_diff = round(sum_diff - diff_list[i-1], dec_4_round)
        sum_diff_list.append(sum_diff)
    # Define a list of lists, containing the time series of the difference of
    # the two simulations and the sums of the differences themselves, computed
    # from each time step onwards, and return it
    ts_diff_sum_diff = [xA, diff_list, sum_diff_list]
    return ts_diff_sum_diff

# Build the header of the file containing the time series of the differences
# between the two simulations to be compared and of the sums of the differences
# themselves, computed from each time step onwards
def sum_diff_file_header(filename, simA, simB, var, dim):
    # Open the file in writing mode
    f = open(filename, "w")
    # Build the header of the file
    print("# %s %s" % ("SIMA:", simA), file = f)
    print("# %s %s" % ("SIMB:", simB), file = f)
    print("# %s %s" % ("VAR: ", var), file = f)
    print("# %s %s" % ("DIM: ", dim), file = f)
    print("#", file = f)
    print("# Columns description:", file = f)
    print("# 1) EXT node", file = f)
    print("# 2) Layer (only for 3D variables)", file = f)
    print("# 3) Time t (YYYY-MM-DD hh:mm:ss)", file = f)
    print("# 4) VAR(SIMA, t) - VAR(SIMB, t) [VAR units]", file = f)
    print("# 5) Sum of (VAR(SIMA, t_i) - VAR(SIMB, t_i)), for t_i >= t [VAR units]", file = f)
    # Close the file
    f.close()
    return

# Format and print the desired content in the file containing the time series
# of the differences between the two simulations to be compared and of the sums
# of the differences themselves, computed from each time step onwards
def print_diff_sum_diff(filename, dim, file_index, column_index, dt_list, diff_list, sum_diff_list):
    # Function calling: set a dummy vertical layer number ("--"), if the
    # variable under analysis is 2D
    column_index = column_index_4_2D_var(dim, column_index)
    # Open the desired file in appending mode
    f = open(filename, "a")
    # For each time step
    for i in range (0, len(dt_list)):
        # Append the desired content (tab-separated) to the file
        print("%s\t%s\t%s\t%s\t%s" % (file_index, column_index, dt_list[i], diff_list[i], sum_diff_list[i]), file = f)
    # Close the file
    f.close()
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

# Define part of the name (full path) of the files to be compared (the entire
# basename of these files will be completed in the following, by adding a
# progressive integer number; e.g. temp.3d. --> temp.3d.1, temp.3d.2, etc.);
# template variables, to be replaced through a "sedfile", are employed
filenameA_tmp = "%%FILEA%%"
filenameB_tmp = "%%FILEB%%"
# Define the basename of the output file, aimed at containing the time series
# of the differences between the two simulations to be compared and of the sums
# of the differences themselves, computed from each time step onwards (template
# variable, to be replaced through a "sedfile")
SPINUP_SUM_DIFF_FILENAME = "%%SPINUP_SUM_DIFF_FILENAME%%"
# Function calling: get the EXT nodes list and associated information only from
# an input file containing them, printing the desired content to an output file
# (template variables are employed, to be replaced through a "sedfile")
EXT_nodes_filename = get_EXTnodes_file("%%EXT_NODES_FILE%%", "%%EXT_NODES_INFO_START%%", "%%EXT_NODES_INFO_END%%")
# Function calling: get the variable, and its dimensionality (2D or 3D), under
# analysis (e.g. temp.3d. -> temp, 3d; zeta.2d. -> zeta, 2d); a template
# variable is employed, to be replaced through a "sedfile"
var = get_var_dim("%%TOPROC%%")[0]
dim = get_var_dim("%%TOPROC%%")[1]

# Function calling: build the header of the file containing the time series of
# the differences between the two simulations to be compared and of the sums of
# the differences themselves, computed from each time step onwards; template
# variables are employed, to be replaced through a "sedfile"
sum_diff_file_header(SPINUP_SUM_DIFF_FILENAME, "%%SIMA%%", "%%SIMB%%", var, dim)

# Initialise the default status for files comparison
finished = False
# Initialise a file (EXT node) index
i = 1
# For each couple of files to be compared
while not finished:
    # Complete the full name of the data files to be compared
    filenameA = filenameA_tmp + str(i)
    filenameB = filenameB_tmp + str(i)
    # If at least one of the data files to be compared does not exist
    if (os.path.isfile(filenameA) == False or os.path.isfile(filenameB) == False):
        # Switch the status for files comparison and continue
        finished = True
        continue
    # Function calling: get the number of columns of files (it is assumed that
    # both files to be compared contain the same number of columns)
    N_columns = get_columns(filenameA)
    # For each column in files (apart from the first, hence starting from the
    # second)
    for ith_column_index in range(2, N_columns + 1):
        # Function calling: get the desired data from a file (first and i-th
        # column)
        dataA = get_data(filenameA, ith_column_index)
        dataB = get_data(filenameB, ith_column_index)
        # Extract and format (function calling) data to be plotted on x- and
        # y-axes
        xA = dt_format(dataA[0])   # time (first simulation)
        yA = dataA[1]              # actual data (first simulation)
        xB = dt_format(dataB[0])   # time (second simulation)
        yB = dataB[1]              # actual data (second simulation)
        # Function calling: get the overlapping time period of the simulations
        # to be compared
        dt_start = get_dt_range(xA, xB)[0]
        dt_end = get_dt_range(xA, xB)[1]
        # Function calling: check if the simulations to be compared overlap in
        # time
        check_overlapping(dt_start, dt_end)
        # Function calling: build a time series plot, overlapping two datasets
        # on the same graph
        plot_time_series(xA, yA, xB, yB, var, dim, i, ith_column_index, EXT_nodes_filename)
        # Function calling: get the desired data (time series) in a given time
        # period (overlapping time period of the simulations to be compared)
        xA_new = get_data_in_dt_range(xA, yA, dt_start, dt_end)[0]
        yA_new = get_data_in_dt_range(xA, yA, dt_start, dt_end)[1]
        xB_new = get_data_in_dt_range(xB, yB, dt_start, dt_end)[0]
        yB_new = get_data_in_dt_range(xB, yB, dt_start, dt_end)[1]
        # Function calling: get the time series of the differences between the
        # two simulations to be compared and of the sums of the differences
        # themselves, computed from each time step onwards (the two simulations
        # have to be provided in the overlapping time period only)
        ts_diff_sum_diff = get_diff_sum_diff(xA_new, yA_new, xB_new, yB_new)
        dt_list = ts_diff_sum_diff[0]         # date and time
        diff_list = ts_diff_sum_diff[1]       # differences
        sum_diff_list = ts_diff_sum_diff[2]   # sum of differences
        # Function calling: format and print the desired content in the file
        # containing the time series of the differences between the two
        # simulations to be compared and of the sums of the differences
        # themselves, computed from each time step onwards
        print_diff_sum_diff(SPINUP_SUM_DIFF_FILENAME, dim, index_form(i), index_form(ith_column_index - 1), dt_list, diff_list, sum_diff_list)
    # Increase the file (EXT node) index by one unit
    i = i + 1

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
    # Move the desired content (post-processing files) to the directory,
    # after compressing figures (template variables, to be replaced through a
    # "sedfile")
    tar -czf "%%TIME_SERIES_PLOTS_ARCHIVE%%" *"%%FIG_FORMAT%%"
    mv "%%TIME_SERIES_PLOTS_ARCHIVE%%" $SHY_POSTPROC_SPINUP_SIMS_VAR_DIR
    mv "%%SPINUP_SUM_DIFF_FILENAME%%" $SHY_POSTPROC_SPINUP_SIMS_VAR_DIR
    echo -e "\n\tDirectory: $(pwd), post-processing files moved to ${SHY_POSTPROC_SPINUP_SIMS_VAR_DIR}.\n"
#  - if something went KO
else
    # Inform the user and exit with an error
    echo -e "\tERROR! Directory: ${SHY_POSTPROC_SPINUP_SIMS_VAR_DIR} unsuccessfully created. EXIT...\n"
    EXIT_STATUS=1; exit $EXIT_STATUS
fi

# ************
#  END OF JOB
# ************
