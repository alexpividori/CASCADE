#!/bin/bash

# ******************************************************************************
#
#  DESCRIPTION:    this job template is aimed at drawing contour plots of the
#                  horizontal distribution of the spin-up time, estimated for a
#                  certain oceanographic variable, at constant depth.
#                  Specifically, a figure is drawn for each depth (vertical
#                  layer, in case of 3D variables) to be considered.
#                  This is performed through GMT 6.0.0 commands.
#
#  EXTERNAL CALLS: none.
#
#  EXTERNAL FILES: - input ASCII file containing estimates of the spin-up time,
#                    according to a regression analysis, formatted in
#                    tab-separated columns, as shown below:
#
#                    # Lines of metadata (preceded by a "#")
#                    column1    column2    column3    column4    column5    column6
#
#                    with
#
#                     -- "column1" dedicated to EXT nodes;
#                     -- "column2" dedicated to vertical layers (3D variables);
#                     -- "column3" dedicated to spin-up time estimates;
#                     -- "column4" dedicated to R²;
#                     -- "column5" dedicated to EXT node's longitude (°E);
#                     -- "column6" dedicated to EXT node's latitude (°N).
#
#  DEVELOPER:      Alessandro Minigher (alessandro.minigher@arpa.fvg.it)
#                  ARPA FVG - S.O.C. Stato dell'Ambiente - CRMA
#                  "AdriaClim" Interreg IT-HR project
#
#  CREATION DATE:  2021-11-18.
#
#  MODIFICATIONS:  2021-11-21 -> compression of figures in a "tar.gz" archive;
#                             -> introduction of the function named "out_form".
#                  2021-11-23 -> addition of the information about the vertical
#                                layer and simulations under analysis.
#                  2021-11-24 -> reduction of the font size of the color bar.
#
#  VERSION:        0.4.
#
# ******************************************************************************

# *************************
#  START OF JOB DIRECTIVES
# *************************

#PBS -P %%JOB_P%%
#PBS -W umask=%%JOB_W_umask%%
#PBS -W block=%%JOB_W_block%%
#PBS -N %%JOB_N%%
#PBS -o %%JOB_o%%
#PBS -e %%JOB_e%%
#PBS -q %%JOB_q%%
#PBS -l nodes=%%JOB_l_nodes%%:ppn=%%JOB_l_ppn%%
#PBS -l walltime=%%JOB_l_walltime%%
##PBS -m %%JOB_m%%
##PBS -M %%JOB_M%%

# ***********************
#  END OF JOB DIRECTIVES
# ***********************

# **************
#  START OF JOB
# **************

#  --- START OF FUNCTIONS ---

# Draw the contour plot of the horizontal distribution of the spin-up time (for
# a certain variable and for a specific depth)
gmt_plot () {
    # Define the domain for which drawing the plot (template variables are
    # employed, to be replaced through a "sedfile")
    local LON_MIN_GMT=%%LON_MIN_GMT%%   # minimum longitude
    local LON_MAX_GMT=%%LON_MAX_GMT%%   # maximum longitude
    local LAT_MIN_GMT=%%LAT_MIN_GMT%%   # minimum latitude
    local LAT_MAX_GMT=%%LAT_MAX_GMT%%   # maximum latitude
    # Define the minimum and maximum values of the static color palette table,
    # together with the step (template variables are employed, to be replaced
    # through a "sedfile")
    local TAU_MIN_GMT=%%TAU_MIN_GMT%%
    local TAU_MAX_GMT=%%TAU_MAX_GMT%%
    local TAU_STEP_GMT=%%TAU_STEP_GMT%%
    # Define the format of the figure (template variable, to be replaced
    # through a "sedfile")
    local FIG_FORMAT="%%FIG_FORMAT%%"
    # Define the title of the figure (template variable, to be replaced through
    # a "sedfile")
    TITLE_GMT="%%TITLE_GMT%%"
    # Build a static color palette table (template variables are employed, to
    # be replaced through a "sedfile")
    gmt makecpt -Cred2green -T$TAU_MIN_GMT/$TAU_MAX_GMT/$TAU_STEP_GMT > colors.cpt -Iz
    # Draw the figure with proper basename (without extension) and format
    gmt begin "${FIGNAME_GMT}" $FIG_FORMAT
        # Draw a contour plot (in a certain domain) and the coastline
        gmt contour @"${FILE2PROC}" -R$LON_MIN_GMT/$LON_MAX_GMT/$LAT_MIN_GMT/$LAT_MAX_GMT -JM6i -Ccolors.cpt -I
        gmt coast -R$LON_MIN_GMT/$LON_MAX_GMT/$LAT_MIN_GMT/$LAT_MAX_GMT -JM6i -B -Ggray -B+t"${TITLE_GMT}"
        # If the variable under analysis is 3D
        if [[ "$DIM" == "3d" ]]; then
            # Write the index of the vertical layer on the graph (top left)
            echo "Layer "$ith_layer| gmt text -R$LON_MIN_GMT/$LON_MAX_GMT/$LAT_MIN_GMT/$LAT_MAX_GMT -JM6i -F+cTL -Dj0.1c/0.2c
        fi
        # Write the couple of simulations under analysis on the graph (top
        # right)
        echo "%%SIMA%% - %%SIMB%%" | gmt text -R$LON_MIN_GMT/$LON_MAX_GMT/$LAT_MIN_GMT/$LAT_MAX_GMT -JM6i -F+cTR -Dj0.1c/0.2c
        # Draw the colorbar, with proper font size
        gmt set FONT_ANNOT_PRIMARY 7p
        gmt colorbar -DJCB -Ccolors.cpt -Bx5f1 -By+l"d" -I
        # Remove the static color palette table
        rm -f colors.cpt
    gmt end
}

# Format the content to be printed in the file to be processed
out_form (){
    # Split the line in tab-separated columns (arguments), putting its
    # elements in an array
    IFS=$'\t' read -r -a array <<< "$line"
    # Get the desired data from the array just created
    layer=${array[1]}   # vertical layer
    tau=${array[2]}     # spin-up time (in seconds)
    lon=${array[4]}     # longitude
    lat=${array[5]}     # latitude
    # Convert the spin-up time from seconds to days (with two decimal
    # digits)
    tau=$(echo "scale=2; $tau/$seconds_in_day" | bc)
    # Format the desired data to be used for plotting, making them suitable
    # for GMT
    out="${lon};${lat};${tau}"
}

#  --- END OF FUNCTIONS ---

#  --- START OF MAIN ---

# Move to the directory where the job was run, informing the user
echo -e "\n\tMoving to ${PBS_O_WORKDIR}.\n"; cd ${PBS_O_WORKDIR}
echo -e "\n\tCurrent directory: $(pwd).\n"

# Purge, load and list the desired environmental modules (template variables,
# to be replaced through a "sedfile")
module purge
module load %%GMT_MOD%%
module list

# Define the default status for the creation of directories:
# - OKKO_mkdir=0 -> all went OK
# - OKKO_mkdir=1 -> something went KO
OKKO_mkdir=0
# Define the name of the directory aimed at storing post-processing files
# related to spin-up tests, for a given variable (template variable, to be
# replaced through a "sedfile")
SHY_POSTPROC_SPINUP_SIMS_VAR_DIR=%%SHY_POSTPROC_SPINUP_SIMS_VAR_DIR%%
# Define the name (full path) of the file aimed at containing estimates of the
# spin-up time, for all the EXT nodes and layers (3D variables)
SPINUP_FIT_FILENAME="%%SPINUP_FIT_FILENAME%%"
# Define the spatial dimension of the variable under analysis (template
# variable, to be replaced through a "sedfile")
DIM="%%DIM%%"
# Define the number of seconds in a day
seconds_in_day=$(echo "scale=2; 3600. * 24." | bc)
# Define the basename of a temporary file aimed at storing the data to be
# processed, deprived of metadata (lines starting with "#")
tmp_file=$(mktemp -u tmp_file.XXXXX)
# Remove metadata (lines starting with "#") from the file aimed at containing
# estimates of the spin-up time, for all the EXT nodes and layers (3D
# variables)
grep -v "^#" $SPINUP_FIT_FILENAME > $tmp_file

# If the variable under analysis is 2D
if [[ "$DIM" == "2d" ]]; then
    # Define the name of the file to be processed
    FILE2PROC=$(mktemp -u file2proc.XXXXX)
    # For each line in the data file
    while read line; do
        # Function calling: format the content to be printed in the file to be
        # processed
        out_form
        echo $out >> $FILE2PROC
    done < $tmp_file
    # Define the basename (without extension) of the figure (template variables
    # are employed, to be replaced through a "sedfile")
    FIGNAME_GMT="hod-%%VAR%%_%%SIMA%%-%%SIMB%%"
    # Function calling: draw the contour plot of the horizontal distribution of
    # the spin-up time (for a certain variable and for a specific depth)
    gmt_plot
    # Remove files that are no longer useful
    rm $tmp_file
    rm $FILE2PROC
# If the variable under analysis is 3D
elif [[ "$DIM" == "3d" ]]; then
    # Get the deepest vertical layer to be considered:
    #  - initialise the deepest vertical layer
    max_layer=0
    #  - for each line in the data file
    while read line; do
        # Split the line in tab-separated columns (arguments), putting its
        # elements in an array
        IFS=$'\t' read -r -a array <<< "$line"
        # Get the current layer
        layer=${array[1]}
        # If the current layer is deeper, set it as the deepest one
        if [ $layer -gt $max_layer ]; then max_layer=$layer; fi
    done < $tmp_file
    # For each layer to be considered
    for (( i=1; i<=$max_layer; i++ )); do
        # Define the basename of the file to be processed
        FILE2PROC="${i}.txt"
        # For each line in the data file
        while read line; do
            # Function calling: format the content to be printed in the file to
            # be processed
            out_form
            # If the current layer is equal to the i-th one
            if [ $layer -eq $i ]; then
                # Save the layer
                ith_layer=$layer
                # Print the data themselves to the file to be processed
                echo $out >> $FILE2PROC
            fi
        done < $tmp_file
        # Get the number of lines in the file to be processed
        n=$(wc -l < $FILE2PROC)
        # If the number of lines in the file to be processed is larger or equal
        # than 3, the contour plot can be drawn
        if [[ n -ge 3 ]]; then
            # Define the basename (without extension) of the figure (template
            # variables are employed, to be replaced through a "sedfile")
            FIGNAME_GMT="hod-%%VAR%%_%%SIMA%%-%%SIMB%%_layer${ith_layer}"
            # Function calling: draw the contour plot of the horizontal
            # distribution of the spin-up time (for a certain variable and for
            # a specific depth)
            gmt_plot
        fi
        # Remove the already processed file
        rm $FILE2PROC
    done
    # Remove the data file
    rm $tmp_file
fi

# Check if the directory aimed at storing post-processing files related to
# spin-up tests exists:
#  - if it exists
if [[ -e $SHY_POSTPROC_SPINUP_SIMS_VAR_DIR ]]; then
    # Inform the user
    echo -e "\n\tDirectory: ${SHY_POSTPROC_SPINUP_SIMS_VAR_DIR} exists.\n"
#  - if it does not exist
else
    # Inform the user and create it
    echo -e "\n\tDirectory: ${SHY_POSTPROC_SPINUP_SIMS_VAR_DIR} does not exist. Creating it...\n"
    mkdir -p $SHY_POSTPROC_SPINUP_SIMS_VAR_DIR || OKKO_mkdir=1
fi
# Check the outcome of the creation of the directory:
#  - if all went OK
if [[ $OKKO_mkdir -eq 0 ]]; then
    # Inform the user
    echo -e "\tDirectory: ${SHY_POSTPROC_SPINUP_SIMS_VAR_DIR} successfully created.\n"
    # Move the desired content (post-processing files) to the directory,
    # after compressing figures (template variables are employed, to be
    # replaced through a "sedfile")
    tar -czf "%%CONTOUR_HOD_PLOTS_ARCHIVE%%" *".%%FIG_FORMAT%%"
    mv "%%CONTOUR_HOD_PLOTS_ARCHIVE%%" $SHY_POSTPROC_SPINUP_SIMS_VAR_DIR
    echo -e "\n\tDirectory: $(pwd), post-processing files moved to ${SHY_POSTPROC_SPINUP_SIMS_VAR_DIR}.\n"
#  - if something went KO
else
    # Inform the user and exit with an error
    echo -e "\tERROR! Directory: ${SHY_POSTPROC_SPINUP_SIMS_VAR_DIR} unsuccessfully created. EXIT...\n"
    EXIT_STATUS=1; exit $EXIT_STATUS
fi

#  --- END OF MAIN ---

# ************
#  END OF JOB
# ************
