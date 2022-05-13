#******************************************************************************
#
# DESCRIPTION:      this Python script is aimed at drawing a time series plot
#                   of current speed (left y-axis) and direction (right
#                   y-axis), starting from the information retrieved in an
#                   initialisation file (see the EXTERNAL FILES comment
#                   section).
#
# EXTERNAL CALLS:   none.
#
# EXTERNAL FILES:   - initialisation file: ASCII file containing, arranged
#                     line by line, the following information
#
#                     input_file-1a	input_file-1b	location-1
#                     input_file-2a	input_file-2b	location-2
#                     ...
#
#                      where
#
#                         input_file-ia = i-th current speed time series input
#                                         file (see the following point)
#                         input_file-ib = i-th current direction time series
#                                         input file (see the following point)
#                         location-i    = name and coordinates (lon, lat) of
#                                         the geographic point for which the
#                                         i-th time series input files are
#                                         provided
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
#                                            (current speed or direction)
#
# DEVELOPER:        Alessandro Minigher (alessandro.minigher@arpa.fvg.it)
#                   ARPA FVG - S.O.C. Stato dell'Ambiente - CRMA
#                   "AdriaClim" Interreg IT-HR project
#
# SOFTWARE VERSION: Python 3.8.1 (python/3.8.1/gcc/8.2.0-mbzms7w).
#
# CREATION DATE:    06/07/2021.
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

# Check the existence of the input files
def check_input_files(file1, file2):
    # Initialisation of a flag to be used to indicate if both the input files
    # exist, or not
    flag = 0
    # If both the input files exist
    if (os.path.isfile(file1) and os.path.isfile(file2)):
        # Print a message to inform the user
        print("\n\tInput files: %s and %s exist. Plotting..." % (file1, file2))
    else:
        # Print a message to inform the user and switch the flag
        print("\n\tWARNING! Input files: %s and %s do not exist. Skip..." % (file1, file2))
        flag = 1
    return flag

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

# Time series plot
def plot(x1, x2, y1, y2, location, input_file_name):
    # Draw a figure of the desired size
    fig_length = 20
    fig_height = 10
    fig, ax1 = plt.subplots(figsize = (fig_length, fig_height))
    # Set the title
    title = location
    title_size = 30
    plt.title(title, fontsize = title_size)
    # Plot (left y-axis)
    ax1.plot(x1, y1, ".", color = "red")
    # Set x- and left y- axes' labels and colors
    x_label = "Time"
    y_label_left = "Current speed (vertically averaged) [m s$^{-1}$]"
    axes_fontsize = 18
    ax1.set_xlabel(x_label, fontsize = axes_fontsize)
    ax1.set_ylabel(y_label_left, fontsize = axes_fontsize)
    color_left = "red"
    ax1.yaxis.label.set_color(color_left)
    ax1.tick_params(axis = "y", colors = color_left)
    ax1.spines["left"].set_color(color_left)
    # Instantiate a second, right y-axis that shares the same x-axis
    ax2 = ax1.twinx()
    # Set right y-axis' label and color
    y_label_right = "Current direction (vertically averaged) [° N]"
    ax2.set_ylabel(y_label_right, fontsize = axes_fontsize)
    color_right = "blue"
    ax2.yaxis.label.set_color(color_right)
    ax2.tick_params(axis = "y", colors = color_right)
    ax2.spines["right"].set_color(color_right)
    # Plot (right y-axis)
    ax2.plot(x2, y2, ".", color = color_right)
    # Set minor axes' ticks
    ax1.yaxis.set_minor_locator(AutoMinorLocator())
    ax2.xaxis.set_minor_locator(AutoMinorLocator())
    ax2.yaxis.set_minor_locator(AutoMinorLocator())
    # Draw the grid
    ax2.grid()
    # Save and close the figure
    fig_name = "CSD." + os.path.basename(input_file_name).split(".")[1] + "." + os.path.basename(input_file_name).split(".")[2]  + ".png"
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
    input_file_name1 = line.split("\t")[0]   # first input file's name
    input_file_name2 = line.split("\t")[1]   # second input file's name
    loc = line.split("\t")[2]                # location and coordinates (lon, lat)

    # Function calling: check the existence of the input files
    GOON = check_input_files(input_file_name1, input_file_name2)
    # If at least one of the input files does not exist, skip to the next
    # couple of files, if existent
    if (GOON != 0): continue

    # Function calling: collect the data to be plotted
    date_time_speed = data_collect(input_file_name1)[0]
    date_time_speed = dt_format(date_time_speed)          # Function calling: format
                                                          # the date and time by building
                                                          # "datetime" objects
    speed = data_collect(input_file_name1)[1]
    date_time_dir = data_collect(input_file_name2)[0]
    date_time_dir = dt_format(date_time_dir)            # Function calling: format
                                                        # the date and time by building
                                                        # "datetime" objects
    cur_dir = data_collect(input_file_name2)[1]

    # Function calling: time series plot
    plot(date_time_speed, date_time_dir, speed, cur_dir, loc, input_file_name1)

# Cosmetics
print()
