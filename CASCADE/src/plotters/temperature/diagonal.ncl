;*****************************************************************************
; 
; This is the first version of a working diagonal slice plotter.  
; This code represent a diagonal vertical slice of a temperature contour.
; The minimum lan or lon dimension, must have at least to points. In another
; case the interpolation can't be done. To plot a slice for constant latitude
; or longitude, please use another script. 
;
; The example model is "trans_1.ncl" downloadable from  
; https://www.ncl.ucar.edu/Applications/Scripts/trans_1.ncl
;
;******************************************************************************
;
; DESCRIPTION:    
;                 The code is able to read a classical initialization file format:
;                 serial_code;lat_min;lat_max;lon_min;lon_max;plot_type;time_step
;                 The eight input parameter (depth level) is ignored.
;                 Giving starting lat/lon and ending lat/lon, the diagonal vertical slice 
;                 connect the two points.
;
; EXTERNAL CALLS: none.
;
; EXTERNAL FILES: - input NetCDF data files;
;                   (e.g. see in /lustre/arpa/scratch/FORECAST/2021/05/03/TEMP/..year../..month../RFVL)
;                   
;
; DEVELOPER:      Alex Pividori (alex.pividori@arpa.fvg.it)
;                 ARPA FVG - S.O.C. Stato dell'Ambiente
;                 "AdriaClim" Interreg IT-HR project
;
; CREATION DATE:  18/05/2021.
;
;
; NCL Version:    6.6.2
;
;
; MODIFICATIONS:  18/05/2021 --->  First version of the present script
;                                   
;
;******************************************************************************************************************************************************

begin
  
; ================================>  ; PARAMETERS

  depth_min =   0.    ; in m, depth of first layer to be included 

;=====> initial resource settings ==========

  initialization_file = "initialization_file.txt"
  init_file = asciiread( initialization_file ,-1,"string")

;==================================================
;
;        START INIT FILE CYCLE LINES
;
;==================================================

do a=0, dimsizes(init_file)-1     ; sycle on initialization lines


line = str_split(init_file(a),";")

         serial_name    =line(0)
         lat_min        =line(1)
         lat_max        =line(2)
         lon_min        =line(3)
         lon_max        =line(4)
         name           =line(5)
         plot_type      =line(6)
         delta_t_string =line(7)

         delta_t = tointeger(line(7))     ; in "s" plot type it identifies the time step to plot. In "r" type it is ignored.

delete(line)

;============= addfiles =================

  file_temp = "/lustre/arpa/scratch/FORECAST/2021/05/03/TEMP/20210504_h-CMCC--TEMP-MFSeas5-MEDATL-b20210502_fc-sv06.00.nc"

if (.not. fileexists(file_temp)) then
  print("Error: Temperature netCDF file doesn't exists.")
  print(""+file_temp)
  exit
end if

  f = addfile(file_temp, "r")

;========================================

  time = f->time
  time_steps = dimsizes(time)

;========== Input parameter check ===================


if ( delta_t .gt. (time_steps - 1) ) then
   print(""+init_file(a))
   print("Error: The delta_t parameter (eight parameter) at line "+(a+1)+" of the "+initialization_file+" is too big.")
   continue
end if

if  ((plot_type .ne. "r") .and. (plot_type .ne. "s") )  then
   print(""+init_file(a))
   print("Error: The plot_type parameter (seventh parameter) at line "+(a+1)+" of the "+initialization_file+" must be equal to r (range) or s(single).")
   continue
end if

if  ( delta_t .lt. 1 )  then
   print(""+init_file(a))
   print("Error: The delta_t parameter (eight parameter) at line "+(a+1)+" of the "+initialization_file+" is too small.")
   continue
end if


if ( ( lat_min .eq. lat_max ) .and. ( lon_min .eq. lon_max ) ) then
   print(""+init_file(a))
   print("Error: The described region is null." )
   continue
end if


;=========== Extraction of Depth Max ================

t_test     = f->thetao(0,{depth_min:1000},{lat_min:lat_max},{lon_min:lon_max})
depth_test = f->depth({depth_min:1000})

level_num  = max( dim_num_n( .not. ismissing(t_test) , 0 ))
depth_max = depth_test(level_num - 1)

delete(t_test)
delete(depth_test)

;==================== Orientation ==========================

    orientation = "o"

;=================== Redefining input parameters ==========

lat1 = tofloat( lat_min )
lat2 = tofloat( lat_max )
  
lon1 = tofloat( lon_min )
lon2 = tofloat( lon_max )

;=============== Calculation og n_fin ====================

time_steps = dimsizes(time)

if ( plot_type .eq. "s"  ) then

t_analysis  = delta_t - 1   ; because NCL starts counting from 0

n_graphs = 1            ; only 1 graph will be plotted

else

   n_graphs = time_steps

end if

n_fin  = n_graphs - 1

;===========================================================
;                START CYCLE ON GRAPHS
;==========================================================

do n=0,n_fin

if ( plot_type .eq. "r") then

 t_analysis = n

end if

  T      = f->thetao(t_analysis,{depth_min:depth_max},{lat1:lat2},{lon1:lon2})
  
  depth1 = f->depth                                       
  lat_t  = f->lat({lat1:lat2})
  lon_t  = f->lon({lon1:lon2})
  time   = f->time                           

  npts=1000

  dist     = gc_latlon(lat1,lon1,lat2,lon2,npts,2)
  points   = ispan(0,npts-1,1)*1.0
 
if      ( (lat2 .lt. lat1) .and. (lon1 .lt. lon2)  ) then  ; latitude decreasing

  T&lat = T&lat(::-1)

else if ( (lat1 .lt. lat2) .and. (lon2 .lt. lon1)  ) then  ; longitude decreasing

  T&lon = T&lon(::-1)

else if ( (lat2 .lt. lat1) .and. (lon2 .lt. lon1)  ) then  ; lat and lon decreasing

  T&lat = T&lat(::-1)
  T&lon = T&lon(::-1)

end if
end if
end if

  trans = linint2_points(T&lon,T&lat,T,True,dist@gclon,dist@gclat,2)

  copy_VarAtts(T,trans)              ; copy attributes from T to trans   

  trans!0        = "depth"           ; create named dimension and assign
  trans&depth    = T&depth 

;=================================================
;              CREATION DATE VARIABLE
;=================================================

    t_1 = cd_calendar(time(t_analysis),0)  
                                            
    ; Year, month and day extraction

    year1    = t_1(:,0)                  ; year extraction
    month1   = sprinti("%0.2i", tointeger( t_1(:,1) )) 
    day1     = sprinti("%0.2i", tointeger( t_1(:,2) ))
    hour1    = sprinti("%0.2i", tointeger( t_1(:,3) ))
    minute1  = sprinti("%0.2i", tointeger( t_1(:,4) ))
    
    ; Date formatting

    date1      = day1+"/"+month1+"/"+year1        ; to be used in plot's subtitles
    date_plot1 = year1+"-"+month1+"-"+day1   ; to be used to rename output immages

;================ Date run extraction ====================================

  date_run =  str_split( file_temp , "b" )
  
  date_run_f = str_split( date_run(1) , "_" )

;================= Graphics ============================
 
  wks = gsn_open_wks("png","contour_T_diagonal_"+date_run_f(0)+"_f"+date_plot1+"_"+hour1+"."+minute1 )       ; send graphics to PNG file

  res                     = True          ; plot mods desired

;======================== X labels =========================

  nLabels                  = 8                
  res@tmXBLabels           = new(nLabels,"string")
  res@tmXBMode             = "Explicit"

  vectorx = toint( fspan(0,dimsizes(T(0,0,:))-1,nLabels) )
  vectory = toint( fspan(0,dimsizes(T(0,:,0))-1,nLabels) )

  res@tmXBValues           =  toint( fspan(0, npts - 1 , nLabels) ) 

   do i=0,nLabels-1
       x = lon_t(vectorx(i))
       y = lat_t(vectory(i))
       res@tmXBLabels(i) = sprintf("%5.1f", y)+"~C~"+sprintf("%5.1f", x)
   end do

;============================================================

  res@cnFillOn            = True         ; turn on color
  res@cnFillPalette       = "gui_default"  ; set color map
  res@cnLinesOn           = False        ; turn off countour lines
  res@lbOrientation       = "vertical"   ; vertical label bar
  res@pmLabelBarOrthogonalPosF = -0.05        ; move label bar closer to plot
 
  res@cnLevelSelectionMode     = "ManualLevels" ; devo dire a NCL che voglio settare manualmente
  res@cnMinLevelValF           =  9
  res@cnMaxLevelValF           =  17
  res@cnLevelSpacingF          =  0.5

  res@tiYAxisString            =  "Depth [m]"
  res@gsnYAxisIrregular2Linear =  True
  res@gsnCenterString          =  "Date: "+(date_plot1)+" "+hour1+":"+minute1+" UTC"
  res@tiMainString             =  "Diagonal slices Temperature"   ; add title
  res@tiXAxisString            = "Latitude    [~S~o~N~N]~C~Longitude [~S~o~N~E]"
  res@tiXAxisFontHeightF       = 0.020
  res@tiXAxisOffsetYF          = -0.015
  res@trYReverse               = True         ; reverse y axis
  res@gsnRightString           = ""
  res@gsnLeftString            = ""

  res@lbTitleFontHeightF       = 0.017
  res@lbTitlePosition          = "Left"
  res@lbTitleAngleF            = 90
  res@lbTitleString            = "Water Temperature [~S~o~N~C]"
  res@lbTitleDirection         = "Across"
  res@lbTitleOffsetF           = 0.2 ; offset title from left to right
  res@lbLeftMarginF            = 0.2 ; offset label bar 

  res@trYMinF                  =  depth_min
  res@trYMaxF                  =  depth_max
  

  plot = gsn_csm_contour(wks,trans,res)  ; create plot

  delete(time)
  delete(T)
  delete(trans)

end do    ; end of cycle on the graphs
                                              

;============= Map transect is plotted one time for each initialization file line =======

  wks1 = gsn_open_wks("png","transect_location_"+sprinti("%0.2i", a))

  mres                        = True                ; plot mods desired
  mres@gsnFrame               = False               ; don't turn page yet
  mres@gsnDraw                = False               ; don't draw yet
  mres@mpOutlineOn            = True

  mres@mpMinLatF              = min((/ lat1 , lat2 /)) - 0.3
  mres@mpMaxLatF              = max((/ lat1 , lat2 /)) + 0.3
  mres@mpMinLonF              = min((/ lon1 , lon2 /)) - 0.3
  mres@mpMaxLonF              = max((/ lon1 , lon2 /)) + 0.3

  mres@pmTickMarkDisplayMode  = "Always"   ; nicer tickmarks
  mres@mpOutlineBoundarySets  = "Geophysical"
  mres@mpDataSetName          = "Earth..4"
  mres@mpDataBaseVersion      = "HighRes"


  mres@tiMainString = "Transect Location" ; title

  map = gsn_csm_map(wks1,mres)         ; create map

; add polyline to map

  pres                  = True           ; polyline mods desired
  pres@gsLineColor      = "red"          ; color of lines
  pres@gsLineThicknessF = 2.0            ; line thickness

  id = gsn_add_polyline(wks1,map,(/lon1,lon2/),(/lat1,lat2/),pres)

  draw(map)    ; draws map and polyline
  frame(wks1)



  delete(depth1)           ; in the next line the region of interest changes (different lat/lon)
  delete(lat_t)
  delete(lon_t)    

end do   ; end of cycle on the initialization_file lines

end
