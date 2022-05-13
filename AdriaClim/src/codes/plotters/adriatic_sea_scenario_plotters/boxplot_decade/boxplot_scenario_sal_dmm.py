from netCDF4 import Dataset as NetCDFFile 
import matplotlib.pyplot as plt
import numpy as np
import datetime
import bottleneck  
import sys

#===================================================================
#
# DESCRIPTION:    This python script uses netCDF edited files (Avg and medians)
#                 to realize boxplots representing different RCP values on 
#                 a series of decades until 2100. The results are available on 
#                 AdriaClim web-page
#
#
# EXTERNAL CALLS: none.
#
# EXTERNAL FILES: - input NetCDF data files;
#                   (e.g. see in /lustre/arpa/AdriaClim/data/Med_CORDEX_files )
#                  
#
#
# DEVELOPER:      Alex Pividori (alex.pividori@arpa.fvg.it)
#                 ARPA FVG - S.O.C. Stato dell'Ambiente
#                 "AdriaClim" Interreg IT-HR project
#
# CREATION DATE:  09/03/2022
#
#
# Python Version:    python/3.8.1/gcc/8.2.0-mbzms7w
#
#
# MODIFICATIONS:  09/03/2022 --->  Creation of script 
#
#=====================================================================

point_name = sys.argv[1]
lat_ref    = float(sys.argv[2])  
lon_ref    = float(sys.argv[3])

data_arc_dir='/lustre/arpa/AdriaClim/data/Med_CORDEX_files' 
output_arc_dir="/lustre/arpa/AdriaClim/public_html/Med_CORDEX_analysis/SCENARIO/dmm_boxplot_py"

file_sal = open("dmm_initialization_file_sal.txt", 'r')
Lines = file_sal.readlines()

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

sal85_2030 = []
sal85_2040 = []
sal85_2050 = []
sal85_2060 = []
sal85_2070 = []
sal85_2080 = []
sal85_2090 = []

sal45_2030 = []
sal45_2040 = []
sal45_2050 = []
sal45_2060 = []
sal45_2070 = []
sal45_2080 = []
sal45_2090 = []

sal26_2030 = []
sal26_2040 = []
sal26_2050 = []
sal26_2060 = []
sal26_2070 = []
sal26_2080 = []
sal26_2090 = []


for line in Lines:
	line      = line.rstrip()
	file_path = line.split("/")
	file_info = file_path[1].split("_")
	year_inf  = int(file_info[9][0:4])
	year_sup  = int(file_info[10][0:4])

	#******* Reading netCDF file
	f_nc     = NetCDFFile( data_arc_dir+"/"+line , mode='r')
	sal  = f_nc.variables['sos_mean'][:,lat_idx,lon_idx]

	if ( file_info[4] == "rcp85" ):
		if   ( year_inf == 2025 ):
			sal85_2030 += list(sal) 
		elif ( year_inf == 2035 ):
			sal85_2040 += list(sal)
		elif ( year_inf == 2045 ):
			sal85_2050 += list(sal)
		elif ( year_inf == 2055 ):
			sal85_2060 += list(sal)
		elif ( year_inf == 2065 ):
			sal85_2070 += list(sal)
		elif ( year_inf == 2075 ):
			sal85_2080 += list(sal)
		elif ( year_inf == 2085 ):
			sal85_2090 += list(sal)


	if ( file_info[4] == "rcp45" ):
		if   ( year_inf == 2025 ):
			sal45_2030 += list(sal)
		elif ( year_inf == 2035 ):
			sal45_2040 += list(sal)
		elif ( year_inf == 2045 ):
			sal45_2050 += list(sal)
		elif ( year_inf == 2055 ):
			sal45_2060 += list(sal)
		elif ( year_inf == 2065 ):
			sal45_2070 += list(sal)
		elif ( year_inf == 2075 ):
			sal45_2080 += list(sal)
		elif ( year_inf == 2085 ):
			sal45_2090 += list(sal)

	if ( file_info[4] == "rcp26" ):
		if   ( year_inf == 2025 ):
			sal26_2030 += list(sal)
		elif ( year_inf == 2035 ):
			sal26_2040 += list(sal)
		elif ( year_inf == 2045 ):
			sal26_2050 += list(sal)
		elif ( year_inf == 2055 ):
			sal26_2060 += list(sal)
		elif ( year_inf == 2065 ):
			sal26_2070 += list(sal)
		elif ( year_inf == 2075 ):
			sal26_2080 += list(sal)
		elif ( year_inf == 2085 ):
			sal26_2090 += list(sal)


file_sal.close()

#*********** Number of models count *************

Dot85_n = 0
Dot45_n = 0
Dot26_n = 0

for i in range( len(sal85_2030) ):
	if ( not type(sal85_2030[i]) == np.ma.core.MaskedConstant ):
		Dot85_n += 1

for i in range( len(sal45_2030) ):
        if ( not type(sal45_2030[i]) == np.ma.core.MaskedConstant ):
                Dot45_n += 1

for i in range( len(sal26_2030) ):
        if ( not type(sal26_2030[i]) == np.ma.core.MaskedConstant ):
                Dot26_n += 1

Mod85_n = int( Dot85_n / 12 )
Mod45_n = int( Dot45_n / 12 )
Mod26_n = int( Dot26_n / 12 )

#===================================================
#          Musked array tractation
#===================================================

sal85_2030n = []
sal85_2040n = []
sal85_2050n = []
sal85_2060n = []
sal85_2070n = []
sal85_2080n = []
sal85_2090n = []

for i in range( len(sal85_2030) ):
	if ( not type(sal85_2030[i]) == np.ma.core.MaskedConstant ):
		sal85_2030n.append( sal85_2030[i] )

for i in range( len(sal85_2040) ):
	if ( not  type(sal85_2040[i]) == np.ma.core.MaskedConstant ):
		sal85_2040n.append( sal85_2040[i] )

for i in range( len(sal85_2050) ):
	if ( not type(sal85_2050[i]) == np.ma.core.MaskedConstant ):
		sal85_2050n.append( sal85_2050[i] )

for i in range( len(sal85_2060) ):
	if ( not type(sal85_2060[i]) == np.ma.core.MaskedConstant ):
		sal85_2060n.append( sal85_2060[i] )

for i in range( len(sal85_2070) ):
	if ( not type(sal85_2070[i]) == np.ma.core.MaskedConstant ):
		sal85_2070n.append( sal85_2070[i] )

for i in range( len(sal85_2080) ):
	if ( not type(sal85_2080[i]) == np.ma.core.MaskedConstant ):
		sal85_2080n.append( sal85_2080[i] )

for i in range( len(sal85_2090) ):
	if ( not type(sal85_2090[i]) == np.ma.core.MaskedConstant ):
		sal85_2090n.append( sal85_2090[i] )

#====================================================

sal45_2030n = []
sal45_2040n = []
sal45_2050n = []
sal45_2060n = []
sal45_2070n = []
sal45_2080n = []
sal45_2090n = []

for i in range( len(sal45_2030) ):
        if ( not type(sal45_2030[i]) == np.ma.core.MaskedConstant ):
                sal45_2030n.append( sal45_2030[i] )

for i in range( len(sal45_2040) ):
        if ( not  type(sal45_2040[i]) == np.ma.core.MaskedConstant ):
                sal45_2040n.append( sal45_2040[i] )

for i in range( len(sal45_2050) ):
        if ( not type(sal45_2050[i]) == np.ma.core.MaskedConstant ):
                sal45_2050n.append( sal45_2050[i] )

for i in range( len(sal45_2060) ):
        if ( not type(sal45_2060[i]) == np.ma.core.MaskedConstant ):
                sal45_2060n.append( sal45_2060[i] )

for i in range( len(sal45_2070) ):
        if ( not type(sal45_2070[i]) == np.ma.core.MaskedConstant ):
                sal45_2070n.append( sal45_2070[i] )

for i in range( len(sal45_2080) ):
        if ( not type(sal45_2080[i]) == np.ma.core.MaskedConstant ):
                sal45_2080n.append( sal45_2080[i] )

for i in range( len(sal45_2090) ):
        if ( not type(sal45_2090[i]) == np.ma.core.MaskedConstant ):
                sal45_2090n.append( sal45_2090[i] )

#====================================================

sal26_2030n = []
sal26_2040n = []
sal26_2050n = []
sal26_2060n = []
sal26_2070n = []
sal26_2080n = []
sal26_2090n = []

for i in range( len(sal26_2030) ):
        if ( not type(sal26_2030[i]) == np.ma.core.MaskedConstant ):
                sal26_2030n.append( sal26_2030[i] )

for i in range( len(sal26_2040) ):
        if ( not  type(sal26_2040[i]) == np.ma.core.MaskedConstant ):
                sal26_2040n.append( sal26_2040[i] )

for i in range( len(sal26_2050) ):
        if ( not type(sal26_2050[i]) == np.ma.core.MaskedConstant ):
                sal26_2050n.append( sal26_2050[i] )

for i in range( len(sal26_2060) ):
        if ( not type(sal26_2060[i]) == np.ma.core.MaskedConstant ):
                sal26_2060n.append( sal26_2060[i] )

for i in range( len(sal26_2070) ):
        if ( not type(sal26_2070[i]) == np.ma.core.MaskedConstant ):
                sal26_2070n.append( sal26_2070[i] )

for i in range( len(sal26_2080) ):
        if ( not type(sal26_2080[i]) == np.ma.core.MaskedConstant ):
                sal26_2080n.append( sal26_2080[i] )

for i in range( len(sal26_2090) ):
        if ( not type(sal26_2090[i]) == np.ma.core.MaskedConstant ):
                sal26_2090n.append( sal26_2090[i] )

#=====================================================
#                 Boxplot creation
#=====================================================

if ( Mod85_n == 0 and Mod45_n == 0 and Mod26_n == 0  ):
	print("The values are all missing: the plot can't be done")
	exit(1)

fig , ax = plt.subplots(figsize=(20,15))

plt.title("Delta monthly mean salinity scenario respect to 2010-2020 decade at point: "+point_name+"\n" , fontsize=30, fontdict={'family':'serif'} )
plt.xlabel("Decade", fontsize=25 )
plt.ylabel("Sea surface delta mean salinity [PSU]", fontsize=25 )
plt.xticks(fontsize=18 )
plt.yticks(fontsize=18 )
plt.grid( linestyle='--')
plt.axis([ 0 , 22  , -1.5 , 2.0 ])
plt.hlines( 0. , -1. , +25. , linestyle="--", linewidth=1.8 )


bp85 = ax.boxplot( ( sal85_2030n , sal85_2040n , sal85_2050n , sal85_2060n , sal85_2070n , sal85_2080n , sal85_2090n )  , 
                positions=[ 2.7, 5.7, 8.7, 11.7, 14.7, 17.7, 20.7], widths=0.5, patch_artist=True,
                showmeans=True, showfliers=True,
                medianprops={"color": "black", "linewidth": 3. },
                boxprops={"facecolor": "r", "edgecolor": "black",
                          "linewidth": 0.5},
                whiskerprops={"color": "black", "linewidth": 2. },
                capprops={"color": "black", "linewidth": 2. } ,
                meanprops={ "markerfacecolor": "blue", "marker":"o" , "markersize":10., "markeredgecolor":'black' } ,
                labels=("","","","","","","") , manage_ticks=False ) 


bp45  = ax.boxplot( ( sal45_2030n , sal45_2040n , sal45_2050n , sal45_2060n , sal45_2070n , sal45_2080n , sal45_2090n )  ,
                positions=[ 2, 5, 8, 11, 14, 17, 20], widths=0.5, patch_artist=True,
                showmeans=True, showfliers=True,
                medianprops={"color": "black", "linewidth": 3. },
                boxprops={"facecolor": "yellow", "edgecolor": "black",
                          "linewidth": 0.5},
                whiskerprops={"color": "black", "linewidth": 2. },
                capprops={"color": "black", "linewidth": 2. } ,
                meanprops={"markerfacecolor": "blue", "marker":"o" , "markersize":10. , "markeredgecolor":'black' } ,
                labels=("2025-2035","2035-2045","2045-2055","2055-2065","2065-2075","2075-2085","2085-2095") )

bp26 = ax.boxplot( ( sal26_2030n , sal26_2040n , sal26_2050n , sal26_2060n , sal26_2070n , sal26_2080n , sal26_2090n )  ,
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


plt.savefig( output_arc_dir+"/"+point_name+"/dmm_boxplot_sal_"+point_name+".png" )

plt.close(fig)
