
#
# +---------------------------------------------------+
# |                                                   |
# | START TAIL HERE BELOW  - THE TASK CORE HERE ABOVE |
# |                                                   |
# +---------------------------------------------------+

sleep %SLEEP%             # Wait SLEEP number of seconds before to 
                          # consider the task completed

# Get end  time in a suitable format to be usefulf for task wall time computation
TASK_END_TIME=$(date -u +%%s)

# Some diagnostict at end of the task
echo -e "\n\t-------------------------------------------------------------------------"
echo -e "\t|           Summary of information about the run of this task           |"
echo -e "\t-------------------------------------------------------------------------"
echo -e "\n\\tSTOP TIME: $(date -u +%%F' '%%T' UTC')"
echo -e "\tTASK WALL TIME: $((${TASK_END_TIME}-${TASK_START_TIME})) s\n"

wait                      # wait for background process to stop
ecflow_client --complete  # Notify ecFlow of a normal end
trap 0                    # Remove all traps
exit 0                    # End the shell
