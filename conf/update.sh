if grep --quiet vagrant /etc/passwd
then
    user="vagrant"
else
    user="ubuntu"
fi

echo "Check git updates"
#############################################
# Get OpenSAT and all the tools
# change version tag as necessary for each tools
cd /home/${user}/repos
(cd "OpenSAT"; git checkout master; git pull)
# (cd "OpenSAT"; git checkout master; git pull; git checkout v2.0)
(cd "ib_diarization_toolkit"; git checkout master; git pull)
# (cd "ib_diarization_toolkit" ; git checkout master; git pull; git checkout v2.0)
(cd "Yunitator" ;git checkout master;  git pull)
# (cd "Yunitator" ; git checkout master; git pull; git checkout v2.0)
(cd "vcm"; git checkout master; git pull)
# (cd "vcm"; git checkout master; git pull; git checkout v2.0)
(cd "To-Combo-SAD" ; git checkout master; git pull)
# (cd "To-Combo-SAD" ; git checkout master; git pull; git checkout v2.0)
(cd "WCE_VM" ; git checkout master; git pull)
# (cd "WCE_VM" ; git checkout master; git pull; git checkout v2.0)

#############################################
