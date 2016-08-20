#!/sbin/sh
#Generate report for Oracle Backups for <company>
#Author: Emmanuel Giyoh Ngala
#Date: September 24, 2006
DUMP_BASE=/tmp
DUMP_FILE=$DUMP_BASE/report_`date +%d"_"%m"_"%y`.txt
REPORT_BASE=/tmp/oracle/report
mkdir -p $REPORT_BASE
/usr/openv/netbackup/bin/admincmd/bpdbjobs -report  -most_columns -mastertime -noheader -file $DUMP_FILE
HEADER="  POLICY,ELAPSED TIME,RATE(KB/s),SIZE(KB),SCHEDULE,CLIENT,START TIME,STATE,STATUS  "
echo $HEADER | awk -F, '{printf("%25s %14s %11s %10s %25s %13s %15s %7s %10s\n\n",$1,$2,$3,$4,$5,$6,$7,$8,$9)}' | tee $REPORT_BASE/report_`date +%d"_"%m"_"%y
`.txt | awk '{}'
state=" "
do_state()
{
 case "$1" in
    '0') state=" QUEUED "
          ;;
    '1') state=" ACTIVE "
          ;;
    '2') state=" WAITING "
          ;;
    '3') state=" DONE "
          ;;
      *)   state=" UNKNOWN "
 esac
return $state;
}
cat $DUMP_FILE | grep -i ora | grep -v nwg | awk -F, '{printf("%28s %4d:%2d:%2d %11d %12d %30s %9s %15d giyoh%s %3d \n",$5,$10/3600,($10/60)%60,$10%60,$35,$1
5,$6,$7,$9,$3,$4)}' | sort -k 1 | tee -a $REPORT_BASE/report_`date +%d"_"%m"_"%y`.txt | awk '{}'
DT=`date +%h" "%d", "%Y`
ADDR=" giyoh@programmer.net your-address@your-company.com "
cat $REPORT_BASE/report_`date +%d"_"%m"_"%y`.txt | sed -e 's/giyoh0/QUEUED/g' -e 's/giyoh1/ACTIVE/g' -e 's/giyoh2/WAITING/g' -e 's/giyoh3/DONE/g' | tee /tmp/
giyoh | awk '{}'
cp /tmp/giyoh $REPORT_BASE/report_`date +%d"_"%m"_"%y`.txt
rm /tmp/giyoh
cat $REPORT_BASE/report_`date +%d"_"%m"_"%y`.txt | uuencode $REPORT_BASE/report_`date +%d"_"%m"_"%y`.txt report_`date +%d"_"%m"_"%y`.txt | mailx -c giyoh@programmer.net -r emmanung@localhost  -s "ATTACHED Oracle NBU1 Report of $DT "  $ADDR
cat $REPORT_BASE/report_`date +%d"_"%m"_"%y`.txt | mailx -c giyoh@programmer.net -r emmanung@localhost  -s "Oracle NBU1 Report of $DT " $ADDR

# $ADDR
#sed -e 's/0/QUEUED/g' -e 's/1/ACTIVE/g' -e 's/2/WAITING/g' -e 's/3/DONE/g'
#/usr/openv/netbackup/bin/admincmd/bpdbjobs -summary -U -file /home/emmanung/testNBU
#/usr/openv/netbackup/bin/admincmd/bpdbjobs -summary -L -append -file /home/emmanung/testNBU
 
 
