from netCDF4 import Dataset as NetCDFFile 
import matplotlib.pyplot as plt
import numpy as np
import datetime
import bottleneck  
import sys
import os.path

point_name  = sys.argv[1]
lat_ref     = float(sys.argv[2])  
lon_ref     = float(sys.argv[3])

data_arc_dir='/lustre/arpa/AdriaClim/data/EURO-CORDEX/FVG' 
output_arc_dir="/lustre/arpa/AdriaClim/public_html/EURO_CORDEX_analysis/SCENARIO/boxplot_annual_pr"

#============= lat/lon indexes =============

f_nc        =  NetCDFFile( data_arc_dir+"/1_HadGEM2-ES_RACMO22E"+"/postproc/monthly/"+"pr_HadGEM2-ES_RACMO22E_rcp26_mon_future.nc" , mode='r')
lat_proof   =  f_nc.variables['lat'][:]
lon_proof   =  f_nc.variables['lon'][:]


for i in range( len(lat_proof) ):
        if ( abs(lat_proof[i] - lat_ref ) < 0.01 ):
           lat_idx=i
           break

for i in range( len(lon_proof) ):
        if ( abs(lon_proof[i] - lon_ref ) < 0.01 ):
           lon_idx=i
           break

del lat_proof, lon_proof 
#===========================================

var26_2015 = []
var26_2030 = []
var26_2040 = []
var26_2050 = []
var26_2060 = []
var26_2070 = []
var26_2080 = []
var26_2090 = []

var45_2015 = []
var45_2030 = []
var45_2040 = []
var45_2050 = []
var45_2060 = []
var45_2070 = []
var45_2080 = []
var45_2090 = []

var85_2015 = []
var85_2030 = []
var85_2040 = []
var85_2050 = []
var85_2060 = []
var85_2070 = []
var85_2080 = []
var85_2090 = []

#============= Acquisition of variable data from all netCDF set ===============

i=1

for model in [ "HadGEM2-ES_RACMO22E", "MPI-ESM-LR_REMO2009", "EC-EARTH_CCLM4-8-17", "EC-EARTH_RACMO22E", "EC-EARTH_RCA4"]:

	#******* Reading netCDF file
	file_path26=data_arc_dir+'/'+str(i)+"_"+model+"/postproc/monthly/"+"pr_"+model+"_rcp26_mon_future.nc"
	file_path45=data_arc_dir+'/'+str(i)+"_"+model+"/postproc/monthly/"+"pr_"+model+"_rcp45_mon_future.nc"
	file_path85=data_arc_dir+'/'+str(i)+"_"+model+"/postproc/monthly/"+"pr_"+model+"_rcp85_mon_future.nc"

	if ( not os.path.isfile( file_path26 ) ) and ( not os.path.isfile( file_path45 ) ) and ( not os.path.isfile( file_path85 ) ):
		print("File"+file_path26+" "+file_path45+" "+file_path85+" doesn't exists or is corrupted")
		i+=1
		continue

	f_nc26     = NetCDFFile( file_path26 , mode='r')     # I have to insert the two subdirectories intermedian /postproc/monthly/
	var26      = f_nc26.variables['pr'][:,lat_idx,lon_idx]

	f_nc45     = NetCDFFile( file_path45 , mode='r')     
	var45      = f_nc45.variables['pr'][:,lat_idx,lon_idx]

	f_nc85     = NetCDFFile( file_path85 , mode='r')     
	var85      = f_nc85.variables['pr'][:,lat_idx,lon_idx]

	for j in range(0,11):                     # j goes from 0 to 10. for a total of  11 year (ex. from 2025 to 2035 )
		var26_2015.append( sum( var26[ ( 48 + j*12  ) : (   48 + j*12    + 13 ) ]*30.42)  )
		var26_2030.append( sum( var26[ ( 228 + j*12 ) : ( ( 228 + j*12 ) + 13 ) ]*30.42)  )
		var26_2040.append( sum( var26[ ( 348 + j*12 ) : ( ( 348 + j*12 ) + 13 ) ]*30.42)  )
		var26_2050.append( sum( var26[ ( 468 + j*12 ) : ( ( 468 + j*12 ) + 13 ) ]*30.42)  )
		var26_2060.append( sum( var26[ ( 588 + j*12 ) : ( ( 588 + j*12 ) + 13 ) ]*30.42)  )
		var26_2070.append( sum( var26[ ( 708 + j*12 ) : ( ( 708 + j*12 ) + 13 ) ]*30.42)  )
		var26_2080.append( sum( var26[ ( 828 + j*12 ) : ( ( 828 + j*12 ) + 13 ) ]*30.42)  )
		var26_2090.append( sum( var26[ ( 948 + j*12 ) : ( ( 948 + j*12 ) + 13 ) ]*30.42)  )
		

		var45_2015.append( sum( var45[ ( 48 + j*12 )  : ( 48 + j*12 + 13 ) ]*30.42 )  )
		var45_2030.append( sum( var45[ ( 228 + j*12 ) : ( ( 228 + j*12 ) + 13 ) ]*30.42)  )
		var45_2040.append( sum( var45[ ( 348 + j*12 ) : ( ( 348 + j*12 ) + 13 ) ]*30.42)  )
		var45_2050.append( sum( var45[ ( 468 + j*12 ) : ( ( 468 + j*12 ) + 13 ) ]*30.42)  )
		var45_2060.append( sum( var45[ ( 588 + j*12 ) : ( ( 588 + j*12 ) + 13 ) ]*30.42)  )
		var45_2070.append( sum( var45[ ( 708 + j*12 ) : ( ( 708 + j*12 ) + 13 ) ]*30.42)  )
		var45_2080.append( sum( var45[ ( 828 + j*12 ) : ( ( 828 + j*12 ) + 13 ) ]*30.42)  )
		var45_2090.append( sum( var45[ ( 948 + j*12 ) : ( ( 948 + j*12 ) + 13 ) ]*30.42)  )

		var85_2015.append( sum( var85[ ( 48 + j*12 )  : ( 48 + j*12 + 13 ) ]*30.42 )  )
		var85_2030.append( sum( var85[ ( 228 + j*12 ) : ( ( 228 + j*12 ) + 13 ) ]*30.42)  )
		var85_2040.append( sum( var85[ ( 348 + j*12 ) : ( ( 348 + j*12 ) + 13 ) ]*30.42)  )
		var85_2050.append( sum( var85[ ( 468 + j*12 ) : ( ( 468 + j*12 ) + 13 ) ]*30.42)  )
		var85_2060.append( sum( var85[ ( 588 + j*12 ) : ( ( 588 + j*12 ) + 13 ) ]*30.42)  )
		var85_2070.append( sum( var85[ ( 708 + j*12 ) : ( ( 708 + j*12 ) + 13 ) ]*30.42)  )
		var85_2080.append( sum( var85[ ( 828 + j*12 ) : ( ( 828 + j*12 ) + 13 ) ]*30.42)  )
		if ( "pr_"+model+"_rcp85_mon_future.nc" != "pr_MPI-ESM-LR_REMO2009_rcp85_mon_future.nc" ):
			var85_2090.append( sum( var85[ ( 948 + j*12 ) : ( ( 948 + j*12 ) + 13 ) ]*30.42)  )


	del var26, var45, var85
	i+=1

#*********** Number of models count *************

Dot_n26 = 0
Dot_n45 = 0
Dot_n85 = 0

for i in range( len(var26_2015) ):
	if ( not type(var26_2015[i]) == np.ma.core.MaskedConstant ):
		Dot_n26 += 1

for i in range( len(var45_2015) ):
        if ( not type(var45_2015[i]) == np.ma.core.MaskedConstant ):
                Dot_n45 += 1

for i in range( len(var85_2015) ):
        if ( not type(var85_2015[i]) == np.ma.core.MaskedConstant ):
                Dot_n85 += 1

Mod26_n = int( Dot_n26 / 11 )
Mod45_n = int( Dot_n45 / 11 )
Mod85_n = int( Dot_n85 / 11 )

#=====================================================
#                 Boxplot creation
#=====================================================

fig , ax = plt.subplots(figsize=(20,15))

plt.title("Cumulative yearly precipitations scenario at point: "+point_name+"\n" , fontsize=30, fontdict={'family':'serif'} )
plt.xlabel("\nDecade", fontsize=25 )
plt.ylabel( "Cumulative precipitations [$mm/year$]", fontsize=25 )
plt.yticks(fontsize=18 )
plt.xticks(fontsize=18 )
plt.grid( linestyle='--')
plt.axis([ 0 , 25 , 500 , 4000 ])

bp85 = ax.boxplot( ( var85_2015 , var85_2030 , var85_2040 , var85_2050 , var85_2060 , var85_2070 , var85_2080 , var85_2090 )  ,
                positions=[ 2.7, 5.7, 8.7, 11.7, 14.7, 17.7, 20.7,23.7], widths=0.5, patch_artist=True,
                showmeans=True, showfliers=True,
                medianprops={"color": "black", "linewidth": 3. },
                boxprops={"facecolor": "r", "edgecolor": "black",
                          "linewidth": 0.5},
                whiskerprops={"color": "black", "linewidth": 2. },
                capprops={"color": "black", "linewidth": 2. } ,
                meanprops={ "markerfacecolor": "blue", "marker":"o" , "markersize":10., "markeredgecolor":'black' } ,
                labels=("","","","","","","","") , manage_ticks=False )


bp45  = ax.boxplot( ( var45_2015 , var45_2030 , var45_2040 , var45_2050 , var45_2060 , var45_2070 , var45_2080 , var45_2090 )  ,
               positions=[ 2, 5, 8, 11, 14, 17, 20,23], widths=0.5, patch_artist=True,
                showmeans=True, showfliers=True,
                medianprops={"color": "black", "linewidth": 3. },
                boxprops={"facecolor": "yellow", "edgecolor": "black",
                          "linewidth": 0.5},
                whiskerprops={"color": "black", "linewidth": 2. },
                capprops={"color": "black", "linewidth": 2. } ,
                meanprops={"markerfacecolor": "blue", "marker":"o" , "markersize":10. , "markeredgecolor":'black' } ,
                labels=("2010-2020","2025-2035","2035-2045","2045-2055","2055-2065","2065-2075","2075-2085","2085-2095") )

bp26 = ax.boxplot( ( var26_2015 , var26_2030 , var26_2040 , var26_2050 , var26_2060 , var26_2070 , var26_2080 , var26_2090 )  ,
                positions=[ 1.3, 4.3, 7.3, 10.3, 13.3, 16.3, 19.3,22.3], widths=0.5, patch_artist=True,
                showmeans=True, showfliers=True,
                medianprops={"color": "black", "linewidth": 3. },
                boxprops={"facecolor": "chartreuse", "edgecolor": "black",
                          "linewidth": 0.5},
                whiskerprops={"color": "black", "linewidth": 2. },
                capprops={"color": "black", "linewidth": 2. } ,
                meanprops={ "markerfacecolor": "blue", "marker":"o" , "markersize":10., "markeredgecolor":'black' } ,
                labels=("","","","","","","","") , manage_ticks=False )

ax.legend( [ bp85["boxes"][0] , bp45["boxes"][0] , bp26["boxes"][0] , bp26["means"][0] ] ,
        ['Ensemble RCP 8.5 - N.mod='+str(Mod85_n), 'Ensemble RCP 4.5 - N.mod='+str(Mod45_n), 'Ensemble RCP 2.6 - N.mod='+str(Mod26_n), 'Ensemble mean' ],   loc=2 , fontsize="x-large" )


plt.savefig( output_arc_dir+"/"+point_name+"/boxplot_cumulative_annual_pr_"+point_name+".png" )

plt.close(fig)
