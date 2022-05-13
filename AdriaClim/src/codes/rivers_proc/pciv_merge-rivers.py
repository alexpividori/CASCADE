#******************************************************************************
#
# DESCRIPTION:      this Python script is aimed at merging two time series (of
#                   discharges of the same river), read from two different
#                   input files (see the EXTERNAL FILES comment section),
#                   properly. This is carried out according to the simple
#                   algorithm described below:
#
#                    - if for a certain time step, only the data related to the
#                      first time series read are available (not NaNs), these
#                      are chosen;
#                    - otherwise, the data related to the second time series
#                      are chosen (available or NaNs).
#
#                   It is assumed that the time series to be merged are
#                   characterized by a constant time resolution, no time gaps
#                   and the same length. Moreover, it is assumed that the input
#                   files are formatted as required in input by the SHYFEM
#                   model (see the EXTERNAL FILES comment section).
#
# EXTERNAL CALLS:   none.
#
# EXTERNAL FILES:   - initialisation file: ASCII file containing, arranged on
#                     each line, the full paths of the couple of input files
#                     to be merged:
#
#                      E.g.
#                      input_file1_1 input_file2_1
#                      input_file1_2 input_file2_2
#                      ...
#
#                     The couple of input files to be merged is characterized
#                     by time series files covering the same time period, with
#                     the same constant time resolution and without time gaps.
#
#                   - input files: ASCII time series files produced through
#                     the Python script "pciv_time_series_extension-rivers.py".
#
#                      E.g.
#                      date&time_1	Q1
#                      date&time_2	Q2
#                      ...
#
#                       where
#
#                        date&time = date and time formatted as YYYY-MM-DD::hh:mm:ss
#                        Q1        = river's discharge (NANs are indicate with
#                                    "nan")
#
#                   - output files: ASCII time series files, formatted as the
#                     input files, but resulting from the merging process.
#
# DEVELOPER:        Alessandro Minigher (alessandro.minigher@arpa.fvg.it)
#                   ARPA FVG - S.O.C. Stato dell'Ambiente - CRMA
#                   "AdriaClim" Interreg IT-HR project
#
# SOFTWARE VERSION: Python 3.8.1 (python/3.8.1/gcc/8.2.0-mbzms7w).
#
# CREATION DATE:    12/04/2021.
#
# MODIFICATIONS:    19/04/2021 ---> debug ("range" function).
#
# VERSION:          0.2.
#
#******************************************************************************

# Modules importation

import os
import sys


# ***********
#  FUNCTIONS
# ***********

# Definition of a first function aimed at collecting data

def data_coll(input_file_name):

    # Initialisation of a list to be filled

    data_list = []

    # Open the input file in reading mode

    input_file = open(input_file_name, "r")

    # For each line in the input file

    for data in input_file:

        # "New line" removal

        data = data.rstrip("\n")

        # List filling

        data_list.append(data)

    # Close the input file

    input_file.close()

    return data_list

# Definition of a second function aimed at formatting the date and time

def dt_form(dt):

    # Extract the date and time parameters

    date = dt.split("::")[0]
    time = dt.split("::")[1]
    year = date.split("-")[0]
    month = date.split("-")[1]
    day= date.split("-")[2]
    hour = time.split(":")[0]
    minute = time.split(":")[1]
    second = time.split(":")[2]

    # Format the date and time: YYYYMMDDhhmmss

    dt_formatted = year + month + day + hour + minute + second

    return dt_formatted


# ******
#  MAIN
# ******

# Definition of the full path of the initialisation file

init_file_name = "/u/arpa/minighera/AdriaClim/src/initialisation_files/init_file_pciv_merge-rivers.txt"

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

for input_files_name in init_file:

    # "New line" removal

    input_files_name = input_files_name.rstrip("\n")

    # Extract the full paths of the input files

    input_file1_name = input_files_name.split()[0]
    input_file2_name = input_files_name.split()[1]

    # If both the input files exist

    if ( os.path.isfile(input_file1_name) == True and os.path.isfile(input_file2_name) == True ):

        # Print message to inform the user

        print("\n\t Input files: %s and %s found. Merging starts..." % (input_file1_name, input_file2_name))

    # If at least one of the initialisation files does not exist

    else:

        # Print message to inform the user and skip to the next couple of files

        print("\n\t Warning! Input files: %s and %s, at least one not found. Please check.\n" % (input_file1_name, input_file2_name))
        continue

    # Function calling to extract the data and the number of lines of both
    # input files

    data1 = data_coll(input_file1_name)
    l1 = len(data1)
    data2 = data_coll(input_file2_name)
    l2 = len(data2)

    # If the inputs files are not characterized by the same number of data
    # lines

    if ( l1 != l2 ):

        # Print message to inform the user

        print("\n\t Input files are not characterized by the same number of data lines:")
        print("\n\t merging cannot be performed. Please check.\n")

    # Extract the starting and ending date and time of the time period under
    # investigation, and format them properly

    dt_start = data1[0].split()[0]
    dt_start = dt_form(dt_start)
    dt_end = data1[l1 -1].split()[0]
    dt_end = dt_form(dt_end)

    # Definition of the basename of the output file

    output_file_basename = os.path.basename(input_file1_name).split(".")[0]
    output_file_name = output_file_basename.split("_pciv_")[0] + "_pciv_" + str(dt_start) + "-" + str(dt_end) + ".dat"

    # If the output file already exists

    if ( os.path.isfile(output_file_name) == True ):

        # Delete the output file

        os.remove(output_file_name)

    # Open the output file in appending mode

    output_file = open(output_file_name, "a")

    # For each line in the input files

    for i in range(0, l1):

        # Extract the river's discharge

        Q1 = data1[i].split()[1]
        Q2 = data2[i].split()[1]

        # If only the first input file contains available data

        if ( Q1 != "nan" and Q2 == "nan" ):

            # Print the available data to the output file

            print(data1[i], file = output_file)

        # Otherwise

        else:

            # Print to the output file

            print(data2[i], file = output_file)

    # Close the output file

    output_file.close()

# Close the initialisation file

init_file.close()
print()
