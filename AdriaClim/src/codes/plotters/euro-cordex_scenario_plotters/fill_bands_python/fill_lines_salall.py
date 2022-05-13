from netCDF4 import Dataset as NetCDFFile 
import matplotlib.pyplot as plt
import numpy as np
import datetime
import bottleneck  
import sys

data_arc_dir='/lustre/arpa/AdriaClim/data/Med_CORDEX_files' 
output_arc_dir="/lustre/arpa/AdriaClim/public_html/Med_CORDEX_analysis/SCENARIO/edmub_lines_py"

#=================== RCP 8.5 =====================

f1 = NetCDFFile( data_arc_dir+'/CMCC-CM_COSMOMED/edmub_sos_MED-06_CMCC-CM_rcp85_r1i1p1_COSMOMED_v1_mon_195901_210012.nc', mode='r')
f2 = NetCDFFile( data_arc_dir+'/CNRM-CM5_CNRM-RCSM4/edmub_sos_OMED-11i_CNRM-CM5_rcp85_r8i1p1_CNRM-RCSM4_v1_mon_195001_210012.nc', mode='r')
f3 = NetCDFFile( data_arc_dir+'/EC-EARTH_CLMcom-GUF-CCLM5-0-9-NEMOMED12-3-6/edmub_sos_MED-12_EC-EARTH_rcp85_r12i1p1_CLMcom-GUF-CCLM5-0-9-NEMOMED12-3-6_v1_mon_195001_209912.nc', mode='r')
f4 = NetCDFFile( data_arc_dir+'/AdriaClim-IPSL-CM5A-MR_LMD-LMDZ4NEMOMED8/edmub_multi_MED8_IPSL-CM5A-MR_rcp85_r1i1p1_LMD-LMDZ4NEMOMED8_v2_mon_197001_205012.nc', mode='r')

#================== RCP 4.5 ====================

g1 = NetCDFFile( data_arc_dir+'/CMCC-CM_COSMOMED/edmub_sos_MED-06_CMCC-CM_rcp45_r1i1p1_COSMOMED_v1_mon_195901_210012.nc', mode='r')
g2 = NetCDFFile( data_arc_dir+'/CNRM-CM5_CNRM-RCSM4/edmub_sos_OMED-11i_CNRM-CM5_rcp45_r8i1p1_CNRM-RCSM4_v1_mon_195001_210012.nc', mode='r')
g3 = NetCDFFile( data_arc_dir+'/CNRM-CM5_ENEA-PROTHEUS/edmub_sos_OMED-11i_CNRM-CM5_rcp45_r1i1p1_ENEA-PROTHEUS_v2_mon_198501_208812.nc', mode='r')

#================== RCP 2.6 ====================

h1 = NetCDFFile( data_arc_dir+'/CNRM-CM5_CNRM-RCSM4/edmub_sos_OMED-11i_CNRM-CM5_rcp26_r8i1p1_CNRM-RCSM4_v1_mon_195001_210012.nc', mode='r')

#===============================================

point_name = sys.argv[1]
lat_ref    = float(sys.argv[2])  # this is B02  45.2 13.04
lon_ref    = float(sys.argv[3])

wdw_mm = 60    # number of timesteps used for the mobile average

#================= RCP 8.5 =================

lat_v1   = f1.variables['lat'][:] 
lon_v1   = f1.variables['lon'][:] 
time_v1  = f1.variables['time'][:]
sal_v1   = f1.variables['sos'][:]

time_v2  = f2.variables['time'][:]
sal_v2   = f2.variables['sos'][:]

time_v3  = f3.variables['time'][:]
sal_v3   = f3.variables['sos'][:]

time_v4  = f4.variables['time'][:]
sal_v4   = f4.variables['sos'][:]

#=============== RCP 4.5 =================

time_g1  = g1.variables['time'][:]
sal_g1   = g1.variables['sos'][:]

time_g2  = g2.variables['time'][:]
sal_g2   = g2.variables['sos'][:]

time_g3  = g3.variables['time'][:]
sal_g3   = g3.variables['sos'][:]

#============= RCP 2.6 ================

time_h1  = h1.variables['time'][:]
sal_h1   = h1.variables['sos'][:]

#======================================

for i in range( len(lat_v1) ):
	if ( abs(lat_v1[i] - lat_ref ) < 0.01 ) :
	   lat_idx=i
	   break

for i in range( len(lon_v1) ):
        if ( abs(lon_v1[i] - lon_ref ) < 0.01 ) :
           lon_idx=i
           break

#=========================================

fig, ax = plt.subplots(figsize=(20,15))

#================ RCP 4.5 ==================

dateList1g  = []
dateList2g  = []
dateList3g  = []

#================== Creation of dates ========================

t_start1g = datetime.datetime.strptime( "1959-01-01::00:00:00" , "%Y-%m-%d::%H:%M:%S")

for i in range( len(time_g1) ):
        time_delta = datetime.timedelta( seconds = time_g1[i] )
        dateList1g.append( t_start1g + time_delta )

t_start2g = datetime.datetime.strptime( "1949-01-01::00:00:00" , "%Y-%m-%d::%H:%M:%S")
for i in range( len(time_g2) ):
        time_delta = datetime.timedelta( days = time_g2[i] )
        dateList2g.append( t_start2g + time_delta )

t_start3g = datetime.datetime.strptime( "1971-01-01::00:00:00" , "%Y-%m-%d::%H:%M:%S")
for i in range( len(time_g3) ):
        time_delta = datetime.timedelta( seconds = time_g3[i] )
        dateList3g.append( t_start3g + time_delta )

g1_mm = bottleneck.move_mean( sal_g1[:,lat_idx,lon_idx],  window=wdw_mm , min_count = None )
g2_mm = bottleneck.move_mean( sal_g2[:,lat_idx,lon_idx],  window=wdw_mm , min_count = None )
g3_mm = bottleneck.move_mean( sal_g3[:,lat_idx,lon_idx],  window=wdw_mm , min_count = None )

for i in range( len(g1_mm) ):
        if ( g1_mm[i] >  1e+10  ):
             g1_mm[i] = np.nan

for i in range( len(g2_mm) ):
        if ( g2_mm[i] >  1e+10  ):
             g2_mm[i] = np.nan

for i in range( len(g3_mm) ):
        if ( g3_mm[i] >  1e+10  ):
             g3_mm[i] = np.nan

#====================== RCP 8.5 ==================================

dateList1  = []
dateList2  = []
dateList3  = []
dateList4  = []

#================== Creation of dates ========================

t_start1 = datetime.datetime.strptime( "1959-01-01::00:00:00" , "%Y-%m-%d::%H:%M:%S")

for i in range( len(time_v1) ):
	time_delta = datetime.timedelta( seconds = time_v1[i] )
	dateList1.append( t_start1 + time_delta )

t_start2 = datetime.datetime.strptime( "1949-01-01::00:00:00" , "%Y-%m-%d::%H:%M:%S")
for i in range( len(time_v2) ):
        time_delta = datetime.timedelta( days = time_v2[i] )
        dateList2.append( t_start2 + time_delta )

t_start3 = datetime.datetime.strptime( "1950-01-01::00:00:00" , "%Y-%m-%d::%H:%M:%S")
for i in range( len(time_v3) ):
        time_delta = datetime.timedelta( seconds = time_v3[i] )
        dateList3.append( t_start3 + time_delta )

t_start4 = datetime.datetime.strptime( "1900-01-01::00:00:00" , "%Y-%m-%d::%H:%M:%S")
for i in range( len(time_v4) ):
        time_delta = datetime.timedelta( days = float(time_v4[i]) )
        dateList4.append( t_start4 + time_delta )


v1_mm = bottleneck.move_mean( sal_v1[:,lat_idx,lon_idx],  window=wdw_mm , min_count = None )
v2_mm = bottleneck.move_mean( sal_v2[:,lat_idx,lon_idx],  window=wdw_mm , min_count = None )
v3_mm = bottleneck.move_mean( sal_v3[:,lat_idx,lon_idx],  window=wdw_mm , min_count = None )
v4_mm = bottleneck.move_mean( sal_v4[:,lat_idx,lon_idx],  window=wdw_mm , min_count = None )

for i in range( len(v1_mm) ):
	if ( v1_mm[i] >  1e+10  ):
	     v1_mm[i] = np.nan

for i in range( len(v2_mm) ):
	if ( v2_mm[i] >  1e+10  ):
	     v2_mm[i] = np.nan

for i in range( len(v3_mm) ):
	if ( v3_mm[i] >  1e+10  ):
	     v3_mm[i] = np.nan

for i in range( len(v4_mm) ):
	if ( v4_mm[i] >  1e+10  ):
	     v4_mm[i] = np.nan

#=========== RCP 2.6 ===========

dateList1h  = []

#================== Creation of dates ========================

t_start1h = datetime.datetime.strptime( "1949-01-01::00:00:00" , "%Y-%m-%d::%H:%M:%S")

for i in range( len(time_h1) ):
        time_delta = datetime.timedelta( days = time_h1[i] )
        dateList1h.append( t_start1h + time_delta )


h1_mm = bottleneck.move_mean( sal_h1[:,lat_idx,lon_idx],  window=wdw_mm , min_count = None )

for i in range( len(h1_mm) ):
        if ( h1_mm[i] >  1e+10  ):
             h1_mm[i] = np.nan

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
st_t3 = int(( date_ref - dateList3[0] )/datetime.timedelta( days = 30.42 ))
st_t4 = int(( date_ref - dateList4[0] )/datetime.timedelta( days = 30.42 ))

for i in range(372):
	vals = [ v1_mm[ st_t1 + i ], v2_mm[ st_t2 + i ] , v3_mm[ st_t3 + i ] , v4_mm[ st_t4 + i ]  ]
	min_v.append( np.nanmin(vals) )
	max_v.append( np.nanmax(vals) )
	perc_50.append( np.nanpercentile(vals,50) )
	dates_perc.append( date_ref + datetime.timedelta( days = 30.42 * i ) )

del vals
for i in range(372,960):
	vals = (v1_mm[ st_t1 + i ], v2_mm[ st_t2 + i ] , v3_mm[ st_t3 + i ]  )
	min_v.append( np.nanmin(vals) )
	max_v.append( np.nanmax(vals) )
	perc_50.append( np.nanpercentile(vals,50) )
	dates_perc.append( date_ref + datetime.timedelta( days = 30.42 * i ) )

#==================== RCP 4.5 percentile ====================

min_g        = []
max_g        = []
perc_50g     = []   # median
dates_perc_g = []


st_t1g = int(( date_ref - dateList1g[0] )/datetime.timedelta( days = 30.42 ))
st_t2g = int(( date_ref - dateList2g[0] )/datetime.timedelta( days = 30.42 ))
st_t3g = int(( date_ref - dateList3g[0] )/datetime.timedelta( days = 30.42 ))

del vals
for i in range(817):
        vals = [ g1_mm[ st_t1g + i ], g2_mm[ st_t2g + i ] , g3_mm[ st_t3g + i ]  ]
        min_g.append( np.nanmin(vals) )
        max_g.append( np.nanmax(vals) )
        perc_50g.append( np.nanpercentile(vals,50) )
        dates_perc_g.append( date_ref + datetime.timedelta( days = 30.42 * i ) )

del vals
for i in range(817,960):
        vals = ( g1_mm[ st_t1g + i ], g2_mm[ st_t2g + i ]   )
        min_g.append( np.nanmin(vals) )
        max_g.append( np.nanmax(vals) )
        perc_50g.append( np.nanpercentile(vals,50) )
        dates_perc_g.append( date_ref + datetime.timedelta( days = 30.42 * i ) )


#=====================================================================================
#                                       Plot
#=====================================================================================

plt.title("Delta Salinity scenario respect to 2010-2020 decade at point: "+point_name , fontsize=30, fontdict={'family':'serif'} )
plt.xlabel("year", fontsize=25 )
plt.ylabel("Sea surface delta salinity [PSU]", fontsize=25 )
plt.xticks(fontsize=18 )
plt.yticks(fontsize=18 )

plt.plot( dateList1 , v1_mm , color="r", label='$Ensemble$ $element$ $RCP$ $8.5$' )
plt.plot( dateList2 , v2_mm , color="r" )
plt.plot( dateList3 , v3_mm , color="r" )
plt.plot( dateList4 , v4_mm , color="r" )

plt.plot( dateList1g , g1_mm , color="y", label='$Ensemble$ $element$ $RCP$ $4.5$' )
plt.plot( dateList2g , g2_mm , color="y" )
plt.plot( dateList3g , g3_mm , color="y" )

plt.plot( dateList1h , h1_mm , color="chartreuse", label='$Ensemble$ $element$ $RCP$ $2.6$' )

if ( not point_name in ["B01","P04","P05","P07","P08","P10"] ):
	plt.plot( dates_perc , perc_50, color="blue" , linestyle=":", label='$Ensemble$ $Median$', linewidth=2. )
	plt.fill_between( dates_perc , min_v , max_v , alpha=.5, linewidth=0 , color="r" , label="$Min$ $to$ $Max$ $model$ $RCP$ $8.5$" )
	plt.plot( dates_perc_g , perc_50g, color="blue" , linestyle=":", linewidth=2. )
	plt.fill_between( dates_perc_g , min_g , max_g , alpha=.5, linewidth=0 , color="y" , label="$Min$ $to$ $Max$ $model$ $RCP$ $4.5$" )


plt.vlines( datetime.datetime.strptime( "2020-01-01::00:00:00" , "%Y-%m-%d::%H:%M:%S") , -3. , +3. , linestyle="--" )
plt.hlines( 0. , datetime.datetime.strptime( "1950-01-01::00:00:00" , "%Y-%m-%d::%H:%M:%S") , datetime.datetime.strptime( "2120-01-01::00:00:00" , "%Y-%m-%d::%H:%M:%S") ,
    linestyle="--" )
plt.legend(loc=2 , fontsize="x-large" )
plt.axis([ datetime.datetime.strptime( "1950-01-01::00:00:00" , "%Y-%m-%d::%H:%M:%S") , datetime.datetime.strptime( "2105-01-01::00:00:00" , "%Y-%m-%d::%H:%M:%S") , -2. , 2.])
plt.grid()

plt.savefig( output_arc_dir+"/"+point_name+"/edmub_fillrcpall_sal_"+point_name+".png")

# Close the figure
plt.close(fig)
