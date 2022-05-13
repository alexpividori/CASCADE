;----------------------------------------------------------------------
; write_asc_1.ncl
;
; Concepts illustrated:
;   - Writing an array of data to an ASCII file using asciiwrite
;----------------------------------------------------------------------
;
; This script read a netCDF file and write the date and hours of time steps 
; of thet file: 1 is the type is set to "s" and everyone if_ it is set to "r".
; In this case the delta_time value is ignored. To lanch this script you have to 
; declare the type and delta_time values by the syntax:
; " ncl 'type="r"' 'delta_time=2' read_time.ncl "  (for example).
; In this last version the file_name indicated by file_cur_n is passed by the bash 
; script that contains the main stream. 
;----------------------------------------------------------------------

begin

  f     = addfile(file_cur_n , "r")
  time  = f->time
  depth = f->depth 
    
  t_1= cd_calendar(time,-5)

    depth_value = depth(lev - 1) 

    ; Date formatting

    year1    = t_1(:,0)                         ; year extraction
    month1   = sprinti("%0.2i", t_1(:,1))       ; month extraction
    day1     = sprinti("%0.2i", t_1(:,2))       ; day extraction
    hour1    = sprinti("%0.2i", t_1(:,3))
    minute1  = sprinti("%0.2i", t_1(:,4))


    date1      = day1+"/"+month1+"/"+year1        ; to be used in plot's subtitles
    date_plot1 = year1+"-"+month1+"-"+day1   ; to be used to rename output immages
    date_time = date_plot1+";"+hour1+";"+minute1+";"+depth_value 

if ( ( type .ne.  "s") .and.  ( type .ne. "r" ) ) then
 print ("Error: plot type not allowed")
 print(type)
end if 

if ( type .eq. "s") then
   asciiwrite("date_time.txt", date_time(delta_time - 1) )
else
   asciiwrite("date_time.txt", date_time)         
end if


end
