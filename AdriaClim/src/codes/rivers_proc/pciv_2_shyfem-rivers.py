#******************************************************************************
#
# DESCRIPTION:      this Python script is aimed at converting the format of
#                   the files containing the time series of rivers' discharges,
#                   as provided by Civil Protection of FVG (see the EXTERNAL
#                   FILES comment section), to the format required in input by
#                   the SHYFEM model (see the EXTERNAL FILES comment section).
#                   It is assumed that the time series to be considered are
#                   characterized by a constant time resolution, to be set in
#                   the script.
#                   Possible time gaps (namely consecutive time steps separated
#                   by integer multiples of the time resolution) are filled by
#                   the introduction of the missing dates, associated with
#                   rivers’ discharges indicated with "nan" (NaN, Not a Number).
#                   For example, if an hourly-resolution time series is
#                   characterized by two consecutive time steps, separated by
#                   three hours (time gap), the two missing hours (required to
#                   have an actual constant resolution) are introduced,
#                   associated with rivers’ discharges indicated with "nan".
#
# EXTERNAL CALLS:   none.
#
# EXTERNAL FILES:   - initialisation file: ASCII file containing the list of
#                     input files (full paths) to be processed, which are
#                     arranged row by row, as shown below:
#
#                      input_file_1
#                      input_file_2
#                      ...
#
#                   - input files: ASCII time series files to be converted to
#                     another format; these files are formatted as shown below
#                     (please note the time gap):
#
#                      Metadata
#                      date_1 time_1;Q_1
#                      date_2 time_2;Q_2
#                      date_5_time_5;Q_5
#                      ...
#
#                      where
#
#                       date = date formatted as DD/MM/YYYY
#                       time = time formatted as hh:mm
#                       Q    = river's discharge, with a comma separating units
#                              from tens
#
#                   - output files: ASCII time series files, obtained through
#                     conversion of input files; these files are formatted as
#                     shown below (please note that time gaps are filled with
#                     missing dates):
#
#                      date&time_1	Q_1
#                      date&time_2	Q_2
#                      date&time_3	nan
#                      date&time_4	nan
#                      date&time_5	Q_5
#                      ...
#
#                      where
#
#                       date&time = date and time formatted as YYYY-MM-DD::hh:mm:ss
#                       Q         = river's discharge, with a point separating
#                                   units from tens
#                       nan       = NaN (Not a Number)
#
# DEVELOPER:        Alessandro Minigher (alessandro.minigher@arpa.fvg.it)
#                   ARPA FVG - S.O.C. Stato dell'Ambiente - CRMA
#                   "AdriaClim" Interreg IT-HR project
#
# SOFTWARE VERSION: Python 3.8.1 (python/3.8.1/gcc/8.2.0-mbzms7w).
#
# CREATION DATE:    08/04/2021.
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

def form(parameter):

    # If the input parameter is smaller than 10

    if ( int(parameter) < 10 ):

        # Built the parameter properly

        parameter = "0" + str(parameter)

    # Otherwise

    else:

        # Set the parameter properly

        parameter = str(parameter)

    return parameter


# ******
#  MAIN
# ******

# Set the constant time resolution of the time series of the input files (in
# hours)

time_res = 1

# Definition of the full path of the initialisation file

init_file_name = "/u/arpa/minighera/AdriaClim/src/initialisation_files/init_file_pciv_2_shyfem-rivers.txt"

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

for input_file_name in init_file:

    # "New line" removal

    input_file_name = input_file_name.rstrip("\n")

    # If the input file exists

    if ( os.path.isfile(input_file_name) == True ):

        # Print message to inform the user

        print("\n\t Input file: %s found. Formatting starts..." % (input_file_name))

    # If the input file does not exist

    else:

        # Print message to inform the user and skip to next file

        print("\n\t Warning! Input file: %s not found. Skip to next file.\n" % (input_file_name))
        continue

    # Open the input file in reading mode

    input_file = open(input_file_name, "r")

    # Definition of the basename of the output file

    output_file_name = os.path.basename(input_file_name).split(".")[0] + ".dat"

    # If the output file already exists

    if ( os.path.isfile(output_file_name) == True ):

        # Delete the output file

        os.remove(output_file_name)

    # Open the output file in appending mode

    output_file = open(output_file_name, "a")

    # Initialisation of a lines counter

    line = 0

    # For each line in the input file

    for data in input_file:

        # "New line" removal

        data = data.rstrip("\n")

        # If the line read is the first (metadata)

        if ( line == 0 ):

            # Change the value of the lines counter and skip to the next line

            line = line + 1
            continue

        # If the line read is not the first (actual data)

        else:

            # Split the line to extract data

            date_time = data.split(";")[0]
            Q = data.split(";")[1]

            # Extract the date and time

            date = date_time.split()[0]   # date
            year = date.split("/")[2]     # year
            month = date.split("/")[1]    # month
            day = date.split("/")[0]      # day
            time = date_time.split()[1]   # time
            hour = time.split(":")[0]     # hour
            minute = time.split(":")[1]   # minute
            second = "00"                 # second

            # Create a "datetime" object for the date and time read

            date_time_curr = datetime(int(year), int(month), int(day), int(hour), int(minute), int(second))

            # Format the date and time: YYYY-MM-DD::hh:mm:ss

            date_time = year + "-" + month + "-" + day + "::" + hour + ":" + minute + ":" + second

            # Format river's discharge: replace comma with dot, and consider
            # two decimal digits only

            Q = Q.replace(",", ".")
            Q = str(round(float(Q), 2))

            # Format the output to be printed

            output = date_time + "\t" + Q

            # If the line read is the second (first actual data)

            if ( line == 1 ):

                # Set the clock as the date and time read, and increase the
                # line counter

                clock = date_time_curr
                line = line + 1

                # Print to the output file

                print(output, file = output_file)

            # If the line read is following to the second

            else:

                # While the clock is earlier than the date and time read
                # (time gap)

                while ( clock < date_time_curr ):

                    # Set the river's discharge as a NaN

                    Q_miss = "nan"

                    date_time_miss = str(clock.year) + "-" + form(clock.month) + "-" + form(clock.day) + "::" + form(clock.hour) + ":" + form(clock.minute) + ":" + form(clock.second)

                    # Format the output to be printed

                    output_miss = date_time_miss + "\t" + Q_miss

                    # Print to the output file

                    print(output_miss, file = output_file)

                    # Increase the clock by the time resolution of the input
                    # time series (in hours)

                    clock = clock + timedelta(hours = time_res)

                # Print to the output file

                print(output, file = output_file)

            # Increase the clock by the time resolution of the input time
            # series (in hours)

            clock = clock + timedelta(hours = time_res)

    # Print message to inform the user that the formatting process
    # ended

    print("\n\t Formatting ends: %s ---> %s.\n" % (input_file_name, output_file_name))

    # Close input and ouput files

    input_file.close()
    output_file.close()

# Close the initialisation file

init_file.close()
