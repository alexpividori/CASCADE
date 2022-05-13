#!/bin/bash
#
# This is the BASH scipt that checks the ecflow server status
# It works as follow:
# 1) if the server is not running the server is started;
# 2) if the server is running and it is aged, then it is stpped and started again; 
# 3) if the server is running and it is NOT aged, no actions are taken; 
#
# The age of the server is given as a parameter (see ECFLOW_AGE) HH:MM
# The scripts works on ecflow environmental modules, that is it loops
# over the list of modules to check the server status (see ECFLOW_MODS)
#
# This script is meant to be run under cron routinely
#
#
# by Dario B. Giaiotti
#    ARPA FVG -CRMA
#    dario.giaiotti@arpa.fvg.it
#
#    For INTERREG IT-HR projects purposes
#    AdriaClim, CASCADE and FIRESPILL
#    
#    Mar 26, 2021
#
  source $HOME/.bash_profile
  source $HOME/.bashrc
#  
# set -x
  set -e
  set -u
#
# +-------------------------------------------+
# |    CONSTANTS AND PARAMETERS HERE BELOW    |
# +-------------------------------------------+
#
  EXIT_STATUS=0             # Default exit status is everything was done (OK)
  ECFLOW_AGE="720:18"       # The max age of the running server. If ecflow server
                            # is running for more than HH:MM then it is going to 
                            # stopped and restarted
  # Here is the list of modules to be considered to check the ecFlow servers
  ECFLOW_MODS="AdriaClim_ecflow CASCADE_ecflow FIRESPILL_ecflow"

  # This is the directory where to work and leave the logs. Log files are removed 
  # if they are older than LOGS_AGE 
  WORK_DIR="${HOME}/log/ecflow_servers" 

  LOG_FILE="ecflow_server-status.log" # Root name for the log file
  LOGS_AGE="120:00"                   # Max age for the log files (HH:MM)
#
# +-------------------------------------------+
# |    MAIN SCRIPT HERE BELOW                 |
# +-------------------------------------------+
#
  #
  # Check working directory existence otherwise create it
  # Transform ages in seconds since epoch
  #
  if [[ -d $WORK_DIR ]];then 
     echo -e "\n\tWorking directory $WORK_DIR is available. I go there to work."
  else
     echo -en "\n\tWorking directory $WORK_DIR is NOT available. I am going to create it ..."
     DIROK=0
     mkdir -p $WORK_DIR || DIROK=1
     if [[ $DIROK -eq 0 ]]; then 
        echo -en " created.\n"
     else
        echo -en " ERROR!!!\n\tDirectory NOT created. I cannot continue!\n"
        EXIT_STAUS=1; exit $EXIT_STATUS
     fi
  fi
  cd $WORK_DIR
  echo -e "\n\tScript for ecFlow servers status check.\n\n\tCurrently I am in: $(pwd)\n"
  #
  # ECFLOW_AGE in seconds
  echo -en "\n\tServers are going to be restarted if age  > $ECFLOW_AGE ("
  ECFLOW_AGE="$((10#${ECFLOW_AGE//:/*60+10#}))"; ECFLOW_AGE="$((10#${ECFLOW_AGE}*60))"
  echo -en "$ECFLOW_AGE seconds)\n"
  #
  # LOG_FILES AGE in seconds
  echo -en "\tLog files are going to be removed if age > $LOGS_AGE ("
  LOGS_AGE="$((10#${LOGS_AGE//:/*60+10#}))"; LOGS_AGE="$((10#${LOGS_AGE}*60))"
  echo -en "$LOGS_AGE seconds)\n"
  #
  # LOG_FILES NAME               
  LOG_FILE="${LOG_FILE}.$(date -u +%Y%m%d-%H%M%S)"
  echo -e "\n\tProgram $0\n\n\tCheck whether ecFlow servers are running for user:" > $LOG_FILE
  echo -e "\n\t$(id)\n\n\tLog files older than $LOGS_AGE seconds are going to be removed" >> $LOG_FILE
  echo -e "\n\tSTART ecFlow servers check.\n\tServers running for more than $ECFLOW_AGE seconds are restarted\n" >> $LOG_FILE
  #
  # Load environmental module arpa to access the ecflow modules
  #
  MOOK=0; module load arpa || MOOK=1
  if [[ $MOOK -ne 0 ]]; then 
        echo -en " ERROR!!!\n\tImpossible to load arpa module. I cannot continue!\n"
        EXIT_STAUS=2; exit $EXIT_STATUS
  fi
  #
  # Loop over the environmental ecflow modules
  #
  NMO=0
  for MO in $ECFLOW_MODS; do
      NMO=$(($NMO +1))
      echo -e "\n\n\t============== CHECK n.  $NMO ==================="
      echo -e "\tWorking on ecFlow server defined with module: $MO"
      echo -e "\tNow it is: $(date -u ) UTC"
      echo -e "\n\n\t============== CHECK n.  $NMO ==================="  >> $LOG_FILE
      echo -e "\tWorking on ecFlow server define with module: $MO\n\t\tNow it is: $(date -u ) UTC\n" >> $LOG_FILE
      MOOK=0; module load $MO || MOOK=1
      if [[ $MOOK -eq 0 ]]; then 
         #
         # Module is loaded, then check the server status 
         #
         TMP_FILE="$(mktemp -u ./ecflow_status.XXXX)"
         ECFOK=0; ecflow_client --stats > $TMP_FILE || ECFOK=1
         if [[ $ECFOK -eq 0 ]];then 
            #
            # ecFlow server is running then check age
            #
            cat $TMP_FILE >> $LOG_FILE
            SVRSTAT="$(grep "Status " $TMP_FILE)"; SVRSTAT="${SVRSTAT##* }"; SVRSTAT="$(echo ${SVRSTAT})"
            if [[ "${SVRSTAT}" == "RUNNING" ]];then
               echo -e "\tOK it is really RUNNING"
               echo -e "\tOK it is really RUNNING" >> $LOG_FILE
               UPSINCE="$(grep "Up since " $TMP_FILE)"; UPSINCE="${UPSINCE##*Up since}"; UPSINCE="$(echo ${UPSINCE})" 
               echo -en "\tThe server is running since ${UPSINCE}  --> "
               UPSINCE="$(echo ${UPSINCE} | sed -e s/Jan/01/ -e s/Feb/02/ -e s/Mar/03/ -e s/Apr/04/ -e s/May/05/ -e s/Jun/06/)"
               UPSINCE="$(echo ${UPSINCE} | sed -e s/Jul/07/ -e s/Aug/08/ -e s/Sep/09/ -e s/Oct/10/ -e s/Nov/11/ -e s/Dec/12/)"
               CUR_AGE="$(date -u -d "${UPSINCE}" +%s)"; CUR_AGE="$(($(date -u +%s) - ${CUR_AGE}))"
               echo -en "${CUR_AGE}  seconds ago\n"
               echo -e "\tThe server is running since ${UPSINCE}  --> $CUR_AGE seconds ago" >> $LOG_FILE
               #
               # Check whether the server is aged and restart if it is needed
               #
               if [[ ${CUR_AGE} -gt ${ECFLOW_AGE} ]];then 
                  echo -e "\n\tThe ecFlow server is aged I am going to restart it" 
                  echo -e "\n\t+--------------------------------------------------+"  >> $LOG_FILE
                  echo -e "\t|The ecFlow server is aged I am going to restart it|"  >> $LOG_FILE
                  echo -e "\t+--------------------------------------------------+\n"  >> $LOG_FILE
                  RE=0; ecflow-crma_stop.sh   -p $ECF_PORT  >> $LOG_FILE 2>&1 || RE=1
                  if [[ $RE -eq 0 ]];then echo -e "\tServer stopped. Waiting 5 seconds"; sleep 5s; else echo -e "\tServer NOT stopped. Pleae check!";fi
                  RE=0; ecflow-crma_start.sh  -d $ECF_HOME -p $ECF_PORT >> $LOG_FILE 2>&1 || RE=1
                  if [[ $RE -eq 0 ]];then echo -e "\tServer started"; else  echo -e "\tServer NOT started. Pleae check!";fi
               fi
            else
               echo -e "\tWARNING!! The server status is: ${SVRSTAT}\n\tPlease check\n"
            fi
         else
            #
            # ecFlow server is NOT running then restart it
            #
            cat $TMP_FILE >> $LOG_FILE
            echo -e "\n\tWARNING!!! SERVER IS NOT RUNNING I AM GOING TO RESTART IT!" >> $LOG_FILE
            echo -e "\n\tWARNING!!! SERVER IS NOT RUNNING I AM GOING TO RESTART IT!" 
            RE=0; ecflow-crma_start.sh  -d $ECF_HOME -p $ECF_PORT >> $LOG_FILE 2>&1 || RE=1
            if [[ $RE -eq 0 ]];then 
               echo -e "\nServer restarted successfully"
                ecflow_client --stats | sed s/^/\\t/g
            else
               echo -e "\nWARNING impossible to restart the server. Please check!! I continue\n"
            fi
         fi
         if [[ -e $TMP_FILE ]];then rm $TMP_FILE;fi
         MOOK=0; module unload $MO || MOOK=1
      else
         #
         # Module is not loaded, so server status is not available
         #
         echo -en " ERROR!!!\n\tImpossible to load $MO module. I cannot check the server, but I continue!\n"
      fi
  done
  #
  # Remove log files too old
  #
  echo -e "\n\n\tCleaning old log files. (age > $((${LOGS_AGE}/60)) minutes)\n" 
  for F in $(find ./ -name "${LOG_FILE%.*}.*" -amin +$((${LOGS_AGE}/60)));do 
      echo -en "\tRemoving file: $F ..."
      RMOK=0; rm $F || RMOK=1
      if [[ $RMOK -eq 0 ]];then echo -en " removed.\n"; else echo -en " NOT removed. Please check!\n";fi
  done
  #
  # Exit the script
  #
  exit $EXIT_STATUS
#
# +-------------------------------------------+
# |    E N D    O F    T H E    S C R I P T   |
# +-------------------------------------------+
#
#
