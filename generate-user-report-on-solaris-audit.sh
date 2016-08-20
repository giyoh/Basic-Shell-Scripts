#/bin/sh
Mon=`date | awk '{print $2}' | cut -c1-3`
echo $Mon
gdate=`date | sed -e 's/ /_/g'`
praudit /var/share/audit/`ls -tr /var/share/audit | tail -1` > /tmp/record
cat /tmp/record | sed -e 's/header.*,//g' -e 's/exec_args,.,//g' -e 's/path.*/empty/g' -e 's/attribute.*/empty/g' -e 's/.*LOGNAME=//g' -e 's/,SSH_CONNECTION.*/!/g' > /tmp/r1
cat /tmp/r1 | sed -e 's/return.*//g' -e 's/subject.*//g' -e 's/CLASSPATH.*//g' -e 's/MAIL.*//g' > /tmp/record2
cat /tmp/record2 | grep -v empty | sed -e 's/,/ /g' -e 's/!.*//g' -e 's/LC_CTYPE.*//g' -e 's/PATH.*//g' > /tmp/record3
rm /tmp/r1
rm /tmp/record
rm /tmp/record2
zip /tmp/user_command_summary_`uname -n`.zip /tmp/record3
uuencode /tmp/user_command_summary_`uname -n`.zip /tmp/Review_Users_Activities_on_Solaris_`uname -n`_$gdate.zip | mailx -s "Review Users Activities on Solaris" -c giyoh@programmer.net,your-email@your-company.com
rm /tmp/user_command_summary_`uname -n`.zip
