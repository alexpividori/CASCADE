#******************************************************************************
#
# DESCRIPTION:      This R script read a collection of in-situ measured and 
#                   hindcast simulated data ( by COPERNICUS-Marine service)
#                   and represent in a scatter plot the absolute value
#                   of temperature or salinity in function of depth.
#                   The depth goes 0.25 m by 0.25 m
# EXTERNAL CALLS:   none.
#
# EXTERNAL FILES:   - prova1.txt: CSV file containing data collected on different columns for single samples
#
#
# DEVELOPER:         Alex Pividori (alex.pividori@arpa.fvg.it)
#                    ARPA FVG - S.O.C. Stato dell'Ambiente - CRMA
#                    "AdriaClim" Interreg IT-HR project
#
# SOFTWARE VERSION: R version r/3.5.2/intel/19.1.1.217-nyr7hab
#
#
# CREATION DATE:    19/10/2021
#
# MODIFICATIONS:    19/10/2021 --> Last version of ecflow adaption
#
# VERSION:          0.1.
#
#******************************************************************************

args <- commandArgs(trailingOnly = TRUE)

  gr=args[1]
  se=args[2]
  input_dir=args[3]
  output_dir=args[4]

se_label=se

#======================= TEMPERATURE VERSION ===========================

a <- read.table( paste( input_dir , "/TEMP_total_data.txt", sep="" ) , header=FALSE , sep=";")
date_start = min(as.Date(a[,4]))
date_fin   = max(as.Date(a[,4]))

pdf(file = paste( output_dir , "/scatter_T_" , gr , ".pdf", sep="" ) )

plot( a[,7], a[,6] ,    # y-values are the depths, x-values instead are the measured temperature 
        xlab=paste("Temperature [\U00B0", "C]" ,sep="") , 
        ylab="Depth [m]" ,
        ylim = rev(range(a[,6])),
        pch=20,
        cex.main=2, cex.lab=1.3, cex.sub=1.0,
        col="red")

axis(3, at=c(7:30) , labels=c(7:30) , las=0  )
title( main=paste("Temperature scatter plot" , " Data:", gr ," Period:", se_label) , line=2.4 , cex.main=1.1 , outer=FALSE )
title( sub=paste("Time period: from ",date_start," to ",date_fin , sep="" )  )

abline(h=(seq(0,30, 5)), col="black", lty="dotted")

