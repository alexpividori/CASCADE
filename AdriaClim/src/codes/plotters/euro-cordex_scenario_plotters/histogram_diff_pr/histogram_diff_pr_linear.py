import matplotlib.pyplot as plt
import numpy as np
import datetime
import bottleneck  
import sys

point_name    = sys.argv[1]
data_file     = sys.argv[2]
data_file_ref = sys.argv[3]
RCP           = sys.argv[4]
year_in       = sys.argv[5]
year_fin      = sys.argv[6]
field_name    = sys.argv[7]

output_arc_dir="/lustre/arpa/AdriaClim/public_html/EURO_CORDEX_analysis/SCENARIO/histogram_pr_py"

file_var     = open( data_file     , 'r')
file_var_ref = open( data_file_ref , 'r')

Lines     = file_var.readlines()
Lines_ref = file_var_ref.readlines()

data_hist         = []
data_hist_rel     = []
data_bin_pos      = []
data_bin          = []
label_bin         = []
tot               = 0

data_hist_ref     = []
data_hist_rel_ref = []
tot_ref           = 0

data_diff_rel     = []

#====== Not linear axis ======

data_diff_rel_not_linear = [] # 
y_axis_val        = []
y_axis_label      = []

#============ Data extraction reference (2010/2020) ===============

i=1
for line in Lines_ref:
        line          = line.rstrip()
        data_col_ref  = line.split(";")
        if ( i < len( Lines_ref )):
                data_hist_ref.append( int( data_col_ref[1] ))
                tot_ref  += int( data_col_ref[1] )
                i+=1

for j in range( len(data_hist_ref) ):
        data_hist_rel_ref.append( data_hist_ref[j]/tot_ref )

#=================== Data extraction decade ========================

i=1
for line in Lines:
	line      = line.rstrip()
	data_col  = line.split(";")
	data_bin.append( int(data_col[0]) )
	if ( i < len( Lines )): 
		data_hist.append( int( data_col[1] ))
		tot       += int( data_col[1] )
		i+=1

for j in range( len(data_hist) ):
	data_hist_rel.append( data_hist[j]/tot )
	data_bin_pos.append( (5.0*j)+2.5 )
	label_bin.append( 5.0*j )

label_bin.append( 5.0*(j+1) )

if ( field_name == "pr" ):
        x_axis_label = "Precipitation [$mm/day$]"

#====================== Difference values ==========================

for j in range( len(data_hist) ):
        data_diff_rel.append( data_hist_rel[j] - data_hist_rel_ref[j] )

#======================= Not linear axis creation ========================

# non linear function: y_max - exp(-a*( y_max/y ))      # where 'a' is a parameter

# y axis label and position

y_max = 0.03
y_min = -y_max

for j in range(10):   # number of y labels
	

#================================ Plot ==============================

fig , ax = plt.subplots(figsize=(20,15))

plt.title("Differences for daily precipitation distribution (rcp"+RCP+") from "+year_in+" to "+year_fin+"\n respect 2010/2020 decade at point: "+point_name+"\n" , fontsize=28, fontdict={'family':'serif'} )
plt.xlabel( x_axis_label , fontsize=25 )
plt.ylabel( "Delta Relative frequency", fontsize=25)
plt.xticks( label_bin , data_bin  , fontsize=18 )
plt.yticks(fontsize=18 )
plt.axis([ 0 , 5*len(data_bin_pos) , y_min , y_max ])
plt.grid( linestyle='--')
ax.bar( data_bin_pos , data_diff_rel , width=5 , alpha=0.40, color='r' )


plt.savefig( output_arc_dir+"/"+point_name+"/histogram_diff_"+field_name+"_"+point_name+"_rcp"+RCP+"_"+year_in+"_"+year_fin+".png" )

plt.close(fig)
file_var.close()
file_var_ref.close()
