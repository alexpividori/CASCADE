#******************************************************************************
#
# DESCRIPTION:      this Python script is aimed at computing and plotting, for
#                   a given range of degrees, the best-fit polynomial function
#                   f (least squares polynomial fit), between two samples x_d
#                   and y_d (time series of daily average river’s discharges,
#                   provided by two different data sources and read from two
#                   different input files), both on a linear and semi-log
#                   scale. In order to help the user in finding the best-
#                   interpolating function, among those considered, a
#                   Kolmogorov-Smirnov statistical test is performed.
#                   Moreover, histograms are built for the investigated
#                   distributions, either before and after the application of
#                   f to the sample x_d.
#                   Finally, assuming that f can be applied also to hourly
#                   distributions, although it is obtained from daily averages,
#                   the hourly time series x_h (read from a third input file)
#                   related to x_d, is corrected through this function (this
#                   script was born to bias-correct Civil Protection of FVG
#                   rivers’ discharges, which are accurate during floods, but
#                   overestimated otherwise).
#
# EXTERNAL CALLS:   none.
#
# EXTERNAL FILES:   - initialisation file: ASCII file containing, arranged
#                     row by row, the full paths of the input files to be
#                     analysed.
#
#                      E.g.
#                      input_file1_1 input_file2_1 input_file3_1
#                      input_file1_2 input_file2_2 input_file3_2
#                      ...
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
#                   - ouput files: same as input files, but bias-corrected through
#                     each best-fit function considered.
#
# DEVELOPER:        Alessandro Minigher (alessandro.minigher@arpa.fvg.it)
#                   ARPA FVG - S.O.C. Stato dell'Ambiente - CRMA
#                   "AdriaClim" Interreg IT-HR project
#
# SOFTWARE VERSION: Python 3.8.1 (python/3.8.1/gcc/8.2.0-mbzms7w).
#
# CREATION DATE:    15/04/2021.
#
# MODIFICATIONS:    19/04/2021 ---> debug ("range" function).
#                   22/04/2021 ---> introduction of a function aimed at
#                                   writing text on histograms.
#
# VERSION:          0.3.
#
#******************************************************************************

# Modules importation

import os
import subprocess
import numpy as np
import sys
import matplotlib.pyplot as plt
from datetime import datetime, timedelta
from scipy import stats


# ***********
#  FUNCTIONS
# ***********

# DATA COLLECTION

def data_coll(input_file_name):

    # Initialisation of a list to be filled

    data_list = []

    # Removal of metadata by the use of Bash-like commands

    cat = subprocess.Popen(['cat', input_file_name], close_fds=True, stdout=subprocess.PIPE)
    grep = subprocess.Popen('grep -v "^#"', shell=True, stdin=cat.stdout, stdout=subprocess.PIPE)

    # For each line in the input file

    for data in grep.stdout:

        # Data decoding and "new line" removal

        data = data.decode("utf-8")
        data = data.rstrip("\n")

        # List filling

        data_list.append(data)

    # Close the input file

    grep.stdout.close()
    return data_list

# BEST-FIT

def interp(x, y, fig_name_prefix):

    # Definition of a global variable

    global deg_range
    deg_range = []

    # Definition of the figure's size

    fig_length = 15   # length
    fig_height = 10   # height

    # Lists conversion to numpy arrays

    x = np.array(x)
    y = np.array(y)

    # Definition of an empty list to be filled

    p_list = []

    # Initialisation of the minimum and maximum degree of the best-fit
    # polynomial, hence the range of degrees to be investigated

    deg_min = 1
    deg_max = 15
    for deg in range(deg_min, deg_max): deg_range.append(deg)

    # For each degree belonging to the range previously created

    for deg in deg_range:

        # Compute the best-fit polynomial

        z = np.polyfit(x, y, deg)   # coefficients
        p = np.poly1d(z)            # function

        # List filling

        p_list.append(p)

        # PLOTTING

        # Draw a figure

        fig, ax = plt.subplots(figsize = (fig_length, fig_height))

        # Draw title and subtitle

        title = "Daily Average Discharge: " + fig_name_prefix.split("_")[2].capitalize() + " River"
        mid = (fig.subplotpars.right + fig.subplotpars.left) / 2.0
        title_size = 25
        subtitle = "Best-fit Polynomial Function: deg. = " + str(deg)
        subtitle_size = 19
        plt.suptitle(title, x = mid, fontsize = title_size)
        plt.title(subtitle, fontsize = subtitle_size)

        # Draw axes' labels

        axes_labels_fontsize = 17
        ax.set_xlabel(r"Discharge - Civil Protection of FVG [m$^{3}$ s$^{-1}$]", fontsize = axes_labels_fontsize)
        ax.set_ylabel(r"Discharge - CNR-ISMAR [m$^{3}$ s$^{-1}$]", fontsize = axes_labels_fontsize)

        # Draw the scatter plot of data

        plt.scatter(x, y, marker = ".", color = "red")

        # Draw the best-fit polynomial function

        x_new = np.linspace(min(x), max(x), 4000)
        y_new = p(x_new)
        plt.plot(x_new, y_new, "-", color = "blue")

        # Draw the grid

        ax.grid()

        # Save figure, building its name properly, and close it

        if ( deg < 10 ): fig_name = fig_name_prefix + "-scatter_plot-deg0" + str(deg) + ".png"
        else: fig_name = fig_name_prefix + "-scatter_plot-deg" + str(deg) + ".png"
        plt.savefig(fig_name)
        plt.close(fig)

    return p_list

# KOLMOGOROV-SMIRNOV STATISTICAL TEST

def ks_test(x, y, p_list, lin_semilog):

    # Initialisation of an index

    i = 0

    # Print the metadata related to the Kolmogorov-Smirnov statistical test

    print("\n\tRESULTS OF KOLMOGOROV-SMIRNOV STATISTICAL TEST: " + lin_semilog + "\n")
    print("\tColumns description:")
    print("\t1) Degree of best-fit polynomial function")
    print("\t2) D statistic")
    print("\t3) P-value")

    # For each best-fit polynomial to be considered

    for p in p_list:

        # Perform the Kolmogorov-Smirnov statistical test

        ks = stats.kstest(p(x), y)

        # Print the results of the Kolmogorov-Smirnov statistical test

        print("\t%s\t%s\t%s" % (deg_range[i], ks[0], ks[1]))

        # Index increasement

        i = i + 1

    return

# WRITE TEXT ON HISTOGRAMS

def histograms_text(ax, stats):

    text_size = 12   # fontsize
    x_pos = 0.65     # x-position

    # Write text on histograms

    ax.text(x_pos, 0.95, "Ave: " + str(round(stats[0], 2)), verticalalignment = "bottom", horizontalalignment = "left", transform = ax.transAxes, fontsize = text_size)
    ax.text(x_pos, 0.92, "Std: " + str(round(stats[1], 2)), verticalalignment = "bottom", horizontalalignment = "left", transform = ax.transAxes, fontsize = text_size)
    ax.text(x_pos, 0.89, "Min: " + str(round(stats[2], 2)), verticalalignment = "bottom", horizontalalignment = "left", transform = ax.transAxes, fontsize = text_size)
    ax.text(x_pos, 0.86, "Max: " + str(round(stats[3], 2)), verticalalignment = "bottom", horizontalalignment = "left", transform = ax.transAxes, fontsize = text_size)
    ax.text(x_pos, 0.83, "Med: " + str(round(stats[4], 2)), verticalalignment = "bottom", horizontalalignment = "left", transform = ax.transAxes, fontsize = text_size)
    ax.text(x_pos, 0.80, "25p: " + str(round(stats[5], 2)), verticalalignment = "bottom", horizontalalignment = "left", transform = ax.transAxes, fontsize = text_size)
    ax.text(x_pos, 0.77, "75p: " + str(round(stats[6], 2)), verticalalignment = "bottom", horizontalalignment = "left", transform = ax.transAxes, fontsize = text_size)

    return

# DRAW HISTOGRAMS

def histograms(x, x_log, y, p_list, fig_name_prefix):

    # Initialisation of an index

    i = 0

    # Definition of the size of the figure

    fig_length = 15   # length
    fig_height = 11   # height

    # Compute some of the main statistical parameters

    x_ave = np.nanmean(x)             # average
    x_std = np.nanstd(x)              # standard deviation
    x_min = np.nanmin(x)              # minimum
    x_max = np.nanmax(x)              # maximum
    x_med = np.nanmedian(x)           # median
    x_25p = np.nanpercentile(x, 25)   # 25th percentile
    x_75p = np.nanpercentile(x, 75)   # 75the percentile
    y_ave = np.nanmean(y)             # average
    y_std = np.nanstd(y)              # standard deviation
    y_min = np.nanmin(y)              # minimum
    y_max = np.nanmax(y)              # maximum
    y_med = np.nanmedian(y)           # median
    y_25p = np.nanpercentile(y, 25)   # 25th percentile
    y_75p = np.nanpercentile(y, 75)   # 75th percentiile

    # For each best-fit polynomial function

    for p in p_list:

        # Compute some of the main statistical parameters

        x_log_ave = np.nanmean(p(x_log))             # average
        x_log_std = np.nanstd(p(x_log))              # standard deviation
        x_log_min = np.nanmin(p(x_log))              # minimum
        x_log_max = np.nanmax(p(x_log))              # maximum
        x_log_med = np.nanmedian(p(x_log))           # median
        x_log_25p = np.nanpercentile(p(x_log), 25)   # 25th ppercentile
        x_log_75p = np.nanpercentile(p(x_log), 75)   # 75th percentile

        # Draw a figure, characterized by multiple subplots

        fig, (ax1, ax2, ax3) = plt.subplots(1, 3, figsize = (fig_length, fig_height))

        # Draw the title of figure and subplots 

        title = "Daily Average Discharge: " + fig_name_prefix.split("_")[2].capitalize() + " River"
        mid = (fig.subplotpars.right + fig.subplotpars.left) / 2.0
        plt.suptitle(title, x = mid, fontsize = 20)
        ax1.set_title("CNR-ISMAR")
        ax2.set_title("Civil Protection of FVG (before bias-correction)")
        ax3.set_title("Civil Protection of FVG (after bias-correction)")

        # Draw the axes' labels

        axes_labels_size = 15
        ax2.set_xlabel(r"Discharge [m$^{3}$ s$^{-1}$]", fontsize = axes_labels_size)
        ax1.set_ylabel("Counts", fontsize = axes_labels_size)

        # Draw histograms

        nbins = 50
        ax1.hist(y, bins = nbins)
        ax2.hist(x, bins = nbins)
        ax3.hist(p(x_log), bins = nbins)

        # Draw the grid

        ax1.grid()
        ax2.grid()
        ax3.grid()

        # Write text on histograms: external function calling

        histograms_text(ax1, [y_ave, y_std, y_min, y_max, y_med, y_25p, y_75p])
        histograms_text(ax2, [x_ave, x_std, x_min, x_max, x_med, x_25p, x_75p])
        histograms_text(ax3, [x_log_ave, x_log_std, x_log_min, x_log_max, x_log_med, x_log_25p, x_log_75p])

        # Save figure, building a proper name, and close it

        if ( deg_range[i] < 10 ): fig_name = fig_name_prefix + "-histograms-deg0" + str(deg_range[i]) + ".png"
        else: fig_name = fig_name_prefix + "-histograms-deg" + str(deg_range[i]) + ".png"
        plt.savefig(fig_name)
        plt.close(fig)

        # Index increasement

        i = i + 1

    return

# BIAS-CORRECTION

def bias_correction(file_2_correct_name, p_list, lin_semilog):

    # Initialisation of an index

    i = 0

    # For each best-fit polynomial function

    for p in p_list:

        # Definition of the basename of the output file

        if ( deg_range[i] < 10 and lin_semilog == 0 ): output_file_name = os.path.basename(file_2_correct_name).split(".")[0] + "_lin_corrected-deg0" + str(deg_range[i]) + ".dat"
        elif ( deg_range[i] >= 10 and lin_semilog == 0 ): output_file_name = os.path.basename(file_2_correct_name).split(".")[0] + "_lin_corrected-deg" + str(deg_range[i]) + ".dat"
        elif ( deg_range[i] < 10 and lin_semilog == 1 ): output_file_name = os.path.basename(file_2_correct_name).split(".")[0] + "_semilog_corrected-deg0" + str(deg_range[i]) + ".dat"
        else: output_file_name = os.path.basename(file_2_correct_name).split(".")[0] + "_semilog_corrected-deg" + str(deg_range[i]) + ".dat"

        # If the output file already exists

        if ( os.path.isfile(output_file_name) == True ):

            # Delete the output file

            os.remove(output_file_name)

        # Open the output file in appending mode

        output_file = open(output_file_name, "a")

        # Open the file to correct in reading mode

        file_2_correct = open(file_2_correct_name, "r")

        # For each line in the file to be corrected

        for data in file_2_correct:

            # "New line" removal

            data = data.rstrip("\n")

            # Data extraction

            dt = data.split()[0]         # date and time
            Q = float(data.split()[1])   # river's discharge

            # Correct the river's discharge read properly

            if ( lin_semilog == 0 ): Q_corr = p(Q)           # semi-log scale
            if ( lin_semilog == 1 ): Q_corr = p(np.log(Q))   # linear scale

            # Format the output to be printed to stdout

            output = dt + "\t" + str(round(Q_corr, 2))

            # Print to output file

            print(output, file = output_file)

        # Close the input and output files

        file_2_correct.close()
        output_file.close()

        # Index increasement

        i = i + 1

    return


# ******
#  MAIN
# ******

# Definition of the full path of the initialisation file

init_file_name = "/u/arpa/minighera/AdriaClim/src/initialisation_files/init_file_pciv_bias_correction-rivers.txt"

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
    file_2_correct_name = input_files_name.split()[2]

    # If all the input files exist

    if ( os.path.isfile(input_file1_name) == True and os.path.isfile(input_file2_name) == True and os.path.isfile(file_2_correct_name) == True ):

        # Print message to inform the user

        print("\n\t Input files: %s, %s and %s found. Bias correction starts..." % (input_file1_name, input_file2_name, file_2_correct_name))

    # If at least one of the input files does not exist

    else:

        # Print message to inform the user and skip to the next couple of files

        print("\n\t Warning! Input files: %s, %s and %s, at least one not found. Please check.\n" % (input_file1_name, input_file2_name, file_2_correct_name))
        continue

    # Function calling to extract the data from both the input files

    data1 = data_coll(input_file1_name)
    data2 = data_coll(input_file2_name)

    # Initialisation of lists to be filled

    Q1_ave_list = []
    Q2_ave_list = []

    # Initialisation of an index

    j_rst = 0

    # For each data line in the first input file

    for i in range(0, len(data1)):

        # Data extraction

        date1 = data1[i].split()[0]           # date and time
        Q1_ave = float(data1[i].split()[1])   # daily average discharge

        # For each data line in the second input file

        for j in range(j_rst, len(data2)):

            # Data extraction

            date2 = data2[j].split()[0]           # date and time
            Q2_ave = float(data2[j].split()[1])   # daily average discharge

            # If the dates read from the input files are the same

            if ( date2 == date1 ):

                # Lists filling

                Q1_ave_list.append(Q1_ave)
                Q2_ave_list.append(Q2_ave)

                # Set the starting index to the current index and break the
                # internal "for" cycle

                j_rst = j
                break

    # Compute the best-fit polynomial: function calling

    func_lin = interp(Q1_ave_list, Q2_ave_list, os.path.basename(file_2_correct_name).split(".")[0] + "_lin")                   # linear scale
    func_semilog = interp(np.log(Q1_ave_list), Q2_ave_list, os.path.basename(file_2_correct_name).split(".")[0] + "_semilog")   # semi-log scale

    # Compute the Kolmogorov-Smirnov statistical test: function calling

    kstest_lin = ks_test(Q1_ave_list, Q2_ave_list, func_lin, "LINEAR SCALE")                     # linear scale
    kstest_semilog = ks_test(np.log(Q1_ave_list), Q2_ave_list, func_semilog, "SEMI-LOG SCALE")   # semi-log scale

    # Draw histograms: function calling

    histograms_lin = histograms(Q1_ave_list, Q1_ave_list, Q2_ave_list, func_lin, os.path.basename(file_2_correct_name).split(".")[0] + "_lin")                       # linear scale
    histograms_semilog = histograms(Q1_ave_list, np.log(Q1_ave_list), Q2_ave_list, func_semilog, os.path.basename(file_2_correct_name).split(".")[0] + "_semilog")   # semi-log scale

    # Bias correction: function calling

    bias_correction_lin = bias_correction(file_2_correct_name, func_lin, 0)           # linear scale
    bias_correction_semilog = bias_correction(file_2_correct_name, func_semilog, 1)   # semi-log scale

# Close the initialisation file

init_file.close()
print()
