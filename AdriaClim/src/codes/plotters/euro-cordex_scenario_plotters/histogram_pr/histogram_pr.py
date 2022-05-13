import matplotlib.pyplot as plt
import numpy as np
import datetime
import bottleneck  
import sys

point_name = sys.argv[1]
data_file = sys.argv[2]
RCP = sys.argv[3]
year_in = sys.argv[4]
year_fin = sys.argv[5]
field_name = sys.argv[6]

output_arc_dir="/lustre/arpa/AdriaClim/public_html/EURO_CORDEX_analysis/SCENARIO/histogram_pr_py"

file_var = open( data_file , 'r')
Lines = file_var.readlines()

data_hist = []
data_hist_rel = []
data_bin_pos = []
data_bin  = []
label_bin = []
tot = 0

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

#================================ Plot ==============================

fig , ax = plt.subplots(figsize=(20,15))

plt.title("Histogram daily precipitation distribution (rcp"+RCP+") from "+year_in+" to "+year_fin+" at point: "+point_name+"\n" , fontsize=30, fontdict={'family':'serif'} )
plt.xlabel( x_axis_label , fontsize=25 )
plt.ylabel( "Relative frequency", fontsize=25)
plt.xticks( label_bin , data_bin  , fontsize=18 )
plt.yticks(fontsize=18 )
plt.axis([ 0 , 5*len(data_bin_pos) , 0 , 1.0 ])
plt.grid( linestyle='--')
ax.bar( data_bin_pos , data_hist_rel , width=5 , alpha=0.40, color='r' )


plt.savefig( output_arc_dir+"/"+point_name+"/histogram_"+field_name+"_"+point_name+"_rcp"+RCP+"_"+year_in+"_"+year_fin+".png" )

plt.close(fig)
