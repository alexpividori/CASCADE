;******************************************************************************
;
; DESCRIPTION:      this NCL script is inspired by the "gsn_stream_4.ncl" NCL
;                   script, which can be found at the following link:
;                   https://www.ncl.ucar.edu/Applications/Scripts/gsn_stream_4.ncl
;                   This script is aimed at drawing a streamline plot, colored
;                   by a given scalar field, and interpolated at two specified
;                   depths, by using "gsn_csm_streamline_scalar_map" (*). This
;                   is performed for each time step belonging to the NetCDF
;                   file to be considered (see the EXTERNAL FILES comment
;                   section).
;                   The magnitude of the current's speed, interpolated at two
;                   depths, is the scalar field mentioned above.
;                   (*) https://www.ncl.ucar.edu/Document/Graphics/Interfaces/gsn_streamline_scalar.shtml
;
; EXTERNAL CALLS:   none.
;
; EXTERNAL FILES:   - input NetCDF data file (currents);
;                   - initialisation file containing the full path of
;                     the input NetCDF file to be considered. This file is
;                     formatted as follows:
;
;                     input NetCDF file
;
; DEVELOPER:        Alessandro Minigher (alessandro.minigher@arpa.fvg.it)
;                   ARPA FVG - S.O.C. Stato dell'Ambiente - CRMA
;                   "AdriaClim" Interreg IT-HR project
;
; SOFTWARE VERSION: NCL 6.6.2.
;
; CREATION DATE:    27/03/2021.
;
; MODIFICATIONS:    15/04/2021 ---> change of the full path of the
;                                   initialisation file.
;
; VERSION:          0.2.
;
;******************************************************************************

;*****************
; START OF SCRIPT
;*****************

begin

; Definition of the full path of the initialisation file

init_file_cur = "/u/arpa/minighera/AdriaClim/src/initialisation_files/init_file_iso_speed_all_time_steps.txt"

; Opening attempt to the initialisation file in reading mode

input_files_cur=asciiread(init_file_cur,-1,"string")

; Definition of the depths to be investigated (in meters)

depth1 = 13
depth2 = 22

; For every data file to be considered.

do i=0,dimsizes(input_files_cur)-1

    ; Opening attempt to the i-th external NetCDF file

    f_cur = addfile(input_files_cur(i),"r")

    ; Extraction of the number of time steps in the data file to be considered

    time = f_cur->time
    time_steps = dimsizes(time)

    ; For every time step in the data file to be considered

    do j=0,time_steps-1

        ; Data extraction from the file to be considered

        u = f_cur->uo(j,:,{42.5:45.97917},{12.:16.})           ; horizontal sea
                                                               ; current along
                                                               ; x-axis
        z_u = f_cur->depth                                     ; depth

        v = f_cur->vo(j,:,{42.5:45.97917},{12.:16.})           ; horizontal sea
                                                               ; current along
                                                               ; y-axis
        z_v = f_cur->depth                                     ; depth

        time = f_cur->time                                     ; date and time
        time = time(j)

        ; Date and time conversion to UTC time

        utc_date = cd_calendar(time,0)

        ; Year, month, day, hour, minute and second extraction

        year = tostring(tointeger(utc_date(j,0)))
        month = tostring(tointeger(utc_date(j,1)))
        day = tostring(tointeger(utc_date(j,2)))
        hour = tostring(tointeger(utc_date(j,3)))
        minute = tostring(tointeger(utc_date(j,4)))
        second = tostring(tointeger(utc_date(j,5)))

        ; Proper date and time formatting

        if (tointeger(month) .lt. 10) then

            month = "0"+month

        end if

        if (tointeger(day) .lt. 10) then

            day = "0"+day

        end if

        if (tointeger(hour) .lt. 10) then

            hour = "0"+hour

        end if

        if (tointeger(minute) .lt. 10) then

            minute = "0"+minute

        end if

        if (tointeger(second) .lt. 10) then

            second = "0"+second

        end if

        date = day+"/"+month+"/"+year+" "+hour+":"+minute        ; to be used in plot's subtitles
        date_plot = year+"-"+month+"-"+day+"-"+hour+"-"+minute   ; to be used to rename output immages

        ; Interpolation of data to be plotted to the specified (constant) depths:

        zlev_u = (/ depth1, depth2 /)               ; Depth specification
        zlev_u@units = z_u@units                    ; Set the specified depth's
                                                    ; units to horizontal current's
                                                    ; x-axis component
        zlev_u!0 = "zlev_u"                         ; assign dimension name
                                                    ; same as variable name
        iso_u = int2p_n_Wrap(z_u,u, zlev_u, 0, 0)   ; Implementation of the desired
                                                    ; interpolation (logarithmic)
        ;iso_u = int2p_n_Wrap(z_u,u, zlev_u, 1, 0)   ; Implementation of the desired
                                                    ; interpolation (linear)
        zlev_v = (/ depth1, depth2 /)               ; Depth specification
        zlev_v@units = z_v@units                    ; Set the specified depth's
                                                    ; units to horizontal current's
                                                    ; y-axis component
        zlev_v!0 = "zlev_v"                         ; assign dimension name
                                                    ; same as variable name
        iso_v = int2p_n_Wrap(z_v,v, zlev_v, 0, 0)   ; Implementation of the desired
                                                    ; interpolation (logarithmic)
        ;iso_v = int2p_n_Wrap(z_v,v, zlev_v, 1, 0)   ; Implementation of the desired
                                                    ; interpolation (linear)

        ; Computation of the interpolated horizontal sea current speed (magnitude)

        iso_speed = sqrt(iso_u^2+iso_v^2)

        ; Print the summary of the desired variables, together with their minimmum
        ; and maximum values

        printVarSummary(iso_u)        ; interpolated current's x-axis component
        printMinMax(iso_u, True)
        printVarSummary(iso_v)        ; interpolated current's y-axis component
        printMinMax(iso_v, True)
        printVarSummary(iso_speed)    ; interpolated speed
        printMinMax(iso_speed, True)

          ;**********
          ; PLOTTING
          ;**********

          ; Array creation to hold plots

          plot_speed = new(2, "graphic")

          ; Workstations opening: send graphics to PNG file

          wks_speed = gsn_open_wks("png","iso_speed_"+date_plot)

          ; Plot's resources

          res = True                                  ; plot mods desired
          res@gsnMaximize = True                      ; maximize plot in frame
          res@gsnDraw = False                         ; turn off automatic draw
          res@gsnFrame = False                        ; turn off the automatic
          res@lbLabelAutoStride = True                ; color bar labels are
                                                      ; checked for overlap before
                                                      ; being drawn
          ;res@cnFillOn = True                        ; turn on color fill
          res@lbOrientation = "vertical"              ; color bar orientation
          res@lbTitleString = "Speed [m s~S~-1~N~]"   ; color bar legend
          res@vfXArray = u&lon                        ; set coordinates locations along
                                                      ; x-axis
          res@vfYArray = u&lat                        ; set coordinates locations along
                                                      ; y-axis
          res@stLineThicknessF = 2.0                  ; set streamlines' thickness
          ;res@mpLandFillColor = "sienna"             ; set land's color
          ;res@mpOceanFillColor = "skyblue"           ; set ocean's color
          ;res@mpInlandWaterFillColor = "skyblue"     ; set inland water color
          res@mpDataBaseVersion = "HighRes"           ; set high coastline resolution
                                                      ; (RANGS database)
          res@stLevelPalette = "gui_default"          ; set color map
          res@gsnAddCyclic = False                    ; turn off longitude cyclic
                                                      ; point addition
          res@pmTickMarkDisplayMode = "Always"        ; ticks mod display
          res@pmLabelBarDisplayMode = "Always"        ; color bar's labels mod display
          ;res@pmLabelBarOrthogonalPosF = -0.02       ; set the coordinate of the base
                                                      ; location of the color bar
          ;res@pmLabelBarWidthF = 0.2                 ; set the width of the color bar
          res@lbPerimOn = False                       ; turn off line drawing around
                                                      ; color bar's perimeter
          res@mpLimitMode      = "LatLon"             ; specify how the extent of the
                                                      ; projected globe that is mapped
                                                      ; into the viewport area is
                                                      ; determined
          res@mpMinLatF        = min(u&lat)           ; minimum latitude got from u's
                                                      ; latitude values (coordinates)
          res@mpMaxLatF        = max(u&lat)           ; maximum latitude got from u's
                                                      ; latitude values (coordinates)
          res@mpMinLonF        = min(u&lon)           ; minimum longitude got from u's
                                                      ; longitude values (coordinates)
          res@mpMaxLonF        = max(u&lon)           ; maximum longitude got from u's
                                                      ; longitude values (coordinates)
          res@mpGridAndLimbOn  = False                ; turn off grid drawing

          resP = True                ; plot mods desired
          ;resP@gsnMaximize = True    ; make as large as possible
          resP@gsnPanelTop = 0.893   ; add extra space at top of panel
          resP@gsnFrame = False      ; turn off the automatic
                                     ; frame advance

          txres = True                  ; set text resources
          txres@txFontHeightF = 0.015   ; set text height

          ; Plot as many subplots as the number of specified depths

          do kl=0,dimsizes(zlev_u)-1

              ; Center string resources

              res@gsnCenterString = "~Z95~depth="+zlev_u(kl)+" m"

              ; Streamline plot over a map: speed

              plot_speed(kl) = gsn_csm_streamline_scalar_map(wks_speed,iso_u(kl,:,:),iso_v(kl,:,:),iso_speed(kl,:,:),res)

              ; Draw the name of some localities on the maps:

              text = gsn_add_text(wks_speed, plot_speed(kl), "Trieste", 13.8042, 45.6362, txres)
              text = gsn_add_text(wks_speed, plot_speed(kl), "Ancona", 13.5110, 43.5991, txres)
              text = gsn_add_text(wks_speed, plot_speed(kl), "Venezia", 12.3319, 45.4398, txres)
              ;text = gsn_add_text(wks_speed, plot_speed(kl), "Koper", 13.7312, 45.5483, txres)
              text = gsn_add_text(wks_speed, plot_speed(kl), "Zadar", 15.24222, 44.11972, txres)
              text = gsn_add_text(wks_speed, plot_speed(kl), "Rijeka", 14.457664, 45.328979, txres)
              text = gsn_add_text(wks_speed, plot_speed(kl), "Foce Po", 12.522222, 44.865, txres)
              ;text = gsn_add_text(wks_speed, plot_speed(kl), "Foce Isonzo", 13.556111, 45.7247222, txres)

          end do

          ; Draw multiple plots of identical size on a single frame: speed

          gsn_panel(wks_speed, plot_speed, (/2,1/), resP)

          ; Set text string resources to draw title and subtitles in panel's top
          ; added space

          txres = True                    ; set text resources
          txres@txJust = "BottomCenter"   ; set justification point of text item

          ; Title

          txres@txFontHeightF = 0.022                         ; set text height
          title = "Current Streamlines at Specified Depths"   ; set title
          gsn_text_ndc(wks_speed,title,0.5,0.95,txres)        ; draw title

          ; First subtitle

          txres@txFontHeightF = 0.012                            ; set text height
          subtitle1 = "Data source: Copernicus Marine Service"   ; set subtitle
          gsn_text_ndc(wks_speed,subtitle1,0.5,0.93,txres)       ; draw subtitle

          ; Second subtitle

          txres@txFontHeightF = 0.015                         ; set text height
          subtitle2 = date                                    ; set subtitle
          gsn_text_ndc(wks_speed,subtitle2,0.5,0.905,txres)   ; draw subtitle

          ; Advance the frame

          frame(wks_speed)

          ; Interpolated variables deletion

          delete(iso_u)
          delete(iso_v)
          delete(iso_speed)

    end do

end do

end

;***************
; END OF SCRIPT
;***************
