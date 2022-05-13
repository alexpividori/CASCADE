import numpy as np
import sys

point_name    = sys.argv[1]
data_file     = sys.argv[2]
data_file_ref = sys.argv[3]
RCP           = sys.argv[4]
year_in       = sys.argv[5]
year_fin      = sys.argv[6]
month         = sys.argv[7]
field_name    = sys.argv[8]

output_arc_dir="/lustre/arpa/AdriaClim/src/codes/plotters/euro-cordex_scenario_plotters/delta_histograms"

file_var     = open( data_file     , 'r')
file_var_ref = open( data_file_ref , 'r')

Lines_proj  = file_var.readlines()
Lines_ref   = file_var_ref.readlines()

#=================================================================

bin_range     = []
bin_split     = []
count_proj    = []
count_ref     = []

tot_ref       = 0
tot_proj      = 0

count_diff    = []
delta_shift   = []

#============ Data extraction reference (2010/2020) ===============
bin_number = 10
i=1
for line in Lines_ref:
	line          = line.rstrip()
	data_col_ref  = line.split(";")
	if ( i <= ( bin_number + 1 ) ):                          # the number of bins is decided previously 
		bin_range.append( int( data_col_ref[0] ))
	if ( i <= ( bin_number  ) ):
		count_ref.append( int( data_col_ref[1] ))
		tot_ref  += int( data_col_ref[1] )
	i+=1

#============= Data extraction projection decade ===================
i=1
for line in Lines_proj:
	line      = line.rstrip()
	data_col  = line.split(";")
	if ( i <= ( bin_number  ) ): 
		count_proj.append( int( data_col[1] ))
		tot_proj  += int( data_col[1] )
	i+=1

#====================== Difference values ==========================
for j in range( len(count_proj)):
        count_diff.append( count_proj[j] - count_ref[j] )

#=================== Bin Split =====================
for j in range( len(bin_range) - 1 ):
	bin_split.append(  bin_range[j] )
	bin_split.append( (bin_range[j] + bin_range[j+1]) / 2 )

bin_split.append( bin_range[ len(bin_range) - 1 ] )

#===================================================
def delta_bin( T_ref, bin_inf, bin_sup, delta_num ):
	if ( T_ref == 0 ):
		return 0.
	else:
		return round(( -delta_num * (bin_sup - bin_inf)) / T_ref, 2)

#======================= Linear system equation  ===================
# the number of equations are bin_number -1 and the variables too
# every bin can create an equation. Every bin front a variable. 
# Please consult documentation 

x_system = np.array([ [1,0,0,0,0,0,0,0,0], [-1,1,0,0,0,0,0,0,0], [0,-1,1,0,0,0,0,0,0], [0,0,-1,1,0,0,0,0,0], [0,0,0,-1,1,0,0,0,0], \
                     [0,0,0,0,-1,1,0,0,0], [0,0,0,0,0,-1,1,0,0], [0,0,0,0,0,0,-1,1,0], [0,0,0,0,0,0,0,-1,1] ])

known_term = np.array( count_diff[:-1] )         # known terms of the linear equation system 

sol = np.linalg.solve(x_system, known_term)

delta_shift.append(0.)     # first semi-bin shift is kept equal to 0
for i in range( 0, len(sol) ):
	if ( sol[i] >= 0 ):
		delta_shift.append(0.)
		delta_shift.append( delta_bin( count_ref[i+1], bin_range[i+1], bin_range[i+2], sol[i] ))
	else:
		delta_shift.append( delta_bin( count_ref[i],   bin_range[i],   bin_range[i+1], sol[i] ))
		delta_shift.append(0.)
delta_shift.append(0.)     # last semi-bin shift is kept equal to 0

if ( int(month) == 1 ):
	with open( "pr_delta_"+point_name+"_rcp"+RCP+"_"+year_in+"_"+year_fin+'.csv', 'w') as f_out:
		f_out.write("# Delta daily precipitation respect to 2010-2020 decade\n")
		f_out.write("# RCP= "+RCP+"\n")
		f_out.write("# Decade= "+year_in+"-"+year_fin+"\n")
		f_out.write("# month; bin-range [mm/day]; delta [mm/day]\n")

with open( "pr_delta_"+point_name+"_rcp"+RCP+"_"+year_in+"_"+year_fin+'.csv', 'a') as f_out:
	for i in range(len(delta_shift)):
		f_out.write( format(int(month),'02') + ";" + str(bin_split[i]) + "-" + str(bin_split[i+1]) + ";" + str(delta_shift[i])+"\n" )

f_out.close()
file_var.close()
file_var_ref.close()
