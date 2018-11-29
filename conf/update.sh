if grep --quiet vagrant /etc/passwd
then
    user="vagrant"
else
    user="ubuntu"
fi

echo "Check git updates"
#############################################
# Get OpenSAT and all the tools
cd /home/${user}/repos
(cd "OpenSAT"; git pull)
(cd "ib_diarization_toolkit" ; git pull)
(cd "dscore" ; git pull)
(cd "Yunitator" ; git pull)
(cd "vcm"; git pull)
(cd "To-Combo-SAD" ; git pull)
#############################################
