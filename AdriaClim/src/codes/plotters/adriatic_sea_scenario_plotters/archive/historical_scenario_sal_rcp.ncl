begin

init_file = asciiread( "initialization_file_sal.txt" ,-1,"string")

 res                  = True               ; plot mods desired
 res@gsnDraw          = False              ; don't draw yet
 res@gsnFrame         = False              ; don't advance frame yet
 res@gsnMaximize      = True

 res@trYMaxF  =  40.5                   ; max value on y-axis
 res@trYMinF  =  31.0                   ; min value on y-axis

 res@trXMinF  =  1950                  ; min value on y-axis
 res@trXMaxF  =  2100

 res@tiXAxisFontHeightF  = 0.02
 res@tiYAxisFontHeightF  = 0.02

 res@gsnXRefLine  = 2006
 res@gsnXRefLineThicknessF = 0.5
 res@gsnXRefLineDashPattern = 2
 
 res@xyLineThicknessF = 2

 lat_ref = 42.6
 lon_ref = 16

wks   = gsn_open_wks ("png", "sal_rcp_scenario_"+lat_ref+"_"+lon_ref ) ; send graphics to PNG file

;===============================================================================

do a=0, dimsizes(init_file)-1

 f     = addfile ( "/lustre/arpa/AdriaClim/data/Med_CORDEX_files/"+init_file(a) , "r")                         ; add file

 time_ext  = f->time    
                            
 date_ext = cd_calendar(time_ext,4) 

 sal = f->sos(:,{lat_ref},{lon_ref})
 

;****************************************
  ihp   = 0                             ; indicating the filter tyep 0 for low_pass
  sigma = 1.0                           ; Lanczos sigma

  nWgt  = 59                            ; loose nWgt months each end side. Higher is nWgt and better the filter is                           
  fca   = 1./60.                        ; 5 years cutoff frequency in months because the files are monthly
  wgtq  = filwgts_lanczos (nWgt, ihp, fca, -999., sigma )
 
  SAL =wgt_runave ( sal, wgtq, 0 )

;*************************
; legend parameters
;*************************

 dir_file_name    = str_split( init_file(a) , "/")
 RCP_val          = str_split( dir_file_name(1) , "_")


if ( RCP_val(4) .eq. "rcp85" ) then
 line_color       = "red"
else if ( RCP_val(4) .eq. "rcp45"  ) then
 line_color       = "blue"
else if ( RCP_val(4) .eq. "rcp26"  ) then
 line_color       = "green"
end if
end if
end if

 res@xyLineColors = line_color

;*************************
; plotting parameters
;*************************
 
 res@tiXAxisString = "Time [year]"
 res@tiYAxisString = "Sea surface salinity [PSU]"
 res@tiMainString  = "Adriatic Sea scenario at: "+lat_ref+" ~S~o~N~N "+lon_ref+" ~S~o~N~E" ; title


if ( a .eq. 0 ) then 
plot = gsn_csm_xy( wks, date_ext , SAL, res ) 
else
plot1= gsn_csm_xy( wks, date_ext , SAL, res ) 
overlay( plot , plot1 )
end if 

delete([/date_ext,time_ext,sal,SAL,dir_file_name, RCP_val/])

end do

;============== LEGEND ========================

  legend_text   = (/ "rcp8.5", "rcp4.5", "rcp2.6" /)
  legend_color  = (/ "red", "blue", "green" /)

  gres     = True     ; legend position
  lineres  = True     ; legend lines
  textres  = True     ; legend labels
  gres@lgAutoManage  = False
  lineres@lgAutoManage  = False
  textres@lgAutoManage  = False

  gres@Position             = "Bottom"
  gres@YPosPercent          = 3.      ; from the bottom
  gres@XPosPercent          = 2.      ; move to the right side
  lineres@lgLineThicknesses = 8.0      ; line thicknesses
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
