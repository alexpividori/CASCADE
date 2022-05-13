#******************************************************************************
#
# DESCRIPTION:      this Python script is aimed at finding the nearest node,
#                   of a desired computational mesh, to a given geographic
#                   point (lon, lat).
#
# EXTERNAL CALLS:   none.
#
# EXTERNAL FILES:   - extra points file: ASCII file containing, arranged line
#                     by line, the following information
#
#                     # Metadata
#                     point-1 lon-1 lat-1
#                     point-2 lon-2 lat-2
#                     ...
#
#                      where
#
#                         point-i = i-th geographic point for which finding
#                                   the nearest node
#                         lon-i   = longitude of the i-th point
#                         lat-i   = latitude of the i-th point
#
#                   - GRD (mesh) file: GRD (.grd) file defining the
#                     computational mesh.
#
# DEVELOPER:        Alessandro Minigher (alessandro.minigher@arpa.fvg.it)
#                   ARPA FVG - S.O.C. Stato dell'Ambiente - CRMA
#                   "AdriaClim" Interreg IT-HR project
#
# SOFTWARE VERSION: Python 3.8.1 (python/3.8.1/gcc/8.2.0-mbzms7w).
#
# CREATION DATE:    20/07/2021.
#
# MODIFICATIONS:    none.
#
# VERSION:          0.1.
#
#******************************************************************************

# Import modules
import sys
import subprocess
from geopy.distance import geodesic

# ***********
#  FUNCTIONS
# ***********

# Find the nearest node to a given geographic point (lon, lat)
def find_nearest_node(GRD_mesh_file_name, point):
    # Initialise the index of the nearest node found (dummy value)
    nearest_node = -99.0
    # Initialise a flag to be used to identify the first node of the GRD
    # (mesh) file
    flag = 0
    # Extract all the lines describing a node from the GRD (mesh) file, by
    # knowing that these start with 1
    cat = subprocess.Popen(['cat', GRD_mesh_file_name], close_fds=True, stdout=subprocess.PIPE)
    grep = subprocess.Popen('grep "^1"', shell=True, stdin=cat.stdout, stdout=subprocess.PIPE)
    # For each line in the GRD (mesh) file (nodes only)
    for line in grep.stdout:
        # Decode and remove the "new line"
        line = line.decode("utf-8")
        line = line.rstrip("\n")
        # Extract the node's number, longitude and latitude
        node_number = line.split()[1]
        node_lon = line.split()[3]
        node_lat = line.split()[4]
        # Extract the geographic point's name, longitude and latitude
        point_name = point.split()[0]
        point_lon = point.split()[1]
        point_lat = point.split()[2]
        # Create couples (lat, lon) for the geographic point and node
        point_coords = (point_lat, point_lon)
        node_coords = (node_lat, node_lon)
        # Compute the geodesic distance between the geographic point and node
        distance = geodesic(point_coords, node_coords)
        # If the current node of the GRD (mesh) file is the first
        if (flag == 0):
            # Set the minimum distance as the current one
            distance_min = distance
            # Switch the flag and skip to the next iteration
            flag = 1
            continue
        # If the current distance is less or equal than the minimum one
        if (distance <= distance_min):
            # Set the minimum distance as the current one and set the current
            # node as the current one
            distance_min = distance
            nearest_node = node_number
    # Build part of the output to be printed
    point_out = point_name + " (" + point_lon + " E, " + point_lat + " N)"
    # Print the desired output
    print(nearest_node, point_out)
    return

# ******
#  MAIN
# ******

# Read the command line arguments: extra points and GRD (mesh) files
extra_pts_file_name = sys.argv[1]
GRD_mesh_file_name = sys.argv[2]
# Remove comments (metadata) from the extra points file, by knowing that these
# start with #
cat = subprocess.Popen(['cat', extra_pts_file_name], close_fds=True, stdout=subprocess.PIPE)
grep = subprocess.Popen('grep -v "^#"', shell=True, stdin=cat.stdout, stdout=subprocess.PIPE)
# For each line in the extra points file
for point in grep.stdout:
    # Decode and remove the "new line"
    point = point.decode("utf-8")
    point = point.rstrip("\n")
    # Function calling: find the nearest node to a given geographic point
    # (lon, lat)
    find_nearest_node(GRD_mesh_file_name, point)
