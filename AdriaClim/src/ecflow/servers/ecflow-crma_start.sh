#!/bin/bash
#==========================================================================
#
#  This is the ecflow-crma_start.sh BASH script
#
#        It start the ecflow_server. It is suited for ARPA FVG - CRMA
#        INTERREG IT-HR projects purposes.
#
#        Several aspects of this script have been inherited from the 
#        analogue script distributed by ECMWF, but written for their
#        own purposes.
#
#        All environmental variables required by ecflow server should
#        be found in the enviroment. A proper module should be used to
#        to set them. At C3HPC there are:
#        AdriaClim_ecflow, CASCADE_ecflow FIRESPILL_ecflow.
#
#        The script checks whether the server is running and if it is not
#        so, it tries to start it.
#
#        A log is sent to the stdout.
#
#        There are lines sent to stdout starting with string "STDOUT:" that bring 
#        information suitable to grasp the status of the server. In particular
#        the variable status is an integer that is set as follow:
#        
#        
#        
#        status=0 ---> the server is already started 
#        status=1 ---> the attempt to start the server failed
#        status=2 ---> the attempt to start the serve was successful and the server is running       
#        status=9 ---> the server is not started and it is giung to be       
#        
#        
#        
#        
#        by Dario B. Giaiotti
#
#        ARPA FVG - CRMA
#        e-mail: dario.giaiotti@arpa.fvg.it
#        Centro Regionale di Modellistica Ambientale 
#        Via Cairoli, 14 
#        I-33057 Palmanova (UD)
#        ITALY
#        Room I/20/U
#        Tel +39 0432 191 8048
#
#
#        Created:  Mar 05, 2021 by Dario B. Giaiotti 
#        Modified: Mar 10, 2021 by Dario B. Giaiotti
#                  Completed the script
#
#
#==========================================================================
#
#
#
#         DEFINE DEBUG OPTIONS AND ERROR TRAPPING
#
#
      # The trap command allows you to execute a command when a signal is received by your script.
      #
      # The trap command catches the listed SIGNALS, which may be signal names with
      # or without the SIG prefix, or signal numbers.
      # If a signal is 0 or EXIT, the COMMANDS are executed when the shell exits.
      # If the signal is specified as ERR; in that case COMMANDS are executed each
      # time a simple command exits with a non-zero status.
      # Note that these commands will not be executed when the non-zero exit status comes
      # from part of an if statement, or a while or until loop. Neither will they be executed
      # if a logical AND (&&) or OR (||) result in a non-zero exit code, or when a command's
      # return status is inverted using the ! operator.

      #
      # This is the defaul trap to stop when any command exits without zero.
      # Please read the above lines for more details on if loops and so on limits
      #
      ERROR() { echo -e "\n\tERROR! Job stopped with any error\n\n"; exit 1;}
      trap 'echo -e "\n\n\tKilled by signal"; ERROR;' ERR

      #
      # Other possible trapps you may want are
      #
      #  trap 'echo -e "\n\n\tKilled by signal"; ERROR;' 1 2 3 4 5 6 7 8 10 12 13 15 # for a set of signals only.
      #  trap ERROR 0                     # call the function ERROR on exit od the shell. Usefull to clean up on exit.
      #
      # The whole list of sigspec can be accessed by kill -l or man kill or trap -l
      #

      set -e                   # stop the shell on first error
      # set -u                   # fail when using an undefined variable
      # set -x                   # echo script lines as they are executed
#
# -----------------------------------------------------------------
#
#
#                     CONSTANTS AND PARAMENTERS
#
#     Remember to define the default exit status parameter EXIT_STATUS
#

     EXIT_STATUS=0         # Default exit status is zero, that is everything went OK.


     export TZ=GMT LANG=             # en_GB.UTF-8 unset, use locale -a to list available locales
     host=$(hostname)                # Get the name the name of the current host 
     force=true                      # Forces the ECF to be restarted 
     backup_server=false             # Do not start ECF for backup server or e-suite
     verbose=false                   # No verbose mode
     rerun=false                     # 

# -----------------------------------------------------------------
#
#
#                     MAIN SCRIPT HERE BELOW
#
#==========================================================================
# Syntax
# ecflow_start [-b] [-d ecf_home_directory] [-f] [-h] [-p port_number ]
#==========================================================================
#
#    Get command line options if any.
#
     while getopts hfbd:vp:r option; do
           case $option in
                f) force=true                 ;;
                b) backup_server=true         ;;
                v) verbose=true               ;;
                d) ecf_home_directory=$OPTARG ;;
                p) ecf_port=$OPTARG           ;;
                r) rerun=true                 ;;
                h)
                  echo "Usage: $0 [-b] [-d ecf_home directory] [-f] [-h]"
                  echo "       -b        start ECF for backup server or e-suite"
                  echo "       -d <dir>  specify the ECF_HOME directory "
                  echo "       -f        forces the ECF to be restarted"
                  echo "       -v        verbose mode"
                  echo "       -h        print this help page"
                  echo "       -p <num>  specify server port number (ECF_PORT number)"
                  exit 1
                ;;
                *)
                  echo "Usage: $0 [-b] [-d ecf_home directory] [-f] [-h]"
                  echo "       -b        start ECF for backup server or e-suite"
                  echo "       -d <dir>  specify the ECF_HOME directory "
                  echo "       -f        forces the ECF to be restarted"
                  echo "       -v        verbose mode"
                  echo "       -h        print this help page"
                  echo "       -p <num>  specify server port number (ECF_PORT number)"
                  exit 1
                ;;
           esac
     done

# =================================================================================
# Write the evironment variables required by ecflow_server to run.
     
     echo -e "\n\tBASH script: $0\n"

     VARS_LIST="ECF_HOST $(ecflow_server -h | grep "    ECF_" | grep ":" | cut -d ":" -f 1)"
     echo -e "\n\\n\tThis is the environment I am going to use"
     for VE in $VARS_LIST; do 
          if [[ ! -z $(eval 'env | grep "${VE}="') ]]; then
             echo -e "\t\tEnvironmental variable: $VE found.\n\t\t\tIt is ($(eval 'env | grep "${VE}="'))" 
          else
             echo -e "\t\tEnvironmental variable: $VE NOT FOUND !!! Warning!!!"
          fi 
     done 

# =================================================================================
#  Some check on port_number and ecFlow HOME directory.
#
     #
     #
     # /------------- ecFlow Port Number --------------/
     #
     #
     #
     # The environmental port number is not set. Check whether an input one is available otherwise exit  
     #
     if [ -z "$ecf_port" -a -z "$ECF_PORT" ] ; then
        echo -e "\n\tThe server port number is not available in the environment neither you specified one!!!."
        echo -e "\tI camnnot continue in testing or activating the ecFlow server\n\n"
        EXIT_STATUS=1; exit $EXIT_STATUS 
     fi
     #
     # The port number is not input as expected 
     #
     if [ -z "$ecf_port" ] ; then
        echo -e "\n\tYou did not set any server port number, so I am going to use the environmental value."
        echo -e "\t\tECF_PORT=${ECF_PORT}\n"
        ecf_port=${ECF_PORT}
     fi
     #
     # The input port number is not matching the environmental value 
     #
     if [ "$ecf_port" != "$ECF_PORT" ] ; then
        echo -e "\n\t\t!!!!!!!!!!!!!!!!!!! WARNING !!!!!!!!!!!!!!!!!"
        echo -e "\tThe server port number you set ($ecf_port) is not matching the environmental value ($ECF_PORT)."
        echo -e "\tI continue with your value, but be aware there could be inconsistencies with other environmental variables"
        echo -e "\t\t!!!!!!!!!!!!!!!!!!! WARNING !!!!!!!!!!!!!!!!!\n"
        ECF_PORT=$ecf_port
        export ECF_PORT
     fi
     #
     #
     # /------------- ecFlow HOME dir --------------/
     #
     #
     # The environmental HOME is not set. Check whether an input one is available otherwise exit  
     #
     if [ -z "$ecf_home_directory" -a -z "$ECF_HOME" ] ; then
        echo -e "\n\tThe HOME directory fo server is not available in the environment neither you specified one!!!."
        echo -e "\tI camnnot continue in testing or activating the ecFlow server\n\n"
        EXIT_STATUS=1; exit $EXIT_STATUS 
     fi
     #
     # The ecFlow HOME directory is not input as expected 
     #
     if [ -z "$ecf_home_directory" ] ; then
        echo -e "\n\tYou did not set any server HOME directory, so I am going to use the environmental value."
        echo -e "\t\tECF_HOME=${ECF_HOME}\n"
        ecf_home_directory=${ECF_HOME}
     fi
     #
     # The input environmental HOME  is not matching the environmental value 
     #
     if [ "$ecf_home_directory" != "$ECF_HOME" ] ; then
        echo -e "\n\tThe server HOME directory you set ($ecf_home_directory) is not matching the environmental value ($ECF_HOME)."
        echo -e "\tI continue with your value, but be aware there could be inconsistencies with other environmental variables"
        ECF_HOME=$ecf_home_directory
        export ECF_HOME
     fi

#===============================================================================
# if the whilelist is not set then set to default value         

     export ECF_LISTS=${ECF_LISTS:-$ECF_HOME/ecf.lists}

     echo -e "\n\tThese are the environmental variables I have found as HOME directory and WHITE LIST file "
     echo -e "\t\tECF_HOME=${ECF_HOME}"
     echo -e "\t\tECF_LISTS=${ECF_LISTS}"

# ===============================================================================
# Test whether the server is already runnig. In that case exit, otherwise continue
    
    if [[ $(eval 'SERVER_UP="$(ecflow_client --port $ECF_PORT --host $ECF_HOST --ping 2>&1)"; echo $?') -eq 0 ]];then  
       eval 'SERVER_UP="$(ecflow_client --port $ECF_PORT --host $ECF_HOST --ping 2>&1)"'
       echo -e "\n\tServer is already started. Messagge is:\n\n\t\t$SERVER_UP\n\n" 
       echo -e "\tUse 'netstat -lnptu' for listing active port\n\tBye.\n\n" 
       echo -e "\nSTDOUT:ecFlow; server=$ECF_HOST;port=$ECF_PORT;date_time=$(date -u +%F" "%T" UTC");status=0;comment=already started;\n\n"
       exit  $EXIT_STATUS
    else
       echo -e "\n\tThe server    --port $ECF_PORT --host $ECF_HOST      is not started.\n\n" 
       echo -e "\nSTDOUT:ecFlow; server=$ECF_HOST;port=$ECF_PORT;date_time=$(date -u +%F" "%T" UTC");status=9;comment=not started;\n\n"
    fi

# ===============================================================================
# Set up default environment variables in case they are not set

    NOW_DATE=$(date -u +%Y%m%d-%H%M%S)
    echo -e "\tNow is: $NOW_DATE"

    export ECF_HOST=${ECF_HOST:-$host}
    export ECF_LOG=${ECF_LOG:-$host.$ECF_PORT.ecf.log}
    export ECF_CHECK=${ECF_CHECK:-$host.$ECF_PORT.chec}
    export ECF_CHECKOLD=${ECF_CHECKOLD:-$host.$ECF_PORT.check.b}

    if [ "$verbose" = "false" ]; then
         export ECF_OUT=/dev/null
    else
         export ECF_OUT=${ECF_LOG//.log/.out}
    fi

    echo -e "\n\tUser:   $(id)"
    echo -e "\n\tAttempting to start ecflow server on ECF_HOST=$ECF_HOST  using  ECF_PORT=$ECF_PORT  and with:"
    echo -e "\t\tECF_HOME     : $ECF_HOME"
    echo -e "\t\tECF_LOG      : $ECF_LOG"
    echo -e "\t\tECF_CHECK    : $ECF_CHECK"
    echo -e "\t\tECF_CHECKOLD : $ECF_CHECKOLD"
    if [ "$verbose" = "false" ]; then
          echo -e "\t\tECF_OUT      : $ECF_OUT"
    else
           echo -e "\t\tECF_OUT      : $ECF_OUT"
    fi
    echo -e "\n\n" 

#==========================================================================
# Some diagnostic on versions of client and server

    echo -e "\tClient version is:\n\t$(ecflow_client --version)\n"
    echo -e "\tServer version is:\n\t$(ecflow_server --version)\n"

#==========================================================================

    echo -e "\n\tBacking up previous check point and log files."

    if [ ! -d $ECF_HOME ] ;then mkdir $ECF_HOME; fi
    cd $ECF_HOME

    if [ ! -d log ] ;then mkdir log ; fi

    if [[ -f $ECF_CHECK ]];then 
       echo -e "\tFound file ECF_CHECK: $ECF_CHECK \n\t\tand copied in $ECF_HOME/log/"
       cp $ECF_CHECK log/${ECF_CHECK##*/}.${NOW_DATE}
    fi

    if [[ -f $ECF_CHECKOLD ]];then 
       echo -e "\tFound file ECF_CHECKOLD: $ECF_CHECKOLD \n\t\tand copied in $ECF_HOME/log/"
        cp $ECF_CHECKOLD log/${ECF_CHECKOLD##*/}.${NOW_DATE}
    fi

    if [[ -f $ECF_LOG ]];then 
       echo -e "\tFound file ECF_LOG: $ECF_LOG \n\t\tand moved in $ECF_HOME/log/"
       mv $ECF_LOG log/${ECF_LOG##*/}.${NOW_DATE}
    fi

    if [[ -f $ECF_OUT ]];then  
       echo -e "\tFound file ECF_OUT: $ECF_OUT \n\t\tand copied in $ECF_HOME/log/"
       cp $ECF_OUT log/${ECF_OUT##*/}.${NOW_DATE}
    fi

# =============================================================================
# ecFlow server start in the background.
#
# o/ nohup is a POSIX command to ignore the HUP (hangup) signal, enabling the command to 
#    keep running after the user who issues the command has logged out. 
#    The HUP (hangup) signal is by convention the way a terminal warns depending processes of logout. 
#
#    Note that these methods prevent the process from being sent a 'stop' signal on logout,
#    but if input/output is being received for these standard IO files (stdin, stdout, or stderr), 
#    they will still hang the terminal
#    This problem can also be overcome by redirecting all three I/O streams:
#
# o/ ecflow_server will by default attempt to recover from a check point file if it is there
#    otherwise it will look for the backup check point file
#
    echo -e "\n\tOK starting ecFlow server..."

    nohup ecflow_server > $ECF_OUT 2>&1 < /dev/null &

    # the sleep allows time for server to start
    if [ "$force" = "true" ]; then
       echo -e "\n\tPlacing server into RESTART mode..."
       sleep 5  
        if [[ $(eval 'SERVER_UP="$(ecflow_client --restart 2>&1)"; echo $?') -eq 0 ]];then  
           echo -e "\n\tServer is ready.\n\n" 
        else
           echo -e "\n\tThe attempt to restart the server failed! The server is not started.\n\n" 
           echo -e "\nSTDOUT:ecFlow; server=$ECF_HOST;port=$ECF_PORT;date_time=$(date -u +%F" "%T" UTC");status=1;comment=not started;\n\n"
           EXIT_STATUS=1; exit  $EXIT_STATUS
        fi
    fi

    echo -e "\n\t\tTo view server on ecflowview - goto Edit/Preferences/Servers and enter"
    echo -e "\t\tName        : <unique ecFlow server name>"
    echo -e "\t\tHost        : $ECF_HOST"
    echo -e "\t\tPort Number : $ECF_PORT"
    echo -e "\n\n"
    echo -e "\nSTDOUT:ecFlow; server=$ECF_HOST;port=$ECF_PORT;date_time=$(date -u +%F" "%T" UTC");status=2;comment=started right now;\n\n"

    exit $EXIT_STATUS
#
#
#                     MAIN SCRIPT HERE ABOVE
#
# -----------------------------------------------------------------
#
#
#                     ENDING SECTION OF THE SCRIPT HERE BELOW
#
#      Remember to set the exit status if the trap does not work
#      exit $EXIT_STATUS
#
# -----------------------------------------------------------------
#
