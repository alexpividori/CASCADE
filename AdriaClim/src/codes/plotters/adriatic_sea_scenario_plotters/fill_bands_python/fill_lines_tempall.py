from netCDF4 import Dataset as NetCDFFile 
import matplotlib.pyplot as plt
import numpy as np
import datetime
import bottleneck  
import sys

data_arc_dir='/lustre/arpa/AdriaClim/data/Med_CORDEX_files' 
output_arc_dir="/lustre/arpa/AdriaClim/public_html/Med_CORDEX_analysis/SCENARIO/edmub_lines_py"

#================= RCP 8.5 ====================

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

#================== RCP 4.5 =================

g1 = NetCDFFile( data_arc_dir+'/CMCC-CM_COSMOMED/edmub_tos_MED-06_CMCC-CM_rcp45_r1i1p1_COSMOMED_v1_mon_195901_210012.nc', mode='r')
g2 = NetCDFFile( data_arc_dir+'/CNRM-CM5_CNRM-RCSM4/edmub_tos_OMED-11i_CNRM-CM5_rcp45_r8i1p1_CNRM-RCSM4_v1_mon_195001_210012.nc', mode='r')
g3 = NetCDFFile( data_arc_dir+'/CNRM-CM5_ENEA-PROTHEUS/edmub_tos_OMED-11i_CNRM-CM5_rcp45_r1i1p1_ENEA-PROTHEUS_v2_mon_198501_208812.nc', mode='r')
g4 = NetCDFFile( data_arc_dir+'/IPSL-CM5A-MR_LMD-LMDZ4NEMOMED8/edmub_tos_OMED-11i_IPSL-CM5A-MR_rcp45_r1i1p1_LMD-LMDZ4NEMOMED8_v1_mon_195101_210012.nc', mode='r')
g5 = NetCDFFile( data_arc_dir+'/MPI-ESM-LR_GERICS-AWI-ROM22/edmub_tos_OMED-11i_MPI-ESM-LR_rcp45_r1i1p1_GERICS-AWI-ROM22_v1_mon_195101_209912.nc', mode='r')

#================== RCP 2.6 ===================

h1 = NetCDFFile( data_arc_dir+'/CNRM-CM5_CNRM-RCSM4/edmub_tos_OMED-11i_CNRM-CM5_rcp26_r8i1p1_CNRM-RCSM4_v1_mon_195001_210012.nc', mode='r')

#==============================================

point_name = sys.argv[1]
lat_ref    = float(sys.argv[2])  # this is B02  45.2 13.04
lon_ref    = float(sys.argv[3])

wdw_mm = 60    # number of timesteps used for the mobile average

#=========== 8.5 ===========

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

#============ 4.5 =============

time_g1  = g1.variables['time'][:]
temp_g1  = g1.variables['tos'][:]

time_g2  = g2.variables['time'][:]
temp_g2  = g2.variables['tos'][:]

time_g3  = g3.variables['time'][:]
temp_g3  = g3.variables['tos'][:]

time_g4  = g4.variables['time'][:]
temp_g4  = g4.variables['tos'][:]

time_g5  = g5.variables['time'][:]
temp_g5  = g5.variables['tos'][:]

#============ 4.5 =============

time_h1  = h1.variables['time'][:]
temp_h1  = h1.variables['tos'][:]


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

#======= 4.5 =======

dateListg1  = []
dateListg2  = []
dateListg3  = []
dateListg4  = []
dateListg5  = []

#======= 2.6 =======

dateListh1  = []

#================== Creation of dates 8.5 ========================

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

#================= Dated 4.5 ==================

t_start1g = datetime.datetime.strptime( "1959-01-01::00:00:00" , "%Y-%m-%d::%H:%M:%S")

for i in range( len(time_g1) ):
        time_delta = datetime.timedelta( seconds = time_g1[i] )
        dateListg1.append( t_start1g + time_delta )

t_start2g = datetime.datetime.strptime( "1949-01-01::00:00:00" , "%Y-%m-%d::%H:%M:%S")
for i in range( len(time_g2) ):
        time_delta = datetime.timedelta( days = time_g2[i] )
        dateListg2.append( t_start2g + time_delta )

t_start3g = datetime.datetime.strptime( "1971-01-01::00:00:00" , "%Y-%m-%d::%H:%M:%S")
for i in range( len(time_g3) ):
        time_delta = datetime.timedelta( seconds = time_g3[i] )
        dateListg3.append( t_start3g + time_delta )

t_start4g = datetime.datetime.strptime( "1949-01-01::00:00:00" , "%Y-%m-%d::%H:%M:%S")
for i in range( len(time_g4) ):
        time_delta = datetime.timedelta( days = time_g4[i] )
        dateListg4.append( t_start4g + time_delta )

t_start5g = datetime.datetime.strptime( "1949-01-01::00:00:00" , "%Y-%m-%d::%H:%M:%S")
for i in range( len(time_g5) ):
        time_delta = datetime.timedelta( days = float(time_g5[i]) )
        dateListg5.append( t_start5g + time_delta )

#================= Dates 2.6 ==================

t_start1h = datetime.datetime.strptime( "1949-01-01::00:00:00" , "%Y-%m-%d::%H:%M:%S")

for i in range( len(time_h1) ):
        time_delta = datetime.timedelta( days = time_h1[i] )
        dateListh1.append( t_start1h + time_delta )

#================= 8.5 ==================
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

#================= 4.5 ==================
g1_mm = bottleneck.move_mean( temp_g1[:,lat_idx,lon_idx],  window=wdw_mm , min_count = None )
g2_mm = bottleneck.move_mean( temp_g2[:,lat_idx,lon_idx],  window=wdw_mm , min_count = None )
g3_mm = bottleneck.move_mean( temp_g3[:,lat_idx,lon_idx],  window=wdw_mm , min_count = None )
g4_mm = bottleneck.move_mean( temp_g4[:,lat_idx,lon_idx],  window=wdw_mm , min_count = None )
g5_mm = bottleneck.move_mean( temp_g5[:,lat_idx,lon_idx],  window=wdw_mm , min_count = None )

#================= 2.6 ==================

h1_mm = bottleneck.move_mean( temp_h1[:,lat_idx,lon_idx],  window=wdw_mm , min_count = None )

#======================================

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

#==================== 4.5 =====================

for i in range( len(g1_mm) ):
        if ( g1_mm[i] >  1e+10  ):
             g1_mm[i] = np.nan

for i in range( len(g2_mm) ):
        if ( g2_mm[i] >  1e+10  ):
             g2_mm[i] = np.nan

for i in range( len(g3_mm) ):
        if ( g3_mm[i] >  1e+10  ):
             g3_mm[i] = np.nan

for i in range( len(g4_mm) ):
        if ( g4_mm[i] >  1e+10  ):
             g4_mm[i] = np.nan

for i in range( len(g5_mm) ):
        if ( g5_mm[i] >  1e+10  ):
             g5_mm[i] = np.nan

#==================== 2.6 =====================

for i in range( len(h1_mm) ):
        if ( h1_mm[i] >  1e+10  ):
             h1_mm[i] = np.nan

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

del vals

for i in range(372,961):
	vals = (v1_mm[ st_t1 + i ], v2_mm[ st_t2 + i ] , v3_mm[ st_t3 + i ] , v4_mm[ st_t4 + i ] , v5_mm[ st_t5 + i ] , v6_mm[ st_t6 + i ] , v7_mm[ st_t7 + i ], v8_mm[ st_t8 + i ], v9_mm[ st_t9 + i ]  )
	perc_10.append( np.nanpercentile(vals,10) )
	perc_90.append( np.nanpercentile(vals,90) )
	perc_50.append( np.nanpercentile(vals,50) )
	dates_perc.append( date_ref + datetime.timedelta( days = 30.42 * i ) )

#================== Percentile lines 4.5 ========================

min_v        = []
max_v        = []
perc_50g     = []   # median
dates_perc_g = []


date_ref = datetime.datetime.strptime( "2020-01-01::00:00:00" , "%Y-%m-%d::%H:%M:%S")
st_t1g = int(( date_ref - dateListg1[0] )/datetime.timedelta( days = 30.42 ))
st_t2g = int(( date_ref - dateListg2[0] )/datetime.timedelta( days = 30.42 ))
st_t3g = int(( date_ref - dateListg3[0] )/datetime.timedelta( days = 30.42 ))
st_t4g = int(( date_ref - dateListg4[0] )/datetime.timedelta( days = 30.42 ))
st_t5g = int(( date_ref - dateListg5[0] )/datetime.timedelta( days = 30.42 ))

del vals
for i in range(817):
        vals = [ g1_mm[ st_t1g + i ], g2_mm[ st_t2g + i ] , g3_mm[ st_t3g + i ] , g4_mm[ st_t4g + i ] , g5_mm[ st_t5g + i ] ]
        min_v.append( np.nanmin(vals) )
        max_v.append( np.nanmax(vals) )
        perc_50g.append( np.nanpercentile(vals,50) )
        dates_perc_g.append( date_ref + datetime.timedelta( days = 30.42 * i ) )

del vals

for i in range(817,960):
        vals = (g1_mm[ st_t1g + i ], g2_mm[ st_t2g + i ] , g4_mm[ st_t4g + i ] , g5_mm[ st_t5g + i ]  )
        min_v.append( np.nanmin(vals) )
        max_v.append( np.nanmax(vals) )
        perc_50g.append( np.nanpercentile(vals,50) )
        dates_perc_g.append( date_ref + datetime.timedelta( days = 30.42 * i ) )

#=====================================================================================
#                                       Plot
#=====================================================================================

plt.title("Delta Temperature scenario respect to 2010-2020 decade at point: "+point_name+"\n" , fontsize=30, fontdict={'family':'serif'} )
plt.xlabel("year", fontsize=25 )
plt.ylabel("Sea surface delta temperature [°C]", fontsize=25 )
plt.xticks(fontsize=18 )
plt.yticks(fontsize=18 )

#================= RCP 8.5 =================
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

#================= RCP 4.5 =================
plt.plot( dateListg1 , g1_mm , color="y", label='$Ensemble$ $element$ $RCP$ $4.5$' )
plt.plot( dateListg2 , g2_mm , color="y" )
plt.plot( dateListg3 , g3_mm , color="y" )
plt.plot( dateListg4 , g4_mm , color="y" )
plt.plot( dateListg5 , g5_mm , color="y" )

#================= RCP 2.6 =================
plt.plot( dateListh1 , h1_mm , color="chartreuse", label='$Ensemble$ $element$ $RCP$ $2.6$' )

#================ Filling ==================

if ( not point_name in ["B01","P04","P05","P07","P08","P10"] ):
        plt.plot( dates_perc , perc_50, color="blue" , linestyle=":", label='$Ensemble$ $Median$', linewidth=2. )
        plt.fill_between( dates_perc , perc_10 , perc_90 , alpha=.5, linewidth=0 , color="r" , label="$10th$ $to$ $90th$ $percentile$ $RCP$ $8.5$" )


if ( not point_name in ["B01","P04","P05","P07","P08","P10"] ):
        plt.plot( dates_perc_g , perc_50g , color="blue" , linestyle=":", linewidth=2. )
        plt.fill_between( dates_perc_g , min_v , max_v , alpha=.5, linewidth=0 , color="yellow" , label="$Min$ $to$ $Max$ $model$ $RCP$ $4.5$" )

#=============================================

plt.vlines( datetime.datetime.strptime( "2020-01-01::00:00:00" , "%Y-%m-%d::%H:%M:%S") , -3. , +5. , linestyle="--" )
plt.hlines( 0. , datetime.datetime.strptime( "1950-01-01::00:00:00" , "%Y-%m-%d::%H:%M:%S") , datetime.datetime.strptime( "2120-01-01::00:00:00" , "%Y-%m-%d::%H:%M:%S") ,
    linestyle="--" )
plt.legend(loc=2 , fontsize="x-large" )
plt.axis([ datetime.datetime.strptime( "1950-01-01::00:00:00" , "%Y-%m-%d::%H:%M:%S") , datetime.datetime.strptime( "2105-01-01::00:00:00" , "%Y-%m-%d::%H:%M:%S") , -2.5 , 4.])
plt.grid()

plt.savefig( output_arc_dir+"/"+point_name+"/edmub_fillrcpall_temp_"+point_name+".png")

# Close the figure
plt.close(fig)
