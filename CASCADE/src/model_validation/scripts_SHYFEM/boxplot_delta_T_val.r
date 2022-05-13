#******************************************************************************
#
# DESCRIPTION:      This R script read a collection of in-situ measured and 
#                   hindcast simulated data ( by COPERNICUS-Marine service)
#                   and represent in a scatter plot the delta value
#                   of temperature of salinity in function of depth.
#                   The depth goes 0.25 m by 0.25 m depth.
# EXTERNAL CALLS:   none.
#
# EXTERNAL FILES:   - .txt: CSV file containing data collected on different columns for single samples
#
#
# DEVELOPER:         Alex Pividori (alex.pividori@arpa.fvg.it)
#                    ARPA FVG - S.O.C. Stato dell'Ambiente - CRMA
#                    "AdriaClim" Interreg IT-HR project
#
# SOFTWARE VERSION: R version r/3.5.2/intel/19.1.1.217-nyr7hab
#
#
# CREATION DATE:    09/08/2021
#
# MODIFICATIONS:    10/08/2021 --> Addition of mode function
#
# VERSION:          0.1.
#
#******************************************************************************

#======================= Temperature VERSION ===========================

args <- commandArgs(trailingOnly = TRUE)

 gr=args[1]
 se=args[2]
 input_dir=args[3]
 output_dir=args[4]

#======================================================================

se_label=se            


info_file  <- read.csv2( paste( input_dir , "/selected_T_files_bydepth.txt", sep="") , header=FALSE , dec="." ) 
                                                                                                                      # .csv2 ise used
 info_dim  <- dim(info_file)                                                                                          # when the separator is ";"

# initialization

colors_rgb <- 1:info_dim[1]

depth_inf  <- info_file[,2]
depth_sup  <- info_file[,3]
file_names <- info_file[,1]
x_names    <- paste( info_file[,2] , "\U00F7" , info_file[,3] , sep="" )

for (i in 1:info_dim[1]){
       data_name <- paste("a_" , i , sep="")
    assign( data_name , read.table( paste( input_dir , "/" , file_names[i] , sep="" ) , header=FALSE , sep=";") )
    colors_rgb[i] = as.numeric(i/info_dim[1])  
}

date_start = min(as.Date(a_1[,4]))
date_fin   = max(as.Date(a_1[,4]))

pdf(file = paste( output_dir , "/boxplot_SHY_T_" , gr , ".pdf", sep="" ) )

if ( info_dim[1] == 6 ) {

boxplot( a_1[,8] - a_1[,7] , a_2[,8] - a_2[,7] , a_3[,8] - a_3[,7], a_4[,8] - a_4[,7] , a_5[,8] - a_5[,7] , a_6[,8] - a_6[,7] ,
        main=paste( "SHYFEM Thind-Tmeas \n Data:", gr ," Period:", se_label ),
#        width=c(0.2,0.2,0.2,0.2,0.2,0.2),
        xlab="Depth[m]" ,
#        xlim=c(min(depth_inf),max(depth_sup)) ,
#        ylim=c( -3 , 8.5 ),
        ylab=paste("Th-Tm [\U00B0", "C]", sep=""),
        at=depth_inf + (depth_sup - depth_inf)/2 ,
        col=rgb(colors_rgb , 1.0 - colors_rgb , 0.0) ,
        sub=paste("Collected Data: from" , date_start , "to" , date_fin ),
        names=x_names )
        mean_val=c( mean(a_1[,8] - a_1[,7]), mean(a_2[,8] - a_2[,7]) , mean(a_3[,8] - a_3[,7]),  mean(a_4[,8] - a_4[,7]),
                    mean(a_5[,8] - a_5[,7]) , mean(a_6[,8] - a_6[,7]) )

} else if ( info_dim[1] == 5 ) {

boxplot( a_1[,8] - a_1[,7] , a_2[,8] - a_2[,7] , a_3[,8] - a_3[,7], a_4[,8] - a_4[,7] , a_5[,8] - a_5[,7] ,
        main=paste( "SHYFEM Thind-Tmeas \n Data:", gr ," Period:", se_label ),
#        width=c(0.2,0.2,0.2,0.2,0.2),
        xlab="Depth[m]" ,
#        xlim=c(2,24.5) ,
#        ylim=c( -3 , 8.5 ),
        ylab=paste("Th-Tm [\U00B0", "C]", sep=""),
        at=depth_inf + (depth_sup - depth_inf)/2 ,
        col=rgb(colors_rgb , 1.0 - colors_rgb , 0.0) ,
        sub=paste("Collected Data: from" , date_start , "to" , date_fin ),
        names=x_names )
        mean_val=c( mean(a_1[,8] - a_1[,7]), mean(a_2[,8] - a_2[,7]) , mean(a_3[,8] - a_3[,7]),  mean(a_4[,8] - a_4[,7]), mean(a_5[,8] - a_5[,7]) )

} else if ( info_dim[1] == 4 ) {

boxplot( a_1[,8] - a_1[,7] , a_2[,8] - a_2[,7] , a_3[,8] - a_3[,7], a_4[,8] - a_4[,7] ,
        main=paste( "SHYFEM Thind-Tmeas  \n Data:", gr ," Period:", se_label ),
 #       width=c(0.2,0.2,0.2,0.2),
        xlab="Depth[m]" ,
      #  xlim=c(min(depth_inf),max(depth_sup)) ,
#        ylim=c( -3 , 8.5 ),
        ylab=paste("Th-Tm [\U00B0", "C]", sep=""),
        at=depth_inf + (depth_sup - depth_inf)/2 ,
        col=rgb(colors_rgb , 1.0 - colors_rgb , 0.0) ,
        sub=paste("Collected Data: from" , date_start , "to" , date_fin ),
        names=x_names )
        mean_val=c( mean(a_1[,8] - a_1[,7]), mean(a_2[,8] - a_2[,7]) , mean(a_3[,8] - a_3[,7]),  mean(a_4[,8] - a_4[,7]) )

} else if ( info_dim[1] == 3 ) {

boxplot( a_1[,8] - a_1[,7] , a_2[,8] - a_2[,7] , a_3[,8] - a_3[,7],
        main=paste( "SHYFEM Thind-Tmeas  \n Data:", gr ," Period:", se_label ),
#        width=c(0.2,0.2,0.2),
        xlab="Depth[m]" ,
#        xlim=c(2,24.5) ,
#        ylim=c( -3 , 8.5 ),
        ylab=paste("Th-Tm [\U00B0", "C]", sep=""),
        at=depth_inf + (depth_sup - depth_inf)/2 ,
        col=rgb(colors_rgb , 1.0 - colors_rgb , 0.0) ,
        sub=paste("Collected Data: from" , date_start , "to" , date_fin ),
        names=x_names )
        mean_val=c( mean(a_1[,8] - a_1[,7]), mean(a_2[,8] - a_2[,7]) , mean(a_3[,8] - a_3[,7]) )
}

abline(h=(seq(-15,-1, 1)), col="black", lty="dotted")
abline(h=(seq( 1, 15, 1)), col="black", lty="dotted")

# mean_tot is the mean on the total periodi considered (2020-07 to 2021-07)

#if        ( gr=="group1" ){
#mean_tot=c( 0.37 , 0.04 , 0.42 , 1.16 )
#} else if ( gr=="group2" ){
#mean_tot=c(0.35 , 0.59 , 1.51 )
#} else if ( gr=="group3" ){
#mean_tot=c(-0.36 , -0.42 , 0.06 , 0.98 , 1.79 , 2.22)
#} else if ( gr=="tot"    ){
#mean_tot=c( 0.00 , -0.06 , 0.42 , 1.04 , 1.79 , 2.22)
#} 

#======================================================================

  labels_val=round( mean_val , digits=2 )

#if ( se=="tot") {
#points(depth_inf + (depth_sup - depth_inf)/2 , mean_val, pch = 21, col="black", bg="red" )
#legend( "topright", legend=c("Annual mean"), col=c("red"), pch=c(19) , cex=1.0, bg="white" )
#} else {
points(depth_inf + (depth_sup - depth_inf)/2 , mean_val, pch = 21, col="black", bg="blue")
#points(depth_inf + (depth_sup - depth_inf)/2 , mean_tot, pch = 21, col="black", bg="red" )
#text(depth_inf + (depth_sup - depth_inf)/2 , mean_tot, labels=mean_tot     , font=2, cex=0.75, adj=c(-0.5,0) )
legend( "topright", legend=c("Mean value"), col=c("blue"), pch=c(19) , cex=1.0, bg="white" )
#}

text(depth_inf + (depth_sup - depth_inf)/2 , mean_val, labels=labels_val   , font=2, cex=0.75, adj=c(-0.5,0) )

abline(h=0, col="black" , lty=2 )
