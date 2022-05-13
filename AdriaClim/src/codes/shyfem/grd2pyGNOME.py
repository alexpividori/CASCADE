#******************************************************************************
#
# DESCRIPTION:      this Python script is aimed at converting part of GRD
#                   (.grd) files (single closed, contour lines, namely boundary
#                   lines and islands), to the format required in input by the
#                   (py)GNOME model, for the "bnd(nbnd, bni)" NetCDF variable
#                   (see the EXTERNAL FILES comment section for a better
#                   understanding).
#
# EXTERNAL CALLS:   none.
#
# EXTERNAL FILES:    - initialisation file: ASCII file containing the full
#                      paths of the input files to be processed, together with
#                      two flags, the description of which is provided in the
#                      following
#
#                       input_file1 island1 water_land1
#                       input_file2 island2 water_land2
#                       ...
#
#                       where
#
#                        input_file = full path of the input file to be
#                                     processed
#                        island     = 0 (not an island), otherwise equal to the
#                                     island's ID
#                        water_land = 0 land, 1 water
#
#                    - input files: ASCII files (part of GRD files) formatted
#                      as shown, as an example, below
#
#                       3 id t nn
#                        n1 n2 n3 ...
#                        ni ni+1 ...
#                        ...
#
#                       where
#
#                        3  = flag identifying a line in a GRD file
#                        id = line's ID
#                        t  = line's type (usually 0)
#                        nn = number of nodes making the line
#                        n  = node's ID
#
#                    - output file: ASCII file formatted as shown below
#
#                        bnd = n1, n2, island12, water_land12,
#                              n2, n3, island23, water_land23,
#                              n3, n4, island34, water_land34,
#                              ...
#                              n_N-1, n_N, islandN-1N, water_landN-1N ;
#
#                       where
#
#                        bnd        = name of the NetCDF variable required by
#                                     the (py)GNOME model
#                        n          = node's ID
#                        island     = 0 if the couple of related nodes makes a
#                                     line that is not part of an island, 1 if
#                                     the couple of related nodes makes a line
#                                     that is part of an island
#                        water_land = 0 if the couple of related nodes makes a
#                                     line that is part of the land (coastline),
#                                     1 if the couple of related nodes makes a
#                                     line that is part of water (boundary line
#                                     in the open sea).
#
# DEVELOPER:        Alessandro Minigher (alessandro.minigher@arpa.fvg.it)
#                   ARPA FVG - S.O.C. Stato dell'Ambiente - CRMA
#                   "AdriaClim" Interreg IT-HR project
#
# SOFTWARE VERSION: Python 3.8.1 (python/3.8.1/gcc/8.2.0-mbzms7w).
#
# CREATION DATE:    29/04/2021.
#
# MODIFICATIONS:    none.
#
# VERSION:          0.1.
#
#******************************************************************************

# Modules importation

import os
import sys


# ***********
#  FUNCTIONS
# ***********

# CHECK THE EXISTENCE OF THE INITIALISATION FILE

def check_init_file(init_file_name):

    # If the initialisation file exists

    if ( os.path.isfile(init_file_name) == True ):

        # Print message to inform the user

        print("\n\t Initialisation file: %s found." % (init_file_name))

    # If the initialisation file does not exist

    else:

        # Print message to inform the user and exit

        print("\n\t Warning! Initialisation file: %s not found. Please check.\n" % (init_file_name))
        sys.exit()

    return

# CHECK THE EXISTENCE OF THE INPUT FILE

def check_input_file(input_file_name):

    # Initialisation of a flag

    flag = 0

    # If the input file exists

    if ( os.path.isfile(input_file_name) == True ):

        # Print message to inform the user

        print("\n\t Input file: %s found. Formatting starts..." % (input_file_name))

    # If the input file does not exist

    else:

        # Print message to inform the user and switch the flag

        print("\n\t Warning! Input file: %s not found. Skip to next file.\n" % (input_file_name))
        flag = 1

    return flag

# CHECK THE EXISTENCE OF THE OUTPUT FILE

def check_output_file(output_file_name):

    # If the output file already exists

    if ( os.path.isfile(output_file_name) == True ):

        # Delete the output file

        os.remove(output_file_name)

    return

# DATA COLLECTION

def data_collect(input_file_name):

    # Initialisation of an empty list to be filled

    nodes = []

    # Initialisation of a flag: 0 = first line of the input file, 1 = otherwise

    line = 0

    # Open the input file in reading mode

    input_file = open(input_file_name, "r")

    # For each line in the input file

    for data in input_file:

        # If the line read is the first

        if ( line == 0 ):

            # Switch the flag and skip to the next line

            line = 1
            continue

        # "New line" removal

        data = data.rstrip("\n")

        # Split data

        data_list = data.split()

        # For each element in the list

        for node in data_list:

            # List filling

            nodes.append(node)

    # Close the input file

    input_file.close()
    return nodes

# OUTPUT FORMATTING

def out_form(output_file_name, nodes, island, land_water, file_index_first, file_index_last):

    # Open the output file in appending mode

    output_file = open(output_file_name, "a")

    # For each element in the list

    for i in range(0, len(nodes) - 1):

        # If the input file is the first, and its line is the first to be
        # processed

        if ( file_index_first == 0 and i == 0 ):

            # Format the output properly

            output = " bnd = " + nodes[i] + ", " + nodes[i + 1] + ", " + island + ", " + land_water + ","

        # If the input file to be processed is not the last, or it is the last,
        # but its line is not the last to be processed

        elif ( file_index_last == 0 or (file_index_last == 1 and i != len(nodes) - 2) ):

            # Format the output properly

            output = "       " + nodes[i] + ", " + nodes[i + 1] + ", " + island + ", " + land_water + ","

        # If the output file is the last and its line is the last to be
        # processed

        elif ( file_index_last == 1 and i == len(nodes) - 2 ):

            # Format the output properly

            output = "       " + nodes[i] + ", " + nodes[i + 1] + ", " + island + ", " + land_water + " ;"

        # Print to the output file

        print(output, file = output_file)

    # Close the output file

    output_file.close()
    return


# ******
#  MAIN
# ******

# Definition of the full path of the initialisation file

#init_file_name = "/lustre/arpa/minighera/initialisation_files/init_file_grd2pyGNOME.txt"
init_file_name = "/u/arpa/minighera/AdriaClim/src/initialisation_files/init_file_grd2pyGNOME.txt"

# Function calling: check the existence of the initialisation file

check_init_file(init_file_name)

# Definition of the basename of the output file

output_file_name = "mesh_nadri-mg_33100_bnd.cdl"

# Function calling: check the existence of the output file

check_output_file(output_file_name)

# Open the initialisation file in reading mode

init_file = open(init_file_name, "r")

# Count the number of input files to be processed

n_lines = 0
for line in init_file:
    n_lines = n_lines + 1

# Close the initialisation file and open it again

init_file.close()
init_file = open(init_file_name, "r")

# Initialisation of a line index

line_index = 0

# For each line in the initialisation file

for line in init_file:

    # Increase the line index

    line_index = line_index + 1

    # "New line" removal

    line = line.rstrip("\n")

    # Extraction of useful information

    input_file_name = line.split()[0]   # name of input file
    island = line.split()[1]            # flag: 1 = island, 0 = not island
    land_water = line.split()[2]        # flag: 1 = water,  0 = land

    # Function calling: check the existence of the input file

    check_input_file(input_file_name)

    # If the input file has not been found, skip to the next file

    if ( check_input_file(input_file_name) == 1 ): continue

    # Function calling: data collection

    nodes = data_collect(input_file_name)

    # If the input file to be processed is the first

    if ( line_index == 1 ):

        # Function calling: output formatting properly

        out_form(output_file_name, nodes, island, land_water, 0, 0)

    # If the input file is neither the first nor the last to be processed

    elif ( line_index != 1 and line_index != n_lines):

        # Function calling: output formatting properly

        out_form(output_file_name, nodes, island, land_water, 1, 0)

    # If the input file is the last to be processed

    else:

        # Function calling: output formatting properly

        out_form(output_file_name, nodes, island, land_water, 1, 1)

# Close the initialisation file

init_file.close()
print()
