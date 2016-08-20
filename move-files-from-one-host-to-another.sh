# Below are the scripts.
# Do not automate the script on the destination server.
# The source script will activate it.
# Configure ssh not to prompt for passwords as this will not work if the ssh configuration is not done.
 
# You must do the following on the source server before running this script.
 
# 1. write the full path to the directory to be transfered across in the file /tmp/source_directories_to_transfer
# 2. write the full path to the directory to which files will be transfered to on the destination server, in the file /tmp/destination_directory
# 3. write the IP address of the destination server in the file /tmp/destination_host
 
# Note that in the above directories there should be only one entry per file.
 
# Please let me know if you have any challenges.
 
# Best wishes,
 
 
# SOURCE SERVER
 
# ==================================
#!/bin/sh
i=`cat /tmp/source_directories_to_transfer`
echo `date` >> /tmp/transfer_logs
echo  "" >>  /tmp/transfer_logs
echo " File and directories in $i will be moved as listed below " >>  /tmp/transfer_logs
echo `ls -ltr $i ` >>  /tmp/transfer_logs
cd $i
/usr/bin/tar -cf MOVE_AND_DELETE.tar ./*
/usr/bin/gzip MOVE_AND_DELETE.tar
DH=`cat /tmp/destination_host`
DD=`cat /tmp/destination_directory`
scp MOVE_AND_DELETE.tar.gz  $DH:$DD
echo "DD,$DD" > /tmp/GIYOH
scp /tmp/GIYOH $DH:/tmp/GIYOH
rm MOVE_AND_DELETE.tar.gz  
ssh $DH $ORACLE_HOME/gextractor.sh
# ==================================
 
 
 
# DESTINATION SERVER
#  $ORACLE_HOME/gextractor.sh
# =============================
#!/bin/sh
DD=`cat /tmp/GIYOH | cut -d, -f2`
rm /tmp/GIYOH
cd $DD
/usr/bin/gunzip MOVE_AND_DELETE.tar.gz
/usr/bin/tar -xf MOVE_AND_DELETE.tar
rm MOVE_AND_DELETE.tar
=============================
 
