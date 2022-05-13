import matplotlib.pyplot as plt
import numpy as np
import math
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
y_axis_val1       = []
y_axis_label1     = []

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

# non linear function: nth root    

# y axis label and position


def not_linear(a):
	if a >= 0:
		y_val =  ( abs(a) / max(map(abs, data_diff_rel)) )**(1/3)
	else:
		y_val = -( abs(a) / max(map(abs, data_diff_rel)) )**(1/3) 
	return y_val


for j in range( len(data_diff_rel) ):   # number of y labels
	data_diff_rel_not_linear.append( not_linear( data_diff_rel[j] )  )

y_max = max( map(abs, data_diff_rel))
y_min = -y_max
n_lab = 15
for j in range( n_lab + 1 ):      # 10 is the number of label we want
	y_val = y_min + (j/n_lab)*(y_max - y_min) 
	y_axis_val.append( not_linear(y_val) )
	y_axis_label.append( float("{:.3f}".format( y_val )) )

for j in range( len(data_diff_rel) ):
	y_axis_val1.append( not_linear(data_diff_rel[j]) )
	y_axis_label1.append( str( float("{:.5f}".format( data_diff_rel[j] ))) )

#================================ Plot ==============================

fig , ax = plt.subplots(figsize=(20,15))

plt.title("Differences for daily precipitation distribution (rcp"+RCP+") from "+year_in+" to "+year_fin+"\n respect 2010/2020 decade at point: "+point_name+"\n" , fontsize=28, fontdict={'family':'serif'} )
plt.xlabel( x_axis_label , fontsize=25 )
plt.hlines( 0.0 , -1. , 5*len(data_bin_pos)+1. , linestyle="--" )
plt.ylabel( "Delta Relative frequency ($f_{"+year_in+"/"+year_fin+"}-f_{2010/2020}$)", fontsize=25)
plt.xticks( label_bin , data_bin  , fontsize=18 )
plt.yticks( y_axis_val, y_axis_label , fontsize=15 )
plt.axis([ 0 , 5*len(data_bin_pos) ,  -1.04 , +1.04 ])
plt.grid( linestyle='--')
plt.text( data_bin_pos[0]  , data_diff_rel_not_linear[0]  , y_axis_label1[0]  , fontsize=16 , ha="center")
plt.text( data_bin_pos[1]  , data_diff_rel_not_linear[1]  , y_axis_label1[1]  , fontsize=16 , ha="center")
plt.text( data_bin_pos[2]  , data_diff_rel_not_linear[2]  , y_axis_label1[2]  , fontsize=16 , ha="center")
plt.text( data_bin_pos[3]  , data_diff_rel_not_linear[3]  , y_axis_label1[3]  , fontsize=16 , ha="center")
plt.text( data_bin_pos[4]  , data_diff_rel_not_linear[4]  , y_axis_label1[4]  , fontsize=16 , ha="center")
plt.text( data_bin_pos[5]  , data_diff_rel_not_linear[5]  , y_axis_label1[5]  , fontsize=16 , ha="center")
plt.text( data_bin_pos[6]  , data_diff_rel_not_linear[6]  , y_axis_label1[6]  , fontsize=16 , ha="center")
plt.text( data_bin_pos[7]  , data_diff_rel_not_linear[7]  , y_axis_label1[7]  , fontsize=16 , ha="center")
plt.text( data_bin_pos[8]  , data_diff_rel_not_linear[8]  , y_axis_label1[8]  , fontsize=16 , ha="center")
plt.text( data_bin_pos[9]  , data_diff_rel_not_linear[9]  , y_axis_label1[9]  , fontsize=16 , ha="center")
plt.text( data_bin_pos[10] , data_diff_rel_not_linear[10] , y_axis_label1[10] , fontsize=16 , ha="center")
plt.text( data_bin_pos[11] , data_diff_rel_not_linear[11] , y_axis_label1[11] , fontsize=16 , ha="center")


ax.bar( data_bin_pos , data_diff_rel_not_linear , width=5 , alpha=0.40, color='r' )


plt.savefig( output_arc_dir+"/"+point_name+"/histogram_diff_"+field_name+"_"+point_name+"_rcp"+RCP+"_"+year_in+"_"+year_fin+".png" )

plt.close(fig)
file_var.close()
file_var_ref.close()
