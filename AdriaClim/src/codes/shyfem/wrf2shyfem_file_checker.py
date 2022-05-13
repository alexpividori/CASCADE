# *****************************************************************************
#
#  DESCRIPTION:      this Python script is aimed at checking the existence of
#                    all the files listed in a list file. Specifically, for
#                    each file that does not exist, a message is printed on
#                    the standard output to inform the user. Even in case all
#                    the files exist, a message is printed on the standard
#                    output to inform the user.
#
#  EXTERNAL CALLS:   none.
#
#  EXTERNAL FILES:   - list file: ASCII file containing a list of files (full
#                      paths), the existence of which is checked by the script.
#                      Each line of the list file may contain more than one
#                      file (files arranged on the same line are separated by
#                      a sigle space). The list file looks as follows:
#
#                      file_1 file_2 file_3 ...
#                      file_i file_i+1 file_i+2 ...
#                      ...
#
#  DEVELOPER:        Alessandro Minigher (alessandro.minigher@arpa.fvg.it)
#                    ARPA FVG - S.O.C. Stato dell'Ambiente - CRMA
#                    "AdriaClim" Interreg IT-HR project
#
#  SOFTWARE VERSION: Python 3.8.1 (python/3.8.1/gcc/8.2.0-mbzms7w).
#
#  CREATION DATE:    08/06/2021.
#
#  MODIFICATIONS:    none.
#
#  VERSION:          0.1.
#
# *****************************************************************************

# Import the needed modules
import sys
import os

# ***********
#  FUNCTIONS
# ***********

# Check the existence of the data files listed in the data list file
def check(file2check_name):
    # Initialise a flag to be used to know if all the data files exist (= 0,
    # all the data files exist; = 1, not all the data files exist)
    file_existence = 0
    # Open the data list file in reading mode
    file2check = open(file2check_name, "r")
    # For each line in the data list file
    for line in file2check:
        # Remove the "new line"
        line = line.rstrip("\n")
        # Extract all the files, putting them into a list, by knowing that for
        # each line several files, separated by a single space, may be present
        datafile_list = line.split()
        # For each data file in the list previously created
        for datafile in datafile_list:
            # Check the existence of the data file:
            # if the data file does not exist
            if (not os.path.isfile(datafile)):
                # Print a message to inform the user and switch the flag
                print("\n\tData file: %s does not exist. Please check." % (datafile))
                file_existence = 1
    # If all the data files exist
    if (file_existence == 0):
        # Print a message to inform the user
        print("\n\tAll the data files to be processed exist.\n")
    return

# ******
#  MAIN
# ******

# Read the command-line argument (data list file to be checked)
file_list = sys.argv[1]

# Function calling: check the existence of the data files listed in the data
# list file
check(file_list)
