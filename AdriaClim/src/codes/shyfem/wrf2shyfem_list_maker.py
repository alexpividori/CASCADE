# *****************************************************************************
#
#  DESCRIPTION:      this Python script is aimed at printing to the standard
#                    output a list of daily NetCDF (.nc) data files, for a
#                    desired time period. Specifically, each line is related
#                    to a specific day (the first line is related to the first
#                    day of the desired time period, the second line is related
#                    to the second day of the desired time period, and so on).
#                    On a single line, several files may be present, each
#                    related to a specific dimension (variable). The data files
#                    list looks as follows:
#
#                    root_dir/var_1-day_1.nc root_dir/var_2-day_1.nc ...
#                    root_dir/var_1-day_2.nc root_dir/var_2-day_2.nc ...
#                    ...
#
#                    where
#
#                    root_dir = root directory storing data files
#                    var_i    = WRF (CRMA) name of the specific dimension
#                               (e.g. U10, V10, PSFC, SWDOWN, HFX, etc.)
#                    day_i    = specific day (YYYYMMDD00-YYYMMDD23) of the
#                               considered time period (e.g. 2017110100-2017110123)
#
#                    e.g.
#
#                    U10-2017110100-2017110123.nc V10-2017110100-2017110123.nc ...
#                    U10-2017110200-2017110223.nc V10-2017110200-2017110223.nc ...
#                    ...
#
#                    The starting and ending date and time of the desired time
#                    period, the root directory storing data files and the
#                    dimensions (variables) to be considered are provided to
#                    the script as command-line arguments.
#
#  EXTERNAL CALLS:   none.
#
#  EXTERNAL FILES:   none.
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
from datetime import datetime, timedelta

# ***********
#  FUNCTIONS
# ***********

# Extraction of date and time (YYYYMMDDhh) elements
def dt_elem_extr(dt):
    # Extract date and time elements by string slicing
    year = dt[0:4]
    month = dt[4:6]
    day = dt[6:8]
    hour = dt[8:10]
    # Define a list containing the date and time elements
    elements = [year, month, day, hour]
    return elements

# Extraction of date and time elements from the clock, formatting them properly
def dt_clock_elem_extr(dt_clock):
    # Extract and format (e.g. 2021-06-04::00, not 2021-6-4::0)
    year = str(dt_clock.year)
    if(dt_clock.month >= 10): month = str(dt_clock.month)
    else: month = "0" + str(dt_clock.month)
    if(dt_clock.day >= 10): day = str(dt_clock.day)
    else: day = "0" + str(dt_clock.day)
    if (dt_clock.hour >= 10): hour = str(dt_clock.hour)
    else: hour = "0" + str(dt_clock.hour)
    # Define a list containing the date and time elements of the clock
    clock_elements = [year, month, day, hour]
    return clock_elements

# Definition of the name (full path) of the data files to be grouped
def filename_def(dimensions, directory, year, month, day):
    # Define an empty list to be filled with the names (full paths) of the data
    # files to be grouped
    names = []
    # For each dimension (variable) to be considered
    for dim in dimensions:
        # Build the name of the data file to be considered by knowing that it
        # lies in the directory "directory" and it is of the following type:
        # dim-YYYYMMDD00-YYYYMMDD23.nc,
        # where "dim" is the WRF (CRMA) name of the considered dimension (e.g.
        # U10, V10, PSFC, SWDOWN, HFX, etc.)
        name = directory + "/" + year + "/" + month + "/" + dim + "-" + year + month + day + "00-" + year + month + day + "23.nc"
        # Fill the list previously defined (append)
        names.append(name)
    # Extract the number of data files to be grouped
    n = len(names)
    # Initialise the set of data files to be grouped with the first file
    filenames = names[0]
    # If the number of data files to be grouped is larger than one
    if(n>1):
        # For each data file to be grouped, except for the first
        for i in range(1,n):
            # Build the content to be printed (file1_i file2_i file3_i ...)
            filenames = filenames + " " + names[i]
    return filenames

# ******
#  MAIN
# ******

# Read command-line arguments
dt_start = sys.argv[1]   # starting date and time of the desired time period:
                         # YYYYMMDDhh
dt_end = sys.argv[2]     # ending date and time of the desired time period:
                         # YYYYMMDDhh
root_dir = sys.argv[3]   # root directory of data storage
dims = sys.argv[4]       # dimensions (variables): var1,var2,var3,...

# Extract the single dimensions (variables), putting them into a list, by
# knowing that these are separated by a comma (,)
dims = dims.split(",")

# Function calling: extraction of date and time elements (from the starting
# and ending date and time of the desired time period)
year_start = dt_elem_extr(dt_start)[0]
month_start = dt_elem_extr(dt_start)[1]
day_start = dt_elem_extr(dt_start)[2]
hour_start = dt_elem_extr(dt_start)[3]
year_end = dt_elem_extr(dt_end)[0]
month_end = dt_elem_extr(dt_end)[1]
day_end = dt_elem_extr(dt_end)[2]
hour_end = dt_elem_extr(dt_end)[3]

# Definition of "datetime" objects, by the use of the starting and ending date
# and time of the desired time period
clock = datetime(int(year_start), int(month_start), int(day_start), int(hour_start))
clock_end = datetime(int(year_end), int(month_end), int(day_end), int(hour_end))

# For the entire desired time period
while(clock <= clock_end):
    # Function calling: extraction of date and time elements from the clock,
    # formatting them properly
    year = dt_clock_elem_extr(clock)[0]
    month = dt_clock_elem_extr(clock)[1]
    day = dt_clock_elem_extr(clock)[2]
    hour = dt_clock_elem_extr(clock)[3]
    # Forward the clock by one day (it is assumed to deal with daily files)
    clock = clock + timedelta(days = 1)
    # Function calling: definition of the name (full path) of the data files to
    # be grouped
    filenames = filename_def(dims, root_dir, year, month, day)
    # Print the name (full path) of the data files to be grouped as follows:
    # file1_1 file2_1 file3_1 ...
    # file1_2 file2_2 file3_2 ...
    # ...
    print(filenames)
