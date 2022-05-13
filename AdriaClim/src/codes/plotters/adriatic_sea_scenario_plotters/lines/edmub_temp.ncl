;************************************************
;
;  DESCRIPTION:      - This NCL script created a scenario and historical
;                    lines for sea surface temperature/salinity or height trend.
;                    The colored line represent a 5 years mobile mean.
;                    
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
;  CREATION DATE:    22/02/2022
;
;  MODIFICATIONS:    ??/02/2022 -->
;
;  VERSION:          0.1.
;
;************************************************

;#################################################
;                 TEMPERATURE VERSION
;#################################################

begin

init_file = asciiread( "initialization_file_temp.txt" ,-1,"string")

 res                  = True               ; plot mods desired
 res@gsnDraw          = False              ; don't draw yet
 res@gsnFrame         = False              ; don't advance frame yet
 res@gsnMaximize      = True

 res@trYMaxF  =   4.0                   ; max value on y-axis 23.0
 res@trYMinF  =  -8.0                   ; min value on y-axis  6.0

 res@trXMinF  =  1950                  ; min value on y-axis
 res@trXMaxF  =  2100

 res@tiXAxisFontHeightF  = 0.02
 res@tiYAxisFontHeightF  = 0.02

 res@gsnXRefLine  = 2006
 res@gsnXRefLineThicknessF = 0.5   
 res@gsnXRefLineDashPattern = 2

 res@gsnYRefLine            = 0.0  ; zero horizontal reference
 res@gsnYRefLineThicknessF  = 0.5
 res@gsnYRefLineDashPattern = 2

 
 res@xyLineThicknessF = 3 ; line thickness of the graph (old value equal to 2)

;=========================== Lon Lat Coordinates ==============================

lat_ref=lat_ref           ; these numbers will be passed by bash script
lon_ref=lon_ref
point_name=point_name

;===============================================================================

wks   = gsn_open_wks ("png", "/lustre/arpa/AdriaClim/public_html/Med_CORDEX_analysis/SCENARIO/edmub_lines_NCL"+\
"/"+point_name+"/"+"edmub_lines_temp_"+point_name )

;================================================  Model Cycle ===========================================================
i_nm=-1
do a=0, dimsizes(init_file)-1

 dir_file_name    = str_split( init_file(a) , "/")
 RCP_val          = str_split( dir_file_name(1) , "_")                     ; splitting for the file name string

; Directory is dir_file_name(0)

print(init_file(a))
        if ( .not. fileexists( "/lustre/arpa/AdriaClim/data/Med_CORDEX_files/"+init_file(a) ) ) then
        print("/lustre/arpa/AdriaClim/data/Med_CORDEX_files/"+init_file(a)+" file doesn't exists")
        continue
        end if

 f     = addfile ( "/lustre/arpa/AdriaClim/data/Med_CORDEX_files/"+init_file(a) , "r")                         ; add file

 time_ext  = f->time                                
 date_ext = cd_calendar(time_ext,4) 

 var_d = f->tos(:,{lat_ref},{lon_ref})     ; Temperature

	if (  ismissing(var_d(0)) ) then
	   print("The point: "+point_name+" is outside the domain. Missing value found.")
           delete([/date_ext,time_ext,var_d,dir_file_name, RCP_val/])
	   continue
        else
         ;  print("The point: "+point_name+" is inside the domain: "+init_file(a) )
           i_nm = i_nm + 1
	end if
 
;****************************************

  ihp   = 0                             ; indicating the filter tyep 0 for low_pass
  sigma = 1.0                           ; Lanczos sigma

  nWgt  = 59                            ; loose nWgt months each end side. Higher is nWgt and better the filter is                           
  fca   = 1./60.                        ; 5 years cutoff frequency in months because the files are monthly
  wgtq  = filwgts_lanczos (nWgt, ihp, fca, -999., sigma )
 
  VAR = wgt_runave ( var_d , wgtq , 0 )

;*************************
; legend parameters
;*************************

 line_color       = toint( ( tofloat(i_nm+1)/(dimsizes(init_file)) )*255. )
 res@xyLineColors = line_color

if ( i_nm .eq. 0 ) then
 legend_color = new( 1 , integer )
 legend_text  = new( 1 , string )
 legend_color(0) = line_color
 legend_text(0)  = dir_file_name(0)+" "+RCP_val(4)+"_"+RCP_val(7)
else 
 legend_color_n = array_append_record ( legend_color , line_color , 0 )
 delete(legend_color)
 legend_color   = legend_color_n
 delete(legend_color_n) 

 legend_text_n = array_append_record ( legend_text , dir_file_name(0)+" "+RCP_val(4)+"_"+RCP_val(7) , 0 )
 delete(legend_text)
 legend_text = legend_text_n
 delete(legend_text_n)
end if

; legend_color(a)  = line_color     ; the a-th color of the a-th line/model
; legend_text(a)   = dir_file_name(0)+" "+RCP_val(4)+"_"+RCP_val(7)

;*************************
; plotting parameters
;*************************
 
 res@tiXAxisString = "Time [year]"
 res@tiYAxisString = "Sea surface Delta temperature [~S~o~N~C]"
 res@tiMainString  = "Adriatic Sea scenario at: "+point_name            ; main title
 res@gsnRightStringFontHeightF = 0.01

;********************************************************************

	if ( i_nm .eq. 0 ) then 
        res@gsnRightString = "Differences compared to 2010-2020 decade mean"
	plot = gsn_csm_xy( wks, date_ext , VAR, res ) 
	else
        res@gsnRightString = ""
	plot1= gsn_csm_xy( wks, date_ext , VAR, res ) 
	overlay( plot , plot1 )
	end if 

delete([/date_ext,time_ext,VAR,var_d,dir_file_name, RCP_val/])

end do

;============== LEGEND ========================

  gres     = True     ; legend position
  lineres  = True     ; legend lines
  textres  = True     ; legend labels
  gres@lgAutoManage  = False
  lineres@lgAutoManage  = False
  textres@lgAutoManage  = False

  gres@Position             = "Bottom"
  gres@YPosPercent          = 3.      ; from the bottom
  gres@XPosPercent          = 2.      ; move to the right side
  lineres@lgLineThicknesses = 8.0      ; line thicknesses of the legend
  lineres@LineLengthPercent = 4.       ; expressed as %, 0->100, length of line
  textres@lgLabelFontHeights = 0.012
  gres@ItemSpacePercent = 2.5

;---Attach legend to first plot
  textres@lgLabels     = legend_text
  lineres@lgLineColors = legend_color 
  plot = simple_legend(wks,plot,gres,lineres,textres)

draw (plot)                                ; draw the contour object
frame (wks)                                ; advance frame

end
