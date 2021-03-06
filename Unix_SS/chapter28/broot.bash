#!/bin/bash
#
# SCRIPT: broot.bash
#
# AUTHOR: Randy Michael
# DATE: 05/08/2007
# REV: 1.0.P
# PLATFORM: Any Unix
#
# PURPOSE: This shell script is used to monitor a login session by
#          capturing all of the terminal data in a log file using
#          the script command. This shell script name should be
#          the last entry in the user.s $HOME/.profile. The log file
#          is both kept locally and emailed to a log file
#          administrative user either locally or on a remote machine.
#
# REV LIST:
#
#
# set -n # Uncomment to check syntax without any execution
# set -x # Uncomment to debug this shell script
#
############# DEFINE AUDIT LOG MANAGER ###################
#
# This user receives all of the audit logs by email. This
# Log Manager can have a local or remote email address. You
# can add more than one email address if you want by separating
# each address with a space.

LOG_MANAGER="logman" # List to email audit log

##########################################################
################ DEFINE FUNCTIONS HERE ###################
##########################################################

cleanup_exit ()
{
# This function is executed on any type of exit except of course
# a kill -9, which cannot be trapped. The script log file is
# emailed either locally or remotely, and the log file is
# compressed. The last "exit" is needed so the user does not
# have the ability to get to the command line without logging.

if [[ -s ${LOGDIR}/${LOGFILE} ]]
then
     mailx -s "$TS - $LOGNAME Audit Report" $LOG_MANAGER \
            < ${LOGDIR}/${LOGFILE}
     compress ${LOGDIR}/${LOGFILE} 2>/dev/null
fi
exit
}

# Set a trap

trap 'cleanup_exit' 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 26

##########################################################
################ DEFINE VARIABLES HERE ###################
##########################################################

TS=$(date +%m%d%y%H%M%S)           # File time stamp
THISHOST=$(hostname|cut -f1-2 -d.) # Host name of this machine
LOGDIR=/usr/local/logs/script      # Directory to hold the logs
LOGFILE=${THISHOST}.${LOGNAME}.$TS # Creates the name of the log file
touch $LOGDIR/$LOGFILE             # Creates the actual file
TMOUT=300                          # Set the root shell timeout!!!
export TMOUT                       # Export the TMOUT variable

# Run root's .profile if one exists

if [[ -f $HOME/.profile ]]
then
     . $HOME/.profile
fi

# set path to include /usr/local/bin
echo $PATH | grep -q ':/usr/local/bin' || PATH=$PATH:/usr/local/bin

# Set the command prompt to override the /.profile default prompt

PS1="$THISHOST:broot> "
export PS1

#################### RUN IT HERE ##########################

chmod 600 ${LOGDIR}/${LOGFILE} # Change permission to RW for the owner

script ${LOGDIR}/${LOGFILE} # Start the script monitoring session

chmod 400 ${LOGDIR}/${LOGFILE} # Set permission to read-only 
                               # for the owner

cleanup_exit # Execute the cleanup and exit function

