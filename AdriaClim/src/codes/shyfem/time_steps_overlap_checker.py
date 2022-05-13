#******************************************************************************
#
# DESCRIPTION:      this Python script is aimed at finding, in a time series
#                   input file, possible consecutive time steps that are
#                   actually the same.
#
# EXTERNAL CALLS:   none.
#
# EXTERNAL FILES:   - initialisation file: ASCII file containing, arranged
#                     line by line, the following information
#
#                     input_file-1
#                     input_file-2
#                     ...
#
#                      where
#
#                         input_file-i = i-th time series input file (see
#                                        the following point)
#
#                   - input_files: ASCII time series file containing, arranged
#                     line by line, the following information
#
#                     date&time-1  var(date&time-1)
#                     date&time-2  var(date&time-2)
#                     ...
#
#                      where
#
#                         date&time-i      = i-th time step (YYYY-MM-DD::hh:mm:ss)
#                         var(date&time-i) = variable at i-th time step
#
# DEVELOPER:        Alessandro Minigher (alessandro.minigher@arpa.fvg.it)
#                   ARPA FVG - S.O.C. Stato dell'Ambiente - CRMA
#                   "AdriaClim" Interreg IT-HR project
#
# SOFTWARE VERSION: Python 3.8.1 (python/3.8.1/gcc/8.2.0-mbzms7w)
#
# CREATION DATE:    13/07/2021.
#
# MODIFICATIONS:    none.
#
# VERSION:          0.1.
#
#******************************************************************************

# Import modules
import sys
import os

# ***********
#  FUNCTIONS
# ***********

# Check the existence of the initialisation file
def check_init_file(init_file_name):
    # If the initialisation file exists
    if (os.path.isfile(init_file_name)):
        # Print a message to inform the user
        print("\n\tInitialisation file: %s found.\n" % (init_file_name))
    # Otherwise
    else:
        # Print a message to inform the user and exit
        print("\n\tWARNING! Initialisation file: %s not found. Exit...\n" % (init_file_name))
        sys.exit()
    return

# Check if a time step appears more the once consecutively
def t_overlap_check(init_file_name):
    # Function calling: check the existence of the initialisation file
    check_init_file(init_file_name)
    # Open the initialisation file in reading mode
    init_file = open(init_file_name, "r")
    # For each line in the initialisation file
    for input_file_name in init_file:
        # Remove the "new line"
        input_file_name = input_file_name.rstrip("\n")
        # If the input file exists
        if (os.path.isfile(input_file_name)):
            # Print a message to inform the user about the current input file
            print("\n\t Input file: %s found." % (input_file_name))
        else:
            # Print a message to inform the user and skip to the next file (if
            # present)
            print("\n\t Input file: %s not found. Skip..." % (input_file_name))
            continue
        # Open the input file in reading mode
        input_file = open(input_file_name, "r")
        # Initialisation of a flag, to be used to identify the first data line
        flag = 0
        # For each line in the input file
        for data in input_file:
           # Remove the "new line"
           data = data.rstrip("\n")
           # Extract the "current" time step
           dt = data.split()[0]
           # If the data line is the first
           if (flag == 0):
               # Switch the flag: first data line read
               flag = 1
           # Otherwise
           else:
               # If the "current" time step is the same as the "previous" one
               if (dt == dt_prev):
                   # Print a message to inform the user
                   print("\n\t\tWARNING! The time step %s appears more than one time." % (dt))
           # Set the "previous" time step as the "current" one
           dt_prev = dt
    return

# ******
#  MAIN
# ******

# Read the command-line argument: initialisation file
init_file_name = sys.argv[1]

# Function calling: check if a time step appears more the once
t_overlap_check(init_file_name)
# Cosmetics
print()
