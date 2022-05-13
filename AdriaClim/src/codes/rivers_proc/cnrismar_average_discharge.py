#******************************************************************************
#
# DESCRIPTION:      this Python script is aimed at reading a time series of
#                   river's discharges, from which the average value is then
#                   computed.
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
#                   - input files: ASCII time series files, formatted as shown
#                     below:
#
#                      date&time_1      Q_1
#                      date&time_2      Q_2
#                      date&time_3      nan
#                      date&time_4      nan
#                      date&time_5      Q_5
#                      ...
#
#                      where
#
#                       date&time = date and time formatted as YYYY-MM-DD::hh:mm:ss
#                       Q         = river's discharge
#                       nan       = NaN (Not a Number)
#
#                   The basename of the input files have to be defined as
#                   shown, as an example, below:
#
#                   portata_isonzo.dat
#                   portata_tagliamento.dat
#                   ...
#                   i.e. [sometext]_[rivername].[someextension]
#
# DEVELOPER:        Alessandro Minigher (alessandro.minigher@arpa.fvg.it)
#                   ARPA FVG - S.O.C. Stato dell'Ambiente - CRMA
#                   "AdriaClim" Interreg IT-HR project
#
# SOFTWARE VERSION: Python 3.8.1 (python/3.8.1/gcc/8.2.0-mbzms7w).
#
# CREATION DATE:    27/04/2021.
#
# MODIFICATIONS:    none.
#
# VERSION:          0.1
#
#******************************************************************************

# Modules importation

import os
import numpy as np


# ***********
#  FUNCTIONS
# ***********

# DATA COLLECTION

def data_collect(input_file_name):

    # Definition of empty lists to be filled

    dt_list = []
    Q_list = []

    # Open the input file in reading mode

    input_file = open(input_file_name, "r")

    # For each line in the input file

    for line in input_file:

        # "New line" removal and data extraction

        line = line.rstrip("\n")
        dt = line.split()[0]         # date and time
        Q = float(line.split()[1])   # river's discharge

        # List filling and output formatting

        dt_list.append(dt)
        Q_list.append(Q)
        output = [dt_list, Q_list]

    # Close the input file

    input_file.close()

    return output


# ******
#  MAIN
# ******

# Definition of the full path of the initialisation file

init_file_name = "/u/arpa/minighera/AdriaClim/src/initialisation_files/init_file_cnrismar_average_discharge.txt"

# Open the initialisation file in reading mode

init_file = open(init_file_name, "r")

# Print to the stdout

print("\n\tAVERAGE RIVER'S DISCHARGE (m^3 s^-1)\n")

# For each line in the initialisation file

for input_file_name in init_file:

    # "New line" removal

    input_file_name = input_file_name.rstrip("\n")

    # Function calling: data collection

    dt_list = data_collect(input_file_name)[0]   # date and time
    Q_list = data_collect(input_file_name)[1]    # river's discharge

    # Compute the average river's discharge, without considering NaNs

    Q_ave = np.nanmean(Q_list)

    # Get useful information

    river_name = os.path.basename(input_file_name).split(".")[0].split("_")[1].capitalize()   # river's name
    dt_start = dt_list[0]                                                                     # starting date and time
    dt_end = dt_list[len(dt_list) - 1]                                                        # ending date and time

    # Print to the stdout

    print("\t%12s: %6.2f (%s - %s)" % (river_name, Q_ave, dt_start, dt_end))

# Close the initialisation file

init_file.close()
print()
