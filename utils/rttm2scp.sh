#sample rttm file 
#SPEAKER NDAR_TC217KM7 1 0.01 0.12 <NA> <NA> spk7 <NA>
# structure is blah filename blah onset dur blah blah speakerid blah
#
#sample scp file:
#BER_0713_07_02_21041_-1_60=BER_0713_07_02_21041.scp[-1,60]
#structure of scp file is:
#filename_begining_end=features[begining,end]

rttm_in=$1
basename=$2
featfile=$3
scp_out=$4


grep SPEAKER $rttm_in | awk -v base="$basename" -v feats="$featfile" '{begg=$4*100;endd=($4+$5)*100; print base "_" begg "_" endd "="feats "[" begg "," endd "]"}' > $scp_out

