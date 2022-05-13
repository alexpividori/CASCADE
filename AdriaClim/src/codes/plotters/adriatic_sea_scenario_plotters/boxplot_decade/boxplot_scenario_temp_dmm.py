from netCDF4 import Dataset as NetCDFFile 
import matplotlib.pyplot as plt
import numpy as np
import datetime
import bottleneck  
import sys
import pandas as pd

point_name = sys.argv[1]
lat_ref    = float(sys.argv[2])  
lon_ref    = float(sys.argv[3])

data_arc_dir='/lustre/arpa/AdriaClim/data/Med_CORDEX_files' 
output_arc_dir="/lustre/arpa/AdriaClim/public_html/Med_CORDEX_analysis/SCENARIO/dmm_boxplot_py"

file_temp = open("dmm_initialization_file_temp.txt", 'r')
Lines = file_temp.readlines()

#============= lat/lon indexes =============

f_nc        =  NetCDFFile( data_arc_dir+"/"+Lines[0].rstrip() , mode='r')
lat_proof   = f_nc.variables['lat'][:]
lon_proof   = f_nc.variables['lon'][:]

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

temp85_2030 = []
temp85_2040 = []
temp85_2050 = []
temp85_2060 = []
temp85_2070 = []
temp85_2080 = []
temp85_2090 = []

temp45_2030 = []
temp45_2040 = []
temp45_2050 = []
temp45_2060 = []
temp45_2070 = []
temp45_2080 = []
temp45_2090 = []

temp26_2030 = []
temp26_2040 = []
temp26_2050 = []
temp26_2060 = []
temp26_2070 = []
temp26_2080 = []
temp26_2090 = []


for line in Lines:
	line      = line.rstrip()
	file_path = line.split("/")
	file_info = file_path[1].split("_")
	year_inf  = int(file_info[9][0:4])
	year_sup  = int(file_info[10][0:4])

	#******* Reading netCDF file
	f_nc     = NetCDFFile( data_arc_dir+"/"+line , mode='r')
	temp  = f_nc.variables['tos_mean'][:,lat_idx,lon_idx]

	if ( file_info[4] == "rcp85" ):
		if   ( year_inf == 2025 ):
			temp85_2030 += list(temp) 
		elif ( year_inf == 2035 ):
			temp85_2040 += list(temp)
		elif ( year_inf == 2045 ):
			temp85_2050 += list(temp)
		elif ( year_inf == 2055 ):
			temp85_2060 += list(temp)
		elif ( year_inf == 2065 ):
			temp85_2070 += list(temp)
		elif ( year_inf == 2075 ):
			temp85_2080 += list(temp)
		elif ( year_inf == 2085 ):
			temp85_2090 += list(temp)


	if ( file_info[4] == "rcp45" ):
		if   ( year_inf == 2025 ):
			temp45_2030 += list(temp)
		elif ( year_inf == 2035 ):
			temp45_2040 += list(temp)
		elif ( year_inf == 2045 ):
			temp45_2050 += list(temp)
		elif ( year_inf == 2055 ):
			temp45_2060 += list(temp)
		elif ( year_inf == 2065 ):
			temp45_2070 += list(temp)
		elif ( year_inf == 2075 ):
			temp45_2080 += list(temp)
		elif ( year_inf == 2085 ):
			temp45_2090 += list(temp)

	if ( file_info[4] == "rcp26" ):
		if   ( year_inf == 2025 ):
			temp26_2030 += list(temp)
		elif ( year_inf == 2035 ):
			temp26_2040 += list(temp)
		elif ( year_inf == 2045 ):
			temp26_2050 += list(temp)
		elif ( year_inf == 2055 ):
			temp26_2060 += list(temp)
		elif ( year_inf == 2065 ):
			temp26_2070 += list(temp)
		elif ( year_inf == 2075 ):
			temp26_2080 += list(temp)
		elif ( year_inf == 2085 ):
			temp26_2090 += list(temp)


file_temp.close()

#*********** Number of models count *************

Dot85_n = 0
Dot45_n = 0
Dot26_n = 0

for i in range( len(temp85_2030) ):
	if ( not type(temp85_2030[i]) == np.ma.core.MaskedConstant ):
		Dot85_n += 1

for i in range( len(temp45_2030) ):
        if ( not type(temp45_2030[i]) == np.ma.core.MaskedConstant ):
                Dot45_n += 1

for i in range( len(temp26_2030) ):
        if ( not type(temp26_2030[i]) == np.ma.core.MaskedConstant ):
                Dot26_n += 1

Mod85_n = int( Dot85_n / 12 )
Mod45_n = int( Dot45_n / 12 )
Mod26_n = int( Dot26_n / 12 )

#===================================================
#          Musked array tractation
#===================================================

temp85_2030n = []
temp85_2040n = []
temp85_2050n = []
temp85_2060n = []
temp85_2070n = []
temp85_2080n = []
temp85_2090n = []

for i in range( len(temp85_2030) ):
	if ( not type(temp85_2030[i]) == np.ma.core.MaskedConstant ):
		temp85_2030n.append( temp85_2030[i] )

for i in range( len(temp85_2040) ):
	if ( not  type(temp85_2040[i]) == np.ma.core.MaskedConstant ):
		temp85_2040n.append( temp85_2040[i] )

for i in range( len(temp85_2050) ):
	if ( not type(temp85_2050[i]) == np.ma.core.MaskedConstant ):
		temp85_2050n.append( temp85_2050[i] )

for i in range( len(temp85_2060) ):
	if ( not type(temp85_2060[i]) == np.ma.core.MaskedConstant ):
		temp85_2060n.append( temp85_2060[i] )

for i in range( len(temp85_2070) ):
	if ( not type(temp85_2070[i]) == np.ma.core.MaskedConstant ):
		temp85_2070n.append( temp85_2070[i] )

for i in range( len(temp85_2080) ):
	if ( not type(temp85_2080[i]) == np.ma.core.MaskedConstant ):
		temp85_2080n.append( temp85_2080[i] )

for i in range( len(temp85_2090) ):
	if ( not type(temp85_2090[i]) == np.ma.core.MaskedConstant ):
		temp85_2090n.append( temp85_2090[i] )

#====================================================

temp45_2030n = []
temp45_2040n = []
temp45_2050n = []
temp45_2060n = []
temp45_2070n = []
temp45_2080n = []
temp45_2090n = []

for i in range( len(temp45_2030) ):
        if ( not type(temp45_2030[i]) == np.ma.core.MaskedConstant ):
                temp45_2030n.append( temp45_2030[i] )

for i in range( len(temp45_2040) ):
        if ( not  type(temp45_2040[i]) == np.ma.core.MaskedConstant ):
                temp45_2040n.append( temp45_2040[i] )

for i in range( len(temp45_2050) ):
        if ( not type(temp45_2050[i]) == np.ma.core.MaskedConstant ):
                temp45_2050n.append( temp45_2050[i] )

for i in range( len(temp45_2060) ):
        if ( not type(temp45_2060[i]) == np.ma.core.MaskedConstant ):
                temp45_2060n.append( temp45_2060[i] )

for i in range( len(temp45_2070) ):
        if ( not type(temp45_2070[i]) == np.ma.core.MaskedConstant ):
                temp45_2070n.append( temp45_2070[i] )

for i in range( len(temp45_2080) ):
        if ( not type(temp45_2080[i]) == np.ma.core.MaskedConstant ):
                temp45_2080n.append( temp45_2080[i] )

for i in range( len(temp45_2090) ):
        if ( not type(temp45_2090[i]) == np.ma.core.MaskedConstant ):
                temp45_2090n.append( temp45_2090[i] )

#====================================================

temp26_2030n = []
temp26_2040n = []
temp26_2050n = []
temp26_2060n = []
temp26_2070n = []
temp26_2080n = []
temp26_2090n = []

for i in range( len(temp26_2030) ):
        if ( not type(temp26_2030[i]) == np.ma.core.MaskedConstant ):
                temp26_2030n.append( temp26_2030[i] )

for i in range( len(temp26_2040) ):
        if ( not  type(temp26_2040[i]) == np.ma.core.MaskedConstant ):
                temp26_2040n.append( temp26_2040[i] )

for i in range( len(temp26_2050) ):
        if ( not type(temp26_2050[i]) == np.ma.core.MaskedConstant ):
                temp26_2050n.append( temp26_2050[i] )

for i in range( len(temp26_2060) ):
        if ( not type(temp26_2060[i]) == np.ma.core.MaskedConstant ):
                temp26_2060n.append( temp26_2060[i] )

for i in range( len(temp26_2070) ):
        if ( not type(temp26_2070[i]) == np.ma.core.MaskedConstant ):
                temp26_2070n.append( temp26_2070[i] )

for i in range( len(temp26_2080) ):
        if ( not type(temp26_2080[i]) == np.ma.core.MaskedConstant ):
                temp26_2080n.append( temp26_2080[i] )

for i in range( len(temp26_2090) ):
        if ( not type(temp26_2090[i]) == np.ma.core.MaskedConstant ):
                temp26_2090n.append( temp26_2090[i] )

#=====================================================
#                 Boxplot creation
#=====================================================

if ( Mod85_n == 0 and Mod45_n == 0 and Mod26_n == 0  ):
	print("The values are all missing: the plot can't be done")
	exit(1)

fig , ax = plt.subplots(figsize=(20,15))

plt.title("Delta monthly means temperatures scenario respect to 2010-2020 decade at point: "+point_name+"\n" , fontsize=30, fontdict={'family':'serif'} )
plt.xlabel("Decade", fontsize=25 )
plt.ylabel("Sea surface delta mean temperature [°C]", fontsize=25 )
plt.xticks(fontsize=18 )
plt.yticks(fontsize=18 )
plt.grid( linestyle='--')
plt.axis([ 0 , 22  , -1.5 , 4.5 ])
plt.hlines( 0. , -1. , +25. , linestyle="--", linewidth=1.8 )


bp85 = ax.boxplot( ( temp85_2030n , temp85_2040n , temp85_2050n , temp85_2060n , temp85_2070n , temp85_2080n , temp85_2090n )  , 
                positions=[ 2.7, 5.7, 8.7, 11.7, 14.7, 17.7, 20.7], widths=0.5, patch_artist=True,
                showmeans=True, showfliers=True,
                medianprops={"color": "black", "linewidth": 3. },
                boxprops={"facecolor": "r", "edgecolor": "black",
                          "linewidth": 0.5},
                whiskerprops={"color": "black", "linewidth": 2. },
                capprops={"color": "black", "linewidth": 2. } ,
                meanprops={ "markerfacecolor": "blue", "marker":"o" , "markersize":10., "markeredgecolor":'black' } ,
                labels=("","","","","","","") , manage_ticks=False ) 


bp45  = ax.boxplot( ( temp45_2030n , temp45_2040n , temp45_2050n , temp45_2060n , temp45_2070n , temp45_2080n , temp45_2090n )  ,
               positions=[ 2, 5, 8, 11, 14, 17, 20], widths=0.5, patch_artist=True,
                showmeans=True, showfliers=True,
                medianprops={"color": "black", "linewidth": 3. },
                boxprops={"facecolor": "yellow", "edgecolor": "black",
                          "linewidth": 0.5},
                whiskerprops={"color": "black", "linewidth": 2. },
                capprops={"color": "black", "linewidth": 2. } ,
                meanprops={"markerfacecolor": "blue", "marker":"o" , "markersize":10. , "markeredgecolor":'black' } ,
                labels=("2025-2035","2035-2045","2045-2055","2055-2065","2065-2075","2075-2085","2085-2095") )

bp26 = ax.boxplot( ( temp26_2030n , temp26_2040n , temp26_2050n , temp26_2060n , temp26_2070n , temp26_2080n , temp26_2090n )  ,
                positions=[ 1.3, 4.3, 7.3, 10.3, 13.3, 16.3, 19.3], widths=0.5, patch_artist=True,
                showmeans=True, showfliers=True,
                medianprops={"color": "black", "linewidth": 3. },
                boxprops={"facecolor": "chartreuse", "edgecolor": "black",
                          "linewidth": 0.5},
                whiskerprops={"color": "black", "linewidth": 2. },
                capprops={"color": "black", "linewidth": 2. } ,
                meanprops={ "markerfacecolor": "blue", "marker":"o" , "markersize":10., "markeredgecolor":'black' } ,
                labels=("","","","","","","") , manage_ticks=False )

if ( Mod85_n > 0 and Mod45_n > 0 and Mod26_n > 0  ):
	ax.legend( [ bp85["boxes"][0] , bp45["boxes"][0] , bp26["boxes"][0] , bp26["means"][0] ] , 
        ['Ensemble RCP 8.5 - N.mod='+str(Mod85_n), 'Ensemble RCP 4.5 - N.mod='+str(Mod45_n), 'Ensemble RCP 2.6 - N.mod='+str(Mod26_n), 'Ensemble mean' ],   loc=2 , fontsize="x-large" )
elif ( Mod85_n > 0 and Mod45_n > 0  and Mod26_n == 0  ):
	ax.legend( [ bp85["boxes"][0] , bp45["boxes"][0]  , bp26["means"][0] ] ,
           ['Ensemble RCP 8.5 - N.mod='+str(Mod85_n), 'Ensemble RCP 4.5 - N.mod='+str(Mod45_n), 'Ensemble mean' ],   loc=2 , fontsize="x-large" )
elif ( Mod85_n > 0 and Mod45_n == 0  and Mod26_n > 0  ):
        ax.legend( [ bp85["boxes"][0] , bp26["boxes"][0]  , bp26["means"][0] ] ,
           ['Ensemble RCP 8.5 - N.mod='+str(Mod85_n), 'Ensemble RCP 2.6 - N.mod='+str(Mod26_n), 'Ensemble mean' ],   loc=2 , fontsize="x-large" )
elif ( Mod85_n == 0 and Mod45_n > 0  and Mod26_n > 0  ):
        ax.legend( [ bp45["boxes"][0] , bp26["boxes"][0]  , bp26["means"][0] ] ,
           ['Ensemble RCP 4.5 - N.mod='+str(Mod45_n), 'Ensemble RCP 2.6 - N.mod='+str(Mod26_n), 'Ensemble mean' ],   loc=2 , fontsize="x-large" )
elif ( Mod85_n == 0 and Mod45_n == 0  and Mod26_n > 0  ):
        ax.legend( [  bp26["boxes"][0]  , bp26["means"][0] ] ,
           [ 'Ensemble RCP 2.6 - N.mod='+str(Mod26_n), 'Ensemble mean' ],   loc=2 , fontsize="x-large" )
elif ( Mod85_n > 0 and Mod45_n == 0  and Mod26_n == 0  ):
        ax.legend( [  bp85["boxes"][0]  , bp26["means"][0] ] ,
           [ 'Ensemble RCP 8.5 - N.mod='+str(Mod85_n), 'Ensemble mean' ],   loc=2 , fontsize="x-large" )
elif ( Mod85_n == 0 and Mod45_n > 0  and Mod26_n == 0  ):
        ax.legend( [  bp45["boxes"][0]  , bp26["means"][0] ] ,
           [ 'Ensemble RCP 4.5 - N.mod='+str(Mod45_n), 'Ensemble mean' ],   loc=2 , fontsize="x-large" )


plt.savefig( output_arc_dir+"/"+point_name+"/dmm_boxplot_temp_"+point_name+".png" )

plt.close(fig)
