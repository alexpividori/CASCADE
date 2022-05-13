begin

init_file = asciiread( "initialization_file_temp_sdim.txt" ,-1,"string")

 res                  = True               ; plot mods desired
 res@gsnDraw          = False              ; don't draw yet
 res@gsnFrame         = False              ; don't advance frame yet
 res@gsnMaximize      = True

 res@trYMaxF  =  28.0                   ; max value on y-axis 23.0
 res@trYMinF  =  4.0                    ; min value on y-axis  6.0

; res@trXMinF  =  1950                  ; min value on y-axis
; res@trXMaxF  =  2100

 res@tiXAxisFontHeightF  = 0.02
 res@tiYAxisFontHeightF  = 0.02

legend_color = (/ "black","black","green","green"/)   ; one for each statistical value: min max p25 p75 (for now)
legend_text  = (/ "minimum","maximum","25 percentile","75 percentile"/)

 lat_ref = 45.60
 lon_ref = 13.30

wks   = gsn_open_wks ("png", "sdim_temp_"+lat_ref+"_"+lon_ref ) ; send graphics to PNG file

;===============================================================================

do a=0, dimsizes(init_file)-1

 f     = addfile ( "/lustre/arpa/AdriaClim/data/Med_CORDEX_files/"+init_file(a) , "r")                         ; add file

 time_ext = f->time                                
 date_ext = cd_calendar(time_ext,-1)
 year0_month0 = str_split_by_length( date_ext(0) , 4  )
 year_middle = year0_month0(0)
 year_inf = toint(year_middle) - 5
 year_sup = toint(year_middle) + 5


 min_val = f->tos_min(:,{lat_ref},{lon_ref})
 max_val = f->tos_max(:,{lat_ref},{lon_ref})
 p25_val = f->tos_p25(:,{lat_ref},{lon_ref})
 p75_val = f->tos_p75(:,{lat_ref},{lon_ref}) 

 min_val_c = min_val - 273.15   ; for delta T you don't have to change unit dimension from K to °C
 max_val_c = max_val - 273.15
 p25_val_c = p25_val - 273.15
 p75_val_c = p75_val - 273.15 

;*************************
; legend parameters
;*************************

 dir_file_name    = str_split( init_file(a) , "/")
 RCP_val          = str_split( dir_file_name(1) , "_")                     ; splitting for the file name string 

;*************************
; plotting parameters
;*************************
 
 res@tiXAxisString = "Time [months]"
 res@tiYAxisString = "Sea surface temperature [~S~o~N~C]"
 res@tiMainString  = "Decade statistical values at: "+lat_ref+" ~S~o~N~N "+lon_ref+" ~S~o~N~E" ; title
 res@gsnLeftStringFontHeightF  = 0.012
 res@gsnRightStringFontHeightF = 0.012
 

 res@xyMarkLineModes   = "Markers"
 res@xyMarkers         =  16
 
months=(/"Jan","Feb","Mar","Apr","Magg","Ji","Lu","Au","Set","Ott","Nov","Dec"/)
res@xyMarkerColor     = "black"
plot1 = gsn_csm_xy( wks, months , min_val_c , res ) 
res@xyMarkerColor     = "black"
plot2 = gsn_csm_xy( wks, months , max_val_c , res )
res@xyMarkerColor     = "green"
plot3 = gsn_csm_xy( wks, months , p25_val_c , res )
res@xyMarkerColor     = "green"
res@gsnLeftString     = "Model:"+dir_file_name(0)+" "+RCP_val(4)+"_"+RCP_val(7)
res@gsnRightString    = "Decade: "+ year_inf +"-"+ year_sup
plot4 = gsn_csm_xy( wks, months , p75_val_c , res )
overlay( plot1 , plot2 )
overlay( plot1 , plot3 )
overlay( plot1 , plot4 )

delete([/ date_ext , time_ext , min_val , max_val , p25_val, p75_val , min_val_c , max_val_c , p25_val_c , p75_val_c , dir_file_name , RCP_val/])

end do

;============== LEGEND ========================

  gres     = True     ; legend position
  mrks     = True     ; legend markers
  textres  = True     ; legend labels
  gres@lgAutoManage     = False
  mrks@lgAutoManage     = False
  textres@lgAutoManage  = False

  gres@Position             = "Bottom"
  gres@YPosPercent          = 3.      ; from the bottom
  gres@XPosPercent          = 2.      ; move to the right side

  textres@lgLabelFontHeights = 0.012
  gres@ItemSpacePercent = 2.5

;---Attach legend to first plot
  textres@lgLabels     = legend_text
  mrks@lgMarkerColors  = legend_color 
  mrks@lgMarkerIndexes = 16

  plot = simple_legend(wks,plot1,gres,mrks,textres)

draw (plot)                                ; draw the contour object
frame (wks)                                ; advance frame

end
