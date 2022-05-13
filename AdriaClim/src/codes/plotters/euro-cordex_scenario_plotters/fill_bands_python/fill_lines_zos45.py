from netCDF4 import Dataset as NetCDFFile 
import matplotlib.pyplot as plt
import numpy as np
import datetime
import bottleneck  
import sys

data_arc_dir='/lustre/arpa/AdriaClim/data/Med_CORDEX_files' 
output_arc_dir="/lustre/arpa/AdriaClim/public_html/Med_CORDEX_analysis/SCENARIO/edmub_lines_py"

f1 = NetCDFFile( data_arc_dir+'/CMCC-CM_COSMOMED/edmub_zos_MED-06_CMCC-CM_rcp45_r1i1p1_COSMOMED_v1_mon_195901_210012.nc', mode='r')
f2 = NetCDFFile( data_arc_dir+'/CNRM-CM5_CNRM-RCSM4/edmub_zos_MED-10_CNRM-CM5_rcp45_r8i1p1_CNRM-RCSM4_v1_mon_195001_210012.nc', mode='r')

point_name = sys.argv[1]
lat_ref    = float(sys.argv[2])  # this is B02  45.2 13.04
lon_ref    = float(sys.argv[3])

wdw_mm = 60    # number of timesteps used for the mobile average

lat_v1   = f1.variables['lat'][:] 
lon_v1   = f1.variables['lon'][:] 
time_v1  = f1.variables['time'][:]
zos_v1  = f1.variables['zos'][:]

time_v2  = f2.variables['time'][:]
zos_v2  = f2.variables['zos'][:]


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
dateList2  = []

#================== Creation of dates ========================

t_start1 = datetime.datetime.strptime( "1959-01-01::00:00:00" , "%Y-%m-%d::%H:%M:%S")

for i in range( len(time_v1) ):
	time_delta = datetime.timedelta( seconds = time_v1[i] )
	dateList1.append( t_start1 + time_delta )

t_start2 = datetime.datetime.strptime( "1950-01-01::00:00:00" , "%Y-%m-%d::%H:%M:%S")
for i in range( len(time_v2) ):
        time_delta = datetime.timedelta( days = time_v2[i]*30.42 )
        dateList2.append( t_start2 + time_delta )


v1_mm = bottleneck.move_mean( zos_v1[:,lat_idx,lon_idx],  window=wdw_mm , min_count = None )
v2_mm = bottleneck.move_mean( zos_v2[:,lat_idx,lon_idx],  window=wdw_mm , min_count = None )

for i in range( len(v1_mm) ):
	if ( v1_mm[i] >  1e+10  ):
	     v1_mm[i] = np.nan

for i in range( len(v2_mm) ):
	if ( v2_mm[i] >  1e+10  ):
	     v2_mm[i] = np.nan


#==================== Percentile lines ====================
# we start from 2020 because de differences are calculated 
# respect to 2010-2020 decade

min_v      = []
max_v      = []
perc_50    = []   # median
dates_perc = []


date_ref = datetime.datetime.strptime( "2020-01-01::00:00:00" , "%Y-%m-%d::%H:%M:%S")
st_t1 = int(( date_ref - dateList1[0] )/datetime.timedelta( days = 30.42 ))
st_t2 = int(( date_ref - dateList2[0] )/datetime.timedelta( days = 30.42 ))

for i in range(970):
	vals = (v1_mm[ st_t1 + i ], v2_mm[ st_t2 + i ]  )
	min_v.append( np.nanmin(vals) )
	max_v.append( np.nanmax(vals) )
	perc_50.append( np.nanpercentile(vals,50) )
	dates_perc.append( date_ref + datetime.timedelta( days = 30.42 * i ) )

#=====================================================================================
#                                       Plot
#=====================================================================================

plt.title("Delta Sea surface height scenario respect to 2010-2020 decade at point: "+point_name+"\n" , fontsize=30, fontdict={'family':'serif'} , y=1.0 )
plt.xlabel("year", fontsize=25 )
plt.ylabel("Sea surface delta height [m]", fontsize=25 )
plt.xticks(fontsize=18 )
plt.yticks(fontsize=18 )

plt.plot( dateList1 , v1_mm , color="y", label='$Ensemble$ $element$ $RCP$ $4.5$' )
plt.plot( dateList2 , v2_mm , color="y" )

if ( not point_name in ["B01","P03","P04","P05","P06","P07","P08","P09","P10","P11"] ):
	plt.plot( dates_perc , perc_50, color="blue" , linestyle=":", label='$Ensemble$ $Median$' )
	plt.fill_between( dates_perc , min_v , max_v , alpha=.5, linewidth=0 , color="y" , label="$Min$ $to$ $Max$ $model$ $RCP$ $4.5$" )

plt.vlines( datetime.datetime.strptime( "2020-01-01::00:00:00" , "%Y-%m-%d::%H:%M:%S") , -3. , +5. , linestyle="--" )
plt.hlines( 0. , datetime.datetime.strptime( "1950-01-01::00:00:00" , "%Y-%m-%d::%H:%M:%S") , datetime.datetime.strptime( "2120-01-01::00:00:00" , "%Y-%m-%d::%H:%M:%S") ,
    linestyle="--" )
plt.legend(loc=2 , fontsize="x-large" )
plt.axis([ datetime.datetime.strptime( "1950-01-01::00:00:00" , "%Y-%m-%d::%H:%M:%S") , datetime.datetime.strptime( "2105-01-01::00:00:00" , "%Y-%m-%d::%H:%M:%S") , -0.2 , +0.2 ])
plt.grid()

plt.savefig( output_arc_dir+"/"+point_name+"/edmub_fillrcp45_zos_"+point_name+".png")

# Close the figure
plt.close(fig)
