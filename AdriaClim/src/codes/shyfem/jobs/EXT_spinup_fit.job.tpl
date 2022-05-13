#!/bin/bash

# ******************************************************************************
#
#  DESCRIPTION:    this job template is aimed at creating and running a
#                  Python 3 script, the aim of which is described in the
#                  following.
#                  The Python 3 script created through this job template is
#                  aimed at estimating the spin-up time of the numerical model
#                  providing the couple of simulations to be compared,
#                  according to a regression analysis. Specifically, the
#                  spin-up time is estimated for a certain oceanographic
#                  variable and for all the EXT nodes and layers (3D
#                  variables) to be analysed, and printed in an output file
#                  (see the EXTERNAL FILES comment section). The fit is
#                  performed on the time series of the sum of the differences
#                  between the two simulations, computed from each time step
#                  onward, and the regression function is piecewise and
#                  continuous.
#                  All the regression plots are drawn.
#                  Files providing the sum of the differences between the two
#                  simulations, computed from each time step onward, have to be
#                  formatted as explained in the EXTERNAL FILES comment
#                  section.
#
#  EXTERNAL CALLS: none.
#
#  EXTERNAL FILES: - input ASCII file containing the time series of the
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
#                  - input file containing information about EXT nodes (it is
#                    the standard output of the splitting/unpacking process of
#                    EXT files, through the "shyelab" SHYFEM model's intrinsic
#                    routine).
#
#                  - output ASCII file containing estimates of the spin-up time,
#                    according to the regression analysis, formatted in
#                    tab-separated columns, as shown below:
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
#  DEVELOPER:      Alessandro Minigher (alessandro.minigher@arpa.fvg.it)
#                  ARPA FVG - S.O.C. Stato dell'Ambiente - CRMA
#                  "AdriaClim" Interreg IT-HR project
#
#  CREATION DATE:  2021-11-05.
#
#  MODIFICATIONS:  2021-11-09 -> spin-up time written on regression plots is
#                                now provided in days instead of seconds.
#                  2021-11-10 -> introduction of the new functions named
#                                "get_EXTnodes_file" and "get_EXTnode_info";
#                             -> modification of the function named
#                                "fig_title_form".
#                  2021-11-16 -> addition of the subtitle of the figures.
#                  2021-11-21 -> compression of figures in a "tar.gz" archive.
#
#  VERSION:        0.5.
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
py_script="EXT_spinup_fit.py"

# Create the desired Python script through a "here document"
cat <<EOF > ./$py_script

# ------------------------
#  START OF PYTHON SCRIPT
# ------------------------

#  --- START OF FUNCTIONS ---

# Get the desired data from an input file, arranged in tab-separated columns
def get_data(filename):
    # Define the columns separator (delimiter)
    delimiter = "\t"
    # Define empty lists, to be filled with the desired data
    ext_nodes_list = []
    layers_list = []
    dts_list = []
    diffs_list = []
    sum_diffs_list = []
    # Open the input file and remove possible comments (metadata) by the use
    # of Bash-like commands (comments are lines starting with "#")
    cat = subprocess.Popen(['cat', filename], close_fds=True, stdout=subprocess.PIPE)
    grep = subprocess.Popen('grep -v "^#"', shell=True, stdin=cat.stdout, stdout=subprocess.PIPE)
    # For each line of the file (without comments)
    for line in grep.stdout:
        # Decode the line (required due to the previous use of Bash-like
        # commands)
        line = line.decode("utf-8")
        # Split the line in columns, on the basis of the delimiter, to get the
        # desired data
        ext_node = line.split(delimiter)[0]
        layer = line.split(delimiter)[1]
        dt = line.split(delimiter)[2]
        diff = float(line.split(delimiter)[3])
        sum_diff = float(line.split(delimiter)[4])
        # Convert the date and time (YYYY-MM-DD hh:mm:ss), from string to
        # "datetime" object
        dt = datetime.strptime(dt, "%Y-%m-%d %H:%M:%S")
        # Fill the lists with the desired data
        ext_nodes_list.append(ext_node)
        layers_list.append(layer)
        dts_list.append(dt)
        diffs_list.append(diff)
        sum_diffs_list.append(sum_diff)
    # Close the file
    grep.stdout.close()
    # Define a list of lists, containing all the desired data, and return it
    data = [ext_nodes_list, layers_list, dts_list, diffs_list, sum_diffs_list]
    return data

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

# Get the EXT nodes list and associated information only from an input file
# containing them, printing the desired content to an output file
def get_EXTnodes_file(filename_in, string_start, string_end):
    # Define the name of an output file, in which temporarily store the desired
    # information retrieved in the input file
    filename_out = "nodes_info.txt"
    # Open the input file in reading mode
    f_in = open(filename_in, "r")
    # Open the output file in writing mode
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
        title = "EXT node " + str(int(file_index)) + " (" + node_name + "; " + lon + " °E, " + lat + " °N)"
    # Otherwise (if the variable to be plotted is 3D)
    else:
        # Create the desired title properly
        title = "EXT node " + str(int(file_index)) + " (" + node_name + "; " + lon + " °E, " + lat + " °N), layer " + str(int(column_index))
    # Return the desired title
    return title

# Format the basename of the figure
def fig_name_form(var, dim, ext_node, layer, simA, simB, fig_format):
    # If the variable under analysis is 2D
    if (dim == "2d"):
        # Build the basename of the figure properly
        fig_name = "fit-" + var + "_" + simA + "-" + simB + "_EXTnode" + str(ext_node) + fig_format
    # Otherwise (if the variable under analysis is 3D)
    else:
        # Build the basename of the figure properly
        fig_name = "fit-" + var + "_" + simA + "-" + simB + "_EXTnode" + str(ext_node) + "-layer" + str(layer) + fig_format
    # Return the desired basename
    return fig_name

# Build the header of the file containing spin-up time estimates
def file_header(filename, simA, simB, var, dim):
    # Open the file in writing mode
    f = open(filename, "w")
    # Build the header of the file
    print("# ************************************************", file = f)
    print("# * REGRESSION ANALYSIS: SPIN-UP TIME ESTIMATION *", file = f)
    print("# ************************************************", file = f)
    print("# %s %s" % ("SIMA:", simA), file = f)
    print("# %s %s" % ("SIMB:", simB), file = f)
    print("# %s %s" % ("VAR: ", var), file = f)
    print("# %s %s" % ("DIM: ", dim), file = f)
    print("#", file = f)
    print("# Columns description:", file = f)
    print("# 1) EXT node", file = f)
    print("# 2) Layer (only for 3D variables)", file = f)
    print("# 3) Spin-up time [s]", file = f)
    print("# 4) R²", file = f)
    print("# 5) Longitude of EXT node (°E)", file = f)
    print("# 6) Latitude of EXT node (°N)", file = f)
    # Close the file
    f.close()
    return

# Get the elapsed seconds between the first date contained in a list of dates
# ("datetime" objects) and the other dates belonging to the same list
def get_elapsed_sec(dt_list):
    # Define an empty list to be filled with the elapsed seconds between the
    # first and the other dates
    elapsed_s_list = []
    # Define the first date
    dt_start = dt_list[0]
    # For each date in the list of dates
    for dt in dt_list:
        # Get the elapsed seconds from the first date (a "datetime" function is
        # employed) and fill the list
        elapsed_s = (dt - dt_start).total_seconds()
        elapsed_s_list.append(elapsed_s)
    # Convert the list to a "numpy" array and return it
    elapsed_s_list = np.array(elapsed_s_list)
    return elapsed_s_list

# Define the piecewise continuous function, to be used to fit the desired data
def piecewise_fit_func(x, x0, a, b, c):
    # Return the desired function: parabolic (a*x**2 + b*x + c) for x<x0,
    # constant otherwise
    return np.piecewise(x, [x < x0], [lambda x:a*x**2 + b*x + c, lambda x:a*x0**2 + b*x0 + c])

# Fit the desired data according to the best-fit piecewise continuous function
# and plot the result
def fit_and_plot(x, y, ext_node, layer, var, dim, filename):
    # Define the decimal place at which rounding the results
    dec_4_round = 3
    # Define the starting parameters, useful to drive the fit (template
    # variables are employed, to be replaced through a "sedfile")
    X0_FIT = %%X0_FIT%%
    A_FIT = %%A_FIT%%
    B_FIT = %%B_FIT%%
    C_FIT = max(y)
    p0 = (X0_FIT, A_FIT, B_FIT, C_FIT)
    # Compute the best-fit parameters and their associated errors
    p, e = scipy.optimize.curve_fit(piecewise_fit_func, x, y, p0)
    # Get each single best-fit parameter
    x0 = p[0]
    a = p[1]
    b = p[2]
    c = p[3]
    # Determine the quality of the fit by computing R²
    squaredDiffs = np.square(y - piecewise_fit_func(x, x0, a, b, c))
    squaredDiffsFromMean = np.square(y - np.mean(y))
    rSquared = 1 - np.sum(squaredDiffs) / np.sum(squaredDiffsFromMean)
    rSquared = round(rSquared, dec_4_round)
    # Determine the quality of the fit by performing a Kolmogorov-Smirnov
    # statistical test
    #D, pvalue = scipy.stats.kstest(y, piecewise_fit_func(x, x0, a, b, c))
    #D = round(D, dec_4_round)
    #pvalue = round(pvalue, dec_4_round)

    # Function calling: get the desired information about EXT nodes from an
    # input file
    lon = get_EXTnode_info(EXT_nodes_filename, int(ext_node))[4]
    lat = get_EXTnode_info(EXT_nodes_filename, int(ext_node))[5]
    node_name = get_EXTnode_info(EXT_nodes_filename, int(ext_node))[6]
    # Define the size of the figure to be plotted
    fig_length = 16
    fig_height = 12
    # Format the title of the figure (function calling) and define its size
    title = fig_title_form(dim, ext_node, layer, lon, lat, node_name)
    title_size = 11
    # Define the subtitle of the figure (template variable, to be replaced
    # through a "sedfile") and its font size
    subtitle = "%%SUBTITLE_FIT%%"
    subtitle_size = 9
    # Define the x- and y-axis names (template variables, to be replaced
    # through a "sedfile") and their font size
    xaxis_name = "%%XAXIS_FIT%%"
    yaxis_name = "%%YAXIS_FIT%%"
    axes_fontsize = 9
    # Define the size of the points to be plotted
    marker_size = 1.
    # Define the legend labels
    legend_label_data = "data"
    legend_label_fit = "fit"
    # Define the size of the legend of the plot and its marker scale
    legend_size = "medium"
    legend_markerscale = 1.
    # Format the name of the figure (function calling, with template variables,
    # to be replaced through a "sedfile")
    fig_name = fig_name_form(var, dim, ext_node, layer, "%%SIMA%%", "%%SIMB%%", "%%FIG_FORMAT%%")
    # Draw the figure
    #fig, ax = plt.subplots(figsize = (fig_length, fig_height))
    fig, ax = plt.subplots()
    # Set the title of the figure (centered)
    mid = (fig.subplotpars.right + fig.subplotpars.left) / 2.0
    plt.suptitle(title, x = mid)
    # Set the subtitle of the figure
    plt.title(subtitle, fontsize = subtitle_size)
    # Plot the data and regression function
    plt.plot(x, y, '.', markersize = marker_size, color = "blue", label = legend_label_data)
    plt.plot(x, piecewise_fit_func(x, x0, a, b, c), '-', linewidth = 1., color = "red", label = legend_label_fit)
    # Set the x- and y-axis names
    plt.xlabel(xaxis_name, fontsize = axes_fontsize)
    plt.ylabel(yaxis_name, fontsize = axes_fontsize)
    # Set minor axes ticks
    ax.xaxis.set_minor_locator(AutoMinorLocator())
    # Draw the grid
    ax.grid()
    # Set the legend
    ax.legend(fontsize = legend_size, markerscale = legend_markerscale)
    # Write information about the regression analysis on the plot
    x0 = round(x0, 0)
    x0 = int(x0)
    x0_days = round(x0 / (3600. * 24.), 2)   # Convert seconds to days
    plt.text(0.75, 0.80, f"\u03C4  = {x0_days} days", transform = ax.transAxes)
    plt.text(0.75, 0.75, f"R² = {rSquared}", transform = ax.transAxes)
    #plt.text(0.75, 0.70, f"a = {a}", transform = ax.transAxes)
    #plt.text(0.75, 0.65, f"b = {b}", transform = ax.transAxes)
    #plt.text(0.75, 0.60, f"c = {c}", transform = ax.transAxes)
    # Save and close the figure
    plt.savefig(fig_name, bbox_inches = "tight")
    plt.close(fig)

    # Open the output file in appending mode
    f = open(filename, "a")
    # Print the desired content (tab-separated) in the output file and close
    # the latter
    print("%s\t%s\t%s\t%s\t%s\t%s" % (str(ext_node), str(layer), str(x0), str(rSquared), lon, lat), file = f)
    f.close()
    return

#  --- END OF FUNCTIONS ---

#  --- START OF MAIN ---

# Import the desired modules
import subprocess
import numpy as np
import scipy.optimize
import scipy.stats
import matplotlib.pyplot as plt
from matplotlib.ticker import AutoMinorLocator
from datetime import datetime

# Define the name (full path) of the file to be processed (template variable,
# to be replaced through a "sedfile")
FILE2PROC = "%%FILE2PROC%%"
# Define the basename of the output file aimed at containing estimates of the
# spin-up time, according to the regression analysis (template variable, to be
# replaced through a "sedfile")
SPINUP_FIT_FILENAME = "%%SPINUP_FIT_FILENAME%%"
# Function calling: get the EXT nodes list and associated information only from
# an input file containing them, printing the desired content to an output file
# (template variables are employed, to be replaced through a "sedfile")
EXT_nodes_filename = get_EXTnodes_file("%%EXT_NODES_FILE%%", "%%EXT_NODES_INFO_START%%", "%%EXT_NODES_INFO_END%%")
# Function calling: get the variable, and its dimensionality (2D or 3D), under
# analysis (e.g. temp.3d. -> temp, 3d; zeta.2d. -> zeta, 2d); a template
# variable is employed, to be replaced through a "sedfile"
TOPROC = "%%TOPROC%%"
var = get_var_dim(TOPROC)[0]
dim = get_var_dim(TOPROC)[1]

# Function calling: build the header of the file containing estimates of the
# spin-up time, according to the regression analysis (template variables are
# employed, to be replaced through a "sedfile")
file_header(SPINUP_FIT_FILENAME, "%%SIMA%%", "%%SIMB%%", var, dim)

# Function calling: get the desired data from an input file, arranged in
# tab-separated columns
ext_nodes_list = get_data(FILE2PROC)[0]
layers_list = get_data(FILE2PROC)[1]
dts_list = get_data(FILE2PROC)[2]
diffs_list = get_data(FILE2PROC)[3]
sum_diffs_list = get_data(FILE2PROC)[4]

# Define empty lists, to be filled with the data to be used for fitting and
# plotting
ext_nodes = []
layers = []
dts = []
diffs = []
sum_diffs = []
# Initialise the first EXT node and layer to be analysed (set them as the
# "previous" ones)
ext_node_prev = ext_nodes_list[0]
layer_prev = layers_list[0]
# For each time step
for i in range(0, len(dts_list)):
    # If the current EXT node is different from the previous one or the current
    # layer is different from the previous one
    if (ext_nodes_list[i] != ext_node_prev or layers_list[i] != layer_prev):
        # Function calling: fit the desired data according to the best-fit
        # piecewise continuous function and plot the result
        fit_and_plot(get_elapsed_sec(dts), sum_diffs, ext_node_prev, layer_prev, var, dim, SPINUP_FIT_FILENAME)
        # Reset the lists and start to fill them again
        ext_nodes = []
        layers = []
        dts = []
        diffs = []
        sum_diffs = []
        ext_nodes.append(ext_nodes_list[i])
        layers.append(layers_list[i])
        dts.append(dts_list[i])
        diffs.append(diffs_list[i])
        sum_diffs.append(sum_diffs_list[i])
    # If the current EXT node is the same as the previous one and the current
    # layer is the same as the previous one
    else:
        # If the current time step is not the last to be analysed
        if (i != len(dts_list) - 1):
            # Fill the lists
            ext_nodes.append(ext_nodes_list[i])
            layers.append(layers_list[i])
            dts.append(dts_list[i])
            diffs.append(diffs_list[i])
            sum_diffs.append(sum_diffs_list[i])
        # If the current time step is the last to be analysed
        else:
            # Function calling: fit the desired data according to the best-fit
            # piecewise continuous function and plot the result
            fit_and_plot(get_elapsed_sec(dts), sum_diffs, ext_nodes_list[i], layers_list[i], var, dim, SPINUP_FIT_FILENAME)
    # Set the current EXT node and layer as the "previous" ones
    ext_node_prev = ext_nodes_list[i]
    layer_prev = layers_list[i]

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
    tar -czf "%%REGRESSION_PLOTS_ARCHIVE%%" *"%%FIG_FORMAT%%"
    mv "%%REGRESSION_PLOTS_ARCHIVE%%" $SHY_POSTPROC_SPINUP_SIMS_VAR_DIR
    mv "%%SPINUP_FIT_FILENAME%%" $SHY_POSTPROC_SPINUP_SIMS_VAR_DIR
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
