;************************************************
;
;  DESCRIPTION:      - This script realize a boxplot diagram  
;                      indicating for each month the distribution
;                      of physical dimension (like temperature and salinity)
;                      monthly mean in a decade time range. 
;                      The values indicated are mean, median, first and third quartile
;                      (25th and 75th percentile). Minimum and maximum.
;
;  EXTERNAL CALLS:   bash script
;
;  EXTERNAL FILES:   - input NetCDF data files downloaded from Med_CORDEX
;                      or ERDDAP official sites
;                   
;
;  DEVELOPER:        Alex Pividori (alex.pividori@arpa.fvg.it)
;                    ARPA FVG - S.O.C. Stato dell'Ambiente - CRMA
;                    "AdriaClim" Interreg IT-HR project
;
;  SOFTWARE VERSION: NCL 6.6.2
;                   
;
;  CREATION DATE:    08/02/2022
;
;  MODIFICATIONS:    ??/02/2022 --> 
;
;  VERSION:          0.1.
;
;************************************************

;#################################################
;                 SALINITY VERSION
;#################################################

begin

init_file = asciiread( "initialization_file_sal_sdim.txt" ,-1,"string")

 res                   = True            ; plot mods desired
; res@gsnMaximize      = True

 res@trYMaxF  =  40.0                    ; max value on y-axis 40.0
 res@trYMinF  =  36.0                    ; min value on y-axis 34.0

 
 res@tmXBLabelFontHeightF = 0.02
 res@tiXAxisFontHeightF  = 0.015
 res@tiYAxisFontHeightF  = 0.02
 res@tmXBLabelAngleF     = 45
 res@tmYMajorGrid                = True          ; implement y grid
 res@tmYMajorGridLineDashPattern = 2             ; select short dash lines

 res@tmXBLabels = (/"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"/)
 res@tiYAxisString = "Sea surface salinity [PSU]" 

;**********************************************
; resources for polylines that draws the boxes
;**********************************************  

 llres                   = True			
 llres@gsLineThicknessF  = 2.7                 ; line thickness 

;**********************************************
; resources that control color and width of boxes
;**********************************************  

  opti          = True			
  opti@boxWidth = 0.7				; Width of box (x units)

;**********************************************

sal_data = new((/ 12 , 5 /),"float")

lat_ref=lat_ref           ; these numbers will be passed by bash script
lon_ref=lon_ref 
point_name=point_name

 x_val = (/ 1. , 2. , 3. , 4. , 5. , 6. , 7. , 8. , 9. , 10. , 11. , 12. /)

;===============================================================================

do a=0, dimsizes(init_file)-1

 f     = addfile ( "/lustre/arpa/AdriaClim/data/Med_CORDEX_files/"+init_file(a) , "r")                         ; add file

 time_ext     = f->time                                
 date_ext     = cd_calendar(time_ext,-1)
 year0_month0 = str_split_by_length( date_ext(0) , 4  )
 year_middle  = year0_month0(0)
 year_inf     = toint(year_middle) - 5
 year_sup     = toint(year_middle) + 5


 min_val    = f->sos_min(:,{lat_ref},{lon_ref})
 max_val    = f->sos_max(:,{lat_ref},{lon_ref})
 p25_val    = f->sos_p25(:,{lat_ref},{lon_ref})
 p75_val    = f->sos_p75(:,{lat_ref},{lon_ref}) 
 median_val = f->sos_med(:,{lat_ref},{lon_ref})
 mean_val   = f->sos_mean(:,{lat_ref},{lon_ref})

if ( ismissing(min_val(0))   ) then
print("The point: "+point_name+" is outside the domain. Missing value found.")
continue
end if

;====== This is an heritage of Temperature version =====

 min_val_c    = min_val       ; for delta T you don't have to change unit dimension from K to °C
 max_val_c    = max_val       ; each of these vectors contains 12 elements
 p25_val_c    = p25_val    
 p75_val_c    = p75_val    
 median_val_c = median_val 
 mean_val_c   = mean_val   

;*******************************************
;   Creation of the boxplot data (matrix)
;*******************************************

do i=0, 11                            ; months are 12: from 0 to 11
   sal_data(i,0) = min_val_c(i)      ; first dimension indicate the month, the second the statistical dimension: temp_data(month,statistical_value) 
   sal_data(i,1) = p25_val_c(i)
   sal_data(i,2) = median_val_c(i)
   sal_data(i,3) = p75_val_c(i)
   sal_data(i,4) = max_val_c(i)
end do

;*************************
; legend parameters
;*************************

 dir_file_name    = str_split( init_file(a) , "/")
 RCP_val          = str_split( dir_file_name(1) , "_")                     ; splitting for the file name string 

;*************************
;   plotting parameters
;************************:*

 res@tiMainString  = "Decade statistical values at: "+point_name+"~C~           from "+year_inf+" to "+year_sup ; title
 res@tiXAxisString = "Model: "+dir_file_name(0)+"_"+RCP_val(4)+"_"+RCP_val(7)  ; I write the model name at the x axis title
 ; dir_file_name(0)  : Global Model and Regional Model CMCC-CM_COSMOMED
 ; RCP_val(4)        : rcp45 rcp85 etc.
 ; RCP_val(7)        : version v1 v2

  mres               = True                     ; marker mods desired
  mres@gsMarkerIndex = 1                        ; polymarker style
  mres@gsMarkerSizeF = 25.                      ; polymarker size
  mres@gsMarkerColor = "blue"                   ; polymarker color

wks   = gsn_open_wks ("png", "/lustre/arpa/AdriaClim/public_html/Med_CORDEX_analysis/SCENARIO/boxplot_NCL/"+dir_file_name(0)+"/"+point_name+"/"+"sdim_boxplot_sal_"+point_name+"_"+dir_file_name(0)+"_"+RCP_val(4)+"_"+RCP_val(7)+"_"+year_inf+"_"+year_sup ) 

plot = boxplot(wks , x_val , sal_data , opti , res , llres)

;**********************************
;        Mean values markers
;**********************************

  dum1  = gsn_add_polymarker(wks, plot , 1  , mean_val_c(0)  , mres) 
  dum2  = gsn_add_polymarker(wks, plot , 2  , mean_val_c(1)  , mres)
  dum3  = gsn_add_polymarker(wks, plot , 3  , mean_val_c(2)  , mres)
  dum4  = gsn_add_polymarker(wks, plot , 4  , mean_val_c(3)  , mres)
  dum5  = gsn_add_polymarker(wks, plot , 5  , mean_val_c(4)  , mres)
  dum6  = gsn_add_polymarker(wks, plot , 6  , mean_val_c(5)  , mres)
  dum7  = gsn_add_polymarker(wks, plot , 7  , mean_val_c(6)  , mres)
  dum8  = gsn_add_polymarker(wks, plot , 8  , mean_val_c(7)  , mres)
  dum9  = gsn_add_polymarker(wks, plot , 9  , mean_val_c(8)  , mres)
  dum10 = gsn_add_polymarker(wks, plot , 10 , mean_val_c(9)  , mres)
  dum11 = gsn_add_polymarker(wks, plot , 11 , mean_val_c(10) , mres)
  dum12 = gsn_add_polymarker(wks, plot , 12 , mean_val_c(11) , mres)

;**************************

draw (plot)                                ; draw the contour object
frame (wks)                                ; advance frame


delete([/ date_ext , time_ext , min_val , max_val , p25_val, p75_val , mean_val , median_val , median_val_c , mean_val_c , min_val_c , max_val_c , p25_val_c , p75_val_c , dir_file_name , RCP_val/])

end do


end
