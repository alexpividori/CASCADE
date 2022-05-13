#******************************************************************************
#
# DESCRIPTION:      this Python script is aimed at building a dummy (constant)
#                   time series, for a desired time period, namely a time
#                   series of a certain quantity which is always the same.
#
#                   E.g.
#
#                   2020-01-01::00:00:00 0.1
#                   2020-01-01::01:00:00 0.1
#                   ...
#                   2021-05-05::00:00:00 0.1
#
# EXTERNAL CALLS:   none.
#
# EXTERNAL FILES:   - initialisation file: ASCII file formatted as shown
#                     below
#
#                     output_file1 dt_start1 dt_end1 var1
#                     output_file2 dt_start2 dt_end2 var2
#                     ...
#
#                     where
#
#                      output_file = name of the output file where writing
#                                    the desired output
#                      dt_start    = starting date of the desired time period,
#                                    formatted as YYYY-MM-DD:dd:hh:ss
#                      dt_end      = ending date of the desired time period,
#                                    formatted as YYYY-MM-DD:dd:hh:ss
#                      var         = constant value to be used to create the
#                                    dummy (constant) time series
#
#                   - output files: ASCII time series files, formatted as shown
#                     below
#
#                     dt1 var
#                     dt2 var
#                     ...
#
#                     where
#
#                      dt  = date and time, formatted as YYYY-MM-DD::hh:mm:ss
#                      var = any number, which is always the same for the
#                            entire length of the time series
#
# DEVELOPER:        Alessandro Minigher (alessandro.minigher@arpa.fvg.it)
#                   ARPA FVG - S.O.C. Stato dell'Ambiente - CRMA
#                   "AdriaClim" Interreg IT-HR project
#
# SOFTWARE VERSION: Python 3.8.1 (python/3.8.1/gcc/8.2.0-mbzms7w).
#
# CREATION DATE:    05/05/2021.
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

# CHECK THE EXISTENCE OF THE INITIALISATION FILE

def check_init_file(init_file_name):

    # If the initialisation file exists

    if ( os.path.isfile(init_file_name) == True ):

        # Print message to inform the user

        print("\n\tInitialisation file: %s found." % (init_file_name))

    # If the initialisation file does not exist

    else:

        # Print message to inform the user and exit

        print("\n\tWarning! Initialisation file: %s not found. Please check.\n" % (init_file_name))
        sys.exit()

    return

# CHECK THE EXISTENCE OF THE OUTPUT FILE

def check_output_file(output_file_name):

    # If the output file already exists

    if ( os.path.isfile(output_file_name) == True ):

        # Delete the output file

        os.remove(output_file_name)

    return

# DATE AND TIME FORMATTING AND OUTPUT PRINTING

def dt_form_print(output_file_name, dt_start, dt_end, var):

    # Open the output file in appending mode

    output_file = open(output_file_name, "a")

    # Extract the elements of the starting and ending date and time

    date_start = dt_start.split("::")[0]
    time_start = dt_start.split("::")[1]
    year_start = date_start.split("-")[0]
    month_start = date_start.split("-")[1]
    day_start = date_start.split("-")[2]
    hour_start = time_start.split(":")[0]
    minute_start = time_start.split(":")[1]
    second_start = time_start.split(":")[2]
    date_end = dt_end.split("::")[0]
    time_end = dt_end.split("::")[1]
    year_end = date_end.split("-")[0]
    month_end = date_end.split("-")[1]
    day_end = date_end.split("-")[2]
    hour_end = time_end.split(":")[0]
    minute_end = time_end.split(":")[1]
    second_end = time_end.split(":")[2]

    # Build "datetime" objects

    dt_start = datetime(int(year_start), int(month_start), int(day_start), int(hour_start), int(minute_start), int(second_start))
    dt_end = datetime(int(year_end), int(month_end), int(day_end), int(hour_end), int(minute_end), int(second_end))

    # Set the clock as the starting date and time

    clock = dt_start

    # As long as the clock is earlier (or equal) than the ending date and time

    while ( clock <= dt_end ):

        # Format the date and time properly: YYYY-MM-DD::hh:mm:ss

        year = str(clock.year)
        if (clock.month < 10): month = "0" + str(clock.month)
        else: month = str(clock.month)
        if (clock.day < 10): day = "0" + str(clock.day)
        else: day = str(clock.day)
        if (clock.hour < 10): hour = "0" + str(clock.hour)
        else: hour = str(clock.hour)
        if (clock.minute < 10): minute = "0" + str(clock.minute)
        else: minute = str(clock.minute)
        if (clock.second < 10): second = "0" + str(clock.second)
        else: second = str(clock.second)
        dt = year + "-" + month + "-" + day + "::" + hour + ":" + minute + ":" + second

        # Format the output and print it to the output file

        output = dt + "\t" + var
        print(output, file = output_file)

        # Forward the clock by one hour

        clock = clock + timedelta(hours = 1)


# ******
#  MAIN
# ******

# Definition of the full path of the initialisation file

#init_file_name = "/lustre/arpa/minighera/initialisation_files/init_file_dummy_time_series_generator.txt"
init_file_name = "/u/arpa/minighera/AdriaClim/src/initialisation_files/init_file_dummy_time_series_generator.txt"

# Function calling: check the existence of the initialisation file

check_init_file(init_file_name)

# Open the initialisation file in reading mode

init_file = open(init_file_name, "r")

# For each line in the initialisation file

for line in init_file:

    # "New line" removal

    line = line.rstrip("\n")

    # Exctraction of useful information

    output_file_name = line.split()[0]   # name of the output file
    dt_start = line.split()[1]           # starting date and time
    dt_end = line.split()[2]             # ending date and time
    var = line.split()[3]                # (constant) variable to be printed

    # Function calling: check the existence of the output file

    check_output_file(output_file_name)

    # Function calling: date and time formatting and output printing

    dt_form_print(output_file_name, dt_start, dt_end, var)

# Close the initialisation file

init_file.close()
print()
