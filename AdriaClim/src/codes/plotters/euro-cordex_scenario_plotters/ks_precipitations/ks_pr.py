from netCDF4 import Dataset as NetCDFFile 
import matplotlib.pyplot as plt
import numpy as np
import sys
import os.path
from scipy.stats import ks_2samp


point_name  =       sys.argv[1]
lat_ref     = float(sys.argv[2])  
lon_ref     = float(sys.argv[3])
RCP         =       sys.argv[4]
year_middle =   int(sys.argv[5])

data_arc_dir='/lustre/arpa/AdriaClim/data/EURO-CORDEX/FVG' 
output_arc_dir="/lustre/arpa/AdriaClim/public_html/EURO_CORDEX_analysis/SCENARIO/ks_p-value_py"

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

var_ref01 = []
var_ref02 = []
var_ref03 = []
var_ref04 = []
var_ref05 = []
var_ref06 = []
var_ref07 = []
var_ref08 = []
var_ref09 = []
var_ref10 = []
var_ref11 = []
var_ref12 = []

var01 = []
var02 = []
var03 = []
var04 = []
var05 = []
var06 = []
var07 = []
var08 = []
var09 = []
var10 = []
var11 = []
var12 = []

#============= Acquisition of REFERENCE variable data from all netCDF RCP set ===============

year_in  = year_middle - 5
year_fin = year_middle + 5

i=1
for model in [ "HadGEM2-ES_RACMO22E", "MPI-ESM-LR_REMO2009", "EC-EARTH_CCLM4-8-17", "EC-EARTH_RACMO22E", "EC-EARTH_RCA4" ]:
	
	#******* Reading netCDF file ********
	file_path = data_arc_dir+'/'+str(i)+"_"+model+"/pr_"+model+"_rcp"+RCP+"_future.nc"
	
	#************************************

	if ( not os.path.isfile( file_path )  ):
		print("File"+file_path+" doesn't exists or is corrupted")
		i+=1
		continue

	f_nc       = NetCDFFile( file_path , mode='r')             # I have to insert the two subdirectories intermedian /postproc/monthly/
	var        = f_nc.variables['pr'][:,lat_idx,lon_idx]

	if ( model == "HadGEM2-ES_RACMO22E" ):
		t_start =  ( year_in - 2006 ) * 360
		for j in range(0,11):  
			var01.extend( var[ ( t_start + j*360       ) : ( t_start + j*360 + 30       ) ]  )  # in 360 days calendar we add 31 to each month because 
			var02.extend( var[ ( t_start + j*360 + 30  ) : ( t_start + j*360 + 30  + 30 ) ]  )  # the upper limit is not included
			var03.extend( var[ ( t_start + j*360 + 60  ) : ( t_start + j*360 + 60  + 30 ) ]  )
			var04.extend( var[ ( t_start + j*360 + 90  ) : ( t_start + j*360 + 90  + 30 ) ]  )
			var05.extend( var[ ( t_start + j*360 + 120 ) : ( t_start + j*360 + 120 + 30 ) ]  )
			var06.extend( var[ ( t_start + j*360 + 150 ) : ( t_start + j*360 + 150 + 30 ) ]  )
			var07.extend( var[ ( t_start + j*360 + 180 ) : ( t_start + j*360 + 180 + 30 ) ]  )
			var08.extend( var[ ( t_start + j*360 + 210 ) : ( t_start + j*360 + 210 + 30 ) ]  )
			var09.extend( var[ ( t_start + j*360 + 240 ) : ( t_start + j*360 + 240 + 30 ) ]  )
			var10.extend( var[ ( t_start + j*360 + 270 ) : ( t_start + j*360 + 270 + 30 ) ]  )
			var11.extend( var[ ( t_start + j*360 + 300 ) : ( t_start + j*360 + 300 + 30 ) ]  )
			var12.extend( var[ ( t_start + j*360 + 330 ) : ( t_start + j*360 + 330 + 30 ) ]  )

			var_ref01.extend( var[ ( 1440 + j*360       ) : ( 1440 + j*360 + 30       ) ]  )
			var_ref02.extend( var[ ( 1440 + j*360 + 30  ) : ( 1440 + j*360 + 30  + 30 ) ]  )
			var_ref03.extend( var[ ( 1440 + j*360 + 60  ) : ( 1440 + j*360 + 60  + 30 ) ]  )
			var_ref04.extend( var[ ( 1440 + j*360 + 90  ) : ( 1440 + j*360 + 90  + 30 ) ]  )
			var_ref05.extend( var[ ( 1440 + j*360 + 120 ) : ( 1440 + j*360 + 120 + 30 ) ]  )
			var_ref06.extend( var[ ( 1440 + j*360 + 150 ) : ( 1440 + j*360 + 150 + 30 ) ]  )
			var_ref07.extend( var[ ( 1440 + j*360 + 180 ) : ( 1440 + j*360 + 180 + 30 ) ]  )
			var_ref08.extend( var[ ( 1440 + j*360 + 210 ) : ( 1440 + j*360 + 210 + 30 ) ]  )
			var_ref09.extend( var[ ( 1440 + j*360 + 240 ) : ( 1440 + j*360 + 240 + 30 ) ]  )
			var_ref10.extend( var[ ( 1440 + j*360 + 270 ) : ( 1440 + j*360 + 270 + 30 ) ]  )
			var_ref11.extend( var[ ( 1440 + j*360 + 300 ) : ( 1440 + j*360 + 300 + 30 ) ]  )
			var_ref12.extend( var[ ( 1440 + j*360 + 330 ) : ( 1440 + j*360 + 330 + 30 ) ]  )

	if ( model != "HadGEM2-ES_RACMO22E" ):
		for j in range(0,11):                                                                        # j goes from 0 to 10. for a total of  11 year (ex. from 2025 to 2035 )
			t_start =  ( year_in - 2006 ) * 365 + int(( year_in + j - 2008)/4.     )             # 2008 was the first bissextile year after 2006
			var01.extend( var[ ( t_start + j*365       ) : ( t_start + j*365       + 31 ) ]  )
			var02.extend( var[ ( t_start + j*365 + 31  ) : ( t_start + j*365 + 31  + 28 ) ]  )
			t_start =  ( year_in - 2006 ) * 365 + int(( year_in + j - 2008)/4. + 1 )
			var03.extend( var[ ( t_start + j*365 + 59  ) : ( t_start + j*365 + 59  + 31 ) ]  )
			var04.extend( var[ ( t_start + j*365 + 90  ) : ( t_start + j*365 + 90  + 30 ) ]  )
			var05.extend( var[ ( t_start + j*365 + 120 ) : ( t_start + j*365 + 120 + 31 ) ]  )
			var06.extend( var[ ( t_start + j*365 + 151 ) : ( t_start + j*365 + 151 + 30 ) ]  )
			var07.extend( var[ ( t_start + j*365 + 181 ) : ( t_start + j*365 + 181 + 31 ) ]  )
			var08.extend( var[ ( t_start + j*365 + 212 ) : ( t_start + j*365 + 212 + 31 ) ]  )
			var09.extend( var[ ( t_start + j*365 + 243 ) : ( t_start + j*365 + 243 + 30 ) ]  )
			var10.extend( var[ ( t_start + j*365 + 273 ) : ( t_start + j*365 + 273 + 31 ) ]  )
			var11.extend( var[ ( t_start + j*365 + 304 ) : ( t_start + j*365 + 304 + 30 ) ]  )
			var12.extend( var[ ( t_start + j*365 + 334 ) : ( t_start + j*365 + 334 + 31 ) ]  )

			var_ref01.extend( var[ ( 1460 + j*365       ) : ( 1460 + j*365       + 31 ) ]  )
			var_ref02.extend( var[ ( 1460 + j*365 + 31  ) : ( 1460 + j*365 + 31  + 28 ) ]  )
			var_ref03.extend( var[ ( 1460 + j*365 + 59  ) : ( 1460 + j*365 + 59  + 31 ) ]  )
			var_ref04.extend( var[ ( 1460 + j*365 + 90  ) : ( 1460 + j*365 + 90  + 30 ) ]  )
			var_ref05.extend( var[ ( 1460 + j*365 + 120 ) : ( 1460 + j*365 + 120 + 31 ) ]  )
			var_ref06.extend( var[ ( 1460 + j*365 + 151 ) : ( 1460 + j*365 + 151 + 30 ) ]  )
			var_ref07.extend( var[ ( 1460 + j*365 + 181 ) : ( 1460 + j*365 + 181 + 31 ) ]  )
			var_ref08.extend( var[ ( 1460 + j*365 + 212 ) : ( 1460 + j*365 + 212 + 31 ) ]  )
			var_ref09.extend( var[ ( 1460 + j*365 + 243 ) : ( 1460 + j*365 + 243 + 30 ) ]  )
			var_ref10.extend( var[ ( 1460 + j*365 + 273 ) : ( 1460 + j*365 + 273 + 31 ) ]  )
			var_ref11.extend( var[ ( 1460 + j*365 + 304 ) : ( 1460 + j*365 + 304 + 30 ) ]  )
			var_ref12.extend( var[ ( 1460 + j*365 + 334 ) : ( 1460 + j*365 + 334 + 31 ) ]  )
	

#		if ( "pr_"+model+"_rcp85_future.nc" != "pr_MPI-ESM-LR_REMO2009_rcp85_future.nc" ):


	i+=1

#=====================================================
#           Kosmogorov-Smirnof test
#=====================================================

p_value = ["","","","","","","","","","","",""]
red_m   = []
green_m = []
red_x   = []
green_x = []

p_value[0]  = float( str( ks_2samp( var_ref01, var01, alternative='two-sided') ).split('=')[2].split(')')[0] )
p_value[1]  = float( str( ks_2samp( var_ref02, var02, alternative='two-sided') ).split('=')[2].split(')')[0] )
p_value[2]  = float( str( ks_2samp( var_ref03, var03, alternative='two-sided') ).split('=')[2].split(')')[0] )
p_value[3]  = float( str( ks_2samp( var_ref04, var04, alternative='two-sided') ).split('=')[2].split(')')[0] )
p_value[4]  = float( str( ks_2samp( var_ref05, var05, alternative='two-sided') ).split('=')[2].split(')')[0] )
p_value[5]  = float( str( ks_2samp( var_ref06, var06, alternative='two-sided') ).split('=')[2].split(')')[0] )
p_value[6]  = float( str( ks_2samp( var_ref07, var07, alternative='two-sided') ).split('=')[2].split(')')[0] )
p_value[7]  = float( str( ks_2samp( var_ref08, var08, alternative='two-sided') ).split('=')[2].split(')')[0] )
p_value[8]  = float( str( ks_2samp( var_ref09, var09, alternative='two-sided') ).split('=')[2].split(')')[0] )
p_value[9]  = float( str( ks_2samp( var_ref10, var10, alternative='two-sided') ).split('=')[2].split(')')[0] )
p_value[10] = float( str( ks_2samp( var_ref11, var11, alternative='two-sided') ).split('=')[2].split(')')[0] )
p_value[11] = float( str( ks_2samp( var_ref12, var12, alternative='two-sided') ).split('=')[2].split(')')[0] )

for i in range(0,12):
	if ( p_value[i] <= 0.05 ):
		red_m.append( p_value[i] )
		red_x.append( i + 1 )
	else:
		green_m.append( p_value[i] )
		green_x.append( i + 1 )

#====================================================
#                     Plot
#====================================================

fig , ax = plt.subplots(figsize=(20,15))

plt.title("Kolmogorov-Smirnov test for daily precipitations at: "+point_name+",\nRCP:"+str(RCP)+" decade:"+str(year_in)+"-"+str(year_fin)+" respect to 2010-2020 decade\n" , fontsize=30, fontdict={'family':'serif'} )
plt.xlabel("\nMonth", fontsize=25 )
plt.ylabel( "p value", fontsize=25 )
plt.yticks(fontsize=18 )
plt.xticks( range(1,13) , ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"] , fontsize=20 )
plt.grid( linestyle='--')
plt.hlines( 0.05 , -1. , +15. , linestyle="--", linewidth=1.5 , color="black" )
plt.axis([ 0 , 13 , -0.01 , 1.0 ])

plt.plot( red_x   , red_m   , marker="o" , markeredgewidth=0 , markersize=12.0, linestyle='', markerfacecolor="r" ,          label="Reject:  p-val $\leq$ 0.05" )
plt.plot( green_x , green_m , marker="o" , markeredgewidth=0 , markersize=12.0, linestyle='', markerfacecolor="lightgreen" , label="Accept: p-val $>$ 0.05")
plt.legend(loc='upper left', fontsize="xx-large", title="               Null Hypothesis: \nDistribution function are the same", title_fontsize="x-large" )

plt.savefig( output_arc_dir+"/"+point_name+"/p-value_pr_"+point_name+"_rcp"+str(RCP)+"_"+str(year_in)+"_"+str(year_fin)+".png" )
plt.close(fig)
