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

 
 res@xyLineThicknessF = 2 ; line thickness of the graph (old value equal to 2)

 lat_ref = 45.60
 lon_ref = 13.30

wks   = gsn_open_wks ("png", "ub_surface_temp_"+lat_ref+"_"+lon_ref ) ; send graphics to PNG file

;===============================================================================

legend_color = new( dimsizes(init_file) , integer )
legend_text  = new( dimsizes(init_file) , string )

do a=0, dimsizes(init_file)-1

 f     = addfile ( "/lustre/arpa/AdriaClim/data/Med_CORDEX_files/"+init_file(a) , "r")                         ; add file

 time_ext  = f->time                                
 date_ext = cd_calendar(time_ext,4) 

 temp = f->tos(:,{lat_ref},{lon_ref})
 
;****************************************
  ihp   = 0                             ; indicating the filter tyep 0 for low_pass
  sigma = 1.0                           ; Lanczos sigma

  nWgt  = 59                            ; loose nWgt months each end side. Higher is nWgt and better the filter is                           
  fca   = 1./60.                        ; 5 years cutoff frequency in months because the files are monthly
  wgtq  = filwgts_lanczos (nWgt, ihp, fca, -999., sigma )
 
  TEMP =wgt_runave ( temp, wgtq, 0 )

;*************************
; legend parameters
;*************************

 line_color       = toint( ( tofloat(a+1)/(dimsizes(init_file)) )*255. )
 legend_color(a)  = line_color
 res@xyLineColors = line_color

 dir_file_name    = str_split( init_file(a) , "/")
 RCP_val          = str_split( dir_file_name(1) , "_") 
 legend_text(a)   = dir_file_name(0)+" "+RCP_val(4)+"_"+RCP_val(7)

;*************************
; plotting parameters
;*************************
 
 res@tiXAxisString = "Time [year]"
 res@tiYAxisString = "Sea surface Delta temperature [~S~o~N~C]"
 res@tiMainString  = "Adriatic Sea scenario at: "+lat_ref+" ~S~o~N~N "+lon_ref+" ~S~o~N~E" ; title
 res@gsnRightString = "Mean from 2010 to 2020"
 res@gsnRightStringFontHeightF = 0.01


if ( a .eq. 0 ) then 
plot = gsn_csm_xy( wks, date_ext , TEMP, res ) 
else
plot1= gsn_csm_xy( wks, date_ext , TEMP, res ) 
overlay( plot , plot1 )
end if 

delete([/date_ext,time_ext,TEMP,temp,dir_file_name, RCP_val/])

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
