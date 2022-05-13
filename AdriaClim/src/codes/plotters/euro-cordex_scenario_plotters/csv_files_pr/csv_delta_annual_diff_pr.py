import numpy as np
import sys
import os

point_name    = sys.argv[1]
data_file     = sys.argv[2]
data_file_ref = sys.argv[3]
RCP           = sys.argv[4]
year_in       = sys.argv[5]
year_fin      = sys.argv[6]
field_name    = sys.argv[7]


file_var     = open( data_file     , 'r')
file_var_ref = open( data_file_ref , 'r')

Lines_proj  = file_var.readlines()
Lines_ref   = file_var_ref.readlines()

#=================================================================

bin_range     = []
count_proj    = []
count_ref     = []

tot_ref       = 0
tot_proj      = 0

count_diff    = []

#============ Data extraction reference (2010/2020) ===============
i=1

for line in Lines_ref:
	line          = line.rstrip()
	data_col_ref  = line.split(";")
	bin_range.append(  data_col_ref[0] )


for line in Lines_ref[:-1]:
	line          = line.rstrip()
	data_col_ref  = line.split(";")
	count_ref.append( int( data_col_ref[1] ))
	tot_ref  += int( data_col_ref[1] )
	i+=1

#============= Data extraction projection decade ===================
i=1
for line in Lines_proj[:-1]:
	line      = line.rstrip()
	data_col  = line.split(";")
	count_proj.append( int( data_col[1] ))
	tot_proj  += int( data_col[1] )
	i+=1

#====================== Difference values ==========================
for j in range( len(count_proj)):
        count_diff.append( count_proj[j]/tot_proj - count_ref[j]/tot_ref )

#======================= Linear system equation  ===================
# the number of equations are bin_number -1 and the variables too
# every bin can create an equation. Every bin front a variable. 
# Please consult documentation 

if (not os.path.exists('AdriaClim_GoT_allscenario_delta-relative-frequency_decade_pr.csv') ):
	with open( 'AdriaClim_GoT_allscenario_delta-relative-frequency_decade_pr.csv', 'w') as f_out:
		f_out.write("# Delta daily precipitation relative frequencies respect to 2010-2020 decade\n")
		f_out.write("# Point; Decade; RCP; bin-range [mm/day]; delta [1]\n")

with open( 'AdriaClim_GoT_allscenario_delta-relative-frequency_decade_pr.csv', 'a') as f_out:
	for i in range(len(count_diff)):
		f_out.write( point_name + ";" + year_in + "-" + \
                             year_fin + ";"+ RCP + ";" + str(bin_range[i]) + "-" + str(bin_range[i+1]) + ";" + '{:.4f}'.format( count_diff[i] )+"\n" )

f_out.close()
file_var.close()
file_var_ref.close()
