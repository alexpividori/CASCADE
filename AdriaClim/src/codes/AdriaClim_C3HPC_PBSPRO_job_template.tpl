#!/bin/bash 
#
#=============================================================================================
#
#         PBS Job script template mandatory for AdriaClim IT-HR Project jobs generation 
#                 BASH script for job submission to the  
#                 PBSPRO queue using the qsub command.    
# 
#         by Dario B. Giaiotti
#         ARPA FVG  CRMA
#         dario.giaiotti@arpa.fvg.it
#         June 15, 2021     
# 
#     Remarks: A line beginning with # is a comment.
#              A line beginning with the prefix #PBS, then it is a PBS directive.
#              PBS directives must come first; any directives after the first executable 
#              statement are ignored.
#
#              All the strings you find between double percentage, %%PARAMETER%% are parameters 
#              you should edit to generate your job 
#             
#              Good luck
#
#     
#     !!! THIS TEMPLATE IS MANDATORY FOR AdriaClim JOBS !!!
#
#
#
#
#=============================================================================================
#
#         PBS  DIRECTIVES HERE BELOW
#
# 
# -------------------------------------------
# --        Specify the Project name       --
#      THIS IS A MANDATORY DIRESTIVE. DO NOT REMOVE IT
#
#PBS -P AdriaClim
#
#
# -------------------------------------------
# --        Set permissions to the log files 
#      THIS IS A MANDATORY DIRESTIVE. DO NOT REMOVE IT
#
#     By default permissions of stdout and stderr files are -rw-------.
#     To change suc permissions use PBS -W option as for umask.
#     If you also need to modify permissions to a project group you need: #PBS -W group_list=project01
#     Note that the this does NOT affect output files written by the programs you start in the job script
#
#     Here is the setting for   -rw-rw-r-- 
#PBS -W umask=0002
# 
# -------------------------------------------
# --        Select shell to be used        --
#      Request Bourne shell as shell for job
#
#PBS -S /bin/bash
#
# -------------------------------------------
# --        Load user environment          --
#     Job inherits all the user environment variables, when -V is activated 
# 
#PBS -V
#
# -------------------------------------------
# --        Define the job name            --
#      User underscores to replace spaces
#
##PBS -N  %%JOBNAME%%      
#
# -------------------------------------------
# --        Define the queue name          --
#      Run in the queue named "hp"
#         example   #PBS -q hp
##PBS -q %%QUEUE%% 
#
#
# -------------------------------------------
# --        Select when to send e-mail     --
#      The  -m  option allows users to designate those points in the execution of a 
#      batch job at which mail will be sent to the submitting user, or to the account(s) 
#      indicated by the -M option.  By requesting mail notification at points of interest 
#      in the life of a job, the submitting user, or other designated users, can track 
#      the  progress the job.
#  
#      Remind options are:                         
#              b     Mail is sent at the beginning of the job.
#              e     Mail is sent at the end of the job.
#              a     Mail is sent when the job is aborted 
#              n     No mail is sent.
#
#              explample of more that one option: #PBS -m aes
#
##PBS -m %%WHEN_TO_SEND_EMAILS%%
#
#
# --        Define mailing list to which send e-mails    --
#           The list of users to which the server that executes 
#           the job has to send mail, if the mail should be sent.
#         
#      Remind that mail addresses should be comma separeted  user[@host],...
#
##PBS -M %%WHO_TO_SEND_EMAILS%%         
#
#
# ------------------------------------------------------------
#           JOB ARRAY DIRECTIVES  
#               A job array is a compact representation of two or more jobs. 
#               A job that is part of a job array is called a subjob 
#               All subjobs in a job array share a single job script, including the PBS 
#               directives and the shell script portion.
#               Each subjob has a unique index. You can refer to job arrays or parts 
#               of job arrays using the following syntax forms:
#                    job array object itself: sequence_number[] or sequence_number[].server.domain.com
#                              Example: 1234[].server or 1234[]
#                    single subjob with index M: sequence_number[M] or sequence_number[M].server.domain.com
#                              Example: 1234[M].server or 1234[M]
#                    a range of subjobs of a job array: sequence_number[start-end[:step]] or 
#                                                       sequence_number[start-end[:step]].server.domain.com
#                              Example: 1234[X-Y:Z].server or 1234[X-Y:Z]
#
#               Important environmental variables for job array are:
#
#               Environment Variable    Used For           Description
#               PBS_ARRAY_INDEX         subjobs            Subjob index in job array, e.g. 7
#               PBS_ARRAY_ID            subjobs            Identifier for a job array. Sequence number
#                                                               of job array, e.g. 1234[].server
#               PBS_JOBID               Jobs, subjobs      Identifier for a job or a subjob. For subjob,
#                                                               sequence number and subjob index in brackets,
#                                                               e.g. 1234[7].server
#
#
#              Syntax for submitting a job array:
#              #PBS -J <index start>-<index end>[:stepping factor]
#                       index start     is the lowest index number in the range (should be >=0)
#                       index end       is the highest index number in the range
#                       stepping factor is the optional difference between index numbers
#                       Example: #PBS -J 1-1000 or #PBS -J 0-100:2
#
#              Relevant informatiomn on exit status
#
#              Exit    Meaning
#              Status
#              0       All subjobs of the job array returned an exit status of 0. 
#                      No PBS error occurred. Deleted subjobs are not considered
#              1       At least 1 subjob returned a non-zero exit status. No PBS error occurred.
#              2       A PBS error occurred
#
#
##PBS -J %%THE_DEFINITION_OF_ARRAY%%
#
#
# ------------------------------------------------------------
# --     Define the path for the standard output, error and input of the batch job.   --- 
#                By default, PBS copies stdout and stderr to the job's submission directory.
#                Environment variables CANNOT be used to generare the file names     
#                The default filename  has the following format:
#                             <job_name>.o<sequence_number> for standard output
#                             <job_name>.e<sequence_number> for standard error 
#                Otherwise you can give your specific name to the files.
#                You can specify relative or absolute paths. If you specify only a file name, 
#                it is assumed to be relative to your home directory. DO NOT USE variables in the path.
#                 
#                It is possible to join the stdout and the stderr in one file. This is done 
#                using the option -j as follow:
#
#                -j  join_list
#
#              join_list defines which streams of  the batch job are to be merged.                 
#
#               e     The standard error of the batch job (JOIN_STD_ERROR).
#               o     The standard output of the batch job (JOIN_STD_OUTPUT).
#               n     NO_JOIN
#
#               If 'n' is specified, then no files are joined. The qsub utility shall consider it an  error  if  any
#               join type other than 'n' is combined with join type 'n' .
#               You can specify one of the following joining options:
#                   oe Standard output and standard error are merged, intermixed, into a single stream, which becomes standard output.
#                   eo Standard output and standard error are merged, intermixed, into a single stream, which becomes standard error.
#                    n Standard output and standard error are not merged.
#                 
#                 
##PBS -j %%WHAT_SHOULD_I_DO_WITH_STDOUT_AND_ERR%%
#                 
#        By default, PBS copies stderr to the job submission directory.
#        The default filename  has the following format:
#          <job_name>.o<sequence_number> for standard output
#          <job_name>.e<sequence_number> for standard error 
#        Standard error file name       
#        example:     
#        #PBS -o /lustre/arpa/username/log/
#        #PBS -o /lustre/arpa/username/log/standard_error.txt
#        #PBS -o ../log/standard_error.txt
#            
#            
##PBS -e %%WHERE_TO_SEND_STDERR%%                  
#            
#            
#        By default, PBS copies stdout to the job submission directory.
#        The default filename  has the following format:
#          <job_name>.e<sequence_number> for standard output
#        Standard output file name       
#        example:     
#        #PBS -e /lustre/arpa/username/log/
#        #PBS -e /lustre/arpa/username/log/standard_output.txt
#        #PBS -e ../log/standard_output.txt
#            
##PBS -o  %%WHERE_TO_SEND_STDOUT%% 
#
#
# ------------------------------------------------------------
# --     Defines the resources required for the job        ---
#
#          Your job can request resources that apply to the entire job, or resources that apply to job chunks.
#          If one job process needs two CPUs and another needs 8 CPUs, your job can request two chunks, one 
#          with two CPUs and one with eight CPUs. 
#
#          All of a chunk is taken from a single host.
#
#          Your job cannot request the same resource in a job-wide request and a chunk-level request.
#          A resource is either job-wide or chunk-level, but not both. 
#
#          Job-wide resources are requested in <resource neme>=<value> pairs. 
#          You can request job-wide resources using any of the following formats:
#                 #PBS  -l <resource>=<value>,<resource>=<value>
#                 #PBS -l <resource>=<value> -l <resource>=<value>
#                 One or more #PBS -l <resource name>=<value> directives
#
#          Remember that in reserving cpus it is importnat to remind the meaning of the keywords:
#
#          nodes      = refers to the physical computational nodes and it is deprecated, but it works;
#          ppn        = refers to the processes (or parallel tasks) per node;
#          select     = refers to the physical computational nodes;
#          ncpus      = refers to the physical cpus per node;
#          mpiprocs   = refers to the cpus per node allocated for the mpi;
#          ompthreads = refers to the number of threads in OpenMP.
#
#          This is very important when mpirun is used with $PBS_NODEFILE, because the content of the file
#          $PBS_NODEFILE should match the number N in mpirun -p N when mpirun is invoked 
#
#          The old format  
#                       #PBS -l nodes=3:ppn=32 
#          still works and generated the 3x32 lines in the $PBS_NODEFILE requird as N in the mpirun -p N
#
#          The new format is described here below keeping in mind the following definitions:
#
#              select=# -- allocate # separate nodes
#              ncpus=# -- on each node allocate # cpus (cores)
#              mpiprocs=# -- on each node allocate # cpus (of the ncpus allocated) to MPI
#              ompthreads==# -- on each node run # of threads in  OpenMP (it sets OMP_NUM_THREADS=#) 
#
#          Example on how the system allocates processor cores for MPI jobs.
#
#          #PBS -l select=8:ncpus=8:mpiprocs=8
#
#          The above example allocates 64 cores all of which are for use by MPI (8 nodes with 8 cpus on each node).
#         
#
#          Example on how the system allocates processor cores for OpenMP jobs.
#
#          PBS Professional supports OpenMP applications by setting the OMP_NUM_THREADS variable in the job's 
#          environment, based on the resource request of the job. The OpenMP run-time picks up the value of 
#          OMP_NUM_THREADS and creates threads appropriately.
#
#          #PBS -l select=2:ncpus=10:ompthreads=10
#
#          The above example allocates 20 cores all of which are for use by OpenMP 20 threads 
#          (2 nodes with 10 cpus on each node executing 10 threads each).
#         
#
#          Example on how the system allocates processor cores for mixed MPI + OpenMP jobs.
#
#          #PBS -l select=2:ncpus=16:mpiprocs=8:ompthreads=2 
#
#          The above example allocates 32 cores over 2 nodes (16 on each node) to be used as  
#          8 MPI processes on each node and each MPI has 2 OpenMPI threads 
#          This would automatically set the environment variable OMP_NUM_THREADS=2 and it can easily be seen 
#          when using OpenMP with MPI that ompthreads multiplied by mpiprocs should equal ncpus if you want 
#          all MPI tasks to each have the same number of threads.
#
#
#
#          Chunk resources are requested in chunk specifications in a select statement. 
#          You can request chunk resources using any of the following:
#                 #PBS -l select=[N:][chunk specification][+[N:]chunk specification] directive
#                 If you do not specify N, the number of chunks, it is taken to be 1.
#                 For example, one chunk might have 2 CPUs and 4GB of memory:
#                 #PBS -l select=ncpus=2:mem=4gb
#                 For example, to request six of the previous chunk:
#                 #PBS -l select=6:ncpus=2:mem=4gb
#                 To request different chunks, concatenate the chunks using the plus sign (+)
#                 For example, to request two sets of chunks where one set of 6 chunks has 2 CPUs per chunk, 
#                 and one set of 3 chunks has 8 CPUs per chunk, and both sets have 4GB of memory per chunk:
#                 #PBS -l select=6:ncpus=2:mem=4gb+3:ncpus=8:mem=4GB
#
#                 No spaces are allowed between chunks.
#                 You must specify all your chunks in a single select statement.
#
#           HERE BELOW THE RESOURCES AT chunck-level
#
##PBS -l select=%%NUMNODES%%:ncpus=%%NUMCORES%%:mpiprocs=%%NUMMPIPROC%%:ompthreads=%%NUMTHREADS%%:mem=%%MAXRAM%%
#
#
#
#           HERE BELOW THE RESOURCES AT job-wide level 
#
#           Specify the maximum  run-time for the job, where walltime=HH:MM:SS
#           example:
#           #PBS -l walltime=2:00:00 (two hours at most)
#
##PBS -l walltime=%%HOW_MUCH_TIME_MAY_I_RUN%%
#
#
# -------------------------------------------------------------------
# --     Defines whether qsub shuld wait until the job ends       ---
#
#    The block job attribute controls blocking. 
#
#    Normally, when you submit a job, the qsub command exits after returning the ID of the new job. 
#    You can use the "-W block=true" option to qsub to specify that you want qsub to "block", 
#    meaning wait for the job to complete and report the exit value of the job.
#
#    If your job is successfully submitted, qsub blocks until the job terminates or an error occurs. 
#    If job submission fails, no special processing takes place.
#    If the job runs to completion, qsub exits with the exit status of the job. 
#    For job arrays, blocking qsub waits until the entire job array is complete, then returns 
#    the exit status of the job array.
#
#     #PBS -W block=true    ----> wait until the job ends
#     #PBS -W block=fasle   ----> return immediately after returning the ID of the new job
#
#PBS -W block=false
#
#
#
# -------------------------------------------------------------------
# --  Defines whether the job should depend on other jobs ends    ---
#     Job dependencies are not supported for subjobs or ranges of subjobs.
#     In case ofdependence on array job use full array identification Job_ID (e.g. 2354[]) 
#
#     Use the -W depend=dependency_lis option to qsub to define dependencies between jobs. 
#     The dependency_list has the format:
#                 type:arg_list[,type:arg_list ...]
#     where except for the on type, the arg_list is one or more PBS job IDs in the form:
#                 jobid[:jobid ...]
#     These are the available dependency types:
#
#        after:arg_list
#        This job may start only after all jobs in arg_list have started execution.
#
#        afterok:arg_list
#        This job may start only after all jobs in arg_list have terminated with no errors.
#
#        afternotok:arg_list
#        This job may start only after all jobs in arg_list have terminated with errors.
#
#        afterany:arg_list
#        This job may start after all jobs in arg_list have finished execution, with or without errors. 
#        This job will not run if a job in the arg_list was deleted without ever having been run.
#
#        before:arg_list
#        Jobs in arg_list may start only after specified jobs have begun execution. 
#        You must submit jobs that will run before other jobs with a type of on.
#
#        beforeok:arg_list
#        Jobs in arg_list may start only after this job terminates without errors.
#
#        beforenotok:arg_list
#        If this job terminates execution with errors, the jobs in arg_list may begin.
#
#        beforeany:arg_list
#        Jobs in arg_list may start only after specified jobs terminate execution, with or without errors. 
#        Requires use of on dependency for jobs that will run before other jobs.
#
#        on:count
#        This job may start only after count dependencies on other jobs have been satisfied. 
#        This type is used in conjunction with one of the before types. count is an integer greater than 0.
#
#        example: #PBS -W depend=afterany:16394:16395 
#
##PBS -W depend=afterany:%%LIST_OF_JOBID_DEPENDENCIES%%
#
#
#
#         PBS  DIRECTIVES HERE ABOVE
#
#=============================================================================================
#
#
#         START SOME DIAGNOSTIC FOR THE ENVIRONMENT
#
#    If you do not want to get the full diagnostic of the environment, you can comment 
#    the following lines. 
#
#
#
     echo -e "\n\n==============   ENVIRONMENT HERE BELOW ======================\n"
     echo -e "\n\n+================================================="
     echo -e "!             Here are some environment varaiables   " 
     echo -e "!                                                    " 
                 env  | grep -v "PBS_" | sed s/^/"!         "/g
     echo -e "!                                                    " 
     echo -e "+=====================================================\n\n"

cat <<EOF

+=============================================================================================  
|  
| LIST OF PBS ENVIRONMET VARIABLES YOU CAN USE IN THIS SCRIPT
|  
| General and environmental
|  
| Variable Name     Value at qsub Time
| PBS_VERSION=$PBS_VERSION
| PBS_ENVIRONMENT=$PBS_ENVIRONMENT
| PBS_O_LANG=$PBS_O_LANG
| PBS_O_TZ=$PBS_O_TZ
| PBS_O_PATH=$PBS_O_PATH
| PBS_O_SHELL=$PBS_O_SHELL
|  
| Host, queue and servers information
|  
| Variable Name     Value at qsub Time
| PBS_O_HOST=$PBS_O_HOST
| PBS_O_SERVER=$PBS_O_SERVER
| PBS_NODEFILE=$PBS_NODEFILE
| PBS_MOMPORT=$PBS_MOMPORT
| PBS_O_QUEUE=$PBS_O_QUEUE
| PBS_O_WORKDIR=$PBS_O_WORKDIR
| PBS_O_INITDIR=$PBS_O_INITDIR
| PBS_O_ROOTDIR=$PBS_O_ROOTDIR
| PBS_TMPDIR=$PBS_TMPDIR
|  
| Job identification
|  
| Variable Name     Value at qsub Time
| PBS_JOBNAME=$PBS_JOBNAME
| PBS_JOBID=$PBS_JOBID
| Array Jobs
|  
| Variable Name     Value at qsub Time
| PBS_ARRAY_INDEX=$PBS_ARRAY_INDEX
| PBS_ARRAY_ID=$PBS_ARRAY_ID
|  
| User identification
|  
| Variable Name     Value at qsub Time
| PBS_O_HOME=$PBS_O_HOME
| PBS_O_LOGNAME=$PBS_O_LOGNAME
| PBS_O_MAIL=$PBS_O_MAIL
|  
+=============================================================================================  

       EXPORTED VARIABLES IN THE JOB 

       Environment variables beginning with "PBS_O_" are created by qsub.  
       PBS automatically exports the following environment variables to  the
       job, and the job's Variable_List attribute is set to this list:

       PBS_ENVIRONMENT=$PBS_ENVIRONMENT
            Set to PBS_BATCH for a batch job.  Set to PBS_INTERACTIVE for an interactive job.  
            Created upon execution.

       PBS_JOBDIR=$PBS_JOBDIR
            Pathname of job's staging and execution directory on the primary execution host.

       PBS_JOBID=$PBS_JOBID
            Job identifier given by PBS when the job is submitted.  
            Created upon execution.

       PBS_JOBNAME=$PBS_JOBNAME
            Job name given by user.  
            Created upon execution.

       PBS_NODEFILE=$PBS_NODEFILE
            Name of file containing the list of nodes assigned to the job.  
            Created upon execution.

       PBS_O_HOME=$PBS_O_HOME
            User's home directory.  
            Value of HOME taken from user's submission environment.

       PBS_O_HOST=$PBS_O_HOST
            Name of submit host.  
            Value taken from user's submission environment.

       PBS_O_LANG=$PBS_O_LANG
            Value of LANG taken from user's submission environment.

       PBS_O_LOGNAME=$PBS_O_LOGNAME
            User's login name.  
            Value of LOGNAME taken from user's submission environment.

       PBS_O_MAIL=$PBS_O_MAIL
            Value of MAIL taken from user's submission environment.

       PBS_O_PATH=$PBS_O_PATH
            User's PATH.  
            Value of PATH taken from user's submission environment.

       PBS_O_QUEUE=$PBS_O_QUEUE
            Name of the queue to which the job was submitted.  
            Value taken from user's submission environment.

       PBS_O_SHELL=$PBS_O_SHELL
            Value taken from user's submission environment.

       PBS_O_SYSTEM=$PBS_O_SYSTEM
            Operating system, from uname -s, on submit host.  
            Value taken from user's submission environment.

       PBS_O_TZ=$PBS_O_TZ
            Value taken from user's submission environment.

       PBS_O_WORKDIR=$PBS_O_WORKDIR
            Absolute path to directory where qsub is run.  
            Value taken from user's submission environment.

       PBS_QUEUE=$PBS_QUEUE
            Name of the queue from which the job is executed.  
            Created upon execution.
  
       TMPDIR=$TMPDIR
            Pathname of job scratch directory.


+=============================================================================================  

EOF
     echo -e "\n\n==============   ENVIRONMENT HERE ABOVE ======================\n\n\n\n"
#
#
#         END OF SOME DIAGNOSTIC FOR THE ENVIRONMENT
#
#=============================================================================================
#
#         
#         +---------------------------------------------------+
#         |                                                   |
#         |     Here below some preliminary activity that     |
#         |     may be usefuls for the execution of your      |
#         |     script. If you want you can comment these     |
#         |     lines here below.                             |
#         |                                                   |
#         +---------------------------------------------------+
#
#
#
         cat << EOF
         +---------------------------------------------------+
         |                                                   |
         |     Here below some preliminary activity that     |
         |     may be usefuls for the execution of your      |
         |     script. If you want you can comment these     |
         |     lines in the script template.                 |
         |                                                   |
         +---------------------------------------------------+
EOF
#
#         Switch to the working directory
#
          cd $PBS_O_WORKDIR
          echo -e "\n\tWorking directory is: $PBS_O_WORKDIR"
          echo -e "\tWorking queue is: $PBS_QUEUE"
#
#         Calculate the number of processors allocated to this run.
#
          N_NODES="%%NUMNODES%%"        
          N_CPUS_NODE="%%NUMCORES%%"
          N_MPIPROCS="%%NUMMPIPROC%%"
          N_OMPTHREADS="%%NUMTHREADS%%"
          
          echo -e "\n\tAllocated resourses are:"
          echo -e "\t\tN_NODES=${N_NODES:=NULL}"
          echo -e "\t\tN_CPUS_NODE=${N_CPUS_NODE:=NULL}"
          echo -e "\n\tProcesses expexted to run are:"
          echo -e "\t\tN_MPIPROCS=${N_MPIPROCS:=NULL}"
          echo -e "\t\tN_OMPTHREAD=${N_OMPTHREADS:=NULL}"
          echo -e "\n\tOMP thread is set to:"
          echo -e "\t\tOMP_NUM_THREADS=${OMP_NUM_THREADS:-NULL}"
# 
#         Set the default value to mpi and threads number if not defined
#
          if [[ "$N_MPIPROCS" == "NULL" ]];then
             echo -e "\n\tThe number of mpi processes is not set (mpiprocs=NULL). I assume it is 1"
             N_MPIPROCS=1
          fi  
          if [[ "$N_OMPTHREADS" == "NULL" ]];then
             echo -e "\n\tThe number of OMP threads is not set (ompthreads=NULL). I assume it is 1"
             N_OMPTHREADS=1
          fi  
# 
#         Check consistency of OMP number of threads
#
          if [[ $N_OMPTHREADS -ne $OMP_NUM_THREADS ]];then
             echo -e "\n\tWARNING the number of OMP threads does not match!"
          fi

          NRESOURCES=$((${N_NODES}*${N_CPUS_NODE}))                      # Reserved cores
          NPROCESSES=$((${N_NODES}*${N_MPIPROCS}*${OMP_NUM_THREADS}))  # Expected processes

          if [[ $NRESOURCES -ge $NPROCESSES ]];then
             echo -e "\n\tN. of reserved cores ($NRESOURCES) >= N. of expected processes ($NPROCESSES). OK"
          else
             echo -e "\n\tWARNING YOU ARE GOING TO RUN IN HYPER-THREADING!!!!"
             echo -e "\tN. of reserved cores ($NRESOURCES)  < N. of expected processes ($NPROCESSES)."
          fi
#
#         Calculate the number of nodes allocated.
#
          NNODES=`uniq $PBS_NODEFILE | wc -l`
          NODESLIST="$(echo $(uniq $PBS_NODEFILE))"
#
#         Display some useful information
#
          echo -e "\n\tRunning on host `hostname` "
          echo -e "\tTime is `date` "
          echo -e "\tDirectory is `pwd` "
          echo -e "\tUsing ${NRESOURCES} processors across ${NNODES} nodes "
          echo -e "\tAllocated nodes are ${NODESLIST}"
          echo -e "\n\n\t====== END OF PRELIMINARY ACTIVITY ======\n\n\n"
#         
#         +---------------------------------------------------+
#         |                                                   |
#         |     Here is an help omn how to run parallel       |
#         |     and serial programs.                          |
#         |                                                   |
#         +---------------------------------------------------+
#
#         For parallel executables (e.g. my-openmpi-program) do as follow.
#         OpenMPI will automatically launch processes on all allocated nodes.
#
#           MPIRUN=$(which mpirun) 
#           ${MPIRUN} -machinefile $PBS_NODEFILE -np ${NPROCESSES} my-openmpi-program
#
#
#         For serial executables (e.g. $HOME/my-program) do as follow.
#
#           $HOME/my-program
#
#
#
#         *****************************************************
#         *                                                   *
#         *                                                   *
#         *           HERE BELOW YOUR SCRIPT STARTS           *
#         *                                                   *
#         *                                                   *
#         *****************************************************
#
#         Some suggestion on the exit status. It would be helpful to manage 
#         the exist status to have only two possible values. They are:
#
#            0 = job executed correctly
#            1 = impossible to do the job as expected
#
#
#
# -----------------------------------------------------------------
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
      # if a logical AND (&&) or OR (||) result in a non-zero exit code, or when a command 
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
#         LOAD MODULES REQUIRED FOR THIS JOB
#
#     module purge   # Clean all modules that may be loaded
#     module load    # Load modules you need
#     module list    # List modules (for diagnostic purposes only)
#     module show    # Show wath modules manage (for diagnostic purposes only)
#
#
# -----------------------------------------------------------------
#
#                    CONSTANTS AND PARAMENTERS
#
#     Remember to define the default exit status parameter EXIT_STATUS
#
      EXIT_STATUS=0

#
# -----------------------------------------------------------------
#
#
#                     FUNCTIONS HERE BELOW    
#
# !!! Be careful in using finction if trap are activated because you may  !!!
# !!! miss something. Otherwise you have to explicitly repeat the trap in !!! 
# !!! the functions to ensure portability                                 !!!
#


# -----------------------------------------------------------------
#
#
#                     MAIN SCRIPT HERE BELOW    
#









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
#             
#----------------------------------------------------------------------------------------
#    SOME DIAGNOSTIC INFORMATION HERE BELOW
#
#     Write the full a summary of the resources used for this job
#
      echo -e "\n\n --------------------------------------------------\n"
      echo -e "  HERE BELOW YOU FIND A SUMMARY OF THE RESOURCES HAVE BEEN\n"
      echo -e "                   USED TO RUN THIS JOB \n\n             "
      echo -e "  To get more details use the following command:  \n\n\t\tqstat -xf $PBS_JOBID"
      echo -e "\n ----------------------------------------------------\n"

      exit $EXIT_STATUS
#
################################################################################
#
# END of the job script here 
#
################################################################################
#
