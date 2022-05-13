from netCDF4 import Dataset as NetCDFFile 
import matplotlib.pyplot as plt
import numpy as np
import datetime
import bottleneck  
import sys

data_arc_dir='/lustre/arpa/AdriaClim/data/Med_CORDEX_files' 
output_arc_dir="/lustre/arpa/AdriaClim/public_html/Med_CORDEX_analysis/SCENARIO/edmub_lines_py"

f1 = NetCDFFile( data_arc_dir+'/CMCC-CM_COSMOMED/edmub_zos_MED-06_CMCC-CM_rcp85_r1i1p1_COSMOMED_v1_mon_195901_210012.nc', mode='r')
f2 = NetCDFFile( data_arc_dir+'/CNRM-CM5_CNRM-RCSM4/edmub_zos_MED-10_CNRM-CM5_rcp85_r8i1p1_CNRM-RCSM4_v1_mon_195001_210012.nc', mode='r')

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

for i in range(960):
	vals = (v1_mm[ st_t1 + i ], v2_mm[ st_t2 + i ]  )
	min_v.append( np.nanmin(vals) )
	max_v.append( np.nanmax(vals) )
	perc_50.append( np.nanpercentile(vals,50) )
	dates_perc.append( date_ref + datetime.timedelta( days = 30.42 * i ) )

#===================================================================
#                              RCP 4.5
#===================================================================

g1 = NetCDFFile( data_arc_dir+'/CMCC-CM_COSMOMED/edmub_zos_MED-06_CMCC-CM_rcp45_r1i1p1_COSMOMED_v1_mon_195901_210012.nc', mode='r')
g2 = NetCDFFile( data_arc_dir+'/CNRM-CM5_CNRM-RCSM4/edmub_zos_MED-10_CNRM-CM5_rcp45_r8i1p1_CNRM-RCSM4_v1_mon_195001_210012.nc', mode='r')

time_g1  = g1.variables['time'][:]
zos_g1   = g1.variables['zos'][:]

time_g2  = g2.variables['time'][:]
zos_g2   = g2.variables['zos'][:]

#==================================================

dateList1g  = []
dateList2g  = []

#================== Creation of dates ========================

t_start1g = datetime.datetime.strptime( "1959-01-01::00:00:00" , "%Y-%m-%d::%H:%M:%S")

for i in range( len(time_g1) ):
        time_delta = datetime.timedelta( seconds = time_g1[i] )
        dateList1g.append( t_start1g + time_delta )

t_start2g = datetime.datetime.strptime( "1950-01-01::00:00:00" , "%Y-%m-%d::%H:%M:%S")
for i in range( len(time_g2) ):
        time_delta = datetime.timedelta( days = time_g2[i]*30.42 )
        dateList2g.append( t_start2g + time_delta )


g1_mm = bottleneck.move_mean( zos_g1[:,lat_idx,lon_idx],  window=wdw_mm , min_count = None )
g2_mm = bottleneck.move_mean( zos_g2[:,lat_idx,lon_idx],  window=wdw_mm , min_count = None )

for i in range( len(g1_mm) ):
        if ( g1_mm[i] >  1e+10  ):
             g1_mm[i] = np.nan

for i in range( len(g2_mm) ):
        if ( g2_mm[i] >  1e+10  ):
             g2_mm[i] = np.nan

#==================== Percentile lines ====================
# we start from 2020 because de differences are calculated
# respect to 2010-2020 decade

min_g        = []
max_g        = []
perc_50g     = []   # median
dates_perc_g = []


date_ref = datetime.datetime.strptime( "2020-01-01::00:00:00" , "%Y-%m-%d::%H:%M:%S")
st_t1g = int(( date_ref - dateList1g[0] )/datetime.timedelta( days = 30.42 ))
st_t2g = int(( date_ref - dateList2g[0] )/datetime.timedelta( days = 30.42 ))

del vals
for i in range(970):
        vals = (g1_mm[ st_t1 + i ], g2_mm[ st_t2 + i ]  )
        min_g.append( np.nanmin(vals) )
        max_g.append( np.nanmax(vals) )
        perc_50g.append( np.nanpercentile(vals,50) )
        dates_perc_g.append( date_ref + datetime.timedelta( days = 30.42 * i ) )

#===================================================================
#                              RCP 2.6
#===================================================================

h1 = NetCDFFile( data_arc_dir+'/CNRM-CM5_CNRM-RCSM4/edmub_zos_MED-10_CNRM-CM5_rcp26_r8i1p1_CNRM-RCSM4_v1_mon_195001_210012.nc', mode='r')

time_h1  = h1.variables['time'][:]
zos_h1   = h1.variables['zos'][:]

dateList1h  = []

#================== Creation of dates ========================

t_start1h = datetime.datetime.strptime( "1950-01-01::00:00:00" , "%Y-%m-%d::%H:%M:%S")

for i in range( len(time_h1) ):
        time_delta = datetime.timedelta( days = time_h1[i]*30.42 )
        dateList1h.append( t_start1h + time_delta )


h1_mm = bottleneck.move_mean( zos_h1[:,lat_idx,lon_idx],  window=wdw_mm , min_count = None )

for i in range( len(h1_mm) ):
        if ( h1_mm[i] >  1e+10  ):
             h1_mm[i] = np.nan

#=====================================================================================
#                                       Plot
#=====================================================================================

plt.title("Delta Sea surface height scenario respect to 2010-2020 decade at point: "+point_name+"\n" , fontsize=30, fontdict={'family':'serif'} , y=1.0 )
plt.xlabel("year", fontsize=25 )
plt.ylabel("Sea surface delta height [m]", fontsize=25 )
plt.xticks(fontsize=18 )
plt.yticks(fontsize=18 )

#**************** RCP 8.5 ***************
plt.plot( dateList1 , v1_mm , color="r", label='$Ensemble$ $element$ $RCP$ $8.5$' )
plt.plot( dateList2 , v2_mm , color="r" )

#**************** RCP 4.5 ***************
plt.plot( dateList1g , g1_mm , color="y", label='$Ensemble$ $element$ $RCP$ $4.5$' )
plt.plot( dateList2g , g2_mm , color="y" )

#**************** RCP 2.6 ***************
if ( point_name in ["B02","B03","P01","P02"] ):
	plt.plot( dateList1h , h1_mm , color="chartreuse", label='$Ensemble$ $element$ $RCP$ $2.6$' )

if ( not point_name in ["B01","P03","P06","P09","P11","P12","P04","P05","P07","P08","P10"] ):
	plt.plot( dates_perc , perc_50, color="blue" , linestyle=":", linewidth=2.0 , label='$Ensemble$ $Median$' )
	plt.fill_between( dates_perc , min_v , max_v , alpha=.5, linewidth=0 , color="r" , label="$Min$ $to$ $Max$ $model$ $RCP$ $8.5$" )
	plt.plot( dates_perc_g , perc_50g , color="blue" , linestyle=":", linewidth=2.0 )
	plt.fill_between( dates_perc_g , min_g , max_g , alpha=.5, linewidth=0 , color="y" , label="$Min$ $to$ $Max$ $model$ $RCP$ $4.5$" )


plt.vlines( datetime.datetime.strptime( "2020-01-01::00:00:00" , "%Y-%m-%d::%H:%M:%S") , -3. , +5. , linestyle="--" )
plt.hlines( 0. , datetime.datetime.strptime( "1950-01-01::00:00:00" , "%Y-%m-%d::%H:%M:%S") , datetime.datetime.strptime( "2120-01-01::00:00:00" , "%Y-%m-%d::%H:%M:%S") ,
    linestyle="--" )
plt.legend(loc=2 , fontsize="x-large" )
plt.axis([ datetime.datetime.strptime( "1950-01-01::00:00:00" , "%Y-%m-%d::%H:%M:%S") , datetime.datetime.strptime( "2105-01-01::00:00:00" , "%Y-%m-%d::%H:%M:%S") , -0.2 , +0.2 ])
plt.grid()

plt.savefig( output_arc_dir+"/"+point_name+"/edmub_fillrcpall_zos_"+point_name+".png")

# Close the figure
plt.close(fig)
