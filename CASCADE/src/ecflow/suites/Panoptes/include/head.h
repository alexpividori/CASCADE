#!/bin/ksh

set -e # stop the shell on first error
set -u # fail when using an undefined variable
#set -x # echo script lines as they are executed
 

# Defines the variables that are needed for any communication with ECF
export ECF_PORT=%ECF_PORT%    # The server port number
export ECF_HOST=%ECF_HOST%    # The name of ecf host that issued this task
export ECF_NAME=%ECF_NAME%    # The name of this current task
export ECF_PASS=%ECF_PASS%    # A unique password
export ECF_TRYNO=%ECF_TRYNO%  # Current try number of the task
export ECF_RID=$$             # record the process id. Also used for zombie detection
 

# Tell ecFlow we have started
ecflow_client --init=$$
 

# Define a error handler
ERROR() {
   set +e                      # Clear -e flag, so we don't fail
   wait                        # wait for background process to stop
   ecflow_client --abort=trap  # Notify ecFlow that something went wrong, using 'trap' as the reason
   trap 0                      # Remove the trap
   exit 0                      # End the script
}
 

# Trap any calls to exit and errors caught by the -e flag
trap ERROR 0
 

# Trap any signal that may cause the script to fail
trap '{ echo "Killed by a signal"; ERROR ; }' 1 2 3 4 5 6 7 8 10 12 13 15

# Get start time in a suitable format to be usefulf for task wall time computation
TASK_START_TIME=$(date -u +%%s)

# Some diagnostict at beginning of the task
echo -e "\n\t-------------------------------------------------------------------------"
echo -e "\t|          Preliminary information about the run of this task           |"
echo -e "\t-------------------------------------------------------------------------"
echo -e "\n\tSUITE NAME: %SUITE%\n\tTASK NAME: %TASK%\n\tTASK FULL NAME: %ECF_NAME%\n\tSTART TIME: $(date -u +%%F' '%%T' UTC')\n"
echo -e "\n\tSUITE DATE: %ECF_DATE%\n\tSUITE TIME: %ECF_TIME%\n\tSUITE CLOCK: %ECF_CLOCK%\n"
echo -e "\n\t-------------------------------------------------------------------------"
echo -e "\t|                  Here below the stdout of this task                   |"
echo -e "\t-------------------------------------------------------------------------"
#
# +---------------------------------------------------+
# |                                                   |
# | HEADER COMPLETED - START THE TASK CORE HERE BELOW |
# |                                                   |
# +---------------------------------------------------+
#

