######################################################################################
#!/sbin/sh
#
# Script to relabel available media in mentioned pools.
#

rm -rf /tmp/tempfile01
rm -rf /tmp/tempfile02
rm -rf /tmp/tempfile03
#
# Run available_media
#
#/usr/openv/netbackup/bin/goodies/available_media | egrep 'pool|AVAILABLE' | awk '{print $1":"$2}' | tee -a /tmp/tempfile01
# Uncomment the line above for the actual 'available_media' command.
# The line below is used for simulation from a sample output in a file named sample.txt. Comment it out in a production environment.
#

cat /sample.txt | egrep 'pool|AVAILABLE' | awk '{print $1":"$2}' | tee -a /tmp/tempfile01

#
# Identifying pools and media from the available_media output
#

for i in `cat /tmp/tempfile01`
  do
    if [ -z "`echo $i | grep pool`" ]
      then
        echo "mediaName:`echo $i | cut -d: -f1`" | tee -a /tmp/tempfile02
      else
        echo "poolName:`echo $i | cut -d: -f1`" | tee -a /tmp/tempfile02
    fi
done

#rm -rf /tmp/tempfile01
POOL="null"
MEDIA="null"

#
# Sorting the output according pools and corresponding media.
#

for j in `cat /tmp/tempfile02`
  do
    if [ -z "`echo $j | grep mediaName`" ]
      then
        POOL=`echo $j | cut -d: -f2`
      else
        MEDIA=`echo $j | cut -d: -f2`
        echo "POOL:$POOL\tMEDIA:$MEDIA" | tee -a /tmp/tempfile03
    fi
done

#rm -rf /tmp/tempfile02

#
# Relabeling the media. The pools of interest MUST be written in the file /RELABEL_POOLS.
# One pool per line and remember it is case sensitive.
#
for k in `cat /RELABEL_POOLS`
  do
    for x in `cat /tmp/tempfile03 | grep $k | awk '{print $2}' | cut -d: -f2`
      do
        DENSITY=`grep $x /tmp/tempfile01 | cut -d: -f2`
        echo "/usr/openv/netbackup/bin/admincmd/bplabel -m $x -d $DENSITY -o -p $k  "
    done
done

# rm -rf /tmp/tempfile03
