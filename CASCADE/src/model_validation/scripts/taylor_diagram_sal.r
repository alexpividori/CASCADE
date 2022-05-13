#******************************************************************************
#
# DESCRIPTION:      This R script realize a Taylor diagram comparing 
#                   in-situ measured data and CMEMS model data. The 
# EXTERNAL CALLS:   none.
#
# EXTERNAL FILES:   - .txt: CSV file containing data collection for a particular 
#                    depth level or small range of levels of temperature or 
#                    salinity (or somethung else)
#
#
# DEVELOPER:         Alex Pividori (alex.pividori@arpa.fvg.it)
#                    ARPA FVG - S.O.C. Stato dell'Ambiente - CRMA
#                    "AdriaClim" Interreg IT-HR project
#
# SOFTWARE VERSION: R version r/3.5.2/intel/19.1.1.217-nyr7hab
#
#
# CREATION DATE:    08/10/2021
#
# MODIFICATIONS:    08/10/2021 --> Intermediate version
#
# VERSION:          0.1.
#
#******************************************************************************

# This package is necessary to realize the Taylor Diagrams

library(plotrix)

#======================= Temperature VERSION ===========================

args <- commandArgs(trailingOnly = TRUE)

         gr=args[1]
         se=args[2]
  input_dir=args[3]
 output_dir=args[4]

#======================================================================

se_label=se            

info_file  <- read.csv2( paste( input_dir , "/selected_S_files_bydepth.txt", sep="") , header=FALSE , dec=".")
 info_dim  <- dim(info_file)

colors_rgb <- 1:info_dim[1]

depth_inf  <- info_file[,2]
depth_sup  <- info_file[,3]
   x_names <- paste( info_file[,2] , "÷" , info_file[,3] , sep="" )
file_names <- info_file[,1]

for (i in 1:info_dim[1]){

    data_name <- "a"
    assign( data_name , read.table( paste( input_dir ,"/", file_names[i] , sep="" ) , header=FALSE , sep=";") )
    colors_rgb[i] = as.numeric(i/info_dim[1])  

    date_start = min(as.Date(a[,4]))
    date_fin   = max(as.Date(a[,4]))
    bottom_depth = max(depth_sup[i])

pdf(file = paste( output_dir ,"/taylor_diagram_sal_" , gr , "_" , date_start , "_to_" , date_fin , "_" , x_names[i] , ".pdf", sep="" ) )

#=============================================================================

taylor.diagram( ref=a[,7]  ,  model=a[,8] ,
               add=FALSE,
               col="red",
               pch=19,
               pos.cor=TRUE,
               xlab="Standard Deviation [PSU]",
               ylab="Standard Deviation [PSU]",
               main=paste("Salinity Taylor Diagram \n Data:", gr , "Period:" , se_label ),
               show.gamma=TRUE,
               sd.arcs=TRUE,
               ref.sd=TRUE,
               ngamma=3,
               gamma.col=8,
               normalize=FALSE,
               sd.method="sample")

#=============================================================================

legend( "topright",legend=paste( info_file[i,2] , "\U00F7" , info_file[i,3] , "m"),pch=19,col="red") # (lpos,lpos) is an (x,y) position
                                                                # external to Taylor Diagram

remove(a)

}

