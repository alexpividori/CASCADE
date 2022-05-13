#******************************************************************************
#
# DESCRIPTION:      Instead of a boxplot, this script places 
#                   on an xy Cartesian diagram a changing color
#                   marker for different SHYFEM simulation in correspondance
#                   of the median value
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

#======================= Salinity VERSION ===========================

args <- commandArgs(trailingOnly = TRUE)

 gr=args[1]
 se=args[2]
 input_dir=args[3]
 output_dir=args[4]
 simulation_codes <- eval(parse(text=args[5]))

#======================================================================
# input_dir defines the pre_initialization_file.txt corresponding line

se_label=se

 info_file  <- read.csv2( paste( "./shyfem_" , simulation_codes[1] , "/" , 
               input_dir , "/selected_S_files_bydepth.txt", sep="") , header=FALSE , dec=".")  # this command only read

                                                                # informations one for all
 info_dim   <- dim(info_file)

 depth_inf  <- info_file[,2]
 depth_sup  <- info_file[,3]
 x_names    <- paste( info_file[,2] , "\U00F7" , info_file[,3] , sep="" )
 file_names <- info_file[,1]

 pdf(file = paste( output_dir ,"/median_multi-diagram_SHY_S_" , gr , ".pdf", sep="" ) )

#======== Look for y axis limits ========
y_min=100 #dummy values
y_max=-100

for (i in 1:info_dim[1]){
for (j in 1:length(simulation_codes) ){
a <- read.table( paste( "shyfem_", simulation_codes[j]  ,"/", input_dir ,"/", file_names[i] , sep="" ) , header=FALSE , sep=";")

if ( median(a[,8] - a[,7] ) < y_min ){
y_min <- median(a[,8] - a[,7])
}

if ( median(a[,8] - a[,7] ) > y_max ){
y_max <- median(a[,8] - a[,7])
}

}}

#========================================

for (i in 1:info_dim[1]){  # loop on depth ranges 1-3   3-5   5-10 ecc

  for (j in 1:length(simulation_codes) ){ # cycle on different simulations 
    
    a <- read.table( paste( "shyfem_", simulation_codes[j]  ,"/", input_dir ,"/", file_names[i] , sep="" ) , header=FALSE , sep=";") 

#=============================================================================

	if ( j==1 && i==1 ){
        par(oma=c(0, 0, 0, 7))
	plot( depth_inf[i] + (depth_sup[i] - depth_inf[i])/2  , median(a[,8] - a[,7] )  ,
              col="black",
              bg=j,
              pch=21,  
              lwd=0.2,
              xlim=c( min(depth_inf + (depth_sup - depth_inf)/2)-0.5 , max(depth_inf + (depth_sup - depth_inf)/2)+0.5 ),
              ylim=c( y_min-1 , y_max+1 ),
              xaxt='n',
              xlab="Depth[m]",
              ylab="Shind-Smeas [PSU]",
              main=paste("SHYFEM model (Shind-Smeas) Median value \n Stations:", gr , " Period:", se_label )
              )
	} else {
	points(depth_inf[i] + (depth_sup[i] - depth_inf[i])/2 , median(a[,8] - a[,7] ), pch = 21, lwd=0.2 , bg=j, col="black" )
	}
#=============================================================================

}
}

abline(h=0, col="black" , lty=2 )
abline(h=(seq(-10,-0.5, 0.5)), col="black", lty="dotted")
abline(h=(seq( 0.5, 10, 0.5)), col="black", lty="dotted")

axis(1 , at=depth_inf + (depth_sup - depth_inf)/2, labels=x_names )
legend( "topright" ,inset=c(-0.38,0), legend=simulation_codes , xpd=NA , 
      title="SHYFEM model run" , pch=19 , cex=0.8, col=1:length(simulation_codes) , bg="white")
