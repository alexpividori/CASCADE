#******************************************************************************
#
# DESCRIPTION:      this Python script is aimed at drawing a time series plot
#                   of a certain dimension/variable, read from an input file
#                   (see the EXTERNAL FILES comment section).
#
# EXTERNAL CALLS:   none.
#
# EXTERNAL FILES:   - initialisation file: ASCII file containing the full
#                     paths of the input files to be read, together with the
#                     name, units and geographic location of the variable to
#                     be plotted
#
#                      input_file1	variable1 [units1]	loc1 (lon1, lat1)
#                      input_file2	variable2 [units2]	loc2 (lon2, lat2)
#                      ...
#
#                   - input files: ASCII time series files, formatted as
#                     shown below
#
#                      # Top line of metadata (starting with #)
#                      date&time1 variable1
#                      date&time2 variable2
#                      ...
#
#                      where
#
#                       date&time = date and time, formatted as YYYY-MM-DD::hh:mm:ss
#                       variable  = dimension/variable to be plotted
#
# DEVELOPER:        Alessandro Minigher (alessandro.minigher@arpa.fvg.it)
#                   ARPA FVG - S.O.C. Stato dell'Ambiente - CRMA
#                   "AdriaClim" Interreg IT-HR project
#
# SOFTWARE VERSION: Python 3.8.1 (python/3.8.1/gcc/8.2.0-mbzms7w).
#
# CREATION DATE:    03/05/2021.
#
# MODIFICATIONS:    none.
#
# VERSION:          0.1.
#
#******************************************************************************

# Modules importation

import os
import sys
import subprocess
import matplotlib.pyplot as plt
from datetime import datetime
from matplotlib.ticker import AutoMinorLocator


# ***********
#  FUNCTIONS
# ***********

# CHECK THE EXISTENCE OF THE INITIALISATION FILE

def check_init_file(init_file_name):

    # If the initialisation file exists

    if ( os.path.isfile(init_file_name) == True ):

        # Print message to inform the user

        print("\n\t Initialisation file: %s found." % (init_file_name))

    # If the initialisation file does not exist

    else:

        # Print message to inform the user and exit

        print("\n\t Warning! Initialisation file: %s not found. Please check.\n" % (init_file_name))
        sys.exit()

    return

# CHECK THE EXISTENCE OF THE INPUT FILE

def check_input_file(input_file_name):

    # Initialisation of a flag

    flag = 0

    # If the input file exists

    if ( os.path.isfile(input_file_name) == True ):

        # Print message to inform the user

        print("\n\t Input file: %s found." % (input_file_name))

    # If the input file does not exist

    else:

        # Print message to inform the user and switch the flag

        print("\n\t Warning! Input file: %s not found. Skip to next file.\n" % (input_file_name))
        flag = 1

    return flag

# DATA COLLECTION

def data_collect(input_file_name):

    # Initialisation of an empty list to be filled

    data_list = []

    # Comments (metadata) removal by the use of Bash-like commands

    cat = subprocess.Popen(['cat', input_file_name], close_fds=True, stdout=subprocess.PIPE)
    grep = subprocess.Popen('grep -v "^#"', shell=True, stdin=cat.stdout, stdout=subprocess.PIPE)

    # For each line in the input file

    for data in grep.stdout:

        # Line decoding

        data = data.decode("utf-8")

        # "New line" removal

        data = data.rstrip("\n")

        # List filling

        data_list.append(data)

    # Close the input file

    grep.stdout.close()
    return data_list

# TIME SERIES PLOT

def ts_plot(data_list, y_label, location):

    # Definition of the size of the figure

    fig_length = 20   # length
    fig_height = 10   # height

    # Draw a figure

    fig, ax = plt.subplots(figsize = (fig_length, fig_height))

    # For each time step to be plotted

    for data in data_list:

        # Data extraction

        dt = data.split()[0]          # date and time
        var = data.split()[1]         # dimension/variable
        date = dt.split("::")[0]      # date
        time = dt.split("::")[1]      # time
        year = date.split("-")[0]     # year
        month = date.split("-")[1]    # month
        day = date.split("-")[2]      # day
        hour = time.split(":")[0]     # hour
        minute = time.split(":")[1]   # minute
        second = time.split(":")[2]   # second

        # Build a "datetime" object

        dt = datetime(int(year), int(month), int(day), int(hour), int(minute), int(second))

        # Plot

        plt.plot(dt, float(var), ".", color = "red")

    # Plot the title and subtitle

    title = "Time Series Plot"
    mid = (fig.subplotpars.right + fig.subplotpars.left) / 2.0
    title_size = 30
    plt.suptitle(title, x = mid, fontsize = title_size)
    subtitle = location
    subtitle_size = 22
    plt.title(subtitle, fontsize = subtitle_size)

    # Set axes' labels

    x_label = "Time"
    axes_fontsize = 18
    plt.xlabel(x_label, fontsize = axes_fontsize)
    plt.ylabel(y_label, fontsize = axes_fontsize)

    # Set minor axes' ticks

    ax.xaxis.set_minor_locator(AutoMinorLocator())

    # Draw the grid

    ax.grid()

    # Save and close the figure

    fig_name = os.path.basename(input_file_name) + "_plot.png"
    plt.savefig(fig_name)
    plt.close(fig)
    return


# ******
#  MAIN
# ******

# Definition of the full path of the initialisation file

#init_file_name = "/lustre/arpa/minighera/initialisation_files/init_file_time_series_plot.txt"
init_file_name = "/u/arpa/minighera/AdriaClim/src/initialisation_files/init_file_time_series_plot.txt"

# Function calling: check the existence of the initialisation file

check_init_file(init_file_name)

# Open the initialisation file in reading mode

init_file = open(init_file_name, "r")

# For each line in the initialisation file

for line in init_file:

    # "New line" removal

    line = line.rstrip("\n")

    # Extraction of useful information

    input_file_name = line.split("\t")[0]   # name of input file
    y_label = line.split("\t")[1]           # y-axis label
    location = line.split("\t")[2]          # geographic location

    # Function calling: check the existence of the input file

    check_input_file(input_file_name)

    # Function calling: data collection

    data2plot = data_collect(input_file_name)

    # Function calling: time series plot

    ts_plot(data2plot, y_label, location)

# Close the initialisation file

init_file.close()
print()
