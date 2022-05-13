;*****************************************************************************
;
; Read potential temp (TEMP), salinity (SALT)
; Compute potential density (PD) for specified range PD(t,s)
; (use ncl function based on Yeager's algorithm for rho computation)
; Used K.Lindsay's "za" for zonal avg -- already binned into basins
; Plots temp vs salt (scatter plot), pd overlay
;
; The example model is "tsdiagram_1.ncl" downloadable from  
; https://www.ncl.ucar.edu/Applications/tsdiagram.shtml
;
;******************************************************************************
;
; DESCRIPTION:    this NCL script is inspired by the "tsdiagram_1.ncl" NCL script
;                 (NCL Graphics) which can be found at the following link:
;                 https://www.ncl.ucar.edu/Applications/iso.shtml in the section
;                 "Contours without maps".
;                 This script is aimed at drawing a TS plot with color change of Markers
;                 over the north of the Adriatic sea. The color intensity of dots have to change in function of depth.
;                 this is performed with a variable RGB index in a do cycle. Has been used netCDF
;                 file from COPERNICUS-Marine. This program, differently from the others, create a TS diagram of a single
;                 water column in a single grid point. So it overlap many diagrams with a single dot with a different color
;                 for each cycle.
;                 The principal goal of this script is to read ASCII data of two drops: one from Celio's measurements and one 
;                 from COPERNICUS reanalysis. After that two overlap TS diagrams will be painted on the same xy plane
;                 for a simple and immediate comparison.
;                 for each data file specified in an initialisation file (see file_inizializzazione.txt).
;                 (*) https://www.ncl.ucar.edu/Document/Functions/Contributed/int2p_n_Wrap.shtml
;
; EXTERNAL CALLS: none.
;
; EXTERNAL FILES: - input NetCDF data files;
;                   For salinity:
;                   ASCII file produced by Celio's measures extraction
;                   and netCDF files extraction.
;                   
;
; DEVELOPER:      Alex Pividori (alex.pividori@arpa.fvg.it)
;                 ARPA FVG - S.O.C. Stato dell'Ambiente
;                 "AdriaClim" Interreg IT-HR project
;
; CREATION DATE:  20/08/2021
;
;
; NCL Version:    6.6.2
;
;
; MODIFICATIONS:  20/08/2021 --->  Creation of script starting from the ncl code "TS_comparison_fenix.ncl"
;                 31/08/2021 --->  Label value every round depth ( 1.0, 2.0, 3.0 ecc )
;                 02/09/2021 --->  Inserting the season check, to change tmin and tmax dinamically
;                                  according to the max values of temp measured
;
;=====================================================================================================

begin  
; ================================>  ; PARAMETERS

  depth_min =   0.    ; in m, depth of first layer to be included 

; plot limits
;
;  The plot limits are useful to plot a mani graph on a single xy axis table to have the same scale and labels

  smincn = 30.0   ; min value of salinity 34 for constant longitude at 13.4 °E same for lat
  smaxcn = 39     ; max value of salinity 39 for constant longitude at 13.4 °E same for lat
 
;=====> initial resource settings ==========

  init_file = asciiread( init_file_TS ,-1,"string")

  resov                            = True
  resov@gsnDraw                    = False    ; Will draw later, after overlaying
  resov@gsnFrame                   = False
  resov@cnLevelSelectionMode       = "AutomaticLevels"
  resov@cnInfoLabelOn              = "False"
  resov@cnLineLabelPlacementMode   = "Constant"
  resov@cnLineLabelFontHeightF     = ".02"

;==================================================
;
;        START INIT FILE CYCLE LINES
;
;==================================================

do a=0, dimsizes(init_file)-1


line = str_split(init_file(a),";")    ; the separator is a semicolon

         file_temp    =line(0)
         file_sal     =line(1)

delete(line)

;============= addfiles =================

if (.not. fileexists( data_dir + "/" + file_temp )) then
  print("Error: Temperature file doesn't exists.")
  exit
end if

if (.not. fileexists( data_dir + "/" + file_sal )) then
  print("Error: Salinity file doesn't exists.")
  exit
end if

;===========================================================
;                START SINGLE GRAPHS
;==========================================================

  delim=";"

  strs_temp = asciiread( data_dir + "/" + file_temp,-1,"string")
  strs_sal  = asciiread( data_dir + "/" + file_sal, -1,"string")
  
 
  temp_data_m = tofloat(str_get_field(strs_temp, 7, delim))
  temp_data_s = tofloat(str_get_field(strs_temp, 8, delim))

  sal_data_m = tofloat(str_get_field(strs_sal, 7, delim))
  sal_data_s = tofloat(str_get_field(strs_sal, 8, delim))


      depth1 = tofloat(str_get_field(strs_temp, 6, delim))
 
  date1 = str_get_field(strs_temp, 4, delim)
    date=date1(0)
  time1 = str_get_field(strs_temp, 5, delim)       
    time=time1(0)
  station_name1 = str_get_field(strs_temp, 1, delim)
   station_name = station_name1(0)

     depth_max = max(depth1)
     level_num = dimsizes(depth1)

;======================================================
;                    SEASON CHECK
;======================================================

max_temp_val = max( (/ temp_data_m , temp_data_s /) )

if      ( max_temp_val .ge. 26.0 ) then
    ; we are in summer
    tmincn = 13.0
    tmaxcn = 30.0
else if ( max_temp_val .ge. 23.0 ) then
    ; we are in autumn
    tmincn = 14.0
    tmaxcn = 26.0
else if ( max_temp_val .ge. 14.0 ) then
    ; we are in spring
    tmincn = 10.0
    tmaxcn = 23.0
else
    ; we are in winter
    tmincn = 3.0
    tmaxcn = 14.0
end if
end if
end if

;============= compute potenial density (PD) according to the season selected =================

; Before I create che pd lines plot
; the season could change every single cycle

  depth = 0.                         ; in meters
  tspan = fspan(tmincn,tmaxcn,51)    ; create an array of temperature points by dividing the temperature interval in 51 parts
  sspan = fspan(smincn,smaxcn,51)    ; create an array of salinity points by dividing the salinity interval in 51 parts

  ; the more points the better... using Yeager's numbers

  t_range = conform_dims((/51,51/),tspan,0)     ; create a 51x51 vector using the tspan elements. The first is the number of raws, the second the colums.
  s_range = conform_dims((/51,51/),sspan,1)     ; number elements of sspan must be a subset of 51*51

  pd = rho_mwjf(t_range,s_range,depth)

  pd!0    = "temp"
  pd!1    = "salt"
  pd&temp = tspan
  pd&salt = sspan
  pd      = 1000.*(pd-1.)        ; Put into kg/m3 pot den units that exceed a m3 of pure water

;  printVarSummary(pd)
;  printVarInfo(pd,"rho_mwjf")

;=================================================
;              CREATION DATE VARIABLE
;=================================================

 time_formatted = str_sub_str( time, ":", "-")

 wks= gsn_open_wks("png", output_dir + "/" + "ts-diag_SHY_" + station_name + "_" + date + "_" + time_formatted ) 

;=================Graphics

; Before I create che pd lines plot

  plotpd = gsn_csm_contour(wks,pd,resov)      ; create the underground mask with constant density lines

;--- scatter plot
  res                        = True
  res@gsnMaximize            = True
  res@gsnDraw                = False       ; Will draw later, after overlaying
  res@gsnFrame               = False
  res@pmLegendWidthF         = 0.05                                     ; Change width and
  res@pmLegendHeightF        = 0.05                                     ; height of legend.
  res@lgPerimOn              = False                                    ; turn on/off box around
  res@lgLabelFontHeightF     = .013                                     ; label font height
  res@pmLegendSide           = "Top"
  res@xyMarkLineModes        = "Markers"   ; simbols used to mark the points
  
  res@tiMainString        = "T-S Diagram at: "+date+" "+" "+time+" UTC"
 
  res@tiXAxisFontHeightF  = 0.02
  res@tiYAxisFontHeightF  = 0.02

;------ min and max extreme of X and Y axes

  res@trXMinF             = smincn      
  res@trXMaxF             = smaxcn
  res@trYMinF             = tmincn
  res@trYMaxF             = tmaxcn

  res@gsnRightString      = "Depth: "+depth_min+" -"+sprintf("%5.1f",depth_max)+" m"     ; string at top right of the graphic

  res@gsnCenterString     = "Denomination: "+station_name                  ; string at top center of the graphic
  res@tiXAxisString       = "Salinity [g/kg]"             
  res@tiYAxisString       = "Temperature [~S~o~N~C] "                      ; the string ~S~o~N~ generate the special character °


  parallelpos =  1.15              ; the legend is disposed vertically, so the parallelpos remain constant
  yposition   = -0.22              ; the initial position of y position of legend

  plotpd = gsn_csm_contour(wks,pd,resov)

;============== ◯ and △ legends ============

res@pmLegendDisplayMode    = "Always"
res@xyMarkers              = 16
res@xyExplicitLegendLabels = "SHYFEM Model" 
res@pmLegendOrthogonalPosF =  -0.12                    ; move units down, distance from the top of the graph
res@pmLegendParallelPosF   = parallelpos  
res@xyMarkerColor          = (/ 0.2 , 0.6 , 0.2  /) 

x = (/ -10. , -10. /)
y = (/ -10. , -10. /)

plot_0 = gsn_csm_xy(wks,x,y,res)
overlay( plotpd , plot_0 )

res@xyMarkers              = 11
res@xyExplicitLegendLabels = "In-situ measures"
res@pmLegendOrthogonalPosF = -0.16                 ; move units down, distance from the top of the graph

plot_0 = gsn_csm_xy(wks,x,y,res)
overlay( plotpd , plot_0 )

;=======================================================

delete([/ res@gsnRightString , res@gsnCenterString /]) ; to avoid smudges on central and right string

i_fin = level_num - 1

do i=0,i_fin   ; cycle on depths
  
  res@xyMarkers              = 16
  res@pmLegendDisplayMode    = "Never"                                 ; turn on legend

  res@pmLegendOrthogonalPosF = yposition                                ; move units down, distance from the top of the graph
  res@pmLegendParallelPosF   = parallelpos                              ; move units right, distance from legends


  if (depth1(i) .lt. 10.0 ) then
  res@pmLegendParallelPosF   = parallelpos - 0.0048                    ; this is only an aesthetic tool to allineate verticall the legend dots
  end if

;  if ( mod( depth1(i) , 1 ) .eq. 0  ) then         ; with shyfem model depths goes already 1 by 1 m
  res@pmLegendDisplayMode    = "Always"
  res@xyExplicitLegendLabels = sprintf("%5.1f",depth1(i))+" m"     ; create explicit labels
  yposition = yposition - 0.05
;  end if 

  res@xyMarkerColor      = (/  tofloat(i)/i_fin , 1.0 -  tofloat(i)/i_fin , 0. /)  

  x = (/ sal_data_s(i) , sal_data_s(i) /)    
  y = (/ temp_data_s(i), temp_data_s(i) /) 
                                  
  plot_i = gsn_csm_xy(wks,x,y,res)      ; create the dots graph with T-S points. Every sinsle x element correspond to a particular

;============== Change marker for Measured values ==========

  res@xyMarkers              = 11 
  res@pmLegendDisplayMode    = "Never"

  x = (/ sal_data_m(i) , sal_data_m(i) /)
  y = (/ temp_data_m(i), temp_data_m(i) /)

  plot_m = gsn_csm_xy(wks,x,y,res)

  overlay(plotpd,plot_i)
  overlay(plotpd,plot_m)  
 
end do    ; end of cycle on depths 

  delete([/sal_data_m,temp_data_m,sal_data_s,temp_data_s,depth1,station_name1,date1,time1,strs_temp,strs_sal,tspan,t_range,pd/])

  draw(plotpd)
  frame(wks)

end do   ; end of cycle on the initialization_file lines

  delete(init_file)
end
