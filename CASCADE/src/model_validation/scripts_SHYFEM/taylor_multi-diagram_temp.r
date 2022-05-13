#******************************************************************************
#
# DESCRIPTION:      This R script realize a Taylor diagram comparing 
#                   different SHYFEM simulations
# 
# EXTERNAL CALLS:   none.
#
# EXTERNAL FILES:   - The external ASCII files read by this R script 
#                    are contained inside selected_depths_# in different 
#                    shyfem_XXXXXXXXXX directories
#
# DEVELOPER:         Alex Pividori (alex.pividori@arpa.fvg.it)
#                    ARPA FVG - S.O.C. Stato dell'Ambiente - CRMA
#                    "AdriaClim" Interreg IT-HR project
#
# SOFTWARE VERSION: R version r/3.5.2/intel/19.1.1.217-nyr7hab
#
#
# CREATION DATE:    09/11/2021
#
# MODIFICATIONS:    09/11/2021 --> Entire definitive version
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
 simulation_codes <- eval(parse(text=args[5]))

#======================================================================

se_label=se

                info_file  <- read.csv2( paste( "./shyfem_" , simulation_codes[1] , "/" , 
                              input_dir , "/selected_T_files_bydepth.txt", sep="") , header=FALSE , dec=".")  # this command only read
                                                                # informations one for all
 info_dim  <- dim(info_file)

 depth_inf  <- info_file[,2]
 depth_sup  <- info_file[,3]
 x_names <- paste( info_file[,2] , "-" , info_file[,3] , sep="" )
 file_names <- info_file[,1]

for (i in 1:info_dim[1]){  # ralize n taylor diagrams one for each depth level

   pdf(file = paste( output_dir ,"/taylor_multi-diagram_SHY_T_" , gr , "_" , x_names[i]  , ".pdf", sep="" ) )

  for (j in 1:length(simulation_codes) ){ # cycle on different simulations 

    data_name <- "a"
    assign( data_name , read.table( paste( "shyfem_", simulation_codes[j]  ,"/", input_dir ,"/", file_names[i] , sep="" ) , header=FALSE , sep=";") )

#=============================================================================

if ( j==1 ){
taylor.diagram( ref=a[,7]  ,  model=a[,8] ,
              add=FALSE,
              col=j,
              pch=19,
              pos.cor=TRUE,
              xlab=paste("Standard Deviation [\U00B0" , "C]", sep=""),
              ylab=paste("Standard Deviation [\U00B0" , "C]", sep=""),
              main=paste("Temperature Taylor Diagram \n Stations:", gr , "Period:", se_label ,"Depth:", info_file[i,2] , "\U00F7" , info_file[i,3] , "m"),
              show.gamma=TRUE,
              sd.arcs=TRUE,
              ref.sd=TRUE,
              ngamma=3,
              gamma.col=8,
              normalize=FALSE,
              sd.method="sample")
 } else {

taylor.diagram( ref=a[,7]  ,  model=a[,8] ,
               add=TRUE,
               col=j )

}
#=============================================================================

remove(a)

}

legend( "topright", legend=simulation_codes , title="SHYFEM model simulations" , pch=19 , cex=0.8 , col=1:length(simulation_codes) )
       # external to Taylor Diagram

}
