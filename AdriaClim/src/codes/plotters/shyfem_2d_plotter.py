#******************************************************************************
#
# DESCRIPTION:      this Python script is aimed at drawing a time series plot
#                   of a certain variable, starting from the information
#                   retrieved in an initialisation file (see the EXTERNAL
#                   FILES comment section).
#
# EXTERNAL CALLS:   none.
#
# EXTERNAL FILES:   - initialisation file: ASCII file containing, arranged
#                     line by line, the following information
#
#                     input_file-1	location-1
#                     input_file-2	location-2
#                     ...
#
#                      where
#
#                         input_file-i = i-th time series input file (see the
#                                        following point)
#                         location-i   = name and coordinates (lon, lat) of the
#                                        geographic point for which the i-th
#                                        time series input file is provided
#
#                   - input files: ASCII time series files containing, arranged
#                     line by line, the following information
#
#                     # Top line of metadata
#                     date_time-1	var(date_time-1)
#                     date_time-2	var(date_time-2)
#                     ...
#
#                      where
#
#                         date_time-i      = i-th time step, formatted as
#                                            YYYY-MM-DD::hh:mm:ss
#                         var(date_time-i) = variable at i-th time step
#
# DEVELOPER:        Alessandro Minigher (alessandro.minigher@arpa.fvg.it)
#                   ARPA FVG - S.O.C. Stato dell'Ambiente - CRMA
#                   "AdriaClim" Interreg IT-HR project
#
# SOFTWARE VERSION: Python 3.8.1 (python/3.8.1/gcc/8.2.0-mbzms7w).
#
# CREATION DATE:    24/06/2021.
#
# MODIFICATIONS:    none.
#
# VERSION:          0.1.
#
#******************************************************************************

# Import modules
import sys
import os
import matplotlib.pyplot as plt
from datetime import datetime
from matplotlib.ticker import AutoMinorLocator

# ***********
#  FUNCTIONS
# ***********

# Collect the data to be plotted
def data_collect(input_file_name):
    # Define empty lists to be filled with data
    date_time_list = []
    var_list = []
    # Open the input file in reading mode
    input_file = open(input_file_name, "r")
    # Initialise a flag to be used to identify the first line of the file
    flag = 0
    # For each line in the input file
    for line in input_file:
        # If the line read is the first
        if (flag == 0):
            # Switch the flag and skip to the next iteration
            flag = 1
            continue
        # Remove the "new line"
        line = line.rstrip("\n")
        # Extract the data and fill the lists
        date_time = line.split()[0]
        var = float(line.split()[1])
        date_time_list.append(date_time)
        var_list.append(var)
    # Build and return the desired output
    output = [date_time_list, var_list]
    return output

# Format the date and time by building "datetime" objects
def dt_format(dt_list):
    # Define an empty list to be filled with formatted date and time
    dt_form_list = []
    # For each element in the list
    for dt in dt_list:
        # Extract the date and time components (year, month, day, hour, etc.),
        # by knowing that these are grouped as YYYY-MM-DD::hh:mm:ss
        date = dt.split("::")[0]
        time = dt.split("::")[1]
        year = date.split("-")[0]
        month = date.split("-")[1]
        day = date.split("-")[2]
        hour = time.split(":")[0]
        minute = time.split(":")[1]
        second = time.split(":")[2]
        # Build a "datetime" object and fill the list
        dt_form = datetime(int(year), int(month), int(day), int(hour), int(minute), int(second))
        dt_form_list.append(dt_form)
    return dt_form_list

# Build the y-axis label
def yaxis_label_maker(var):
    # Build the y-axis label according to the variable to be plotted
    if (var=="dir"): yaxis_label = "Current direction (vertically averaged) [° N]"
    elif (var=="salt"): yaxis_label = "Salinity (vertically averaged) [PSU]"
    elif (var=="speed"): yaxis_label = r"Current velocity (vertically averaged) [m s$^{-1}$]"
    elif (var=="temp"): yaxis_label = "Water temperature (vertically averaged) [°C]"
    elif (var=="velx"): yaxis_label = r"Zonal current velocity (vertically averaged) [m s$^{-1}$]"
    elif (var=="vely"): yaxis_label = r"Meridional current velocity (vertically averaged) [m s$^{-1}$]"
    elif (var=="zeta"): yaxis_label = "Water level [m]"
    return yaxis_label

# Time series plot
def plot(x, y, yaxis_label, location, input_file_name):
    # Draw a figure of the desired size
    fig_length = 20
    fig_height = 10
    fig, ax = plt.subplots(figsize = (fig_length, fig_height))
    # Set the title
    title = location
    title_size = 30
    plt.title(title, fontsize = title_size)
    # Plot
    plt.plot(x, y, ".", color = "red")
    # Set axes' labels
    x_label = "Time"
    y_label = yaxis_label
    axes_fontsize = 18
    plt.xlabel(x_label, fontsize = axes_fontsize)
    plt.ylabel(y_label, fontsize = axes_fontsize)
    # Set minor axes' ticks
    ax.xaxis.set_minor_locator(AutoMinorLocator())
    # Draw the grid
    ax.grid()
    # Save and close the figure
    fig_name = os.path.basename(input_file_name) + ".png"
    plt.savefig(fig_name)
    plt.close(fig)
    return

# ******
#  MAIN
# ******

# Read the command-line argument: initialisation file
init_file_name = sys.argv[1]
# Open the initialisation file in reading mode
init_file = open(init_file_name, "r")
# For each line in the initialisation file
for line in init_file:
    # Remove the "new line"
    line = line.rstrip("\n")
    # Extract information from the line read
    input_file_name = line.split("\t")[0]   # input file's name
    loc = line.split("\t")[1]               # location and coordinates (lon, lat)
    # Extract the type of variable to be plotted from the input file's name
    var_type = os.path.basename(input_file_name).split(".")[0]

    # Function calling: collect the data to be plotted
    data = data_collect(input_file_name)
    var = data[1]
    # Function calling: format the date and time by building "datetime" objects
    date_time = dt_format(data[0])

    # Function calling: build the y-axis label
    yaxis_label = yaxis_label_maker(var_type)
    # Function calling: time series plot
    plot(date_time, var, yaxis_label, loc, input_file_name)
