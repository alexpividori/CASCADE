;*****************************************************************************
; 
; This script is used to plot bathymetry for a shyfem script. In this version 
; is plotted a contour bathymetry colored by a rainbow scale without map.
;
;******************************************************************************
;
; DESCRIPTION:    In this case
;                 the code is able to read a classical initialization file format:
;                 serial_code;lat_min;lat_max;lon_min;lon_max;plot_type;time_step;depth_level
;                 Time step and depth level are ignored.
;
; EXTERNAL CALLS: none.
;
; EXTERNAL FILES: - input NetCDF data files;
;                   (e.g. see in /lustre/arpa/scratch/nadri-mg_2020.hydro.nc )
;                   
;
; DEVELOPER:      Alex Pividori (alex.pividori@arpa.fvg.it)
;                 ARPA FVG - S.O.C. Stato dell'Ambiente
;                 "AdriaClim" Interreg IT-HR project
;
; CREATION DATE:  17/05/2021.
;
;
; NCL Version:    6.6.2
;
;
; MODIFICATIONS:  18/05/2021 ---> First version of the script 
;                                  
;                                                      
;
;******************************************************************************************************************************************************

begin
  
; ================================>  ; PARAMETERS

  depth_min =   0.    ; in m, depth of first layer to be included 

;=====> initial resource settings ==========

  initialization_file = "shy_initialization_file.txt"
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
         level_section_string  =line(8)
         
         delta_t = tointeger(line(7))     ; in "s" plot type it identifies the time step to plot. In "r" type it is ignored.
         level_section = tointeger(line(8)) - 1

delete(line)

;============= addfiles =================

  file_bat = "/lustre/arpa/scratch/nadri-mg_2020.hydro.nc"

if (.not. fileexists(file_bat)) then
  print("Error: Bathymetry netCDF file doesn't exists.")
  print(""+file_bat)
  exit
end if

  f = addfile(file_bat, "r")

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


if ( ( lat_min .eq. lat_max ) .or. ( lon_min .eq. lon_max ) ) then
   print(""+init_file(a))
   print("Error: The described region is null. Please insert a 2D extended region." )
   continue
end if

;=============== Calculation of n_fin ====================

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


  bat    = f->total_depth({lat_min:lat_max},{lon_min:lon_max})
  
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

;============ Reading diffusors coordinates =============

  diffusors = asciiread("dots_coordinates.txt",-1,"string")

  lat_diff   = todouble( str_get_field(diffusors,1,";") )
  lon_diff   = todouble( str_get_field(diffusors,2,";") )
  denom_diff = str_get_field(diffusors,3,";")

;================= Graphics ============================
 
 wks = gsn_open_wks("png","bathymetry_"+sprinti("%0.2i", tointeger( a + 1 )) )

 res                          = True
 res@gsnDraw                  = False      ; Will draw after overlay
 res@gsnFrame                 = False

 res@cnFillOn                 = True          ; turn on color fill
 res@cnLineLabelsOn           = False         ; turns off contour line labels
 res@cnLinesOn                = False
 res@cnInfoLabelOn            = False         ; turns off contour info label
 res@cnFillPalette            = "gui_default" ; set color map

 res@trXMinF                  = todouble(lon_min)
 res@trXMaxF                  = todouble(lon_max)
 res@trYMinF                  = todouble(lat_min)
 res@trYMaxF                  = todouble(lat_max)

;---Data is regional
 res@gsnAddCyclic             = False

 res@gsnMaximize              =  True            ; Maximize plot in frame
 res@gsnXAxisIrregular2Linear =  True   ; converts irreg depth to linear
 res@gsnYAxisIrregular2Linear =  True   ; converts irreg depth to linear
 res@lbOrientation            = "vertical" ; horizontal label bar
 res@tiYAxisString            =  "Latitude [~S~o~N~N]"
 res@cnLevelSelectionMode     = "ManualLevels" ; devo dire a NCL che voglio settare manualmente
 res@cnMinLevelValF           =  0.
 res@cnMaxLevelValF           =  30
 res@cnLevelSpacingF          =  1.0

 res@lbTitleFontHeightF       = 0.017
 res@lbTitlePosition          = "Left"
 res@lbTitleAngleF            = 90
 res@lbTitleString            = "Bathymetry [m]"
 res@lbTitleDirection         = "Across"

 res@tiXAxisFontHeightF       = 0.019
 res@tiYAxisFontHeightF       = 0.019
 res@tiXAxisString            = "Longitude [~S~o~N~E]"
 res@pmTickMarkDisplayMode    = "Always"
 res@gsnRightString           = ""
 res@gsnLeftString            = ""
 
 res@tiMainString             = "Bathymetry"

;---XY plot

  xyres                        = True
  xyres@gsnDraw                = False      ; Will draw after overlay
  xyres@gsnFrame               = False

  xyres@gsnMaximize           = True
  xyres@xyMarkLineMode         = "Markers"  ; Create a scatter plot
  xyres@xyMarker               = 16         ; The default xyMarker is 16. X correspond to number 5 and + to number 2
  xyres@xyMarkerSizeF          = 10.0
  xyres@xyMarkerColor          = "red"

;********************* Denomination Diffusors *****************

  txyres                = True
  txyres@gsnDraw        = False      ; Will draw after overlay
  txyres@gsnFrame       = False

  txyres@txFontHeightF  = 0.014
  txyres@txJust         = "TopLeft"      ; dot position respect to the label

;***************************************************

  plot_dots = gsn_csm_xy(wks,lon_diff,lat_diff,xyres)

  plot_text = gsn_add_text(wks,plot_dots,denom_diff,lon_diff,lat_diff,txyres)  ; this command add the text label denomination under the dots

  plot      = gsn_csm_contour(wks,bat(:,:),res)

  overlay(plot,plot_dots)

  draw(plot)
  frame(wks)

;******************************************************

  delete(time)
  delete(bat)

end do    ; end of cycle on the graphs
                                              

end do   ; end of cycle on the initialization_file lines

end
