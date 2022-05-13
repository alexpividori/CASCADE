#******************************************************************************
#
# DESCRIPTION:      this Python script is aimed at drawing box and whiskers
#                   plots (henceforth boxplots) and averages from pre-
#                   calculated daily statistics of distributions of river’s
#                   discharges: a figure is produced for each month to be
#                   considered, and a boxplot is drawn for each day belonging
#                   to this month, together with the related daily average
#                   value. Moreover, also the corresponding average values,
#                   belonging to a different, comparison distribution, are
#                   plotted on the same figure.
#
# EXTERNAL CALLS:   none.
#
# EXTERNAL FILES:   - initialisation file:
#
#                   - input files:
#
# DEVELOPER:        Alessandro Minigher (alessandro.minigher@arpa.fvg.it)
#                   ARPA FVG - S.O.C. Stato dell'Ambiente - CRMA
#                   "AdriaClim" Interreg IT-HR project
#
# SOFTWARE VERSION: Python 3.8.1 (python/3.8.1/gcc/8.2.0-mbzms7w).
#
# CREATION DATE:    20/04/2021.
#
# MODIFICATIONS:    none.
#
# VERSION:          0.1.
#
#******************************************************************************

# Modules importation

import os
import sys
import subprocess
import matplotlib.pyplot as plt


# ***********
#  FUNCTIONS
# ***********

# DATA COLLECTION

def data_coll(input_file_name):

    # Initialisation of an empty list to be filled

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

# DRAW BOXPLOTS

def boxplots(data1, data2, fig_name_prefix):

    # Initialisation of an index

    m_rst = 0

    # Definition of the size of the figure

    fig_length = 20   # length
    fig_height = 10   # height

    # Definition of some fontsizes

    title_fontsize = 25       # title
    subtitle_fontsize = 17    # subtitle
    axes_fontsize = 15        # axes' labels

    # For each data in the first input file

    for k in range(0, len(data1)):

        # Data extraction

        date1 = data1[k].split()[0]           # date
        year1 = date1.split("-")[0]           # year
        month1 = date1.split("-")[1]          # month
        day1 = date1.split("-")[2]            # day
        Q1_ave = float(data1[k].split()[1])   # average discharge
        Q1_min = float(data1[k].split()[2])   # minimum discharge
        Q1_max = float(data1[k].split()[3])   # maximum discharge
        Q1_med = float(data1[k].split()[4])   # median discharge
        Q1_25p = float(data1[k].split()[5])   # 25th percentile
        Q1_75p = float(data1[k].split()[6])   # 75th percentile

        # Collect statistics to be used to draw the related boxplot

        statistics1 = [{"mean":  Q1_ave, "med": Q1_med, "q1": Q1_25p, "q3": Q1_75p, "whislo": Q1_min, "whishi": Q1_max}]

        # If the data read is the first

        if ( k == 0 ):

            # Draw a figure

            fig, ax = plt.subplots(figsize = (fig_length, fig_height))

            # Draw title and subtitle

            mid = (fig.subplotpars.right + fig.subplotpars.left) / 2.0
            title = title = "Daily Discharge: " + fig_name_prefix.split("_")[2].capitalize() + " River (" + year1 + "/" + month1 + ")"
            subtitle = "Civil Protection of FVG (boxplot; average, red dots) - CNR-ISMAR (average, blue dots)"
            plt.suptitle(title, x = mid, fontsize = title_fontsize)
            plt.title(subtitle, fontsize = subtitle_fontsize)

            # Draw the daily boxplot and daily average discharge

            ax.bxp(statistics1, showfliers = False, positions = [int(day1)])
            plt.plot(int(day1), Q1_ave, ".", color = "red")

            # Draw the related daily average discharge of the second input
            # file, properly looking for it

            for m in range(m_rst, len(data2)):
                date2 = data2[m].split()[0]
                Q2_ave = float(data2[m].split()[1])
                if ( date2 == date1 ):
                    plt.plot(int(day1), Q2_ave, ".", color = "blue")
                    m_rst = m
                    break

        # If the data read is not the first

        else:

            # If the current month is the same as the previous one, and not
            # the last to be considered

            if ( month1 == month_prev and k != len(data1) - 1):

                # Draw the daily boxplot and daily average discharge

                ax.bxp(statistics1, showfliers = False, positions = [int(day1)])
                plt.plot(int(day1), Q1_ave, ".", color = "red")

                # Draw the related daily average discharge of the second input
                # file, properly looking for it

                for m in range(m_rst, len(data2)):
                    date2 = data2[m].split()[0]
                    Q2_ave = float(data2[m].split()[1])
                    if ( date2 == date1 ):
                        plt.plot(int(day1), Q2_ave, ".", color = "blue")
                        m_rst = m
                        break

            # If the current month is the same as the previosu one, and the
            # last to be considered

            elif( month1 == month_prev and k == len(data1) - 1):

                # Draw the daily boxplot and daily average discharge

                ax.bxp(statistics1, showfliers = False, positions = [int(day1)])
                plt.plot(int(day1), Q1_ave, ".", color = "red")

                # Draw the related daily average discharge of the second input
                # file, properly looking for it

                for m in range(m_rst, len(data2)):
                    date2 = data2[m].split()[0]
                    Q2_ave = float(data2[m].split()[1])
                    if ( date2 == date1 ):
                        plt.plot(int(day1), Q2_ave, ".", color = "blue")
                        m_rst = m
                        break

                # Set axes' labels and draw the grid

                ax.set_xlabel("Day", fontsize = axes_fontsize)
                ax.set_ylabel(r"Discharge [m$^{3}$ s$^{-1}$]", fontsize = axes_fontsize)
                ax.grid()

                # Save and close the figure

                fig_name = fig_name_prefix + "_boxplots_" + year1 + "-" + month1 + ".png"
                plt.savefig(fig_name)
                plt.close(fig)

            # If the current month is different from the previous one, and not
            # the last to be considered

            elif ( month1 != month_prev and k != len(data1) - 1 ):

                # Set axes' labels and draw the grid

                ax.set_xlabel("Day", fontsize = axes_fontsize)
                ax.set_ylabel(r"Discharge [m$^{3}$ s$^{-1}$]", fontsize = axes_fontsize)
                ax.grid()

                # Save and close the figure

                fig_name = fig_name_prefix + "_boxplots_" + year_prev + "-" + month_prev + ".png"
                plt.savefig(fig_name)
                plt.close(fig)

                # Draw a new figure

                fig, ax = plt.subplots(figsize = (fig_length, fig_height))

                # Draw title and subtitle

                mid = (fig.subplotpars.right + fig.subplotpars.left) / 2.0
                title = title = "Daily Discharge: " + fig_name_prefix.split("_")[2].capitalize() + " River (" + year1 + "/" + month1 + ")"
                subtitle = "Civil Protection of FVG (boxplot; average, red dots) - CNR-ISMAR (average, blue dots)"
                plt.suptitle(title, x = mid, fontsize = title_fontsize)
                plt.title(subtitle, fontsize = subtitle_fontsize)

                # Draw the daily boxplot and daily average discharge

                ax.bxp(statistics1, showfliers = False, positions = [int(day1)])
                plt.plot(int(day1), Q1_ave, ".", color = "red")

                # Draw the related daily average discharge of the second input
                # file, properly looking for it

                for m in range(m_rst, len(data2)):
                    date2 = data2[m].split()[0]
                    Q2_ave = float(data2[m].split()[1])
                    if ( date2 == date1 ):
                        plt.plot(int(day1), Q2_ave, ".", color = "blue")
                        m_rst = m
                        break

            # If the current month is different from the previous one, and the
            # last to be considered

            elif ( month1 != month_prev and k == len(data1) - 1 ):

                # Set axes' labels and draw the grid

                ax.set_xlabel("Day", fontsize = axes_fontsize)
                ax.set_ylabel(r"Discharge [m$^{3}$ s$^{-1}$]", fontsize = axes_fontsize)
                ax.grid()

                # Save and close the figure

                fig_name = fig_name_prefix + "_boxplots_" + year_prev + "-" + month_prev + ".png"
                plt.savefig(fig_name)
                plt.close(fig)

                # Draw a new figure

                fig, ax = plt.subplots(figsize = (fig_length, fig_height))

                # Draw title and subtitle

                mid = (fig.subplotpars.right + fig.subplotpars.left) / 2.0
                title = title = "Daily Discharge: " + fig_name_prefix.split("_")[2].capitalize() + " River (" + year1 + "/" + month1 + ")"
                subtitle = "Civil Protection of FVG (boxplot; average, red dots) - CNR-ISMAR (average, blue dots)"
                plt.suptitle(title, x = mid, fontsize = title_fontsize)
                plt.title(subtitle, fontsize = subtitle_fontsize)

                # Draw the daily boxplot and daily average discharge

                ax.bxp(statistics1, showfliers = False, positions = [int(day1)])
                plt.plot(int(day1), Q1_ave, ".", color = "red")

                # Draw the related daily average discharge of the second input
                # file, properly looking for it

                for m in range(m_rst, len(data2) - 1):
                    date2 = data2[m].split()[0]
                    Q2_ave = float(data2[m].split()[1])
                    if ( date2 == date1 ):
                        plt.plot(int(day1), Q2_ave, ".", color = "blue")
                        m_rst = m
                        break

                # Set axes' labels and draw the grid

                ax.set_xlabel("Day", fontsize = axes_fontsize)
                ax.set_ylabel(r"Discharge [m$^{3}$ s$^{-1}$]", fontsize = axes_fontsize)
                ax.grid()

                # Save and close the figure

                fig_name = fig_name_prefix + "_boxplots_" + year1 + "-" + month1 + ".png"
                plt.savefig(fig_name)
                plt.close(fig)

        # Set the "previous" date as the "current" one

        year_prev = year1
        month_prev = month1
        day_prev = day1

    return


# ******
#  MAIN
# ******

# Definition of the full path of the initialisation file

init_file_name = "/u/arpa/minighera/AdriaClim/src/initialisation_files/init_file_ismarcnr-pciv_boxplots-rivers.txt"

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

    # If both the input files exist

    if ( os.path.isfile(input_file1_name) == True and os.path.isfile(input_file2_name) == True ):

        # Print message to inform the user

        print("\n\t Input files: %s and %s found. Plotting...\n" % (input_file1_name, input_file2_name))

    # If at least one of the input files does not exist

    else:

        # Print message to inform the user and skip to the next couple of files

        print("\n\t Warning! Input files: %s and %s, at least one not found. Please check.\n" % (input_file1_name, input_file2_name))
        continue

    # Function calling to extract the data from both the input files

    data1 = data_coll(input_file1_name)
    data2 = data_coll(input_file2_name)

    # Draw boxplots: function calling

    boxplots(data1, data2, os.path.basename(input_file1_name).split(".")[0])
