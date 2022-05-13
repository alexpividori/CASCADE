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
n_month     =   int(sys.argv[6])

data_arc_dir='/lustre/arpa/AdriaClim/data/EURO-CORDEX/FVG' 
output_arc_dir="/lustre/arpa/AdriaClim/public_html/EURO_CORDEX_analysis/SCENARIO/ks_ecdf_py"

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

	else:
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
	
	i+=1

#===============================================================================
#                                Data analysis
#===============================================================================

var=eval( "var"+str('{:0>2}'.format(n_month)) )
var_ref=eval( "var_ref"+str('{:0>2}'.format(n_month)) )


p_value  = '{:.3f}'.format( float( str( ks_2samp( var_ref , var , alternative='two-sided') ).split('=')[2].split(')')[0] ) )
D_val    = '{:.3f}'.format( float( str( ks_2samp( var_ref , var , alternative='two-sided') ).split('=')[1].split(',')[0] ) )

n     = len( var     )
n_ref = len( var_ref )

var.sort()
var_ref.sort()

ECDF_y   = np.arange(1, n     + 1) / n
ECDF_ref = np.arange(1, n_ref + 1) / n_ref

#pr_val = np.arange(0 , 50 , 0.01 )

pr_val=list(dict.fromkeys( var + var_ref ))    # remove multiple values
pr_val.sort()                                  # with this sample pr value the software is so faster and more accurate

count     = [0]*len(pr_val)
count_ref = [0]*len(pr_val)

for i in range(0 , len(pr_val) ):           # precipitation range
	for j in range( n ):
		if ( var[j]     <= pr_val[i] ):
			count[i]     += 1
		else:
			break
	for j in range( n_ref ):
		if ( var_ref[j] <= pr_val[i] ):
			count_ref[i] += 1
		else:
			break


delta = np.subtract( np.divide( count , n ) , np.divide( count_ref , n_ref ) ) 

ks_cr05 = 1.36/ np.sqrt( ( len(var) * len(var_ref) ) / ( len(var) + len(var_ref) ) )
ks_cr01 = 1.63/ np.sqrt( ( len(var) * len(var_ref) ) / ( len(var) + len(var_ref) ) )

#====================================================
#                     Plot
#====================================================

months=["January","February","March","April","May","June","July","August","September","October","November","December"]
month=months[n_month - 1]

fig , ax = plt.subplots( ncols=1, nrows=2, gridspec_kw={ 'height_ratios':[2,1] } , figsize=(20,15) )

plt.figure(1)

plt.subplot(2, 1, 1)
plt.suptitle("ECDF for daily precipitations in "+month+" at: "+point_name+",\nRCP:"+str(RCP)+\
" decade:"+str(year_in)+"-"+str(year_fin)+" respect to 2010-2020 decade\n" , fontsize=28, fontdict={'family':'serif'} )
plt.title( "$ n_{"+str(year_in)+"-"+str(year_fin)+"}$="+str(n)+"             $n_{2010-2020}$="+str(n_ref)+"       p-value="+str(p_value) , fontsize=20 )
plt.xlabel("Daily precipitation [mm/day]", fontsize=20 )
plt.ylabel( "Empirical cumulative\ndistribution function", fontsize=23 )
plt.xticks(fontsize=18 )
plt.yticks(fontsize=18 )
plt.grid( linestyle='--')
plt.hlines( 0.25 , -1. , +200 , linestyle="--", linewidth=1.5 , color="black" )
plt.hlines( 0.50 , -1. , +200 , linestyle="--", linewidth=1.5 , color="black" )
plt.hlines( 0.75 , -1. , +200 , linestyle="--", linewidth=1.5 , color="black" )
plt.text( 38, 0.25, 'First quartile', fontsize="xx-large" , ha ='right', va ='bottom')
plt.text( 38, 0.50, 'Median'        , fontsize="xx-large" , ha ='right', va ='bottom')
plt.text( 38, 0.75, 'Third quartile', fontsize="xx-large" , ha ='right', va ='bottom')
plt.axis( [ -1 , 50 , 0.2 , 1.0] )

plt.plot( var     , ECDF_y     , linestyle='-' , linewidth=1.8 , color="blue", label="ECDF: "+str(year_in)+"-"+str(year_fin) )
plt.plot( var_ref , ECDF_ref   , linestyle='-' , linewidth=1.8 , color="r"   , label="ECDF: 2010-2020" )

plt.legend( loc='lower right', fontsize="xx-large", facecolor="white" , framealpha=1.0 )

#=================================================================================

plt.subplot(2, 1, 2)
plt.xlabel("Daily precipitation [mm/day]", fontsize=20 )
plt.ylabel( "Delta ECDF's", fontsize=23 )
plt.xticks(fontsize=18 )
plt.yticks(fontsize=18 )
plt.grid( linestyle='--')
plt.hlines(     0.0   , -1. , +200 , linestyle="--", linewidth=1.2 , color="black" )
plt.hlines(  ks_cr05  , -1. , +200 , linestyle="--", linewidth=1.0 , color="black" )
plt.hlines( -ks_cr05  , -1. , +200 , linestyle="--", linewidth=1.0 , color="black" )
plt.hlines(  ks_cr01  , -1. , +200 , linestyle="--", linewidth=1.0 , color="black" )
plt.hlines( -ks_cr01  , -1. , +200 , linestyle="--", linewidth=1.0 , color="black" )

plt.axis([ -1 , 50 , -( max( np.abs(delta) ) + 0.002 ) , max( np.abs(delta)) + 0.002 ])

plt.plot( pr_val , delta  , linestyle='-' , linewidth=1.8 , color="r"   , label="$ECDF_{"+str(year_in)+"-"+str(year_fin)+"} - ECDF_{2010-2020}$" )
plt.legend( loc='lower right', fontsize="xx-large", facecolor="white" , framealpha=1.0 )
plt.text( 50 - 1 , max( np.abs(delta))-0.002 , "|$D_{KS}|=$"+str(D_val)+"\n$c_{0.05}=$"+str('{:.4f}'.format(ks_cr05))+"\n$c_{0.01}=$"+str('{:.4f}'.format(ks_cr01)) ,\
          ha ='right', va ='top', fontsize=18 , bbox=dict(boxstyle="square", ec="white", fc="white" ) )

if ( ks_cr01 <=  max(np.abs(delta))  ):
        plt.text( 34,  ks_cr01 , "$c_{0.01}$", ha ='right', va ='bottom', fontsize="xx-large")
        plt.text( 34, -ks_cr01 , "$c_{0.01}$", ha ='right', va ='bottom', fontsize="xx-large")


if ( ks_cr05 <=  max(np.abs(delta))  ):
	plt.text( 34,  ks_cr05 , "$c_{0.05}$", ha ='right', va ='bottom', fontsize="xx-large")
	plt.text( 34, -ks_cr05 , "$c_{0.05}$", ha ='right', va ='bottom', fontsize="xx-large")


plt.savefig( output_arc_dir+"/"+point_name+"/ecdf_pr_"+point_name+"_rcp"+str(RCP)+"_"+str('{:0>2}'.format(n_month))+"_"+str(year_in)+"_"+str(year_fin)+".png" )
plt.close(fig)
