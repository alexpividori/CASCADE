begin

init_file = asciiread( "initialization_file_temp.txt" , -1 , "string" )

 res                  = True               ; plot mods desired
 res@gsnDraw          = False              ; don't draw yet
 res@gsnFrame         = False              ; don't advance frame yet
 res@gsnMaximize      = True
 res@tmYMajorGrid     = True          ; implement y grid
 res@tmYMajorGridLineDashPattern = 2             ; select short dash lines
 res@tmXBMode         = "Explicit"

 res@trYMaxF  =   5.0               
 res@trYMinF  =  -3.0                  
 
 res@trXMaxF  =   13.0
 res@trXMinF  =    0.0


 res@tiXAxisFontHeightF  = 0.015
 res@tiYAxisFontHeightF  = 0.02


res@tmXBValues = (/ 1. , 2. , 3. , 4. , 5. , 6. , 7. , 8. , 9. , 10. , 11. , 12. /)
res@tmXBLabels = (/"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"/)
x_val = (/ 1. , 2. , 3. , 4. , 5. , 6. , 7. , 8. , 9. , 10. , 11. , 12. /)
res@tmXBLabelAngleF = 45

res@gsnYRefLine = 0.0
res@gsnYRefLineDashPattern = 2
res@gsnYRefLineThicknessF  = 1.5

;==================== Lon Lat Coordinates ======================================

lat_ref=lat_ref           ; these numbers will be passed by bash script
lon_ref=lon_ref
point_name=point_name

;===============================================================================

do a=0, dimsizes(init_file)-1

 dir_file_name    = str_split( init_file(a) , "/")
 RCP_val          = str_split( dir_file_name(1) , "_")                     ; splitting for the file name string

; Median file path is contained in the initialization file
; Directory is dir_file_name(0)

	if ( .not. fileexists( "/lustre/arpa/AdriaClim/data/Med_CORDEX_files/"+init_file(a) ) ) then
	print("/lustre/arpa/AdriaClim/data/Med_CORDEX_files/"+init_file(a)+" file doesn't exists")
	continue
	end if

mean_file_name="dmm_"+RCP_val(1)+"_"+RCP_val(2)+"_"+RCP_val(3)+"_"+RCP_val(4)+"_"+RCP_val(5)+"_"+RCP_val(6)+"_"+RCP_val(7)+"_"+RCP_val(8)+"_"+RCP_val(9)+"_"+RCP_val(10)

 f     = addfile ( "/lustre/arpa/AdriaClim/data/Med_CORDEX_files/"+init_file(a) , "r")                                    ; median
 g     = addfile ( "/lustre/arpa/AdriaClim/data/Med_CORDEX_files/"+dir_file_name(0)+"/"+mean_file_name , "r")             ; mean

;===============================
;        Year/s extraction
;===============================

 time_ext = f->time                                
 date_ext = cd_calendar(time_ext,-1)
 year0_month0 = str_split_by_length( date_ext(0) , 4  )
 year_middle = year0_month0(0)
 year_inf = toint(year_middle) - 5
 year_sup = toint(year_middle) + 5


 median_val = f->tos_med(:,{lat_ref},{lon_ref})
 mean_val   = g->tos_mean(:,{lat_ref},{lon_ref}) 

;*************************
; plotting parameters
;*************************

 res@tiXAxisString = "Model:"+dir_file_name(0)+"_"+RCP_val(4)+"_"+RCP_val(7) 
 res@tiYAxisString = "Difference Sea surface temperature [~S~o~N~C]"
 res@tiMainString  = "Decade statistical values at: "+point_name ; title
 res@gsnLeftStringFontHeightF  = 0.012
 res@gsnRightStringFontHeightF = 0.012
 

 res@xyMarkLineModes   = "Markers"
 res@xyMarkers         =  16

wks   = gsn_open_wks ("png", "/lustre/arpa/AdriaClim/public_html/Med_CORDEX_analysis/SCENARIO/dmme_dots_NCL/"+dir_file_name(0)+"/"+point_name+"/"+"dmme_dots_temp_"+point_name+"_"+dir_file_name(0)+"_"+RCP_val(4)+"_"+RCP_val(7)+"_"+year_inf+"_"+year_sup )

res@pmLegendDisplayMode    = "Always"
res@xyExplicitLegendLabels = "Median"
res@pmLegendOrthogonalPosF =  -0.21                    ; move units down, distance from the top of the graph
res@pmLegendParallelPosF   = 0.90
res@pmLegendWidthF         = 0.05                                     ; Change width and
res@pmLegendHeightF        = 0.05                                     ; height of legend.
res@lgPerimOn              = False                                    ; turn on/off box around
res@lgLabelFontHeightF     = .015                                     ; label font height
res@pmLegendSide           = "Top"


res@xyMarkerColor     = "blue"
plot1 = gsn_csm_xy( wks, x_val , median_val , res ) 
res@xyMarkerColor     = "red"
res@gsnLeftString     = "Reference decade: 2010-2020"
res@xyExplicitLegendLabels = "  Mean "
res@pmLegendOrthogonalPosF =  -0.25
res@gsnRightString    = "Decade: "+ year_inf +"-"+ year_sup
plot2 = gsn_csm_xy( wks, x_val , mean_val   , res )
overlay( plot1 , plot2 )

draw (plot1)                               ; draw the contour object
frame (wks)                                ; advance frame

delete([/ date_ext , time_ext , median_val, mean_val , dir_file_name , RCP_val , res@gsnRightString /])

end do


end
