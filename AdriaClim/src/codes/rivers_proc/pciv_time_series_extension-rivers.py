#******************************************************************************
#
# DESCRIPTION:      this Python script is aimed at extending a time series of
#                   river’s discharges to a desired time period fictitiously,
#                   by the introduction of the missing dates, associated with
#                   river’s discharges indicated with "nan" (NaN, Not a
#                   Number). For example, if it is desired to extend a time
#                   series, ranging from 2nd to 30th January, to the entire
#                   month of January, the dates 1st and 31st January will be
#                   properly introduced, associated with river’s discharges
#                   indicated with "nan".
#                   It is assumed that the time series to be considered are
#                   characterized by a constant time resolution, to be set in
#                   the script, and no time gaps. Moreover, it is assumed that
#                   the input files are formatted as required in input by the
#                   SHYFEM model (see the EXTERNAL FILES comment section).
#
# EXTERNAL CALLS:   none.
#
# EXTERNAL FILES:   - initialisation file: ASCII file containing, arranged on
#                     each line, the full path of the input file to be
#                     processed and the starting and ending date and time of
#                     the time period to which extending the input time series
#                     (formatted as YYYYMMDDhhmmss).
#
#                   - input files: ASCII time series files produced through
#                     the Python script named "pciv_2_shyfem-rivers.py".
#
#                      E.g.
#                      date&time_1	Q1
#                      date&time_2	Q2
#                      ...
#
#                       where
#
#                        date&time = date and time formatted as YYYY-MM-DD::hh:mm:ss
#                        Q1        = river's discharge (NaNs are indicated with
#                                    "nan")
#
#                   - output files: ASCII time series files, formatted as the
#                     input files, but extended till the starting and ending
#                     date and time of the desired time period, by the
#                     introduction of possible missing dates, associated to
#                     dummy variables indicated with "nan" (NaN, Not a Number).
#
# DEVELOPER:        Alessandro Minigher (alessandro.minigher@arpa.fvg.it)
#                   ARPA FVG - S.O.C. Stato dell'Ambiente - CRMA
#                   "AdriaClim" Interreg IT-HR project
#
# SOFTWARE VERSION: Python 3.8.1 (python/3.8.1/gcc/8.2.0-mbzms7w).
#
# CREATION DATE:    12/04/2021.
#
# MODIFICATIONS:    none.
#
# VERSION:          0.1.
#
#******************************************************************************

# Modules importation

import os
import sys
from datetime import datetime, timedelta


# ***********
#  FUNCTIONS
# ***********

# Definition of a function aimed at formatting date and time's parameters
# (e.g. month, day, hour, etc.)

def form_clock(clock_parameter):

    # If the parameter is smaller than 10

    if ( clock_parameter < 10 ):

        # Define the parameter properly

        clock_parameter = "0" + str(clock_parameter)

    # Otherwise

    else:

        # Set the parameter properly

        clock_parameter = str(clock_parameter)

    return clock_parameter


# ******
#  MAIN
# ******

# Set the constant time resolution of the time series of the input files (in
# hours)

time_res = 1

# Definition of the full path of the initialisation file

init_file_name = "/u/arpa/minighera/AdriaClim/src/initialisation_files/init_file_pciv_time_series_extension-rivers.txt"

# If the initialisation file exists

if ( os.path.isfile(init_file_name) == True ):

    # Print message to inform the user

    print("\n\t Initialisation file: %s found." % (init_file_name))

# If the initialisation file does not exist

else:

    # Print message to inform the user and exit

    print("\n\t Warning! Initialisation file: %s not found. Please check.\n" % (init_file_name))
    sys.exit()

# Open the initialisation file in reading mode

init_file = open(init_file_name, "r")

# For each line in the initialisation file

for line in init_file:

    # "New line" removal

    line = line.rstrip("\n")

    # Content extraction by line splitting

    input_file_name = line.split()[0]   # input file
    dt_start = line.split()[1]          # starting date and time
    dt_end = line.split()[2]            # ending date and time

    # Extract starting and ending date and time parameters by string slicing

    year_start = dt_start[0:4]       # starting year
    month_start = dt_start[4:6]      # starting month
    day_start = dt_start[6:8]        # starting day
    hour_start = dt_start[8:10]      # starting hour
    minute_start = dt_start[10:12]   # starting minute
    second_start = dt_start[12:14]   # starting second
    year_end = dt_end[0:4]           # ending year
    month_end = dt_end[4:6]          # ending month
    day_end = dt_end[6:8]            # ending day
    hour_end = dt_end[8:10]          # ending hour
    minute_end = dt_end[10:12]       # ending minute
    second_end = dt_end[12:14]       # ending second

    # Define a clock, setting it to the starting date and time read from the
    # initialisation file

    clock = datetime(int(year_start), int(month_start), int(day_start), int(hour_start), int(minute_start), int(second_start))

    # Define a "datetime" object for the ending date and time read from the
    # initialisation file

    clock_end = datetime(int(year_end), int(month_end), int(day_end), int(hour_end), int(minute_end), int(second_end))

    # If the input file exists

    if ( os.path.isfile(input_file_name) == True ):

        # Print message to inform the user

        print("\n\t Input file: %s found. Extension starts..." % (input_file_name))

    # If the input file does not exist

    else:

        # Print message to inform the user and skip to the next file

        print("\n\t Warning! Input file: %s not found. Skip to next file...\n" % (input_file_name))
        continue

    # Definition of the basename of the output file

    output_file_name = os.path.basename(input_file_name).split(".")[0] + "_ext_" + dt_start + "-" + dt_end + ".dat"

    # If the output file already exists

    if ( os.path.isfile(output_file_name) == True ):

        # Delete the output file

        os.remove(output_file_name)

    # Open the output file in appending mode

    output_file = open(output_file_name, "a")

    # Open the input file in reading mode

    input_file = open(input_file_name, "r")

    # Read the first line of the input file only

    for data in input_file:

        # "New line" removal

        data = data.rstrip("\n")

        # Date and time extraction

        dt = data.split()[0]          # date and time
        date = dt.split("::")[0]      # date
        time = dt.split("::")[1]      # time
        year = date.split("-")[0]     # year
        month = date.split("-")[1]    # month
        day = date.split("-")[2]      # day
        hour = time.split(":")[0]     # hour
        minute = time.split(":")[1]   # minute
        second = time.split(":")[2]   # second

        # Create a "datetime" object for the date and time read

        dt_curr = datetime(int(year), int(month), int(day), int(hour), int(minute), int(second))

        # Exit the "for" cycle: read the first line only

        break

    # As long as the clock is previous to the date and time read

    while (clock < dt_curr):

        # Extract the parameters of the clock and call the function

        year_clock = str(clock.year)              # year
        month_clock = form_clock(clock.month)     # month
        day_clock = form_clock(clock.day)         # day
        hour_clock = form_clock(clock.hour)       # hour
        minute_clock = form_clock(clock.minute)   # minute
        second_clock = form_clock(clock.second)   # second

        # Format the date and time of the clock

        clock_form = year_clock + "-" + month_clock + "-" + day_clock + "::" + hour_clock + ":" + minute_clock + ":" + second_clock

        # Format the output to be printed to the output file

        output = clock_form + "\t" + "nan"

        # Print to output file

        print(output, file = output_file)

        # Forward the clock by the time resolution of the input time series

        clock = clock + timedelta(hours = time_res)

    # Close the input file and open it in reading mode again

    input_file.close()
    input_file = open(input_file_name, "r")

    # For each line in the input file

    for data in input_file:
 
        # "New line" removal

        data = data.rstrip("\n")

        # Date and time extraction

        dt = data.split()[0]          # date and time
        date = dt.split("::")[0]      # date
        time = dt.split("::")[1]      # time
        year = date.split("-")[0]     # year
        month = date.split("-")[1]    # month
        day = date.split("-")[2]      # day
        hour = time.split(":")[0]     # hour
        minute = time.split(":")[1]   # minute
        second = time.split(":")[2]   # second

        # Create a "datetime" object

        dt_curr = datetime(int(year), int(month), int(day), int(hour), int(minute), int(second))

        # Print to output file

        print(data, file = output_file)

    # Set the clock as the last date and time read from the input file,
    # increased by the time resolution of the input time series

    clock = dt_curr + timedelta(hours = time_res)

    # As long as the clock is previous, or equal, to the ending date and time
    # read from the initialisation file (increased by the time resolution of
    # the input time series)

    while ( clock <= clock_end ):

        # Extract the parameters of the clock and call the function

        year_clock = str(clock.year)              # year
        month_clock = form_clock(clock.month)     # month
        day_clock = form_clock(clock.day)         # day
        hour_clock = form_clock(clock.hour)       # hour
        minute_clock = form_clock(clock.minute)   # minute
        second_clock = form_clock(clock.second)   # second

        # Format the date and time of the clock

        clock_form = year_clock + "-" + month_clock + "-" + day_clock + "::" + hour_clock + ":" + minute_clock + ":" + second_clock

        # Format the output to be printed to the output file

        output = clock_form + "\t" + "nan"

        # Print to output file

        print(output, file = output_file)

        # Forward the clock by the time resolution of the input time series

        clock = clock + timedelta(hours = time_res)

    # Close input and output files

    input_file.close()
    output_file.close()

# Close the initialisation file

init_file.close()
print()
