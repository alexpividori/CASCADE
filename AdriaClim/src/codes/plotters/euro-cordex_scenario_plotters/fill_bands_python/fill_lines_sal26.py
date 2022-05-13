from netCDF4 import Dataset as NetCDFFile 
import matplotlib.pyplot as plt
import numpy as np
import datetime
import bottleneck  
import sys

data_arc_dir='/lustre/arpa/AdriaClim/data/Med_CORDEX_files' 
output_arc_dir="/lustre/arpa/AdriaClim/public_html/Med_CORDEX_analysis/SCENARIO/edmub_lines_py"

f1 = NetCDFFile( data_arc_dir+'/CNRM-CM5_CNRM-RCSM4/edmub_sos_OMED-11i_CNRM-CM5_rcp26_r8i1p1_CNRM-RCSM4_v1_mon_195001_210012.nc', mode='r')

point_name = sys.argv[1]
lat_ref    = float(sys.argv[2])  # this is B02  45.2 13.04
lon_ref    = float(sys.argv[3])

wdw_mm = 60    # number of timesteps used for the mobile average

lat_v1   = f1.variables['lat'][:] 
lon_v1   = f1.variables['lon'][:] 
time_v1  = f1.variables['time'][:]
sal_v1  = f1.variables['sos'][:]


for i in range( len(lat_v1) ):
	if ( abs(lat_v1[i] - lat_ref ) < 0.01 ) :
	   lat_idx=i
	   break

for i in range( len(lon_v1) ):
        if ( abs(lon_v1[i] - lon_ref ) < 0.01 ) :
           lon_idx=i
           break

#============================================================
fig, ax = plt.subplots(figsize=(20,15))

dateList1  = []

#================== Creation of dates ========================

t_start1 = datetime.datetime.strptime( "1949-01-01::00:00:00" , "%Y-%m-%d::%H:%M:%S")

for i in range( len(time_v1) ):
	time_delta = datetime.timedelta( days = time_v1[i] )
	dateList1.append( t_start1 + time_delta )


v1_mm = bottleneck.move_mean( sal_v1[:,lat_idx,lon_idx],  window=wdw_mm , min_count = None )

for i in range( len(v1_mm) ):
	if ( v1_mm[i] >  1e+10  ):
	     v1_mm[i] = np.nan

#=====================================================================================
#                                       Plot
#=====================================================================================

plt.title("Delta Salinity scenario respect to 2010-2020 decade at point: "+point_name , fontsize=30, fontdict={'family':'serif'} )
plt.xlabel("year", fontsize=25 )
plt.ylabel("Sea surface delta salinity [PSU]", fontsize=25 )
plt.xticks(fontsize=18 )
plt.yticks(fontsize=18 )

plt.plot( dateList1 , v1_mm , color="chartreuse", label='$Ensemble$ $element$ $RCP$ $2.6$' )

plt.vlines( datetime.datetime.strptime( "2020-01-01::00:00:00" , "%Y-%m-%d::%H:%M:%S") , -3. , +5. , linestyle="--" )
plt.hlines( 0. , datetime.datetime.strptime( "1950-01-01::00:00:00" , "%Y-%m-%d::%H:%M:%S") , datetime.datetime.strptime( "2120-01-01::00:00:00" , "%Y-%m-%d::%H:%M:%S") ,
    linestyle="--" )
plt.legend(loc=2 , fontsize="x-large" )
plt.axis([ datetime.datetime.strptime( "1950-01-01::00:00:00" , "%Y-%m-%d::%H:%M:%S") , datetime.datetime.strptime( "2105-01-01::00:00:00" , "%Y-%m-%d::%H:%M:%S") , -2. , 2.])
plt.grid()

plt.savefig( output_arc_dir+"/"+point_name+"/edmub_fillrcp26_sal_"+point_name+".png")

# Close the figure
plt.close(fig)
