#******************************************************************************
#
# DESCRIPTION:      this Python script is aimed at building and printing to
#                   the standard output the following information:
#
#                   input_file-1a     input_file-1b   location-1
#                   input_file-2a     input_file-2b   location-2
#                   ...
#
#                    where
#
#                       input_file-ia = i-th time series input file for a
#                                       certain variable "a"
#                       input_file-ib = i-th time series input file for a
#                                       certain variable "b"
#                       location-i    = name and coordinates (lon, lat) of
#                                       the geographic point for which the
#                                       i-th time series input files are
#                                       provided
#
#                   This code requires the 5 (five) following command line
#                   arguments:
#
#                   root_dir       = root directory containing the input files
#                   var_1          = a certain variable "a" (es. temp, salt,
#                                    etc.)
#                   var_2          = a certain variable "b" (es. temp, salt,
#                                    etc.)
#                   dim            = spatial dimension (2d or 3d)
#                   extra_pts_file = name (full path) of an ASCII file (see
#                                    the EXTERNAL FILES comment section)
#
#
#                   NOTE: this script was born to deal with ASCII time series
#                         files obtained from the "extra" files resulting from
#                         numerical simulations performed with the SHYFEM
#                         model.
#                   
# EXTERNAL CALLS:   none.
#
# EXTERNAL FILES:   - ASCII file containing, arranged line by line, the
#                     following information
#
#                     location-1
#                     location-2
#                     ...
#
#                      where
#
#                         location-i   = name and coordinates (lon, lat) of the
#                                        geographic point for which the i-th
#                                        time series input files are provided
#
# DEVELOPER:        Alessandro Minigher (alessandro.minigher@arpa.fvg.it)
#                   ARPA FVG - S.O.C. Stato dell'Ambiente - CRMA
#                   "AdriaClim" Interreg IT-HR project
#
# SOFTWARE VERSION: Python 3.8.1 (python/3.8.1/gcc/8.2.0-mbzms7w).
#
# CREATION DATE:    07/07/2021.
#
# MODIFICATIONS:    none.
#
# VERSION:          0.1.
#
#******************************************************************************

# Import modules
import sys

# ***********
#  FUNCTIONS
# ***********

# Make a list of information
def list_maker(root_dir, var1, var2, dim, extra_pts_file_name):
    # Open the "extra" points file in reading mode
    extra_pts_file = open(extra_pts_file_name, "r")
    # Initialisation of an "extra" points counter
    extra_pts_counter = 0
    # For each line in the "extra" points file
    for coords in extra_pts_file:
        # Remove the "new line"
        coords = coords.rstrip("\n")
        # Increase the "extra" points counter by one unit
        extra_pts_counter = extra_pts_counter + 1
        # Define the names of two files, to be arranged on the same line of
        # the list
        filename1 = root_dir + "/" + var1 + "." + dim + "." + str(extra_pts_counter)
        filename2 = root_dir + "/" + var2 + "." + dim + "." + str(extra_pts_counter)
        # Build the line of the list and print it
        line_out = filename1 + "\t" + filename2 + "\t" + coords
        print(line_out)
    return

# ******
#  MAIN
# ******

# Read command-line arguments
root_dir = sys.argv[1]
var1 = sys.argv[2]
var2 = sys.argv[3]
dim = sys.argv[4]
extra_pts_file_name = sys.argv[5]

# Function calling:
list_maker(root_dir, var1, var2, dim, extra_pts_file_name)
