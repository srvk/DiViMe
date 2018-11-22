#sample rttm file 
#SPEAKER NDAR_TC217KM7 1 0.01 0.12 <NA> <NA> spk7 <NA>
# structure is blah filename blah onset dur blah blah speakerid blah
#times are in seconds

#sample min file
#0 6031 S0
#structure is onset offset speakerid
#numbers are in seconds

#takes as input a folder that contains txts
#and will receive the rttm files
#eg ./min2rttm.sh  /pylon2/ci560op/acrsta/data/starterACLEW/

folder=$1

for j in $folder/*.lab
do
#echo $j
#echo "$folder/${subf}_ref.rttm"
    subf=`basename ${j} | sed "s/.lab//"`
    type=${subf: -5}

    if [ $type != "_lena" ] 
    then 
      type="" 
    fi
    subf=`echo $subf | sed "s/_lena//"`
    grep ' speech' $j | awk '{print "SPEAKER" " " "'$subf'" " " 1  " " $1  " " $2-$1 " " "<NA>" " " "<NA>"  " " $3  " "  "<NA>"}'   > $folder/${subf}${type}.rttm
done
