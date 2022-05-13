from netCDF4 import Dataset as NetCDFFile 
import matplotlib.pyplot as plt
import numpy as np
import bottleneck  
import sys
import os.path
import statistics as stat

point_name  = sys.argv[1]
lat_ref     = float(sys.argv[2])  
lon_ref     = float(sys.argv[3])
year_middle = int(sys.argv[4])

data_arc_dir='/lustre/arpa/AdriaClim/data/EURO-CORDEX/FVG' 
output_arc_dir="/lustre/arpa/AdriaClim/public_html/EURO_CORDEX_analysis/SCENARIO/boxplot_delta_cumulative_py"

#============= lat/lon indexes =============

f_nc        =  NetCDFFile( data_arc_dir+"/1_HadGEM2-ES_RACMO22E"+"/postproc/monthly/"+"pr_HadGEM2-ES_RACMO22E_rcp26_mon_future.nc" , mode='r')
lat_proof   =  f_nc.variables['lat'][:]
lon_proof   =  f_nc.variables['lon'][:]


for i in range( len(lat_proof) ):    # starts from 0
        if ( abs(lat_proof[i] - lat_ref ) < 0.01 ):
           lat_idx=i
           break

for i in range( len(lon_proof) ):
        if ( abs(lon_proof[i] - lon_ref ) < 0.01 ):
           lon_idx=i
           break

del lat_proof, lon_proof 
#===========================================

var26_01 = []
var26_02 = []
var26_03 = []
var26_04 = []
var26_05 = []
var26_06 = []
var26_07 = []
var26_08 = []
var26_09 = []
var26_10 = []
var26_11 = []
var26_12 = []

var45_01 = []
var45_02 = []
var45_03 = []
var45_04 = []
var45_05 = []
var45_06 = []
var45_07 = []
var45_08 = []
var45_09 = []
var45_10 = []
var45_11 = []
var45_12 = []

var85_01 = []
var85_02 = []
var85_03 = []
var85_04 = []
var85_05 = []
var85_06 = []
var85_07 = []
var85_08 = []
var85_09 = []
var85_10 = []
var85_11 = []
var85_12 = []

#===== ref =====

ref26_01 = []
ref26_02 = []
ref26_03 = []
ref26_04 = []
ref26_05 = []
ref26_06 = []
ref26_07 = []
ref26_08 = []
ref26_09 = []
ref26_10 = []
ref26_11 = []
ref26_12 = []

ref45_01 = []
ref45_02 = []
ref45_03 = []
ref45_04 = []
ref45_05 = []
ref45_06 = []
ref45_07 = []
ref45_08 = []
ref45_09 = []
ref45_10 = []
ref45_11 = []
ref45_12 = []

ref85_01 = []
ref85_02 = []
ref85_03 = []
ref85_04 = []
ref85_05 = []
ref85_06 = []
ref85_07 = []
ref85_08 = []
ref85_09 = []
ref85_10 = []
ref85_11 = []
ref85_12 = []

#============= Acquisition of variable data from all netCDF set ===============

year_in   = year_middle - 5
year_fin  = year_middle + 5

#============================== MOnthly reference ===============================

# The reference decade is 2010-2020, so the monthly t_start is (2010-2006)*12 = 48

t_start = 48

#================================================================================

for RCP in ["26", "45", "85"]:
        i=1
        for model in [ "HadGEM2-ES_RACMO22E", "MPI-ESM-LR_REMO2009", "EC-EARTH_CCLM4-8-17", "EC-EARTH_RACMO22E", "EC-EARTH_RCA4"]:

                #******* Reading netCDF file
                file_path=data_arc_dir+'/'+str(i)+"_"+model+"/postproc/monthly/"+"pr_"+model+"_rcp"+RCP+"_mon_future.nc"

                if ( not os.path.isfile( file_path ) ):
                        print("File"+file_path+" doesn't exists or is corrupted")
                        i+=1
                        continue

                f_nc     = NetCDFFile( file_path , mode='r')     # I have to insert the two subdirectories intermedian /postproc/monthly/
                var      = f_nc.variables['pr'][:,lat_idx,lon_idx]

                if ( RCP == "85" ):
                        for j in range(0,11):                                        # 11 year from 0 to 10 starting from year_in (not properly decade)
                                ref85_01.append( var[t_start +      j*12 ] * 30.42 )      # total number of elements: 11*5 (11 years*number of models)
                                ref85_02.append( var[t_start + 1  + j*12 ] * 30.42 )
                                ref85_03.append( var[t_start + 2  + j*12 ] * 30.42 )
                                ref85_04.append( var[t_start + 3  + j*12 ] * 30.42 )
                                ref85_05.append( var[t_start + 4  + j*12 ] * 30.42 )
                                ref85_06.append( var[t_start + 5  + j*12 ] * 30.42 )
                                ref85_07.append( var[t_start + 6  + j*12 ] * 30.42 )
                                ref85_08.append( var[t_start + 7  + j*12 ] * 30.42 )
                                ref85_09.append( var[t_start + 8  + j*12 ] * 30.42 )
                                ref85_10.append( var[t_start + 9  + j*12 ] * 30.42 )
                                ref85_11.append( var[t_start + 10 + j*12 ] * 30.42 )
                                ref85_12.append( var[t_start + 11 + j*12 ] * 30.42 )

                elif ( RCP == "45" ):
                        for j in range(0,11):                                        # 11 year from 0 to 10 starting from year_in (not properly decade)
                                ref45_01.append( var[t_start +      j*12 ] * 30.42 )      # total number of elements: 11*5 (11 years*number of models)
                                ref45_02.append( var[t_start + 1  + j*12 ] * 30.42 )
                                ref45_03.append( var[t_start + 2  + j*12 ] * 30.42 )
                                ref45_04.append( var[t_start + 3  + j*12 ] * 30.42 )
                                ref45_05.append( var[t_start + 4  + j*12 ] * 30.42 )
                                ref45_06.append( var[t_start + 5  + j*12 ] * 30.42 )
                                ref45_07.append( var[t_start + 6  + j*12 ] * 30.42 )
                                ref45_08.append( var[t_start + 7  + j*12 ] * 30.42 )
                                ref45_09.append( var[t_start + 8  + j*12 ] * 30.42 )
                                ref45_10.append( var[t_start + 9  + j*12 ] * 30.42 )
                                ref45_11.append( var[t_start + 10 + j*12 ] * 30.42 )
                                ref45_12.append( var[t_start + 11 + j*12 ] * 30.42 )

                if ( RCP == "26" ):
                        for j in range(0,11):                                        # 11 year from 0 to 10 starting from year_in (not properly decade)
                                ref26_01.append( var[t_start +      j*12 ] * 30.42 )      # total number of elements: 11*5 (11 years*number of models)
                                ref26_02.append( var[t_start + 1  + j*12 ] * 30.42 )
                                ref26_03.append( var[t_start + 2  + j*12 ] * 30.42 )
                                ref26_04.append( var[t_start + 3  + j*12 ] * 30.42 )
                                ref26_05.append( var[t_start + 4  + j*12 ] * 30.42 )
                                ref26_06.append( var[t_start + 5  + j*12 ] * 30.42 )
                                ref26_07.append( var[t_start + 6  + j*12 ] * 30.42 )
                                ref26_08.append( var[t_start + 7  + j*12 ] * 30.42 )
                                ref26_09.append( var[t_start + 8  + j*12 ] * 30.42 )
                                ref26_10.append( var[t_start + 9  + j*12 ] * 30.42 )
                                ref26_11.append( var[t_start + 10 + j*12 ] * 30.42 )
                                ref26_12.append( var[t_start + 11 + j*12 ] * 30.42 )

                del var
                i+=1

#*************** t_start setting *******************

if   ( year_middle == 2015 ):     # indexes starts with 0, t_start is refered to January of year_in for that decade. The value is get by: 12*(year_in - 2006)
        t_start = 48
elif ( year_middle == 2030 ):
        t_start = 228
elif ( year_middle == 2040 ):
        t_start = 348
elif ( year_middle == 2050 ):
        t_start = 468
elif ( year_middle == 2060 ):
        t_start = 588
elif ( year_middle == 2070 ):
        t_start = 708
elif ( year_middle == 2080 ):
        t_start = 828
elif ( year_middle == 2090 ):
        t_start = 948
else:
        print("Year-middle not valid")
        exit(1)


#============= Cumulative Monthly values for scenario decade ====================

for RCP in ["26", "45", "85"]:
	i=1
	for model in [ "HadGEM2-ES_RACMO22E", "MPI-ESM-LR_REMO2009", "EC-EARTH_CCLM4-8-17", "EC-EARTH_RACMO22E", "EC-EARTH_RCA4"]:

		#******* Reading netCDF file
		file_path=data_arc_dir+'/'+str(i)+"_"+model+"/postproc/monthly/"+"pr_"+model+"_rcp"+RCP+"_mon_future.nc"
	
		if ( not os.path.isfile( file_path ) ):
			print("File"+file_path+" doesn't exists or is corrupted")
			i+=1
			continue

		f_nc     = NetCDFFile( file_path , mode='r')     # I have to insert the two subdirectories intermedian /postproc/monthly/
		var      = f_nc.variables['pr'][:,lat_idx,lon_idx]

		if ( RCP == "85" ):
			for j in range(0,11):                                        # 11 year from 0 to 10 starting from year_in (not properly decade)
				var85_01.append( var[t_start +      j*12 ] * 30.42 )      # total number of elements: 11*5 (11 years*number of models)
				var85_02.append( var[t_start + 1  + j*12 ] * 30.42 )
				var85_03.append( var[t_start + 2  + j*12 ] * 30.42 )
				var85_04.append( var[t_start + 3  + j*12 ] * 30.42 )
				if ( ("pr_"+model+"_rcp"+RCP+"_mon_future.nc" == "pr_MPI-ESM-LR_REMO2009_rcp85_mon_future.nc") and ( j >= 9 ) and ( year_middle == 2090 ) ):
					break
				var85_05.append( var[t_start + 4  + j*12 ] * 30.42 )
				var85_06.append( var[t_start + 5  + j*12 ] * 30.42 )
				var85_07.append( var[t_start + 6  + j*12 ] * 30.42 )
				var85_08.append( var[t_start + 7  + j*12 ] * 30.42 )
				var85_09.append( var[t_start + 8  + j*12 ] * 30.42 )
				var85_10.append( var[t_start + 9  + j*12 ] * 30.42 )
				var85_11.append( var[t_start + 10 + j*12 ] * 30.42 )
				var85_12.append( var[t_start + 11 + j*12 ] * 30.42 )

		elif ( RCP == "45" ):
			for j in range(0,11):                                        # 11 year from 0 to 10 starting from year_in (not properly decade)
				var45_01.append( var[t_start +      j*12 ] * 30.42 )      # total number of elements: 11*5 (11 years*number of models)
				var45_02.append( var[t_start + 1  + j*12 ] * 30.42 )
				var45_03.append( var[t_start + 2  + j*12 ] * 30.42 )
				var45_04.append( var[t_start + 3  + j*12 ] * 30.42 )
				var45_05.append( var[t_start + 4  + j*12 ] * 30.42 )
				var45_06.append( var[t_start + 5  + j*12 ] * 30.42 )
				var45_07.append( var[t_start + 6  + j*12 ] * 30.42 )
				var45_08.append( var[t_start + 7  + j*12 ] * 30.42 )
				var45_09.append( var[t_start + 8  + j*12 ] * 30.42 )
				var45_10.append( var[t_start + 9  + j*12 ] * 30.42 )
				var45_11.append( var[t_start + 10 + j*12 ] * 30.42 )
				var45_12.append( var[t_start + 11 + j*12 ] * 30.42 )

		if ( RCP == "26" ):
			for j in range(0,11):                                        # 11 year from 0 to 10 starting from year_in (not properly decade)
				var26_01.append( var[t_start +      j*12 ] * 30.42 )      # total number of elements: 11*5 (11 years*number of models)
				var26_02.append( var[t_start + 1  + j*12 ] * 30.42 )
				var26_03.append( var[t_start + 2  + j*12 ] * 30.42 )
				var26_04.append( var[t_start + 3  + j*12 ] * 30.42 )
				var26_05.append( var[t_start + 4  + j*12 ] * 30.42 )
				var26_06.append( var[t_start + 5  + j*12 ] * 30.42 )
				var26_07.append( var[t_start + 6  + j*12 ] * 30.42 )
				var26_08.append( var[t_start + 7  + j*12 ] * 30.42 )
				var26_09.append( var[t_start + 8  + j*12 ] * 30.42 )
				var26_10.append( var[t_start + 9  + j*12 ] * 30.42 )
				var26_11.append( var[t_start + 10 + j*12 ] * 30.42 )
				var26_12.append( var[t_start + 11 + j*12 ] * 30.42 )

		del var
		i+=1

#*********** Number of models count *************

Dot_n = 0
for i in range( len(var26_12) ):
	if ( not type(var26_12[i]) == np.ma.core.MaskedConstant ):
		Dot_n += 1
Mod26_n = int( Dot_n / 11 )

Dot_n = 0
for i in range( len(var45_12) ):
        if ( not type(var45_12[i]) == np.ma.core.MaskedConstant ):
                Dot_n += 1
Mod45_n = int( Dot_n / 11 )

Dot_n = 0
for i in range( len(var85_12) ):
        if ( not type(var85_12[i]) == np.ma.core.MaskedConstant ):
                Dot_n += 1
Mod85_n = int( Dot_n / 11 )

#========= Delta =========

var26_01 = np.subtract( var26_01, stat.mean(ref26_01) ) 
var26_02 = np.subtract( var26_02, stat.mean(ref26_02) )
var26_03 = np.subtract( var26_03, stat.mean(ref26_03) )
var26_04 = np.subtract( var26_04, stat.mean(ref26_04) )
var26_05 = np.subtract( var26_05, stat.mean(ref26_05) )
var26_06 = np.subtract( var26_06, stat.mean(ref26_06) )
var26_07 = np.subtract( var26_07, stat.mean(ref26_07) )
var26_08 = np.subtract( var26_08, stat.mean(ref26_08) )
var26_09 = np.subtract( var26_09, stat.mean(ref26_09) )
var26_10 = np.subtract( var26_10, stat.mean(ref26_10) )
var26_11 = np.subtract( var26_11, stat.mean(ref26_11) )
var26_12 = np.subtract( var26_12, stat.mean(ref26_12) )

var45_01 = np.subtract( var45_01, stat.mean(ref45_01) )
var45_02 = np.subtract( var45_02, stat.mean(ref45_02) )
var45_03 = np.subtract( var45_03, stat.mean(ref45_03) )
var45_04 = np.subtract( var45_04, stat.mean(ref45_04) )
var45_05 = np.subtract( var45_05, stat.mean(ref45_05) )
var45_06 = np.subtract( var45_06, stat.mean(ref45_06) )
var45_07 = np.subtract( var45_07, stat.mean(ref45_07) )
var45_08 = np.subtract( var45_08, stat.mean(ref45_08) )
var45_09 = np.subtract( var45_09, stat.mean(ref45_09) )
var45_10 = np.subtract( var45_10, stat.mean(ref45_10) )
var45_11 = np.subtract( var45_11, stat.mean(ref45_11) )
var45_12 = np.subtract( var45_12, stat.mean(ref45_12) )

var85_01 = np.subtract( var85_01, stat.mean(ref85_01) )
var85_02 = np.subtract( var85_02, stat.mean(ref85_02) )
var85_03 = np.subtract( var85_03, stat.mean(ref85_03) )
var85_04 = np.subtract( var85_04, stat.mean(ref85_04) )
var85_05 = np.subtract( var85_05, stat.mean(ref85_05) )
var85_06 = np.subtract( var85_06, stat.mean(ref85_06) )
var85_07 = np.subtract( var85_07, stat.mean(ref85_07) )
var85_08 = np.subtract( var85_08, stat.mean(ref85_08) )
var85_09 = np.subtract( var85_09, stat.mean(ref85_09) )
var85_10 = np.subtract( var85_10, stat.mean(ref85_10) )
var85_11 = np.subtract( var85_11, stat.mean(ref85_11) )
var85_12  =np.subtract( var85_12, stat.mean(ref85_12) )

#=====================================================
#                 Boxplot creation
#=====================================================

if ( Mod85_n == 0 and Mod45_n == 0 and Mod26_n == 0  ):
        print("The values are all missing: the plot can't be done")
        exit(1)

fig , ax = plt.subplots(figsize=(20,15))

plt.title("Delta monthly cumulative precipitations scenario\nfrom:"+str(year_in)+" to "+str(year_fin)+" respect to 2010-2020 decade at point: "+point_name+"\n" , fontsize=28, fontdict={'family':'serif'} )
plt.xlabel("Month", fontsize=22 )
plt.ylabel( "Delta monthly cumulative precipitations [mm/month]", fontsize=22 )
plt.xticks(fontsize=18 )
plt.yticks(fontsize=18 )
plt.grid( linestyle='--')
plt.axis([ 0 , 37 , -300 , +400 ])
plt.hlines( 0. , -1. , +38. , linestyle="--", linewidth=1.8 )


bp85 = ax.boxplot( ( var85_01 , var85_02, var85_03, var85_04, var85_05, var85_06, var85_07, var85_08, var85_09, var85_10, var85_11, var85_12 )  ,
                positions=[ 2.7, 5.7, 8.7, 11.7, 14.7, 17.7, 20.7, 23.7, 26.7, 29.7, 32.7, 35.7 ], widths=0.5, patch_artist=True,
                showmeans=True, showfliers=True,
                medianprops={"color": "black", "linewidth": 3. },
                boxprops={"facecolor": "r", "edgecolor": "black",
                          "linewidth": 0.5},
                whiskerprops={"color": "black", "linewidth": 2. },
                capprops={"color": "black", "linewidth": 2. } ,
                meanprops={ "markerfacecolor": "blue", "marker":"o" , "markersize":10., "markeredgecolor":'black' } ,
                labels=("","","","","","","","","","","","") , manage_ticks=False )

bp45  = ax.boxplot( ( var45_01 , var45_02, var45_03, var45_04, var45_05, var45_06, var45_07, var45_08, var45_09, var45_10, var45_11, var45_12 )  ,
               positions=[ 2, 5, 8, 11, 14, 17, 20, 23, 26, 29, 32, 35], widths=0.5, patch_artist=True,
                showmeans=True, showfliers=True,
                medianprops={"color": "black", "linewidth": 3. },
                boxprops={"facecolor": "yellow", "edgecolor": "black",
                          "linewidth": 0.5},
                whiskerprops={"color": "black", "linewidth": 2. },
                capprops={"color": "black", "linewidth": 2. } ,
                meanprops={"markerfacecolor": "blue", "marker":"o" , "markersize":10. , "markeredgecolor":'black' } ,
                labels=("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec") )

bp26 = ax.boxplot( ( var26_01 , var26_02, var26_03, var26_04, var26_05, var26_06, var26_07, var26_08, var26_09, var26_10, var26_11, var26_12 )  ,
                positions=[ 1.3, 4.3, 7.3, 10.3, 13.3, 16.3, 19.3, 22.3, 25.3, 28.3, 31.3, 34.3 ], widths=0.5, patch_artist=True,
                showmeans=True, showfliers=True,
                medianprops={"color": "black", "linewidth": 3. },
                boxprops={"facecolor": "chartreuse", "edgecolor": "black",
                          "linewidth": 0.5},
                whiskerprops={"color": "black", "linewidth": 2. },
                capprops={"color": "black", "linewidth": 2. } ,
                meanprops={ "markerfacecolor": "blue", "marker":"o" , "markersize":10., "markeredgecolor":'black' } ,
                labels=("","","","","","","","","","","","") , manage_ticks=False )

ax.legend( [ bp85["boxes"][0] , bp45["boxes"][0] , bp26["boxes"][0] , bp26["means"][0] ] ,
        ['Ensemble RCP 8.5 - N.mod='+str(Mod85_n), 'Ensemble RCP 4.5 - N.mod='+str(Mod45_n), 'Ensemble RCP 2.6 - N.mod='+str(Mod26_n), 'Ensemble mean' ],   loc=2 , fontsize="x-large" )


plt.savefig( output_arc_dir+"/"+point_name+"/boxplot_delta_cumulative_monthly_pr_"+point_name+"_"+str(year_in)+"_"+str(year_fin)+".png" )

plt.close(fig)
