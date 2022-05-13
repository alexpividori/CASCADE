#******************************************************************************
#
# DESCRIPTION:      this Python script is aimed at computing some of the main
#                   statistical parameters (average, minimum, maximum, median
#                   and 25th and 75th percentiles) for a daily distribution of
#                   data (time series of river’s discharges), characterized by
#                   sub-daily (or daily, as a boundary case) time resolution.
#                   This is performed for the entire length of the time series
#                   to be considered.
#                   It is assumed that the input files are formatted as
#                   required in input by the SHYFEM model (see the EXTERNAL
#                   FILES comment section).
#
# EXTERNAL CALLS:   none.
#
# EXTERNAL FILES:   - initialisation file: ASCII file containing, arranged on
#                     each line, the full paths of the input time series files
#                     to be analysed.
#
#                      E.g.
#                      input_file1
#                      input_file2
#
#                   - input files: ASCII time series file, formatted as shown
#                     below
#
#                      date&time1   Q1
#                      date&time2   Q2
#                      ...
#
#                       where
#
#                        date&time = date and time formatted as YYYY-MM-DD::hh:mm:ss
#                        Q         = river's discharge (NaNs are indicated with
#                                    "nan")
#
#                   - output files: ASCII time series file, formatted as shown
#                     below
#
#                      date&time1 Q1_ave Q1_min Q1_max Q1_med Q1_25p Q1_75p
#                      date&time2 Q2_ave Q2_min Q2_max Q2_med Q2_25p Q2_75p
#                      ...
#
#                       where
#
#                        date&time = date and time formatted as YYYY-MM-DD::hh:mm:ss
#                        Q_ave = daily average dischage
#                        Q_min = daily minimum discharge
#                        Q_max = daily maximum discharge
#                        Q_med = daily median discharge
#                        Q_25p = daily 25th percentile
#                        Q_75p = daily 75th percentile
#
# DEVELOPER:        Alessandro Minigher (alessandro.minigher@arpa.fvg.it)
#                   ARPA FVG - S.O.C. Stato dell'Ambiente - CRMA
#                   "AdriaClim" Interreg IT-HR project
#
# SOFTWARE VERSION: Python 3.8.1 (python/3.8.1/gcc/8.2.0-mbzms7w).
#
# CREATION DATE:    12/04/2021.
#
# MODIFICATIONS:    19/04/2021 ---> debug (compute daily statistics also if the
#                                   last day to be considered is not complete).
#                   20/04/2021 ---> debug (further treatment of limiting
#                                   cases).
#
# VERSION:          0.3.
#
#******************************************************************************

# Modules importation

import os
import sys
import numpy as np
from datetime import datetime, timedelta


# ***********
#  FUNCTIONS
# ***********

# Definition of a function aimed at printing metadata

def header(file_out):

    # Print the header of the output files (metadata)

    print("# Columns description:", file = file_out)
    print("#", file = file_out)
    print("# 1) Date (YYYY-MM-DD)", file = file_out)
    print("# 2) Daily average river's discharge [m^3 s^-1]", file = file_out)
    print("# 3) Daily minimum river's discharge [m^3 s^-1]", file = file_out)
    print("# 4) Daily maximum river's discharge [m^3 s^-1]", file = file_out)
    print("# 5) Daily median river's discharge [m^3 s^-1]", file = file_out)
    print("# 6) Daily 25th percentile [m^3 s^-1]", file = file_out)
    print("# 7) Daily 75th percentile [m^3 s^-1]", file = file_out)
    print("#", file = file_out)

    return


# ******
#  MAIN
# ******

# Definition of the full path of the initialisation file

init_file_name = "/u/arpa/minighera/AdriaClim/src/initialisation_files/init_file_daily_statistics-rivers.txt"

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

        print("\n\t Input file: %s found. Computation of statistics starts..." % (input_file_name))

    # If the input file does not exist

    else:

        # Print message to inform the user and skip to the next file

        print("\n\t Warning! Input file: %s not found. Skip to next file....\n" % (input_file_name))
        continue

    # Definition of the basename of the ouput file
    
    output_file_name = os.path.basename(input_file_name).split(".")[0] + "_daily_statistics.dat"
    
    # If the output file already exists

    if ( os.path.isfile(output_file_name) == True ):

        # Delete the output file

        os.remove(output_file_name)

    # Open the output file in appending mode

    output_file = open(output_file_name, "a")

    # Function calling: print the header od the output files

    header(output_file)

    # Open the input file in reading mode

    input_file = open(input_file_name, "r")

    # Definition of an empty list to be filled
    
    Q_list = []

    # Initialisation of a lines counter

    counter = 0

    # For each line in the input file, increase the counter

    for line in input_file: counter = counter + 1

    # Close the input file and open it again

    input_file.close()
    input_file = open(input_file_name, "r")

    # Initialisation of a flag to be used to identify the first line of the
    # inpu file: 0 = first line, 1 otherwise
    
    n_line = 0

    # Initialisation of an index

    index = 0
    
    # For each line in the input file
    
    for data in input_file:
    
        # Increase the index

        index = index + 1

        # "New line" removal
        
        data = data.rstrip("\n")
        
        # Data extraction
        
        dt = data.split()[0]          # date and time
        Q = float(data.split()[1])    # river's discharge
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
        
        # If the line read is the first
        
        if ( n_line == 0):
        
            # List filling
            
            Q_list.append(Q)

            # Switch the flag: first line has been read
        
            n_line = 1
            
            # Set the "previous" date and time as the "current" ones
        
            year_prev = year
            month_prev = month
            day_prev = day
            hour_prev = hour
            minute_prev = minute
            second_prev = second

        # If the line read is not the first

        else:

            # If the current day is the same as the previous one, and not the
            # last to be considered
            
            if ( day == day_prev and month == month_prev and year == year_prev and index != counter ):
            
                # List filling
                
                Q_list.append(Q)

            # If the current day is the same as the previous one, and the last
            # to be considered

            elif (day == day_prev and month == month_prev and year == year_prev and index == counter):

                # List filling

                Q_list.append(Q)

                # Compute some of the main statistical parameters, without
                # caring about NaNs

                Q_ave = np.nanmean(Q_list)             # average
                Q_min = np.nanmin(Q_list)              # minimum
                Q_max = np.nanmax(Q_list)              # maximum
                Q_med = np.nanmedian(Q_list)           # median
                Q_25p = np.nanpercentile(Q_list, 25)   # 25th percentile
                Q_75p = np.nanpercentile(Q_list, 75)   # 75th percentile

                # Format the date: YYYY-MM-DD

                date_prev = year_prev + "-" + month_prev + "-" + day_prev

                # Print to the output file

                print("%s %10.2f %10.2f %10.2f %10.2f %10.2f %10.2f" % (date_prev, Q_ave, Q_min, Q_max, Q_med, Q_25p, Q_75p), file = output_file)

            # If the current day is different from the previous one, and not
            # the last to be considered
                
            elif ( day != day_prev and index != counter ):

                # Conversion of the list to "numpy" arrays
                
                Q_list = np.array(Q_list)

                # Compute some of the main statistics parameters
                
                Q_ave = np.nanmean(Q_list)             # average
                Q_min = np.nanmin(Q_list)              # median
                Q_max = np.nanmax(Q_list)              # maximum
                Q_med = np.nanmedian(Q_list)           # median
                Q_25p = np.nanpercentile(Q_list, 25)   # 25th percentile
                Q_75p = np.nanpercentile(Q_list, 75)   # 75th percentile

                # Format the date: YYYY-MM-DD

                date_prev = year_prev + "-" + month_prev + "-" + day_prev

                # Print to the output file
                
                print("%s %10.2f %10.2f %10.2f %10.2f %10.2f %10.2f" % (date_prev, Q_ave, Q_min, Q_max, Q_med, Q_25p, Q_75p), file = output_file)

                # List restoration
                
                Q_list = []
                
                # List filling
                
                Q_list.append(Q)

            # If the current day is different from the previous one, and the
            # last to be considered

            if ( day != day_prev and index == counter ):

                # Conversion of the list to "numpy" arrays

                Q_list = np.array(Q_list)

                # Compute some of the main statistics parameters

                Q_ave = np.nanmean(Q_list)             # average
                Q_min = np.nanmin(Q_list)              # minimum
                Q_max = np.nanmax(Q_list)              # maximum
                Q_med = np.nanmedian(Q_list)           # median
                Q_25p = np.nanpercentile(Q_list, 25)   # 25th percentile
                Q_75p = np.nanpercentile(Q_list, 75)   # 75th percentile

                # Format the date: YYYY-MM-DD

                date_prev = year_prev + "-" + month_prev + "-" + day_prev

                # Print to the output file

                print("%s %10.2f %10.2f %10.2f %10.2f %10.2f %10.2f" % (date_prev, Q_ave, Q_min, Q_max, Q_med, Q_25p, Q_75p), file = output_file)

                # List restoration

                Q_list = []

                # List filling

                Q_list.append(Q)

                # Conversion of the list to "numpy" arrays

                Q_list = np.array(Q_list)

                # Compute some of the main statistics parameters

                Q_ave = np.nanmean(Q_list)
                Q_min = np.nanmin(Q_list)
                Q_max = np.nanmax(Q_list)
                Q_med = np.nanmedian(Q_list)
                Q_25p = np.nanpercentile(Q_list, 25)
                Q_75p = np.nanpercentile(Q_list, 75)

                # Format the date: YYYY-MM-DD

                date_prev = year + "-" + month + "-" + day

                # Print to the output file

                print("%s %10.2f %10.2f %10.2f %10.2f %10.2f %10.2f" % (date_prev, Q_ave, Q_min, Q_max, Q_med, Q_25p, Q_75p), file = output_file)

        # Set the "previous" date and time as the "current" ones
        
        year_prev = year
        month_prev = month
        day_prev = day
        hour_prev = hour
        minute_prev = minute
        second_prev = second

    # Close input and output files

    input_file.close()
    output_file.close()

# Close the initialisation file

init_file.close()
print()
