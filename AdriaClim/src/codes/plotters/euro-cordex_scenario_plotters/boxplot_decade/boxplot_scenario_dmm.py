from netCDF4 import Dataset as NetCDFFile 
import matplotlib.pyplot as plt
import numpy as np
import datetime
import bottleneck  
import sys
import os.path

point_name = sys.argv[1]
lat_ref    = float(sys.argv[2])  
lon_ref    = float(sys.argv[3])
field_name = sys.argv[4]

data_arc_dir='/lustre/arpa/AdriaClim/data/EURO-CORDEX/FVG' 
output_arc_dir="/lustre/arpa/AdriaClim/public_html/EURO_CORDEX_analysis/SCENARIO/dmm_boxplot_py"

file_var = open("initialization_data_file.txt", 'r')
Lines = file_var.readlines()

#============= lat/lon indexes =============

Lines[0] = Lines[0].rstrip()
file_test= Lines[0].split("/")

f_nc        =  NetCDFFile( data_arc_dir+"/"+file_test[0]+"/postproc/monthly/"+file_test[1] , mode='r')
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

del lat_proof, lon_proof , file_test
#===========================================

var85_2030 = []
var85_2040 = []
var85_2050 = []
var85_2060 = []
var85_2070 = []
var85_2080 = []
var85_2090 = []

var45_2030 = []
var45_2040 = []
var45_2050 = []
var45_2060 = []
var45_2070 = []
var45_2080 = []
var45_2090 = []

var26_2030 = []
var26_2040 = []
var26_2050 = []
var26_2060 = []
var26_2070 = []
var26_2080 = []
var26_2090 = []

#============= Acquisition of variable data from all netCDF set ===============

for line in Lines:
	line      = line.rstrip()
	file_path = line.split("/")
	file_info = file_path[1].split("_")
	year_inf  = int(file_info[7][0:4])
	year_sup  = int(file_info[8][0:4])

	#******* Reading netCDF file
	file_path=data_arc_dir+'/'+file_path[0]+"/postproc/monthly/"+"dmm"+"_"+field_name+"_"+file_info[2]+"_"+file_info[3]+"_"+file_info[4]+"_"+file_info[5]+"_"+file_info[6]+"_"+file_info[7]+"_"+file_info[8]

	if ( not os.path.isfile( file_path ) ):
		continue

	f_nc     = NetCDFFile( file_path , mode='r')     # I have to insert the two subdirectories intermedian /postproc/monthly/
	var  = f_nc.variables[field_name+'_mean'][:,lat_idx,lon_idx]

	if ( file_info[4] == "rcp85" ):
		if   ( year_inf == 2025 ):
			var85_2030 += list(var) 
		elif ( year_inf == 2035 ):
			var85_2040 += list(var)
		elif ( year_inf == 2045 ):
			var85_2050 += list(var)
		elif ( year_inf == 2055 ):
			var85_2060 += list(var)
		elif ( year_inf == 2065 ):
			var85_2070 += list(var)
		elif ( year_inf == 2075 ):
			var85_2080 += list(var)
		elif ( year_inf == 2085 ):
			var85_2090 += list(var)


	if ( file_info[4] == "rcp45" ):
		if   ( year_inf == 2025 ):
			var45_2030 += list(var)
		elif ( year_inf == 2035 ):
			var45_2040 += list(var)
		elif ( year_inf == 2045 ):
			var45_2050 += list(var)
		elif ( year_inf == 2055 ):
			var45_2060 += list(var)
		elif ( year_inf == 2065 ):
			var45_2070 += list(var)
		elif ( year_inf == 2075 ):
			var45_2080 += list(var)
		elif ( year_inf == 2085 ):
			var45_2090 += list(var)

	if ( file_info[4] == "rcp26" ):
		if   ( year_inf == 2025 ):
			var26_2030 += list(var)
		elif ( year_inf == 2035 ):
			var26_2040 += list(var)
		elif ( year_inf == 2045 ):
			var26_2050 += list(var)
		elif ( year_inf == 2055 ):
			var26_2060 += list(var)
		elif ( year_inf == 2065 ):
			var26_2070 += list(var)
		elif ( year_inf == 2075 ):
			var26_2080 += list(var)
		elif ( year_inf == 2085 ):
			var26_2090 += list(var)


file_var.close()

#*********** Number of models count *************

Dot85_n = 0
Dot45_n = 0
Dot26_n = 0

for i in range( len(var85_2030) ):
	if ( not type(var85_2030[i]) == np.ma.core.MaskedConstant ):
		Dot85_n += 1

for i in range( len(var45_2030) ):
        if ( not type(var45_2030[i]) == np.ma.core.MaskedConstant ):
                Dot45_n += 1

for i in range( len(var26_2030) ):
        if ( not type(var26_2030[i]) == np.ma.core.MaskedConstant ):
                Dot26_n += 1

Mod85_n = int( Dot85_n / 12 )
Mod45_n = int( Dot45_n / 12 )
Mod26_n = int( Dot26_n / 12 )

#=====================================================
#                 Boxplot creation
#=====================================================

#*************** y-axis range *******************

if   ( field_name == "uas" ):
	y_inf = -2.5
	y_sup =  2.5
	y_axis_label = "Eastward Near- Surface Wind Velocity [$m/s$]"
elif ( field_name == "vas" ):
	y_inf = -2.5
	y_sup =  2.5
	y_axis_label = "Northward Near- Surface Wind Velocity [$m/s$]"
elif ( field_name == "hfls" ):
        y_inf = -40.
        y_sup =  60.
        y_axis_label = "Surface Upward Latent Heat Flux [$W/m^2$]"
elif ( field_name == "ps" ):
        y_inf = -800
        y_sup =  800
        y_axis_label = "Surface Air Pressure [$Pa$]"
elif ( field_name == "rsds" ):
        y_inf = -30
        y_sup =  30
        y_axis_label = "Surface Downwelling Shortwave Radiation [$W/m^2$]"
elif ( field_name == "tas" ):
        y_inf = -3
        y_sup =  6
        y_axis_label = "Near-Surface Air Temperature [$°C$]"
elif ( field_name == "huss" ):
        y_inf = -0.0015
        y_sup =  0.004
        y_axis_label = "Near-Surface Specific Humidity [$kg/kg$]"
elif ( field_name == "pr" ):
        y_inf = -6.
        y_sup = +6.
        y_axis_label = "Precipitation [$mm/day$]"
elif ( field_name == "hfss" ):
        y_inf = -20
        y_sup =  30
        y_axis_label = "Surface Upward Sensible Heat Flux [$W/m^2$]"
elif ( field_name == "rlds" ):
        y_inf = -30
        y_sup =  40
        y_axis_label = "Surface Downwelling Longwave Radiation [$W/m^2$]"
elif ( field_name == "ts" ):
        y_inf = -1
        y_sup =  5
        y_axis_label = "Surface Temperature [$°C$]"
elif ( field_name == "evspsbl" ):
        y_inf = -0.000025
        y_sup =  0.000030
        y_axis_label = "Evaporation [$kg/m^2 \cdot s$]"
elif ( field_name == "tasmax" ):
        y_inf = -2
        y_sup =  6
        y_axis_label = "Daily Maximum Near-Surface Air Temperature [$°C$]"
elif ( field_name == "tasmin" ):
        y_inf = -2
        y_sup =  6
        y_axis_label = "Daily Minimum Near-Surface Air Temperature [$°C$]"


#======================================================

if ( Mod85_n == 0 and Mod45_n == 0 and Mod26_n == 0  ):
	print("The values are all missing: the plot can't be done")
	exit(1)

fig , ax = plt.subplots(figsize=(20,15))

plt.title("Delta monthly mean "+field_name+" scenario respect to 2010-2020 decade at point: "+point_name+"\n" , fontsize=30, fontdict={'family':'serif'} )
plt.xlabel("Decade", fontsize=25 )
plt.ylabel( y_axis_label, fontsize=25 )
plt.xticks(fontsize=18 )
plt.yticks(fontsize=18 )
plt.grid( linestyle='--')
plt.axis([ 0 , 22 , y_inf , y_sup ])
plt.hlines( 0. , -1. , +25. , linestyle="--", linewidth=1.8 )


bp85 = ax.boxplot( ( var85_2030 , var85_2040 , var85_2050 , var85_2060 , var85_2070 , var85_2080 , var85_2090 )  , 
                positions=[ 2.7, 5.7, 8.7, 11.7, 14.7, 17.7, 20.7], widths=0.5, patch_artist=True,
                showmeans=True, showfliers=True,
                medianprops={"color": "black", "linewidth": 3. },
                boxprops={"facecolor": "r", "edgecolor": "black",
                          "linewidth": 0.5},
                whiskerprops={"color": "black", "linewidth": 2. },
                capprops={"color": "black", "linewidth": 2. } ,
                meanprops={ "markerfacecolor": "blue", "marker":"o" , "markersize":10., "markeredgecolor":'black' } ,
                labels=("","","","","","","") , manage_ticks=False ) 


bp45  = ax.boxplot( ( var45_2030 , var45_2040 , var45_2050 , var45_2060 , var45_2070 , var45_2080 , var45_2090 )  ,
               positions=[ 2, 5, 8, 11, 14, 17, 20], widths=0.5, patch_artist=True,
                showmeans=True, showfliers=True,
                medianprops={"color": "black", "linewidth": 3. },
                boxprops={"facecolor": "yellow", "edgecolor": "black",
                          "linewidth": 0.5},
                whiskerprops={"color": "black", "linewidth": 2. },
                capprops={"color": "black", "linewidth": 2. } ,
                meanprops={"markerfacecolor": "blue", "marker":"o" , "markersize":10. , "markeredgecolor":'black' } ,
                labels=("2025-2035","2035-2045","2045-2055","2055-2065","2065-2075","2075-2085","2085-2095") )

bp26 = ax.boxplot( ( var26_2030 , var26_2040 , var26_2050 , var26_2060 , var26_2070 , var26_2080 , var26_2090 )  ,
                positions=[ 1.3, 4.3, 7.3, 10.3, 13.3, 16.3, 19.3], widths=0.5, patch_artist=True,
                showmeans=True, showfliers=True,
                medianprops={"color": "black", "linewidth": 3. },
                boxprops={"facecolor": "chartreuse", "edgecolor": "black",
                          "linewidth": 0.5},
                whiskerprops={"color": "black", "linewidth": 2. },
                capprops={"color": "black", "linewidth": 2. } ,
                meanprops={ "markerfacecolor": "blue", "marker":"o" , "markersize":10., "markeredgecolor":'black' } ,
                labels=("","","","","","","") , manage_ticks=False )

ax.legend( [ bp85["boxes"][0] , bp45["boxes"][0] , bp26["boxes"][0] , bp26["means"][0] ] , 
        ['Ensemble RCP 8.5 - N.mod='+str(Mod85_n), 'Ensemble RCP 4.5 - N.mod='+str(Mod45_n), 'Ensemble RCP 2.6 - N.mod='+str(Mod26_n), 'Ensemble mean' ],   loc=2 , fontsize="x-large" )


plt.savefig( output_arc_dir+"/"+point_name+"/dmm_boxplot_"+field_name+"_"+point_name+".png" )

plt.close(fig)
