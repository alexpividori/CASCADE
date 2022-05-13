#-----------------------------------------------------------------------------
#       THIS IS THE FUNCTION MANAGING THE PBS QUEUE JOB SUBMISSION
#
#        It works for both BASH and KSH
#
#        Version managing both sible job and array jobs
#
#        By Dario B. Giaiotti 
#
#        ARPA FVG - CRMA
#        Centro Regionale di Modellistica Ambientale 
#        Via Cairoli, 14 
#        I-33057 Palmanova (UD)
#        ITALY
#        Room I/20/U
#        Tel +39 0432 191 8048
#        Fax:+39 0432 191 8120
#        Certified e-mail - PEC arpa@certregione.fvg.it
#        e-mail dario.giaiotti@arpa.fvg.it
#        
#        Feb 03, 2016
#-----------------------------------------------------------------------------

function ecflow_qsub()
{
#
# Submit the job to the queue and monitor it until it exits
# then reprt a summary of the job features than can be used 
# for further statistics
#
# Trap any signal that may cause the script to fail
  set -e
  set -u
  trap '{ return 1 ; }' 1 2 3 4 5 6 7 8 10 12 13 15

  local JOB_FEATURES_LIST="Job_Name Job_Owner submit_args submit_host server queue "
  JOB_FEATURES_LIST="${JOB_FEATURES_LIST} resources_used.cput resources_used.walltime Resource_List.walltime resources_used.mem resources_used.vmem "
  JOB_FEATURES_LIST="${JOB_FEATURES_LIST} Resource_List.nodect Resource_List.nodes etime start_time comp_time total_runtime job_state  exit_status"
  
  local JOB_TO_SUBMIT=$1                  # Load the job to be submitted
  local RETURN_STATUS=0                   # Set default return status
  #
  # Submit job to the queue and get the ID job number for further monitoring
  #
  echo -e "\n\tSubmission of job: $JOB_TO_SUBMIT\n"
  JOBNUMBER=$(qsub  $JOB_TO_SUBMIT)       

  
  #
  # Check when jobs end and report status
  #
    local N_CHECKS=0
    echo -e "\n\tSubmitted the job: $JOBNUMBER on: $(date -u) UTC\n\tCheck status every $PBS_JOB_CHECK_TIME seconds"
  #
  # Check whether the job is an array job or a single one 
  #
    sleep 5 # Sleep five seconds to allow the queue to submit all the elements of the array
    ARRAY_LIST=$(qstat -tf $JOBNUMBER  | grep "job_array_id") ||  ARRAY_LIST=""
    if [[ -z $ARRAY_LIST ]];then 
       #
       #                 Single Job 
       #
       echo -e "\n\tThis is a single job: $ARRAY_LIST\n"
       while ! qstat -f $JOBNUMBER | grep "exit_status" ; do
             local  JOB_STATE=$(qstat -f $JOBNUMBER |  grep "job_state =")
             if [[ $(($N_CHECKS%%40)) -ne 0 ]];then PRE=''; else PRE="\n\t$(date -u +%%F' '%%T' UTC:')";fi 
             JOB_STATE=${JOB_STATE##*=};  JOB_STATE=${JOB_STATE// /}
             echo -en "${PRE} ${JOB_STATE}"
             sleep $PBS_JOB_CHECK_TIME 
             N_CHECKS=$(($N_CHECKS +1)) 
       done
       echo -e "\n\tCompleted check on submitted job at: $(date -u) UTC"
   
       JOB_STATE=$(qstat -f $JOBNUMBER | grep "exit_status =" | cut -d "=" -f 2)
       RETURN_STATUS=${JOB_STATE}
       echo -e "\n\tJob terminate with RETURN_STATUS=$RETURN_STATUS  Summary of job features is:\n"
       local JOB_FEATURES_FILE="$(mktemp job-features.XXXXX)"
       qstat -f $JOBNUMBER > $JOB_FEATURES_FILE 
       for FEAT in $JOB_FEATURES_LIST; do echo -e "\tTASK JOB_FEATURE_ECF_OUT: $(grep "$FEAT =" $JOB_FEATURES_FILE)"; done
       if [[ -e $JOB_FEATURES_FILE ]]; then rm $JOB_FEATURES_FILE ; fi
    else
       #
       #                 Array  Job 
       #
       # Get information on the array elements
       #
       START_ARRAY_CHECK=$(date -u +%%s)
       ARRAY_LIST=${ARRAY_LIST//job_array_id =/}; declare -a ARRAY_N=(${ARRAY_LIST})
       declare -a  ARRAY_STATUS; declare -a  ARRAY_EXIT
       echo -e "\n\tThis is an array job: $JOBNUMBER"
       echo -en "\n\tNumber of array elements is: ${#ARRAY_N[@]}\n\tThey are:" 
       IN=0; while [[ $IN -lt ${#ARRAY_N[@]} ]]; do  
             if [[ $(($IN%%15)) -eq 0 ]]; then FMTST="\n\t%%6d"; else  FMTST="%%6d"; fi 
             printf "$FMTST" ${ARRAY_N[$IN]}
             IN=$(($IN+1))
       done
       #
       # Loop to check the exit status of the array alements as far as at least one has not exit
       #
       NLOOPS=${#ARRAY_N[@]}
       while [[ $NLOOPS -gt 0 ]];do 
             NA=0
             while [[ $NA -lt ${#ARRAY_N[@]} ]];do
                 if [[ -z ${ARRAY_EXIT[$NA]:-""} ]];then 
                    NJOB=${ARRAY_N[$NA]}
                    NJ=${JOBNUMBER/[]/[${NJOB}]}
                    #
                    # Get status of the array element
                    #
                    JOB_STATE=$(qstat -f $NJ | grep "job_state =") || JOB_STATE="NA" 
                    JOB_STATE=${JOB_STATE##*=};  JOB_STATE=${JOB_STATE// /}
                    ARRAY_STATUS[$NA]=$JOB_STATE 
                    #
                    # Get exit of the array element
                    #
                    JOB_EXIT=$(qstat -f $NJ | grep "exit_status") || JOB_EXIT="" 
                    JOB_EXIT=${JOB_EXIT##*=};  JOB_EXIT=${JOB_EXIT// /}
                    ARRAY_EXIT[$NA]=$JOB_EXIT 
                    #
                    # Decrease the flag variable if the array element has exit status
                    #
                    if [[ ! -z ${ARRAY_EXIT[$NA]} ]];then  NLOOPS=$(($NLOOPS-1)); fi
                 fi
                 #
                 # Print on stdout the result of whole array check
                 #
                 if [[ $NA -eq 0 ]]; then 
                    echo -e "\n\n\tChecking array at:$(date -u +%%F' '%%T' UTC:')"
                    echo -en "\tHere below JOB_ARRAY_ID: JOB_STATUS: JOB_EXIT_STATUS;"
                 fi
                 PRSTR="%%6d:%%3s:%%3s;"
                 if [[ $(($NA%%5)) -eq 0 ]]; then PRSTR="\n\tJOB_ARRAY_CHECK=%%6d:%%3s:%%3s; ";fi
                 printf "${PRSTR}" ${ARRAY_N[$NA]} ${ARRAY_STATUS[$NA]:-NA} ${ARRAY_EXIT[$NA]:-NA} 
                 NA=$(($NA+1))
             done
             sleep $PBS_JOB_CHECK_TIME 
       done
       STOP_ARRAY_CHECK=$(date -u +%%s)
       TOTS_ARRAY_CHECK=$(($STOP_ARRAY_CHECK -$START_ARRAY_CHECK))
       TOTT_ARRAY_CHECK="$(($TOTS_ARRAY_CHECK/60)) min  $(($TOTS_ARRAY_CHECK%%60)) s"  
       echo -e "\n\n\tCompleted check on submitted job at: $(date -u) UTC [$TOTT_ARRAY_CHECK]"
       #
       # Verify ho many array element have failed 
       #
       NA=0; NEXITS_OK=0; NEXITS_KO=0; NEXITS_UNKNOWN=0; FAILURE_LIST="";  UNKNOWN_LIST=""
       while [[ $NA -lt ${#ARRAY_N[@]} ]];do
             if [[ ${ARRAY_EXIT[$NA]} -eq 0 ]]; then 
                NEXITS_OK=$(($NEXITS_OK+1))
             elif [[ ${ARRAY_EXIT[$NA]} -eq 1 ]]; then 
                NEXITS_KO=$(($NEXITS_KO+1))
                FAILURE_LIST="$FAILURE_LIST ${ARRAY_N[$NA]}"
             else
                NEXITS_UNKNOWN=$(($NEXITS_UNKNOWN+1))
                UNKNOWN_LIST="$UNKNOWN_LIST ${ARRAY_N[$NA]}"
             fi
             NA=$(($NA+1))
       done
       echo -e "\n\tSummary of execution for array job $JOBNUMBER"
       echo -e "\t\tNumber of successful exits (exit_status=0): $NEXITS_OK"
       echo -e "\t\tNumber of failed     exits (exit_status=1): $NEXITS_KO"
       echo -e "\t\tNumber of unknown    exits (exit_status !=0 or !=1): $NEXITS_UNKNOWN"
       if [[ $NEXITS_KO -gt 0 ]];then 
          echo -en "\n\tThe list of failed  exits elements is:"
          NFJ=0 
          for FJ in $FAILURE_LIST; do 
              PRSTR="%%6d";if [[ $(($NFJ%%10)) -eq 0 ]]; then PRSTR="\n\t\t%%6d";fi; printf "$PRSTR" $FJ 
              NFJ=$(($NFJ+1))
          done
          RETURN_STATUS=1
       fi
       if [[ $NEXITS_UNKNOWN -gt 0 ]];then 
          echo -en "\n\tThe list of unknown exits elements is: "
          NFJ=0 
          for FJ in $UNKNOWN_LIST; do 
              PRSTR="%%6d";if [[ $(($NFJ%%10)) -eq 0 ]]; then PRSTR="\n\t\t%%6d";fi; printf "$PRSTR" $FJ 
              NFJ=$(($NFJ+1))
          done
          if [[ $RETURN_STATUS -ne 1 ]]; then RETURN_STATUS=2; fi
       fi
       echo -e "\n\n\t-----------   RETURN_STATUS=$RETURN_STATUS   ---------\n\n" 
    fi 
return $RETURN_STATUS
}

#-----------------------------------------------------------------------------
#       END OF THE FUNCTION MANAGING THE PBS QUEUE JOB SUBMISSION
#-----------------------------------------------------------------------------
