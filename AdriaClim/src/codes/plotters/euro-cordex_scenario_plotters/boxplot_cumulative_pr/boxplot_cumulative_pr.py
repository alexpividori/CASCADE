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
RCP         = sys.argv[4]
year_middle = int(sys.argv[5])

data_arc_dir='/lustre/arpa/AdriaClim/data/EURO-CORDEX/FVG' 
output_arc_dir="/lustre/arpa/AdriaClim/public_html/EURO_CORDEX_analysis/SCENARIO/boxplot_cumulative_py"

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

var_01 = []
var_02 = []
var_03 = []
var_04 = []
var_05 = []
var_06 = []
var_07 = []
var_08 = []
var_09 = []
var_10 = []
var_11 = []
var_12 = []


#*************** t_start setting *******************

if   ( year_middle == 2015 ):
        t_start = 48
#elif ( year_middle == 2020 ):     # decade from 2015 to 2025 doesn't exists
#        t_start = 108
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

#============= Acquisition of variable data from all netCDF set ===============

i=1
year_in   = year_middle - 5
year_fin  = year_middle + 5

for model in [ "HadGEM2-ES_RACMO22E", "MPI-ESM-LR_REMO2009", "EC-EARTH_CCLM4-8-17", "EC-EARTH_RACMO22E", "EC-EARTH_RCA4"]:

	#******* Reading netCDF file
	file_path=data_arc_dir+'/'+str(i)+"_"+model+"/postproc/monthly/"+"pr_"+model+"_rcp"+RCP+"_mon_future.nc"
	
	if ( not os.path.isfile( file_path ) ) or ( "pr_"+model+"_rcp"+RCP+"_mon_future.nc" == "pr_MPI-ESM-LR_REMO2009_rcp85_mon_future.nc" ):
		print("File"+file_path+" doesn't exists or is corrupted")
		i+=1
		continue

	f_nc     = NetCDFFile( file_path , mode='r')     # I have to insert the two subdirectories intermedian /postproc/monthly/
	var      = f_nc.variables['pr'][:,lat_idx,lon_idx]

	for j in range(0,11):                                        # 11 year from 0 to 10 starting from year_in (not properly decade)
		var_01.append( var[t_start +      j*12 ] * 30 )      # total number of elements: 11*5 (11 years*number of models)
		var_02.append( var[t_start + 1  + j*12 ] * 30 )
		var_03.append( var[t_start + 2  + j*12 ] * 30 )
		var_04.append( var[t_start + 3  + j*12 ] * 30 )
		var_05.append( var[t_start + 4  + j*12 ] * 30 )
		var_06.append( var[t_start + 5  + j*12 ] * 30 )
		var_07.append( var[t_start + 6  + j*12 ] * 30 )
		var_08.append( var[t_start + 7  + j*12 ] * 30 )
		var_09.append( var[t_start + 8  + j*12 ] * 30 )
		var_10.append( var[t_start + 9  + j*12 ] * 30 )
		var_11.append( var[t_start + 10 + j*12 ] * 30 )
		var_12.append( var[t_start + 11 + j*12 ] * 30 )

	del var
	i+=1

#*********** Number of models count *************

Dot_n = 0
for i in range( len(var_01) ):
	if ( not type(var_01[i]) == np.ma.core.MaskedConstant ):
		Dot_n += 1

Mod_n = int( Dot_n / 11 )

#=====================================================
#                 Boxplot creation
#=====================================================

if   ( RCP == "26" ):
	box_color = "chartreuse"
elif ( RCP == "45" ):
	box_color = "yellow"
elif ( RCP == "85" ):
	box_color = "red"

fig , ax = plt.subplots(figsize=(20,15))

plt.title("Cumulative monthly precipitations scenario (rcp"+RCP+") from "+str(year_in)+" to "+str(year_fin)+" at point: "+point_name+"\n" , fontsize=30, fontdict={'family':'serif'} )
plt.xlabel("\nMonth", fontsize=25 )
plt.ylabel( "Cumulative precipitations [$mm/month$]", fontsize=25 )
plt.xticks( [1,2,3,4,5,6,7,8,9,10,11,12] , ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"] ,fontsize=20 )
plt.yticks(fontsize=18 )
plt.grid( linestyle='--')
plt.axis([ 0 , 13 , -5 , 550 ])
plt.hlines( 0. , -1. , +25. , linestyle="--", linewidth=1.8 )


bp = ax.boxplot( ( var_01,var_02,var_03,var_04,var_05,var_06,var_07,var_08,var_09 ,var_10,var_11,var_12 )  , 
                positions=[1,2,3,4,5,6,7,8,9,10,11,12], widths=0.5, patch_artist=True,
                showmeans=True, showfliers=True,
                medianprops={"color": "black", "linewidth": 3. },
                boxprops={"facecolor": box_color, "edgecolor": "black",
                          "linewidth": 0.5},
                whiskerprops={"color": "black", "linewidth": 2. },
                capprops={"color": "black", "linewidth": 2. } ,
                meanprops={ "markerfacecolor": "blue", "marker":"o" , "markersize":10., "markeredgecolor":'black' } ,
                labels=("","","","","","","","","","","","") , manage_ticks=False ) 


ax.legend( [ bp["boxes"][0]  , bp["means"][0] ] , ['Ensemble RCP '+RCP+' N.mod='+str(Mod_n), 'Ensemble mean' ], loc=2, fontsize="x-large" )


plt.savefig( output_arc_dir+"/"+point_name+"/boxplot_cumulative_pr_"+point_name+"_rcp"+RCP+"_"+str(year_in)+"_"+str(year_fin)+".png" )

plt.close(fig)
