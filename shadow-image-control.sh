#! /bin/ksh
########################################################
# Purpose: To control ShadowImage actions
# Uses   : /etc/horcm.conf
########################################################
# Command line options
#---------------------
USAGE="Usage: $0 < -g group > < -o | -i >\nwhere:\ngroup is {ORACCB_DEV | ORAIFS_DEV | ORAPPMS_DEV}\n-o : ora prep\n-i : info
 (status)\nLast action specified will be executed"

while getopts oig: choice
do
     case $choice in
        o )   ACTION="ORAPREP"
              ACTION_MSG="preparation for Oracle startup"
              MACHINE=""
              DSTATE='PSUS|SMPL'
              UDSTATE='PAIR|COPY|RCPY|PSUE|PFUS|PDUB'
              ;;

        i )   ACTION="INFO"
              ACTION_MSG="pair info / status"
              MACHINE=""
              DSTATE=""
              UDSTATE=""
              ;;

        g)       GARG=$OPTARG;;

        \?)      echo $USAGE
        
                 exit 1;;
     esac
done

 

 

# Which mirror group?
#--------------------

case $GARG in

   ORACCB_DEV ) if [ "$ACTION" = "ORAPREP" ]
                  then
                        MACHINE='ekiti'
                        DISKGROUP='oraccb_dg'
                  fi
                  ;;

   ORAIFS_DEV )  if [ "$ACTION" = "ORAPREP" ]
                  then
                        MACHINE='ekiti'
                        DISKGROUP='oraifs_dg'
                  fi
                  ;;

   ORAPPMS_DEV ) if [ "$ACTION" = "ORAPREP" ]
                  then
                        MACHINE='ekiti'
                        DISKGROUP='orappms_dg'
                  fi
                  ;;                                                    ## CHANGE GROUPS HERE
   "" ) echo "ERROR: no group specified"
        echo $USAGE
        exit 1
        ;;

   * ) echo "ERROR: invalid group \"$GARG\" specified"
       exit 1
       ;;
esac


 

if [ "$ACTION" = "" ]
then
        echo "ERROR: no action specified"
        echo $USAGE
        exit 1
fi


# Check for root
#-----------

 

id | grep "^uid=0(root)" >/dev/null 2>&1
if [ $? -ne 0 ]; then
        echo "ERROR: only root can run this utility"
        exit 1
fi


# Check whether daemon is running
#--------------------------------

ps -ef | grep horcmd | grep -v grep >/dev/null 2>&1
if [ $? -ne 0 ]; then
        echo "ERROR: horcm daemon not running"
        echo "please restart with command: /etc/init.d/horcm start"
        exit 1
fi

 
###########
# FUNCTIONS
###########

# Correct machine?
#-----------------

CorrectMachine() {
        if [ "$1" = "" ]
        then
                return 0
        fi

        if [ `uname -n` != "$1" ]; then
                echo "ERROR: must be run on $1"
                exit 2
        fi
}


# Undesired state of pair
#------------------------

UndesiredState() {
        if [ "$1" = "" ]
        then
                return 0
        fi

        pairdisplay -g $GARG -fxc | /usr/xpg4/bin/grep -E $1 >/dev/null 2>&1
        if [ $? -eq 0 ]; then
                echo "ERROR: illegal current status ($UDSTATE)"
                echo "ERROR: pair status should be  ($DSTATE)"
                exit 1
        fi
}

 
# Desired state of pair
#----------------------

DesiredState() {
        if [ "$1" = "" ]
        then
                return 0
        fi
        pairdisplay -g $GARG -fxc | /usr/xpg4/bin/grep -E $1 >/dev/null 2>&1
        if [ $? -ne 0 ]; then
                echo "ERROR: pair status should be ($DSTATE)"
                exit 1
        fi
}

 

 

# Prepare for Oracle action
#--------------------------

OraPrep() {
        echo
        # Import the oradat_dg disk group
        vxdg -fC import $DISKGROUP
        if [ $? -ne 0 ]; then
                echo "import of disk group $DISKGROUP unsuccessful"
                exit 1
        fi
        echo "$DISKGROUP imported"

        # Start oradat_dg volumes
        vxvol -g $DISKGROUP startall
        if [ $? -ne 0 ]; then
                echo "start of volumes unsuccessful"
                exit 1
        fi
        echo "volumes started"

        # Check and mount the filesystems
        if [ ! -f /HORCM/mtn/${DISKGROUP}.fs ]
        then
                echo "ERROR: /HORCM/mtn/${DISKGROUP}.fs does not exist"
                exit 2
        fi
        for i in `cat /HORCM/mtn/${DISKGROUP}.fs`
        do
                echo "checking $i: \c"
                fsck $i >/dev/null 2>&1 || { echo "filesystem check failed"; exit; }
                echo "ok"
                echo "mounting $i: \c"
                mount $i || { echo "filesystem mount failed"; exit; }
                echo "ok"
        done
        cat <<!

 ********************************
*
* Please verify the status of
*
*  1. Disk group $DISKGROUP
*  2. Filesystems
*
* manually before proceeding with Oracle start
*
********************************
!
}

############################################################################
# MAIN # MAIN # MAIN # MAIN # MAIN # MAIN # MAIN # MAIN # MAIN # MAIN # MAIN
############################################################################

# Run prereq checks
#------------------

CorrectMachine $MACHINE
UndesiredState $UDSTATE
DesiredState $DSTATE

# Last chance
#------------

echo "Machine : ${MACHINE:=`uname -n`}"
echo "Group   : $GARG"
echo "Action  : $ACTION"

 
echo "Do you want to continue with the $ACTION_MSG (y/n)? : \c"
read enterkey
if [ "$enterkey" != "y" ]; then
        echo "$ACTION_MSG cancelled on user request"
        exit 3
fi
 

# And go for it
#--------------

case $ACTION in
        INITIAL_COPY)
                paircreate -g $GARG -vl -c 15 || echo "$ACTION_MSG ($ACTION) failed"
                ;;

        SPLIT_C)
                pairsplit -g $GARG -C 15 || echo "$ACTION_MSG ($ACTION) failed"
                ;;

        SPLIT_S)
                pairsplit -g $GARG -S || echo "$ACTION_MSG ($ACTION) failed"
                ;;

        RESYNC)
                pairresync -g $GARG -c 15 || echo "$ACTION_MSG ($ACTION) failed"
                ;;

        ORAPREP)
                OraPrep
                ;;

        INFO)
                pairdisplay -g $GARG -fxc | more
                ;;
        *)
                echo "ERROR: internal error, call SunPS"
                exit 5
                ;;
esac

echo "$ACTION_MSG ($ACTION) performed successfully"
