;*****************************************************************************
; 
; This script is used to create a contour salinity for slice section
; at constant latitude or longitude.
; If lat_min is equal to lat_max (in the initialization file), the result is
; an horizontal section slice. Instead if the lon_min is equal to
; lon_max the result is a vertical slice section Salinity contour.
; The script recognise the slice orientation.
;
; The example model is "slice_1.ncl" downloadable from  
; https://www.ncl.ucar.edu/Applications/Scripts/slice_1.ncl
;
;******************************************************************************
;
; DESCRIPTION:    This is similar to the old version of this script but in this case
;                 the code is able to read a classical initialization file format:
;                 serial_code;lat_min;lat_max;lon_min;lon_max;plot_type;time_step
;                 The eight input parameter (depth level) is ignored.
;
; EXTERNAL CALLS: none.
;
; EXTERNAL FILES: - input NetCDF data files;
;                   (e.g. see in /lustre/arpa/scratch/FORECAST/2021/05/03/PSAL/..year../..month../RFVL)
;                   
;
; DEVELOPER:      Alex Pividori (alex.pividori@arpa.fvg.it)
;                 ARPA FVG - S.O.C. Stato dell'Ambiente
;                 "AdriaClim" Interreg IT-HR project
;
; CREATION DATE:  04/05/2021.
;
;
; NCL Version:    6.6.2
;
;
; MODIFICATIONS:  04/05/2021 --->  At this point the script is at the same step of other codes like
;                                  TS_diagrams
;                                  
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

  file_sal = "/lustre/arpa/scratch/FORECAST/2021/05/03/PSAL/adriatic_20210503_h-CMCC--PSAL-MFSeas5-MEDATL-b20210502_fc-sv06.00.nc"

if (.not. fileexists(file_sal)) then
  print("Error: Salinity netCDF file doesn't exists.")
  print(""+file_sal)
  exit
end if

  f = addfile(file_sal, "r")

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

if ( ( lat_min .ne. lat_max ) .and. ( lon_min .ne. lon_max ) ) then
   print(""+init_file(a))
   print("Error: This script plots a vertical slice contour, so the latitude or longitude interval has to be constant." )
   continue
end if

if ( ( lat_min .eq. lat_max ) .and. ( lon_min .eq. lon_max ) ) then
   print(""+init_file(a))
   print("Error: The represented lat/lon region is null." )
   continue
end if


;=========== Extraction of Depth Max ================

s_test     = f->so(0,{depth_min:1000},{lat_min:lat_max},{lon_min:lon_max})
depth_test = f->depth({depth_min:1000})

level_num  = max( dim_num_n( .not. ismissing(s_test) , 0 ))
depth_max = depth_test(level_num - 1)

delete(s_test)
delete(depth_test)

;==================== Orientation ==========================

    if ( lat_min .eq. lat_max ) then   ; constant latitude
    orientation = "o"
    else
    orientation = "v"
    end if

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


  S      = f->so(t_analysis,:,{lat_min:lat_max},{lon_min:lon_max})
  
  depth1 = f->depth({depth_min:depth_max})                                                 ; extract depth
  lat_t  = f->lat({lat_min:lat_max})
  lon_t  = f->lon({lon_min:lon_max})
  time   = f->time                           

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

  date_run = str_split( file_sal , "/" )

  year_run  = date_run(4)
  month_run = sprinti("%0.2i", tointeger( date_run(5) ))
  day_run   = sprinti("%0.2i", tointeger( date_run(6) ) -1 )

  date_run_f = year_run+month_run+day_run

;================= Graphics ============================
 
 res                          = True

 res@cnFillOn                 = True          ; turn on color fill
 res@cnLineLabelsOn           = False         ; turns off contour line labels
 res@cnLinesOn                = False
 res@cnInfoLabelOn            = False         ; turns off contour info label
 res@cnFillPalette            = "gui_default" ; set color map

 res@gsnMaximize              =  True            ; Maximize plot in frame
 res@gsnCenterString          =  "Date: "+(date_plot1)+" "+hour1+":"+minute1+" UTC"
 res@trYReverse               =  True
 res@gsnYAxisIrregular2Linear =  True   ; converts irreg depth to linear
 res@lbOrientation            = "vertical" ; horizontal label bar
 res@tiYAxisString            =  " Depth [m]"
 res@cnLevelSelectionMode     = "ManualLevels" ; devo dire a NCL che voglio settare manualmente
 res@cnMinLevelValF           =  34
 res@cnMaxLevelValF           =  40
 res@cnLevelSpacingF          =  0.5

 res@lbTitleFontHeightF       = 0.017
 res@lbTitlePosition          = "Left"
 res@lbTitleAngleF            = 90
 res@lbTitleString            = "Water salinity [g/kg]"
 res@lbTitleDirection         = "Across"

 res@trYMinF                  =  depth_min
 res@trYMaxF                  =  depth_max
 res@pmTickMarkDisplayMode    = "Always"
 res@gsnRightString           = ""
 res@gsnLeftString            = ""

if (orientation .eq. "o" ) then
 wks                    = gsn_open_wks("png","S_contour_slice_"+lat_min+"N_"+date_run_f+"_f"+date_plot1+"_"+hour1+"."+minute1 ) 
 res@tiMainString       = "Salinity contour slice at "+lat_min+" ~S~o~N~N "    
 res@trXMinF            =  min(lon_t)        
 res@trXMaxF            =  max(lon_t)        
 res@tiXAxisString      =  "Longitude [~S~o~N~E]"
 plot                   = gsn_csm_contour(wks,S(:,0,:),res)     
else
 wks                    = gsn_open_wks("png","S_contour_slice_"+lon_min+"E_"+date_run_f+"_f"+date_plot1+"_"+hour1+"."+minute1 )
 res@tiMainString       = "Salinity contour slice at "+lon_min+" ~S~o~N~E "  
 res@trXMinF            =  min(lat_t)        
 res@trXMaxF            =  max(lat_t)       
 res@tiXAxisString      =  "Latitude [~S~o~N~N]"
 plot                   = gsn_csm_contour(wks,S(:,:,0),res)
end if

  delete(time)
  delete(S)

end do    ; end of cycle on the graphs
                                              
  delete(depth1)           ; in the next line the region of interest changes (different lat/lon)

end do   ; end of cycle on the initialization_file lines

end
