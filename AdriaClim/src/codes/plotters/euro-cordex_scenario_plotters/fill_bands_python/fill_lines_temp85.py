from netCDF4 import Dataset as NetCDFFile 
import matplotlib.pyplot as plt
import numpy as np
import datetime
import bottleneck  
import sys

data_arc_dir='/lustre/arpa/AdriaClim/data/Med_CORDEX_files' 
output_arc_dir="/lustre/arpa/AdriaClim/public_html/Med_CORDEX_analysis/SCENARIO/edmub_lines_py"

f1 = NetCDFFile( data_arc_dir+'/CMCC-CM_COSMOMED/edmub_tos_MED-06_CMCC-CM_rcp85_r1i1p1_COSMOMED_v1_mon_195901_210012.nc', mode='r')
f2 = NetCDFFile( data_arc_dir+'/CNRM-CM5_CNRM-RCSM4/edmub_tos_OMED-11i_CNRM-CM5_rcp85_r8i1p1_CNRM-RCSM4_v1_mon_195001_210012.nc', mode='r')
f3 = NetCDFFile( data_arc_dir+'/EC-EARTH_CLMcom-GUF-CCLM5-0-9-NEMOMED12-3-6/edmub_tos_OMED-11i_EC-EARTH_rcp85_r12i1p1_CLMcom-GUF-CCLM5-0-9-NEMOMED12-3-6_v1_mon_195001_210012.nc', mode='r')
f4 = NetCDFFile( data_arc_dir+'/IPSL-CM5A-MR_LMD-LMDZ4NEMOMED8/edmub_tos_OMED-11i_IPSL-CM5A-MR_rcp85_r1i1p1_LMD-LMDZ4NEMOMED8_v1_mon_195101_210012.nc', mode='r')
f5 = NetCDFFile( data_arc_dir+'/IPSL-CM5A-MR_LMD-LMDZ4NEMOMED8/edmub_tos_OMED-11i_IPSL-CM5A-MR_rcp85_r1i1p1_LMD-LMDZ4NEMOMED8_v2_mon_195101_210012.nc', mode='r')
f6 = NetCDFFile( data_arc_dir+'/MPI-ESM-LR_GERICS-AWI-ROM22/edmub_tos_OMED-11i_MPI-ESM-LR_rcp85_r1i1p1_GERICS-AWI-ROM22_v1_mon_195101_209912.nc', mode='r')
f7 = NetCDFFile( data_arc_dir+'/MPI-ESM-LR_GERICS-AWI-ROM44/edmub_tos_OMED-11i_MPI-ESM-LR_rcp85_r1i1p1_GERICS-AWI-ROM44_v1_mon_195101_209912.nc', mode='r')
f8 = NetCDFFile( data_arc_dir+'/MPI-ESM-LR_UNIBELGRADE-EBUPOM2c/edmub_tos_OMED-11i_MPI-ESM-LR_rcp85_r1i1p1_UNIBELGRADE-EBUPOM2c_v1_mon_195001_210012.nc', mode='r')
f9 = NetCDFFile( data_arc_dir+'/MPI-ESM-MR_LMD-LMDZ4NEMOMED8/edmub_tos_OMED-11i_MPI-ESM-MR_rcp85_r1i1p1_LMD-LMDZ4NEMOMED8_v2_mon_195101_210012.nc', mode='r')
f10 = NetCDFFile( data_arc_dir+'/AdriaClim-IPSL-CM5A-MR_LMD-LMDZ4NEMOMED8/edmub_multi_MED8_IPSL-CM5A-MR_rcp85_r1i1p1_LMD-LMDZ4NEMOMED8_v2_mon_197001_205012.nc', mode='r')

point_name = sys.argv[1]
lat_ref    = float(sys.argv[2])  # this is B02  45.2 13.04
lon_ref    = float(sys.argv[3])

wdw_mm = 60    # number of timesteps used for the mobile average

lat_v1   = f1.variables['lat'][:] 
lon_v1   = f1.variables['lon'][:] 
time_v1  = f1.variables['time'][:]
temp_v1  = f1.variables['tos'][:]

time_v2  = f2.variables['time'][:]
temp_v2  = f2.variables['tos'][:]

time_v3  = f3.variables['time'][:]
temp_v3  = f3.variables['tos'][:]

time_v4  = f4.variables['time'][:]
temp_v4  = f4.variables['tos'][:]

time_v5  = f5.variables['time'][:]
temp_v5  = f5.variables['tos'][:]

time_v6  = f6.variables['time'][:]
temp_v6  = f6.variables['tos'][:]

time_v7  = f7.variables['time'][:]
temp_v7  = f7.variables['tos'][:]

time_v8  = f8.variables['time'][:]
temp_v8  = f8.variables['tos'][:]

time_v9  = f9.variables['time'][:]
temp_v9  = f9.variables['tos'][:]

time_v10  = f10.variables['time'][:]
temp_v10  = f10.variables['tos'][:]

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
dateList3  = []
dateList4  = []
dateList5  = []
dateList6  = []
dateList7  = []
dateList8  = []
dateList9  = []
dateList10 = []

#================== Creation of dates ========================

t_start1 = datetime.datetime.strptime( "1959-01-01::00:00:00" , "%Y-%m-%d::%H:%M:%S")

for i in range( len(time_v1) ):
	time_delta = datetime.timedelta( seconds = time_v1[i] )
	dateList1.append( t_start1 + time_delta )

t_start2 = datetime.datetime.strptime( "1949-01-01::00:00:00" , "%Y-%m-%d::%H:%M:%S")
for i in range( len(time_v2) ):
        time_delta = datetime.timedelta( days = time_v2[i] )
        dateList2.append( t_start2 + time_delta )

t_start3 = datetime.datetime.strptime( "1950-1-1::00:00:00" , "%Y-%m-%d::%H:%M:%S")
for i in range( len(time_v3) ):
        time_delta = datetime.timedelta( days = time_v3[i] )
        dateList3.append( t_start3 + time_delta )

t_start4 = datetime.datetime.strptime( "1949-01-01::00:00:00" , "%Y-%m-%d::%H:%M:%S")
for i in range( len(time_v4) ):
        time_delta = datetime.timedelta( days = time_v4[i] )
        dateList4.append( t_start4 + time_delta )

t_start5 = datetime.datetime.strptime( "1949-01-01::00:00:00" , "%Y-%m-%d::%H:%M:%S")
for i in range( len(time_v5) ):
        time_delta = datetime.timedelta( days = time_v5[i] )
        dateList5.append( t_start5 + time_delta )

t_start6 = datetime.datetime.strptime( "1949-01-01::00:00:00" , "%Y-%m-%d::%H:%M:%S")
for i in range( len(time_v6) ):
        time_delta = datetime.timedelta( days = float(time_v6[i]) )
        dateList6.append( t_start6 + time_delta )

t_start7 = datetime.datetime.strptime( "1949-01-01::00:00:00" , "%Y-%m-%d::%H:%M:%S")
for i in range( len(time_v7) ):
        time_delta = datetime.timedelta( days = float(time_v7[i]) )
        dateList7.append( t_start7 + time_delta )

t_start8 = datetime.datetime.strptime( "1950-1-1::00:00:00" , "%Y-%m-%d::%H:%M:%S")
for i in range( len(time_v8) ):
        time_delta = datetime.timedelta( hours = time_v8[i] )
        dateList8.append( t_start8 + time_delta )

t_start9 = datetime.datetime.strptime( "1949-01-01::00:00:00" , "%Y-%m-%d::%H:%M:%S")
for i in range( len(time_v9) ):
        time_delta = datetime.timedelta( days = time_v9[i] )
        dateList9.append( t_start9 + time_delta )

t_start10 = datetime.datetime.strptime( "1900-01-01::00:00:00" , "%Y-%m-%d::%H:%M:%S")
for i in range( len(time_v10) ):
        time_delta = datetime.timedelta( days = float(time_v10[i]) )
        dateList10.append( t_start10 + time_delta )


v1_mm = bottleneck.move_mean( temp_v1[:,lat_idx,lon_idx],  window=wdw_mm , min_count = None )
v2_mm = bottleneck.move_mean( temp_v2[:,lat_idx,lon_idx],  window=wdw_mm , min_count = None )
v3_mm = bottleneck.move_mean( temp_v3[:,lat_idx,lon_idx],  window=wdw_mm , min_count = None )
v4_mm = bottleneck.move_mean( temp_v4[:,lat_idx,lon_idx],  window=wdw_mm , min_count = None )
v5_mm = bottleneck.move_mean( temp_v5[:,lat_idx,lon_idx],  window=wdw_mm , min_count = None )
v6_mm = bottleneck.move_mean( temp_v6[:,lat_idx,lon_idx],  window=wdw_mm , min_count = None )
v7_mm = bottleneck.move_mean( temp_v7[:,lat_idx,lon_idx],  window=wdw_mm , min_count = None )
v8_mm = bottleneck.move_mean( temp_v8[:,lat_idx,lon_idx],  window=wdw_mm , min_count = None ) 
v9_mm = bottleneck.move_mean( temp_v9[:,lat_idx,lon_idx],  window=wdw_mm , min_count = None )
v10_mm = bottleneck.move_mean( temp_v10[:,lat_idx,lon_idx], window=wdw_mm , min_count = None )

for i in range( len(v1_mm) ):
        if ( v1_mm[i] >  1e+10  ):
                v1_mm[i] = np.nan

for i in range( len(v2_mm) ):
	if ( v2_mm[i] == 1e+20  ):
		v2_mm[i] = np.nan

for i in range( len(v3_mm) ):
        if ( v3_mm[i] == 1e+20  ):
                v3_mm[i] = np.nan

for i in range( len(v4_mm) ):
        if ( v4_mm[i] == 1e+20  ):
                v4_mm[i] = np.nan

for i in range( len(v5_mm) ):
        if ( v5_mm[i] == 1e+20  ):
                v5_mm[i] = np.nan

for i in range( len(v6_mm) ):
        if ( v6_mm[i] == 1e+20  ):
                v6_mm[i] = np.nan

for i in range( len(v7_mm) ):
        if ( v7_mm[i] == 1e+20  ):
                v7_mm[i] = np.nan

for i in range( len(v8_mm) ):
        if ( v8_mm[i] == 1e+20  ):
                v8_mm[i] = np.nan

for i in range( len(v9_mm) ):
        if ( v9_mm[i] == 1e+20  ):
                v9_mm[i] = np.nan

for i in range( len(v10_mm) ):
        if ( v10_mm[i] == 1e+20  ):
                v10_mm[i] = np.nan


#==================== Percentile lines ====================
# we start from 2020 because de differences are calculated 
# respect to 2010-2020 decade

perc_10    = []
perc_90    = []
perc_50    = []   # median
dates_perc = []


date_ref = datetime.datetime.strptime( "2020-01-01::00:00:00" , "%Y-%m-%d::%H:%M:%S")
st_t1 = int(( date_ref - dateList1[0] )/datetime.timedelta( days = 30.42 ))
st_t2 = int(( date_ref - dateList2[0] )/datetime.timedelta( days = 30.42 ))
st_t3 = int(( date_ref - dateList3[0] )/datetime.timedelta( days = 30.42 ))
st_t4 = int(( date_ref - dateList4[0] )/datetime.timedelta( days = 30.42 ))
st_t5 = int(( date_ref - dateList5[0] )/datetime.timedelta( days = 30.42 ))
st_t6 = int(( date_ref - dateList6[0] )/datetime.timedelta( days = 30.42 ))
st_t7 = int(( date_ref - dateList7[0] )/datetime.timedelta( days = 30.42 ))
st_t8 = int(( date_ref - dateList8[0] )/datetime.timedelta( days = 30.42 ))
st_t9 = int(( date_ref - dateList9[0] )/datetime.timedelta( days = 30.42 ))
st_t10 = int(( date_ref - dateList10[0] )/datetime.timedelta( days = 30.42 ))


for i in range(372):
	vals = (v1_mm[ st_t1 + i ], v2_mm[ st_t2 + i ] , v3_mm[ st_t3 + i ] , v4_mm[ st_t4 + i ] , v5_mm[ st_t5 + i ] , v6_mm[ st_t6 + i ] , v7_mm[ st_t7 + i ], v8_mm[ st_t8 + i ], v9_mm[ st_t9 + i ] , v10_mm[ st_t10 + i ] )
	perc_10.append( np.nanpercentile(vals,10) )
	perc_90.append( np.nanpercentile(vals,90) )
	perc_50.append( np.nanpercentile(vals,50) )
	dates_perc.append( date_ref + datetime.timedelta( days = 30.42 * i ) )

for i in range(372,961):
	vals = (v1_mm[ st_t1 + i ], v2_mm[ st_t2 + i ] , v3_mm[ st_t3 + i ] , v4_mm[ st_t4 + i ] , v5_mm[ st_t5 + i ] , v6_mm[ st_t6 + i ] , v7_mm[ st_t7 + i ], v8_mm[ st_t8 + i ], v9_mm[ st_t9 + i ]  )
	perc_10.append( np.nanpercentile(vals,10) )
	perc_90.append( np.nanpercentile(vals,90) )
	perc_50.append( np.nanpercentile(vals,50) )
	dates_perc.append( date_ref + datetime.timedelta( days = 30.42 * i ) )


#=====================================================================================
#                                       Plot
#=====================================================================================

plt.title("Delta Temperature scenario respect to 2010-2020 decade at point: "+point_name , fontsize=30, fontdict={'family':'serif'} )
plt.xlabel("year", fontsize=25 )
plt.ylabel("Sea surface delta temperature [°C]", fontsize=25 )
plt.xticks(fontsize=18 )
plt.yticks(fontsize=18 )

plt.plot( dateList1 , v1_mm , color="r", label='$Ensemble$ $element$ $RCP$ $8.5$' )
plt.plot( dateList2 , v2_mm , color="r" )
plt.plot( dateList3 , v3_mm , color="r" )
plt.plot( dateList4 , v4_mm , color="r" )
plt.plot( dateList5 , v5_mm , color="r" )
plt.plot( dateList6 , v6_mm , color="r" )
plt.plot( dateList7 , v7_mm , color="r" )
plt.plot( dateList8 , v8_mm , color="r" )
plt.plot( dateList9 , v9_mm , color="r" )
plt.plot( dateList10, v10_mm, color="r" )
if ( not point_name in ["B01","P04","P05","P07","P08","P10"] ):
	#plt.plot( dates_perc , perc_10, color="blue" )
	#plt.plot( dates_perc , perc_90, color="blue" )
	plt.plot( dates_perc , perc_50, color="blue" , linestyle=":", label='$Ensemble$ $Median$' )
	plt.fill_between( dates_perc , perc_10 , perc_90 , alpha=.5, linewidth=0 , color="r" , label="$10th$ $to$ $90th$ $percentile$ $RCP$ $8.5$" )

plt.vlines( datetime.datetime.strptime( "2020-01-01::00:00:00" , "%Y-%m-%d::%H:%M:%S") , -3. , +5. , linestyle="--" )
plt.hlines( 0. , datetime.datetime.strptime( "1950-01-01::00:00:00" , "%Y-%m-%d::%H:%M:%S") , datetime.datetime.strptime( "2120-01-01::00:00:00" , "%Y-%m-%d::%H:%M:%S") ,
    linestyle="--" )
plt.legend(loc=2 , fontsize="x-large" )
plt.axis([ datetime.datetime.strptime( "1950-01-01::00:00:00" , "%Y-%m-%d::%H:%M:%S") , datetime.datetime.strptime( "2105-01-01::00:00:00" , "%Y-%m-%d::%H:%M:%S") , -2.5 , 4.])
plt.grid()

plt.savefig( output_arc_dir+"/"+point_name+"/edmub_fillrcp85_temp_"+point_name+".png")

# Close the figure
plt.close(fig)
