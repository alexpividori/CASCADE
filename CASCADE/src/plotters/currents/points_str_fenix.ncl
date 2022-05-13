;*****************************************************************************
;
; Read currents (CUR) uo and vo from a netCDF file
; Plot the streamlines for a specific region defined in the initialization_file.txt
; coloring the streamlines using a palette that depends on the velocity module.
; This script works only for COPERNICUS-Marine netCDF files because the names are
; adapted to that format. 
;
; The example model is "stream_11.ncl" downloadable from  
; https://www.ncl.ucar.edu/Applications/Scripts/stream_11.ncl
;
;******************************************************************************
;
; DESCRIPTION:    this NCL script is inspired by the "stream_11.ncl" NCL script
;                 (NCL Graphics) which can be found at the following link:
;                 "https://www.ncl.ucar.edu/Applications/Scripts/stream_11.ncl" in the section
;                 "NCL Graphics: Streamlines".
;                 This script, differently from the others, creates a by "gsn_csm_streamline_scalar_map"
;                 a single (s) or a multiple (r) streamline overlying on a high resolution map 
;                 for each line specified in an initialization file (see initialization_file.txt).
;                
;
; EXTERNAL CALLS: none.
;
; EXTERNAL FILES: - input NetCDF data files;
;                   (e.g. see in /lustre/arpa/AdriaClim/COPERNICUSData/..year../..month../RFVL)
;                   
;
; DEVELOPER:      Alex Pividori (alex.pividori@arpa.fvg.it)
;                 ARPA FVG - S.O.C. Stato dell'Ambiente
;                 "AdriaClim" Interreg IT-HR project
;
; CREATION DATE:  12/04/2021.
;
;
; NCL Version:    6.6.2
;
;
; MODIFICATIONS:  12/04/2021 --->  Creation of script starting from the ncl code "S_T_diagram.ncl"
;                                  present in the path: "/lustre/arpa/scratch/pividori.tmp/golfo/S_T_diagram"
;                                  Now that file has been lost cause Exact tecnical problems and hs been replaced by TS_fenix.ncl in 
;                                  /u/arpa/pividoria/TS_diagram.
;                                  
;               
;                 13/04/2021 --->  Implementation of changes. Change colorbar, max_level and min_level, spacing, study of max values of  
;                                  velocity module.
;                 30/04/2021 --->  Adamtation of the script to Copernicus Marine netCDF file. 
;                 03/05/2021 --->  Insertion of the part in which the diffusors coordinates are read from an external file "diffusors_coordinates.txt"
;                                  file.                      
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
         diffusor_name  =line(5)
         plot_type      =line(6)
         delta_t_string =line(7)
         level_section_string  =line(8)   ; level at which we want to draw streamlines (starting from 1, not from 0)     

         delta_t = tointeger(line(7))     ; in "s" plot type it identifies the time step to plot. In "r" type it is ignored.
         level_section = tointeger(line(8)) - 1   ; we subtract 1 because we want to select the depth_levels starting from 1

delete(line)

;============= addfiles =================

  file_cur = "/u/arpa/pividoria/str_lines/staranzano_01.nc"

if (.not. fileexists(file_cur)) then
  print("Error: Current netCDF file doesn't exists.")
  print(""+file_cur)
  exit
end if

  f = addfile(file_cur, "r")

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


;=========== Extraction of Depth Max ================

cur_test   = f->uo(0,{depth_min:1000},{lat_min:lat_max},{lon_min:lon_max})
depth_test = f->depth({depth_min:1000})
level_num  = max( dim_num_n( .not. ismissing(cur_test) , 0 ))

depth_max = depth_test(level_num - 1)

delete(cur_test)
delete(depth_test)

;============ Reading diffusors coordinates =============

  diffusors = asciiread("diffusors_coordinates.txt",-1,"string")
  
  lat_diff = todouble( str_get_field(diffusors,1,";") )
  lon_diff = todouble( str_get_field(diffusors,2,";") )
  denom_diff = str_get_field(diffusors,3,";") 

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

  

  u      = f->uo(t_analysis,level_section,{lat_min:lat_max},{lon_min:lon_max})
  v      = f->vo(t_analysis,level_section,{lat_min:lat_max},{lon_min:lon_max})
  depth1 = f->depth({depth_min:depth_max})                                                 ; extract depth
  
  time = f->time                                ; time of f and g should be the same (in this program). So the is no difference in using
                                                ; f(TEMP) or g(PASAL) file

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

;===== Date run extraction ====================================

;  date_run = str_split( file_cur , "/" )

;  year_run  = date_run(4)
;  month_run = sprinti("%0.2i", tointeger( date_run(5) ))
;  day_run   = sprinti("%0.2i", tointeger( date_run(6) ))

;  date_run_f = year_run+"-"+month_run+"-"+day_run

   date_run_f = "2021-05-03"    ; bulletin_date (run date)
;=================================================

if ( plot_type .eq. "s" ) then
 wks= gsn_open_wks("png","streamlines_"+date_run_f+"_"+diffusor_name+"_"+sprinti("%0.2i", tointeger(level_section_string) )+"_f"+date_plot1+"_"+hour1+"."+minute1 )    ; send graphics to PNG file
else
 wks= gsn_open_wks("png","streamlines_"+date_run_f+"_"+diffusor_name+"_"+sprinti("%0.2i", tointeger(level_section_string) )+"_f"+date_plot1+"_"+hour1+"."+minute1+"_"+plot_type+"_"+sprinti("%0.3i", n))
end if

;=================Graphics

;--- streamlines plot

  mpres                       = True
  mpres@gsnDraw               = False      ; Will draw after overlay
  mpres@gsnFrame              = False
  mpres@gsnMaximize           = True
  mpres@tiMainString          = "Streamlines currents at: "+date_plot1+" "+hour1+":"+minute1+" UTC"
 
  mpres@gsnRightString        = "Depth= "+sprintf( "%3.2f"  , depth1(level_section) )+" m"     ; string at top right of the graphic
  mpres@gsnRightStringFontHeightF  = 0.012
  mpres@gsnCenterString       = "Denomination: "+diffusor_name                  ; string at top center of the graphic
  mpres@gsnCenterStringFontHeightF  = 0.012

;---Zoom in on map
  mpres@mpMinLatF             = todouble(lat_min)
  mpres@mpMaxLatF             = todouble(lat_max)
  mpres@mpMinLonF             = todouble(lon_min)
  mpres@mpMaxLonF             = todouble(lon_max)

  mpres@mpOutlineOn           = True
  mpres@mpDataBaseVersion     = "HighRes"   ; slightly better outlines

;---Data is regional
  mpres@gsnAddCyclic          = False

;---Change the streamline levels

  mpres@stLevelPalette        = "cosam12" 
  mpres@stLineThicknessF      = 5.0         ; default value 1.0 is too thin
  mpres@stLevelSelectionMode  = "ManualLevels"
  mpres@stMinLevelValF        = 0.05
  mpres@stMaxLevelValF        = 0.50    ; the color bar contains olso the 30/40 cm/s region
  mpres@stLevelSpacingF       = 0.05
  mpres@pmTickMarkDisplayMode = "Always"    ; more detailed tickmarks
  mpres@stZeroFLabelSide      = "Bottom"
;--- Label bar 

  mpres@lbTitleString         = "Water velocity [m/s]"
  mpres@lbTitleFontHeightF    = 0.015
  mpres@lbTitlePosition       = "Bottom"
  mpres@stArrowLengthF        = 0.01   ; lenght of the lines used to draw the arrows
;  mpres@stArrowStride         = 1      ; number of nodes for each arrow
;  mpres@stMaxArrowSpacingF    = 0.1   ; min distance between lines
;  mpres@stArrowStride        = 1
 

  plot = gsn_csm_streamline_scalar_map(wks, u, v, sqrt( u^2 + v^2 ) , mpres)

;******************* Dots **************************

;---XY plot

  xyres                = True
  xyres@gsnDraw        = False      ; Will draw after overlay
  xyres@gsnFrame       = False

;  xyres@gsnMaximize           = True
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
 
  overlay(plot,plot_dots)

  draw(plot)
  frame(wks)

  delete(time)
  delete(u)
  delete(v)

end do    ; end of cycle on the graphs
                                              
  delete(depth1)           ; in the next line the region of interest changes (different lat/lon)

end do   ; end of cycle on the initialization_file lines

end
