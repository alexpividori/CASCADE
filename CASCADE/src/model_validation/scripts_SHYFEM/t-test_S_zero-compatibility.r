# t-test for Temp
# this sampre script have the aim to validate the null hypothesis H0 that the delta T values are 
# equaly spaced from positive and negative values and their mean values are 0. In other words if the
# delta T distribution is compatible with 0 °C values or if the is a sistematic error.

gr="group1"
se="season4"
output_dir="p_values_group_seasons"

#==========================================

info_file  <- read.csv2( paste( "./selected_depths_" , gr ,"_", se, "/selected_S_files_bydepth.txt" , sep="") , header=FALSE )
 info_dim  <- dim(info_file)

file_names <- 1:info_dim[1]
depth_inf  <- 1:info_dim[1]
depth_sup  <- 1:info_dim[1]
x_names    <- 1:info_dim[1]


for (i in 1:info_dim[1]){

    file_names[i] = toString(info_file[i,1])
    depth_inf[i]  = info_file[i,2]
    depth_sup[i]  = info_file[i,3]
   
       camp_1 <- read.table( paste( "./selected_depths_", gr , "_" , se ,"/" , file_names[i] , sep="" ) , header=FALSE , sep=",") 
   x_names[i] = paste( info_file[i,2] , "÷" , info_file[i,3] , sep="" )

    sink(paste( output_dir ,"/p-values_sal_zero.comp_", gr , "_", se ,".txt", sep="" ) , append=TRUE ) 
      print(paste("t-test PSAL ",gr , se , ": null hipotesys (compatibility with 0), 
            alternative hypotesis: two sided sistematic error, conf.level=95%") )
      print( paste( gr , se , ": Depth range " , x_names[i] ))
      print( t.test( camp_1[,8] - camp_1[,7] , mu=0.0 , alternative='two.sided' , conf.level=0.95 ) ) 
    sink()

    remove(camp_1)   # cause the number of elements could change 
}
