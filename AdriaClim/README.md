# AdriaClim
This is the AdriaClim (INTERREG IT-HR) project repository for PP11 - ARPA FVG purposes. The main directory is composed by following sub folders:

* **data** -- storing data, that is: measurements, model outputs, post elaborations, and so on. This foleder is not under version: see .gitignore 
* **doc** -- storing general purpose documentation files. The documentation specific for each code is available in the subfolders of src. 
* **ecflow_server** -- storing the log files of ecFlow server. This foleder is not under version: see .gitignore 
* **src** -- storing codes and all files that are under version. This folder is split in sub folders according to the specific tools

## Important notes in adding news sub folders
If news folders are going to be added, remember to consider whether they need to be versioned or not. So do not put stuff under **src** or **doc** if it won't be versioned. Furthermore, new sub directories placed at the top level should be exluded by way of .gitignore, if files in them do not require versioning.

## Further details on subdirectories content

  **data** --Root directory
  
   \+-- **shyfem_inputs**     --         Input files for SHYFEM model runs 
   
   \+---- **cnr-ismar**        --         The inputs released by CMR ISMAR




