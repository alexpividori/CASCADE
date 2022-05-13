#!/bin/bash
#==========================================================================
#
#  This is the ecflow-crma_stop.sh BASH script
#
#        It stops the ecflow_server. It is suited for ARPA FVG - CRMA
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
#        The script checks whether the server is running and if it is so 
#        it tries to stop it.
#
#        A log is sent to the stdout.
#
#        There are lines sent to stdout starting with string "STDOUT:" that bring 
#        information suitable to grasp the status of the server. In particular
#        the variable status is an integer that is set as follow:
#        
#        
#        
#        status=0 ---> the server is already stopped 
#        status=1 ---> the attempt to stop the server failed
#        status=2 ---> the attempt to stop the serve was successful and the server is halted        
#        status=9 ---> the server is not halted  and it is giung to be
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
     backup_server=false             # Do not stop  ECF for backup server or e-suite

# -----------------------------------------------------------------
#
#
#                     MAIN SCRIPT HERE BELOW
#
#==========================================================================
# Syntax
# ecf_stop [-b] [-p port_number ] [-h]
#==========================================================================
#
#    Get command line options if any.
#
     while getopts hb:p: option; do
           case $option in
                b) backup_server=true         ;;
                p) ecf_port=$OPTARG           ;;
                h)
                  echo "Usage: $0 [-b] [-p port_number] [-h]"
                  echo "       -b        stop ECF backup server"
                  echo "       -p <num>  specify server port number(ECF_PORT number)"
                  echo "       -h        print this help page"
                  exit 1
                ;;
                *)
                  echo "Usage: $0 [-b] [-p port_number] [-h]"
                  echo "       -b        stop ECF backup server"
                  echo "       -p <num>  specify server port number(ECF_PORT number)"
                  echo "       -h        print this help page"
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
#  Some check on port_number.
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
        echo -e "\tI camnnot continue in testing or stopping the ecFlow server\n\n"
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

# ===============================================================================
# Test whether the server is already stopped. In that case exit, otherwise continue
    
    if [[ $(eval 'SERVER_UP="$(ecflow_client --port $ECF_PORT --host $ECF_HOST --ping 2>&1)"; echo $?') -eq 1 ]];then  
       eval 'SERVER_UP="$(ecflow_client --port $ECF_PORT --host $ECF_HOST --ping 2>&1; echo $?)"'
       echo -e "\n\tServer is already stopped. Messagge is:\n\n\t$(echo $SERVER_UP | head -n 1 | sed s/'attempts.'/\\n\\t/g)\n\n" 
       echo -e "\nSTDOUT:ecFlow; server=$ECF_HOST;port=$ECF_PORT;date_time=$(date -u +%F" "%T" UTC");status=0;comment=already stopped;\n\n"
       exit  $EXIT_STATUS
    else
       echo -e "\n\tThe server    --port $ECF_PORT --host $ECF_HOST  is running.\n\n" 
       echo -e "\nSTDOUT:ecFlow; server=$ECF_HOST;port=$ECF_PORT;date_time=$(date -u +%F" "%T" UTC");status=9;comment=running;\n\n"
    fi

# ===============================================================================
# Set up default environment variables in case they are not set

    NOW_DATE=$(date -u +%Y%m%d-%H%M%S)
    echo -e "\tNow is: $NOW_DATE"

    export ECF_HOST=${ECF_HOST:-$host}

    echo -e "\n\tUser:   $(id)"
    echo -e "\n\tAttempting to stop  ecflow server on ECF_HOST=$ECF_HOST  using  ECF_PORT=$ECF_PORT  and with:"
    echo -e "\t\tECF_HOME     : $ECF_HOME"
    echo -e "\t\tECF_LOG      : $ECF_LOG"
    echo -e "\t\tECF_CHECK    : $ECF_CHECK"
    echo -e "\t\tECF_CHECKOLD : $ECF_CHECKOLD"
    echo -e "\n\n" 

#==========================================================================
# Some diagnostic on versions of client and server

    echo -e "\tClient version is:\n\t$(ecflow_client --version)\n"
    echo -e "\tServer version is:\n\t$(ecflow_server --version)\n"

# =============================================================================
# ecFlow server stopped in the background.
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
    echo -e "\n\tOK starting ecFlow shutdown....\n"
    #
    # Halting the server
    #
    echo -en "\tHalting ecFlow ..."
    if [[ $(eval 'SERVER_UP="$(ecflow_client --host $ECF_HOST --port $ECF_PORT --halt=yes 2>&1)"; echo $?') -eq 0 ]];then  
       sleep 1s
       echo -en "\tServer is halted.\n\n" 
    else
       echo -e "\n\tThe attempt to halt the server failed! The server is not halted.\n\n" 
       echo -e "\nSTDOUT:ecFlow; server=$ECF_HOST;port=$ECF_PORT;date_time=$(date -u +%F" "%T" UTC");status=1;comment=not halted;\n\n"
       EXIT_STATUS=1; exit  $EXIT_STATUS
    fi
    #
    # Checkpointing the server
    #
    echo -en "\tCheckpointing ecFlow ..."
    if [[ $(eval 'SERVER_UP="$(ecflow_client --host $ECF_HOST --port $ECF_PORT --check_pt 2>&1)"; echo $?') -eq 0 ]];then  
       sleep 1s
       echo -en "\tServer is checkpointed.\n\n" 
    else
       echo -e "\n\tThe attempt to checkpoin the server failed! The server is not checkpointed.\n\n" 
       echo -e "\nSTDOUT:ecFlow; server=$ECF_HOST;port=$ECF_PORT;date_time=$(date -u +%F" "%T" UTC");status=1;comment=not checkpointed;\n\n"
       EXIT_STATUS=1; exit  $EXIT_STATUS
    fi
    #
    # Terminate the server
    #
    echo -en "\tTerminating ecFlow ..."
    if [[ $(eval 'SERVER_UP="$(ecflow_client --host $ECF_HOST --port $ECF_PORT --terminate=yes 2>&1)"; echo $?') -eq 0 ]];then  
       sleep 1s
       echo -e "\tServer is terninated.\n\n" 
    else
       echo -e "\n\tThe attempt to teminate the server failed! The server is not terminated.\n\n" 
       echo -e "\nSTDOUT:ecFlow; server=$ECF_HOST;port=$ECF_PORT;date_time=$(date -u +%F" "%T" UTC");status=1;comment=not terminated;\n\n"
       EXIT_STATUS=1; exit  $EXIT_STATUS
    fi



    echo -e "\nSTDOUT:ecFlow; server=$ECF_HOST;port=$ECF_PORT;date_time=$(date -u +%F" "%T" UTC");status=2;comment=halted, checkpointed and terminated right now;\n\n"

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
