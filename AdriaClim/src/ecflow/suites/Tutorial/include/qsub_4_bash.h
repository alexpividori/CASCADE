#-----------------------------------------------------------------------------
#       THIS IS THE FUNCTION MANAGING THE PBS QUEUE JOB SUBMISSION
#       ==> VERSION FOR PBSPro REPLACING THE PREVIUOUS FOR PBSTorque
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
#        Mar 08, 2018
#-----------------------------------------------------------------------------

function ecflow_qsub()
{
#
# Submit the job to the queue.  
# Finaly generates a  summary of the job features than can be used 
# for further statistics
#
# Trap any signal that may cause the script to fail
  set -e
  set -u
  trap '{ return 1 ; }' 1 2 3 4 5 6 7 8 10 12 13 15

  local JOB_FEATURES_LIST="Job_Name Job_Owner server queue project block exec_host "
        JOB_FEATURES_LIST="${JOB_FEATURES_LIST} exec_vnode resources_used.cpupercent resources_used.cput"
        JOB_FEATURES_LIST="${JOB_FEATURES_LIST} resources_used.ncpus resources_used.mem resources_used.vmem "
        JOB_FEATURES_LIST="${JOB_FEATURES_LIST} resources_used.walltime Resource_List.walltime"
        JOB_FEATURES_LIST="${JOB_FEATURES_LIST} Resource_List.nodect Resource_List.nodes Resource_List.select "
        JOB_FEATURES_LIST="${JOB_FEATURES_LIST} ctime mtime qtime stime etime job_state  Exit_status"
  
  local JOB_TO_SUBMIT=$1                  # Load the job to be submitted
  local RETURN_STATUS=0                   # Set default return status

  #
  # Header message to show that this is the stdout of qsub function
  #
  echo -e "\n\t+-------- This is the qsub ecFlow function ---------+"
  #
  # In case of verbose activation a detailed list of resources for all array elements 
  # will be reported ARRAY_VERBOSE should be defined in the suite definition file
  #
  local ARRAY_VERBOSE="%ARRAY_VERBOSE:NULL%" 
  #
  # Check whether any module required for queue submission is required
  #
  local QUEUE_MODULE="%QUEUE_MODULE:NULL%"
  if [[ "$QUEUE_MODULE" == "NULL" ]];then 
     echo -e "\tNo modules are required to use one of the following queues:"
     qstat -q -G | sed s/^/\\t/g
     echo -e "\t===================================================\n"
  else
     echo -e "\tThe following modules:\n\t$QUEUE_MODULE"
     echo -e "\tare required to use one of the following queues:"
     local MODLULEOK=0
     module load $QUEUE_MODULE  2>&1   || MODLULEOK=1 
     if [[ $MODLULEOK -eq 1 ]];then
        echo -e "\n\tError in loading module: $QUEUE_MODULE. I must exit\n"
        RETURN_STATUS=1; return $RETURN_STATUS
     fi 
     qstat -q -G | sed s/^/\\t/g
     echo -e "\t===================================================\n"
  fi
  #
  #             JOB SUMMARY REPORT FILE DEFINITION AND CHECKS
  # Check whether the Directory for the job report summary has been defined
  #
  local JOBS_REPORT_DIR="%JOBS_REPORT_DIR:NULL%"
  if [[ "$JOBS_REPORT_DIR" == "NULL" ]];then 
     echo -e "\tNo jobs report directory has been defined in this suite."
     echo -e "\tI am going to use (%%ECF_HOME%%): %ECF_HOME%"
     echo -e "\tOtherwise you should define the JOBS_REPORT_DIR in the suite definition file."
     JOBS_REPORT_DIR="%ECF_HOME%"
  else
     echo -e "\tThe following jobs report directory has been defined in this suite:\n\t$JOBS_REPORT_DIR"
  fi
  local SR_GOON=0
  if [[ ! -d  $JOBS_REPORT_DIR ]];then mkdir -p $JOBS_REPORT_DIR || SR_GOON=1;fi
  if [[ $SR_GOON -eq 0 ]];then   
     local JOBS_REPORT_FILE="${JOBS_REPORT_DIR}/%YYYY%_ecFlow_jobs-summary.csv"
     echo -e "\tSummary report for the job will be saved in:\n\t$JOBS_REPORT_FILE\n"
  else
     echo -e "\tProblems in creating the directory $JOBS_REPORT_DIR.\n\tNo summary report file will be created\n"
  fi
  #
  #           JOB SUBMISSION SECTION 
  # Submit job to the queue and get the ID job number for further monitoring
  #
  local DJS=$(date -u +%%s)
  echo -e "\n\tJob submission procedure starts at: $(date -u) UTC"
  echo -en "\tSubmission of job: $JOB_TO_SUBMIT\n\tRemenber that script is waiting the job completes ( -W block=true) ..."
  local JOB_GOON=0; local JOBNUMBER
  #
  # Submit job with block=True activated 
  #
  JOBNUMBER=$(qsub -W block=true $JOB_TO_SUBMIT) || JOB_GOON=1    
  RETURN_STATUS=$JOB_GOON
  if [[ $JOB_GOON -eq 0 ]];then
     echo -en " successfully completed.\n\tThis job ID is: $JOBNUMBER\n"
  else
     echo -en " completed with errors. \n\tPlease check! (qstat -xf $JOBNUMBER)\n"
     echo -e  "\tThis job ID is: $JOBNUMBER"
  fi
  #
  # In case the job had problem before to be run, that is no JOBNUMBER is available
  # Then return with exit status 2 and do not perform any further check
  #
  if [[ -z $JOBNUMBER ]];then
     echo -e "\tThe Job did NOT enter in the queue and there is NO Job number available.\n"
     RETURN_STATUS=2; return $RETURN_STATUS
  fi 
  #
  # Check when jobs end and report status
  #
  local DJE=$(date -u +%%s)
  echo -e "\tJob submission procedure stops  at: $(date -u) UTC"
  echo -e "\tTotal time spent on queue: $(($DJE - $DJS)) seconds i.e. $((($DJE - $DJS)/60)) minutes\n"
  #
  # Get information on the job execution 
  #
  local JOB_NUM_ONLY="${JOBNUMBER%%.*}"; JOB_NUM_ONLY="${JOB_NUM_ONLY%%[*}"
  local JOB_SUMMARY_TMP_FILE=$(mktemp -u job_summary-${JOB_NUM_ONLY}.XXXXX)
  #
  # The JOB_SUMMARY_FILE is a global variable storing the summary of the job resurces reservation and usage
  #
  JOB_SUMMARY_FILE="${JOB_SUMMARY_TMP_FILE%%%%.*}.joblog"
  if [[ -e $JOB_SUMMARY_FILE ]];then rm JOB_SUMMARY_FILE ;fi
  sleep 2 # Sleep two seconds to allow the queue to report all the information  
  qstat -xtf $JOBNUMBER > $JOB_SUMMARY_TMP_FILE
  #
  # Some common informatiomn on the task to be loaded in the JOB_SUMMARY_FILE
  #
  echo -e "    ecFlow node = %ECF_NAME%"          > $JOB_SUMMARY_FILE
  echo -e "    ecFlow script = %ECF_SCRIPT%"     >> $JOB_SUMMARY_FILE
  echo -e "    ecFlow job = %ECF_JOB%"           >> $JOB_SUMMARY_FILE
  echo -e "    ecFlow job output = %ECF_JOBOUT%" >> $JOB_SUMMARY_FILE
  echo -e "    Job number = $JOBNUMBER"          >> $JOB_SUMMARY_FILE
  #
  # Get the stdout and stderr default file names 
  #
  # STANDARD OUTPUT FIRST
  JOB_STD_OUT_FILE="$(grep -m 1 -A5 "Output_Path =" $JOB_SUMMARY_TMP_FILE | sed ':a;N;$!ba;s/\n//g' | sed s/\\t//g | cut -d "=" -f 2 )" 
  JOB_STD_OUT_FILE="${JOB_STD_OUT_FILE:=NULL}";JOB_STD_OUT_FILE="${JOB_STD_OUT_FILE##*:}"; JOB_STD_OUT_FILE="${JOB_STD_OUT_FILE%%%% *}"
  JOB_STD_OUT_FILE="${JOB_STD_OUT_FILE//.^array_index^/.*}"
  # STANDARD ERROR SECOND
  JOB_STD_ERR_FILE="$(grep -m 1 -A5 "Error_Path =" $JOB_SUMMARY_TMP_FILE | sed ':a;N;$!ba;s/\n//g' | sed s/\\t//g | cut -d "=" -f 2 )" 
  JOB_STD_ERR_FILE="${JOB_STD_ERR_FILE:=NULL}";JOB_STD_ERR_FILE="${JOB_STD_ERR_FILE##*:}"; JOB_STD_ERR_FILE="${JOB_STD_ERR_FILE%%%% *}"
  JOB_STD_ERR_FILE="${JOB_STD_ERR_FILE//.^array_index^/.*}"
  #
  # Check whether the job is an array job or a single one 
  #
  local IS_ARRAY=0; local YN_ARRAY
  grep -q "array = True" $JOB_SUMMARY_TMP_FILE || IS_ARRAY=1
  #
  # Retrieve information on the job execution and resources used and reserved
  #
  if [[ $IS_ARRAY -eq 0 ]];then
      YN_ARRAY="ArrayJob"
      local ARRAY_IDS="$(grep array_indices_submitted $JOB_SUMMARY_TMP_FILE)"
      echo -e "\tThis is an array job -> $ARRAY_IDS\n\tSummary report here below."
      for K in $JOB_FEATURES_LIST;do grep -m 1 "${K} =" $JOB_SUMMARY_TMP_FILE | sed s/^/\\t/g ;done
      echo -e "    Array job: $ARRAY_IDS " >> $JOB_SUMMARY_FILE
      for K in $JOB_FEATURES_LIST;do grep -m 1 "${K} =" $JOB_SUMMARY_TMP_FILE >> $JOB_SUMMARY_FILE ;done
      #
      # Incase of verbose activation each array element is scanned 
      #
      if [[ "${ARRAY_VERBOSE}" != "NULL" ]];then 
          ARRAY_IDS="${ARRAY_IDS##*=}"
          local AS=${ARRAY_IDS%%%%-*}; local AD=${ARRAY_IDS##*:}; local AE=${ARRAY_IDS##*-}; AE=${AE%%%%:*}
          ARRAY_IDS="$(seq $AS $AD $AE)"
          local NSNE NS NE NA NAR NTOT
          NAR=1 ;NTOT=$(echo $ARRAY_IDS | wc -w)
          for NA in $ARRAY_IDS;do 
             NSNE=$(grep -n "Job Id: " $JOB_SUMMARY_TMP_FILE | grep -A1 "${JOB_NUM_ONLY}\[${NA}\]" | cut -d ":" -f 1)
             NS=$(echo $NSNE | cut -d " " -f 1); NE=$(echo $NSNE | cut -d " " -f 2)
             if [[ $NAR -eq $NTOT ]];then NE=$(cat $JOB_SUMMARY_TMP_FILE | wc -l);fi 
             echo  -e "\n\t=================\n\tArray element: $NA (${JOB_NUM_ONLY}[${NA}])"
             head -n $(($NE-1)) $JOB_SUMMARY_TMP_FILE | tail -n $(($NE-$NS)) | sed s/^/\\t/g
             echo  -e "\t================="
             NAR=$(($NAR+1))
          done
      else
          echo -e "\tVerbose for each array element resources list in not acrivated: ARRAY_VERBOSE=${ARRAY_VERBOSE}"
          echo -e "\tIf needed, define it as a suite variable in the suite definition file: edit ARRAY_VERBOSE TRUE"
      fi
  else
      YN_ARRAY="SingleJob"
      echo -e "\tThis is a signle job.\n\tSummary report here below."
      for K in $JOB_FEATURES_LIST;do grep "${K} =" $JOB_SUMMARY_TMP_FILE | sed s/^/\\t/g ;done
      for K in $JOB_FEATURES_LIST;do grep "${K} =" $JOB_SUMMARY_TMP_FILE >>  $JOB_SUMMARY_FILE ;done
  fi
  #
  # Save job summary is going to me appended to the JOBS_REPORT_FILE
  #
  if [[ $SR_GOON -eq 0 ]];then   
     JOB_FEATURES_LIST="ecFlow+node ecFlow+script ecFlow+job ecFlow+job+output Job+number ${JOB_FEATURES_LIST}"
     #
     # When JOBS_REPORT_FILE does not exist, write the header 
     #
     if [[ ! -e $JOBS_REPORT_FILE ]];then 
        echo -e "#\n# This is the yearly summary report for jobs sunbitted by ecFlow nodes\n#" > $JOBS_REPORT_FILE
        echo -e "#  For details on content use qstat manual since a qstat -xtf has generated these info." >> $JOBS_REPORT_FILE
        echo -e "# N record = content" >> $JOBS_REPORT_FILE
        local NSRP=1; local SRPS
        local  SRPS_LIST="Job_number_only Array_or_Single_Job Year Month Day UTC_Hour UTC_Minute UTC_Second ${JOB_FEATURES_LIST}"
        for SRPS in ${SRPS_LIST};do
            echo -e "# $(printf %%8d ${NSRP}) ${SRPS}"  >> $JOBS_REPORT_FILE
            NSRP=$(($NSRP + 1))
        done
     fi 
     #
     # Create theh record and append it to the JOBS_REPORT_FILE
     #
     local JOBS_REPORT_FILE_RECORD="${JOB_NUM_ONLY};${YN_ARRAY};$(date -u "+%%Y;%%m;%%d;%%H;%%M;%%S;")"
     local JRF_REC="NULL"
     for XJF in $JOB_FEATURES_LIST;do
         JRF_REC="$(grep "${XJF//+/ } =" $JOB_SUMMARY_FILE | cut -d "=" -f 2-)" || JRF_REC="NULL"
         JRF_REC="${JRF_REC:=NULL}"
         JOBS_REPORT_FILE_RECORD="${JOBS_REPORT_FILE_RECORD}${JRF_REC# *};"
     done
     echo -e "${JOBS_REPORT_FILE_RECORD}" >> $JOBS_REPORT_FILE
     echo -e "\n\tSummary report for this job has been appended to the file:\n\t$JOBS_REPORT_FILE\n"
  fi  
  
  echo -e "\n\n\t-----------   RETURN_STATUS=$RETURN_STATUS   ---------" 
  echo -e "\n\tThe above job summary is available in file:\n\t$(pwd)/$JOB_SUMMARY_FILE"
  echo -e "\tThis script global variable: JOB_SUMMARY_FILE stores file name: ${JOB_SUMMARY_FILE}.\n"
  echo -e "\tThe job STDOUT is available in file:\n\t${JOB_STD_OUT_FILE}"
  echo -e "\tThis script global variable: JOB_STD_OUT_FILE stores the full STDOUT file name path.\n"
  echo -e "\tThe job STDERR is available in file:\n\t${JOB_STD_ERR_FILE}"
  echo -e "\tThis script global variable: JOB_STD_ERR_FILE stores the full STDERR file name path.\n"
  #
  # +--------------------------------------------------------------+
  # | Copy the jobscripts standard output and standard error in the|
  # | directory defined for storing inforamtion on job results.    |
  # | For ARPA FVG - CRMA data provenance pourposes the default is |
  # | a job_stdoe subdirectory of the ecFlow family job and output |
  # | nodes files (%%ECF_JOBOUT%% and %%ECF_JOB%%)                 |
  # +--------------------------------------------------------------+
  #
   PROVENANCE_ROOT_DIR="%ECF_JOBOUT%"; PROVENANCE_DIR="${PROVENANCE_ROOT_DIR%%/*}/jobstdeo/"
   echo -e "\n\tFor data provenace the job scripts stdout and stderr are going to be saved in:"
   echo -e "\t${PROVENANCE_DIR}"
   MKDI=0; if [[ ! -d ${PROVENANCE_DIR} ]];then mkdir -p ${PROVENANCE_DIR} || MKDI=1;fi
   if [[ $MKDI -ne 0 ]];then
      echo -e "\n\tWARNING impossible to save job stdout and stderr for data provenance in:"
      echo -e "\t${PROVENANCE_DIR}\n\tdirectory cannot be created\n"
   else
      CPFI=0; cp -v $JOB_STD_OUT_FILE $PROVENANCE_DIR | sed s/^/\\t/g || CPFI=1
              cp -v $JOB_STD_ERR_FILE $PROVENANCE_DIR | sed s/^/\\t/g || CPFI=1
              cp -v $JOB_SUMMARY_FILE $PROVENANCE_DIR | sed s/^/\\t/g || CPFI=1
      if [[ $CPFI -ne 0 ]];then
         echo -e "\n\tWARNING impossible to save at least some file for data provenance!!\n"
      fi
   fi
  echo -e "\t+-------- This was the qsub ecFlow function ---------+\n"
return $RETURN_STATUS
}

#-----------------------------------------------------------------------------
#       END OF THE FUNCTION MANAGING THE PBS QUEUE JOB SUBMISSION
#-----------------------------------------------------------------------------
