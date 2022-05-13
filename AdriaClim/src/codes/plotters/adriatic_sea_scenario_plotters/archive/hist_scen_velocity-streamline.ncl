begin
;=================================================;
; open file and read in data
;=================================================;

 fu    = addfile("/lustre/arpa/AdriaClim/data/Med_CORDEX_files/CNRM-CM5_CNRM-RCSM4/mean_uos_MED-10_CNRM-CM5_rcp85_r8i1p1_CNRM-RCSM4_v1_decade_195001_210012.nc","r")
 fv    = addfile("/lustre/arpa/AdriaClim/data/Med_CORDEX_files/CNRM-CM5_CNRM-RCSM4/mean_vos_MED-10_CNRM-CM5_rcp85_r8i1p1_CNRM-RCSM4_v1_decade_195001_210012.nc","r")
 time_ext = fu->time
 date_ext = cd_calendar(time_ext,0)

do a=0, dimsizes(date_ext(:,0))-1

 u     = fu->uos(a,0,:,:)    ; read in example data [2D only here]
 v     = fv->vos(a,0,:,:)
 speed = sqrt(u^2+v^2)                

;=================================================;
; Create plot
;=================================================;
  wks  = gsn_open_wks("png","str_lines_vel_"+sprinti("%0.2i", a) )          ; send graphics to PNG file

  mpres                  = True                      ; plot mods desired
  mpres@gsnMaximize      = True                      ; maximize plot in frame
  mpres@gsnDraw       = False          
  mpres@gsnFrame      = False          


  mpres@vfXArray         = u&lon
  mpres@vfYArray         = u&lat

  mpres@tiMainString                = "Velocity decade mean RCP 8.5: "+(date_ext(a,0)-4)+" to "+(date_ext(a,0)+6)
  mpres@tiMainFontHeightF = 0.02
;  mpres@gsnRightString              = "Surface water velocity"     ; string at top right of the graphic
;  mpres@gsnRightStringFontHeightF   = 0.012
;  mpres@gsnCenterString             = "RCP "                  ; string at top center of the graphic
;  mpres@gsnCenterStringFontHeightF  = 0.014

;---Zoom in on map
  mpres@mpMinLatF             = 44
  mpres@mpMaxLatF             = 46
  mpres@mpMinLonF             = 12
  mpres@mpMaxLonF             = 14

  mpres@mpOutlineOn           = True
  mpres@mpDataBaseVersion     = "HighRes"   ; slightly better outlines

;---Data is regional
  mpres@gsnAddCyclic          = False

;---Change the streamline levels

  mpres@stLevelPalette        = "gui_default" 
  mpres@stLineThicknessF      = 3.0         ; default value 1.0 is too thin
  mpres@stLevelSelectionMode  = "ManualLevels"
  mpres@stMinLevelValF        = 1
  mpres@stMaxLevelValF        = 10        ; the color bar contains olso the 50 and 0 cm/s region
  mpres@stLevelSpacingF       = 1
  mpres@pmTickMarkDisplayMode = "Always"    ; more detailed tickmarks
  mpres@stZeroFLabelSide      = "Bottom"
;--- Label bar 

  mpres@lbTitleString         = "Sea surface velocity[cm/s]"
  mpres@lbTitleFontHeightF    = 0.013
  mpres@lbLabelFontHeightF    = 0.013
  mpres@lbTitlePosition       = "Bottom"
  mpres@stArrowLengthF        = 0.01 

  plot = gsn_csm_streamline_scalar_map(wks,u,v,speed*100,mpres)
  
  res = True
  res@txFontHeightF = 0.015
  text =  gsn_add_text(wks,plot,"CNRM-CM5_CNRM-RCSM4",12.45,45.9,res)
  draw(plot)
  frame(wks)
end do
end
