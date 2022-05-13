;*****************************************************************************
;
; Read currents (CUR) from a netCDF file
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
;                   (e.g. see in /lustre/arpa/AdriaClim/COPERNICUSData/PSAL)
;                   and
;                   (e.g. see in /lustre/arpa/AdriaClim/COPERNICUSData/TEMP)
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
; MODIFICATIONS:  17/02/2021 --->  Creation of script starting from the ncl code "S_T_diagram.ncl"
;                                  present in the path: "/lustre/arpa/scratch/pividori.tmp/golfo/S_T_diagram"
;
;                                  The "S_T_diagram.ncl" was created to plot the TS diagram from a single daily data .nc file    
;               
;                  23/02/2021 --->  Modification of the do cycle transformating a single x and y data in a 2D array with the same value to
;                                   plot a single dot in a xy graph. In this way it is possible to make a TS diagram of a single water column.    
;                                  -Insertion of an if()then end if when the legend number is .lt. 10 to allineate all the dots on the same vertical line.

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
         level_section_string  =line(8)         

         delta_t = tointeger(line(7))
         level_section = tointeger(line(8))

delete(line)

;============= addfiles =================

  file_cur = "/lustre/arpa/scratch/COPERNICUSMarine_dowload/2020/12/RFVL/20201201_h-CMCC--RFVL-MFSeas5-MEDATL-b20201215_an-sv06.00.nc"

if (.not. fileexists(file_cur)) then
  print("Error: Temperature file doesn't exists.")
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

cur_test = f->uo(0,{depth_min:1000},{lat_min:lat_max},{lon_min:lon_max})
depth_test = f->depth({depth_min:1000})
level_num = max( dim_num_n( .not. ismissing(cur_test) , 0 ))

depth_max = depth_test(level_num - 1)

delete(cur_test)
delete(depth_test)

;=======================================================

time_steps = dimsizes(time)

if ( plot_type .eq. "s"  ) then

t_analysis  = delta_t   ; because NCL starts counting from 0

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

  wks= gsn_open_wks("png","tsdiagram"+"_"+serial_name+"_"+a+"_"+plot_type+"_"+sprinti("%0.3i", n))    ; send graphics to PNG file

  u = f->uo(t_analysis,level_section,{lat_min:lat_max},{lon_min:lon_max})
  v = f->vo(t_analysis,level_section,{lat_min:lat_max},{lon_min:lon_max})
  depth1 = f->depth({depth_min:depth_max})                                                 ; extract depth
  
  time = f->time                                ; time of f and g should be the same (in this program). So the is no difference in using
                                                ; f(TEMP) or g(PASAL) file

;=================================================
;              CREATION DATE VARIABLE
;=================================================

    t_1 = cd_calendar(time(t_analysis),0)  
                                            
    ; Year, month and day extraction

    year1 = t_1(:,0)                 ; year extraction (to string conversion)
    month1 = t_1(:,1)                ; month extraction (to string convertion)
    day1 = t_1(:,2)                  ; day extraction (to string convertion)
    hour1 = t_1(:,3)             
    minute1 = t_1(:,4)
    ; Date formatting

    date1 = day1+"/"+month1+"/"+year1        ; to be used in plot's subtitles
    date_plot1 = year1+"-"+month1+"-"+day1   ; to be used to rename output immages

;=================Graphics

;--- streamlines plot

  mpres                       = True
  mpres@gsnMaximize           = True
;  mpres@tiMainString          = "Streamlines currents at: "+date_plot1+" "+hour1+":"+minute1
 
;  mpres@gsnRightString        = "Depth= "+depth1(level_section)+" m"     ; string at top right of the graphic

;  mpres@gsnCenterString       = "Diffusor:"+serial_name      ; string at top center of the graphic

;---Zoom in on map
  mpres@mpMinLatF             = todouble(lat_min)
  mpres@mpMaxLatF             = todouble(lat_max)
  mpres@mpMinLonF             = todouble(lon_min)
  mpres@mpMaxLonF             = todouble(lon_max)

  mpres@mpOutlineOn           = True
  mpres@mpDataBaseVersion     = "HighRes"   ; slightly better outlines
  mpres@mpLandFillColor       = "gray91"
;---Data is regional
  mpres@gsnAddCyclic          = False

;---Change the streamline levels
;  mpres@stLevelSpacingF       = 30.

  mpres@stLevelPalette        = "ncl_default" ; "MPL_Spectral" 
  mpres@stLineThicknessF      = 1.0         ; default is 1.0
  mpres@stLevelSelectionMode  = "ManualLevels"
  mpres@stMinLevelValF        = 0
  mpres@stMaxLevelValF        = 0.5
  mpres@stLevelSpacingF       = 0.01

  mpres@pmTickMarkDisplayMode = "Always"    ; more detailed tickmarks

  speed = sqrt( u^2 + v^2 )

  plot = gsn_csm_streamline_scalar_map(wks, u(:,:), v(:,:), speed(:,:) , mpres)

  delete(u)
  delete(v)

end do    ; end of cycle on the graphs
                                              ; y element in the same order. 
  delete(depth1)

end do   ; end of cycle on the initialization_file lines

end
