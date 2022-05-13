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
;                 for each data file specified in an initialisation file (see file_inizializzazione.txt).
;                 (*) https://www.ncl.ucar.edu/Document/Functions/Contributed/int2p_n_Wrap.shtml
;
; EXTERNAL CALLS: none.
;
; EXTERNAL FILES: - input NetCDF data files;
;                   For salinity:
;                   (e.g. see in /lustre/arpa/AdriaClim/...)
;                   For temperature:
;                   (e.g. see in /lustre/arpa/AdriaClim/...)
;
;
; DEVELOPER:      Alex Pividori (alex.pividori@arpa.fvg.it)
;                 ARPA FVG - S.O.C. Stato dell'Ambiente
;                 "AdriaClim" Interreg IT-HR project
;
; CREATION DATE:  08/04/2021.
;
;
; NCL Version:    6.6.2
;
;
; MODIFICATIONS:  17/02/2021 --->  Creation of script starting from the ncl code "S_T_diagram.ncl"
;                                  present in the path: "/lustre/arpa/scratch/pividori.tmp/golfo/S_T_diagram"
;
;                                  The "S_T_diagram.ncl" was created to plot the TS diagram from a single daily data .nc file    
;               
;                  23/02/2021 --->  Modification of the do cycle transformating a single x and y data in a 2D array with the same value to
;                                   plot a single dot in a xy graph. In this way it is possible to make a TS diagram of a single water column.    
;                                  -Insertion of an if()then end if when the legend number is .lt. 10 to allineate all the dots on the same vertical line.
;
;=====================================================================================================

begin  
; ================================>  ; PARAMETERS

  depth_min =   0.    ; in m, depth of first layer to be included 

; plot limits
;
;  The plot limits are useful to plot a mani graph on a single xy axis table to have the same scale and labels

  smincn = 32.0  ; min value of salinity 34 for constant longitude at 13.4 °E same for lat
  smaxcn = 39.0  ; max value of salinity 39 for constant longitude at 13.4 °E same for lat
  tmincn = 6.    ; min value of temperature 6 °C for constant longitude at 13.4 °E same for lat
  tmaxcn = 18.   ; max value of temperature 18 °C for constant longitude at 13.4 °E same for lat
;
 
;=====> initial resource settings ==========

initialization_file = "initialization_file.txt"
init_file = asciiread( initialization_file ,-1,"string")

;============== compute potenial density (PD), using rho_mwjf

; Before I create che pd lines plot

  resov                            = True
  resov@gsnDraw                    = False    ; Will draw later, after overlaying
  resov@gsnFrame                   = False
  resov@cnLevelSelectionMode       = "AutomaticLevels"
  resov@cnInfoLabelOn              = "False"
  resov@cnLineLabelPlacementMode   = "Constant"
  resov@cnLineLabelFontHeightF     = ".02"

  depth = 0.                         ;in meters
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

; create the pd lines plot

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


line = str_split(init_file(a),";")

         serial_name    =line(0)
         lat_min        =line(1)
         lat_max        =line(2)
         lon_min        =line(3)
         lon_max        =line(4)
         diffusor_name  =line(5)
         plot_type      =line(6)
         delta_t_string =line(7)
         
         delta_t = tointeger(line(7))

delete(line)

;============= addfiles =================

  file_temp = "/lustre/arpa/scratch/FORECAST/2021/05/04/TEMP/20210505_h-CMCC--TEMP-MFSeas5-MEDATL-b20210503_fc-sv06.00.nc"
  file_sal  = "/lustre/arpa/scratch/FORECAST/2021/05/04/PSAL/20210505_h-CMCC--PSAL-MFSeas5-MEDATL-b20210503_fc-sv06.00.nc"

if (.not. fileexists(file_temp)) then
  print("Error: Temperature file doesn't exists.")
  exit
end if

if (.not. fileexists(file_sal)) then
  print("Error: Salinity file doesn't exists.")
  exit
end if

  f = addfile(file_temp, "r")

  g = addfile(file_sal, "r")

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

temp_test = f->thetao(0,{depth_min:1000},{lat_min:lat_max},{lon_min:lon_max})
depth_test = f->depth({depth_min:1000})
level_num = max( dim_num_n( .not. ismissing(temp_test) , 0 ))

depth_max = depth_test(level_num - 1)

delete(temp_test)
delete(depth_test)

;=======================================================

time_steps = dimsizes(time)

if ( plot_type .eq. "s"  ) then

t_init  = delta_t - 1   ; because NCL starts counting from 0
t_final = delta_t - 1
n_graphs = 1            ; only 1 graph will be plotted

else

   if ( mod(time_steps - 1,delta_t) .eq. 0 ) then
   n_graphs = (time_steps - 1)/delta_t
   else
   n_graphs = ((time_steps - 1)/delta_t) + 1   ; the +1 is the incomplete graph that will be added 
   end if

end if

n_fin  = n_graphs - 1

;===========================================================
;                START CYCLE ON GRAPHS
;==========================================================

do n=0,n_fin

if ( plot_type .eq. "r") then

 if ( mod(time_steps,delta_t) .ne. 0) then

    if (n .lt. n_fin) then
      t_init = n*delta_t 
      t_final = (n+1)*delta_t 
    else
      t_init = n*delta_t 
      t_final = dimsizes(time) - 1
    end if
 
  else

      t_init = n*delta_t
      t_final = (n+1)*delta_t  

  end if

end if


  temp = f->thetao(t_init:t_final,{depth_min:depth_max},{lat_min:lat_max},{lon_min:lon_max})
  salt = g->so(t_init:t_final,{depth_min:depth_max},{lat_min:lat_max},{lon_min:lon_max})   ; so(tempo=0,{depth interval},lat,lon)
  depth1 = f->depth({depth_min:depth_max})                                                 ; extract depth
  
  time = f->time                                ; time of f and g should be the same (in this program). So the is no difference in using
                                                ; f(TEMP) or g(PASAL) file

;=================================================
;              CREATION DATE VARIABLE
;=================================================

    t_1 = cd_calendar(time(t_init),0)  
    t_2 = cd_calendar(time(t_final),0)             
                                            
    ; Year, month and day extraction

    year1   = t_1(:,0)                 ; year extraction (to string conversion)
    year2   = t_2(:,0)                 ; year extraction (to string conversion)
                 
    month1  = sprinti("%0.2i", tointeger( t_1(:,1) ))      ; month extraction (to string convertion)
    month2  = sprinti("%0.2i", tointeger( t_2(:,1) ))      ; month extraction (to string convertion)
                                          
    day1    = sprinti("%0.2i", tointeger( t_1(:,2)  ))                  ; day extraction (to string convertion)
    day2    = sprinti("%0.2i", tointeger( t_2(:,2)  ))                  ; day extraction (to string convertion)
                                           
    hour1   = sprinti( "%0.2i" , tointeger( t_1(:,3) ))             
    hour2   = sprinti( "%0.2i" , tointeger( t_2(:,3) ))

    minute1 = sprinti("%0.2i", tointeger( t_1(:,4) ))
    minute2 = sprinti("%0.2i", tointeger( t_2(:,4) ))

    ; Date formatting

    date1 = day1+"/"+month1+"/"+year1        ; to be used in plot's subtitles
    date_plot1 = year1+"-"+month1+"-"+day1   ; to be used to rename output immages

    date2 = day2+"/"+month2+"/"+year2       ; to be used in plot's subtitles
    date_plot2 = year2+"-"+month2+"-"+day2   ; to be used to rename output immages

;================================================
;             date_run extraction
;===============================================

  date_run = str_split( file_temp , "/" )

  year_run  = date_run(4)
  month_run = sprinti("%0.2i", tointeger( date_run(5) ))
  day_run   = sprinti("%0.2i", tointeger( date_run(6) ) - 1)   ; bulletin day

  date_run_f = year_run+"-"+month_run+"-"+day_run
 
;=================================================

if ( plot_type .eq. "s" ) then
 wks= gsn_open_wks("png","tsdiagram_"+date_run_f+"_"+diffusor_name+"_f"+date_plot1+"_"+hour1+"."+minute1 )    ; send graphics to PNG file
else
 wks= gsn_open_wks("png","tsdiagram_"+date_run_f+"_"+diffusor_name+"_f"+date_plot1+"_"+hour1+"."+minute1+"_"+plot_type+"_"+sprinti("%0.3i", n)) 
end if
;=================Graphics

; Before I create che pd lines plot

  resov                            = True
  resov@gsnDraw                    = False    ; Will draw later, after overlaying
  resov@gsnFrame                   = False
  resov@cnLevelSelectionMode       = "AutomaticLevels"
  resov@cnInfoLabelOn              = "False"
  resov@cnLineLabelPlacementMode   = "Constant"
  resov@cnLineLabelFontHeightF     = ".02"

  plotpd = gsn_csm_contour(wks,pd,resov)      ; create the underground mask with constant density lines


;--- scatter plot
  res                     = True
  res@gsnMaximize         = True
  res@gsnDraw             = False       ; Will draw later, after overlaying
  res@gsnFrame            = False

  res@xyMarkLineModes     = "Markers"   ; simbols used to mark the points
  res@xyMarkers           = 16
  res@txFontHeightF       = 0.015       ; font dimension of center string

if ( plot_type .eq. "s") then
  res@tiMainString        = "T-S Diagram at: "+date_plot1+" "+" "+hour1+":"+minute1+" UTC"
else
  res@tiMainString        = "T-S Diagram: from "+date_plot1+" "+hour1+":"+minute1+" to "+date_plot2+" "+hour2+":"+minute2+" UTC"
end if
 
  res@tiXAxisFontHeightF  = 0.02
  res@tiYAxisFontHeightF  = 0.02

;------ min and max extreme of X and Y axes

  res@trXMinF             = smincn      
  res@trXMaxF             = smaxcn
  res@trYMinF             = tmincn
  res@trYMaxF             = tmaxcn

  res@gsnRightString      = "Depth: "+depth_min+" -"+sprintf("%5.1f",depth_max)+" m"     ; string at top right of the graphic

  res@gsnCenterString     = "Denomination:"+diffusor_name      ; string at top center of the graphic
  res@tiXAxisString          = "Salinity [g/kg]"             
  res@tiYAxisString          = "Temperature [~S~o~N~C] "     ; the string ~S~o~N~ generate the special character °


  parallelpos = 1.15               ; the legend is disposed vertically, so the parallelpos remain constant
  yposition = -0.22                ; the initial position of y position of legend

plotpd = gsn_csm_contour(wks,pd,resov)

i_fin = level_num - 1

do i=0,i_fin   ; cycle on depths
  
  res@pmLegendDisplayMode    = "Always"                                 ; turn on legend
  res@pmLegendSide           = "Top"                                    ; Change order of collocation legends
;  res@lgAutoManage           = True

  res@pmLegendOrthogonalPosF = yposition                                ; move units down, distance from the top of the graph
  res@pmLegendParallelPosF   = parallelpos                              ; move units right, distance from legends

  res@pmLegendWidthF         = 0.05                                     ; Change width and
  res@pmLegendHeightF        = 0.05                                     ; height of legend.
  res@lgPerimOn              = False                                    ; turn on/off box around
  res@lgLabelFontHeightF     = .013                                     ; label font height

  if (depth1(i) .lt. 10.0 ) then
  res@pmLegendParallelPosF   = parallelpos - 0.0048                    ; this is only an aesthetic tool to allineate verticall the legend dots
  end if

  res@xyExplicitLegendLabels = sprintf("%5.1f",depth1(i))+" m"     ; create explicit labels
 
 
  x = ndtooned(salt(:,i,:,:))      ; select only the lat/long coordinates we want to plot in integer coordinates using the discrete grid/matrix
  y = ndtooned(temp(:,i,:,:))      ; created during the assignement above (in this case the lat long correspond to a {0:18}x{0:36} discrete grid)
                                   ; it is not necessary that correspond to the .nc coordinates selected

  res@xyMarkerColor      = (/  todouble(i)/i_fin , 1.0 -  todouble(i)/i_fin , 0./)  ; at numerator there is n+1 to avoid black

  plot_i = gsn_csm_xy(wks,x,y,res)      ; create the dots graph with T-S points. Every sinsle x element correspond to a particular

  overlay(plotpd,plot_i)

  yposition = yposition - 0.05
 
 delete(x)
 delete(y)

end do    ; end of cycle on depths 

  delete(temp)
  delete(salt)

  draw(plotpd)
  frame(wks)


end do    ; end of cycle on the graphs
                                              ; y element in the same order. 
  
  delete(depth1)

end do   ; end of cycle on the initialization_file lines

end
