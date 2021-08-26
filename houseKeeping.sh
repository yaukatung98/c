#!/bin/bash

# Color Output for CMD

YELLOW=$'\e[1;33m' # Yellow Color

RED=$'\e[0;31m' # Red Color

NC=$'\e[0m' # No Color

# Basic Vars for Script and Logging

TIMESTAMP=$(date +"%Y%m%d")

BACKUP_BareOS=/home/ynutty/bareos/

BACKUP_Local=/home/ynutty/bareos-bak/

RETENTION="0"

BACKUP_LOG=/home/ynutty/${TIMESTAMP}_backup.log

# Logging Header

echo " \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/ " >> $BACKUP_LOG

echo " ----- ----- ----- " >> $BACKUP_LOG

echo "Date: $(date)" >> $BACKUP_LOG

echo "Hostname: $(hostname)" >> $BACKUP_LOG

echo "Backup script has run. " >> $BACKUP_LOG

echo " ----- ----- ----- " >> $BACKUP_LOG

# cleaner usage function

usage()

{

cat << EOF

cleaner.sh 

This script cleans directories.  It is useful for backup 

and log file directories, when you want to transport/delete older files. 

USAGE:  cleaner.sh [options]

OPTIONS:

   -h      Show this message

   -q      This script defaults to verbose, use -q to turn off messages 

           (Useful when using the cleaner.sh in automated scripts).

   -s      A search string to limit file deletion, defaults to '*' (All files).

   -m      The minimum number of files required in the directory (Files 

           to be maintained), defaults to 5.

   -d      The directory to clean, defaults to the current directory.

   

EXAMPLES: 

   In the current directory, transport/delete everything but the 5 most recently touched 

   files: 

     cleaner.sh

         Same as:

     cleaner.sh -s * -m 5 -d .

   In the /home/myUser directory, transport/delete all files including text "test", except 

   the most recent:

     cleaner.sh -s test -m 1 -d /home/myUser

         Don't ask for any confirmation:

     cleaner.sh -s test -m 1 -d /home/myUser -q              

EOF

}

# Set default values for VARS

SEARCH_STRING='keyword'

MIN_FILES='0'

QUIET=0

REMOVED=0

DELETED=0

# cleaner transport files function

transport()

{

FILES_TRANSPORT=`ls -1p *"$SEARCH_STRING" 2>/dev/null | grep -vc "/$"`

while [ $FILES_TRANSPORT -gt $MIN_FILES ]

do

  ls -tr *"$SEARCH_STRING" 2>/dev/null | head -1 | xargs -i mv {} $BACKUP_Local

  FILES_TRANSPORT=`ls -1p *"$SEARCH_STRING" 2>/dev/null | grep -vc "/$"` 

  let "REMOVED+=1"

done

}

# cleaner delete files function

delete()

{

FILES_DELETE=`ls -1p *"$SEARCH_STRING" 2>/dev/null | grep -vc "/$"`

while [ $FILES_DELETE -gt $MIN_FILES ]

do

  ls -tr *"$SEARCH_STRING" 2>/dev/null | head -1 | xargs -i rm {}

  FILES_DELETE=`ls -1p *"$SEARCH_STRING" 2>/dev/null | grep -vc "/$"`

  let "DELETED+=1"

done

}

delete_volume()

{

    if [ $MIN_FILES = 0 ]

    then 

        echo "${RED}Delete the following files (y/n)?${NC}"

        echo "${RED}Delete the following files (y/n)?${NC}" >> $BACKUP_LOG

        ls -alF *"$SEARCH_STRING" >> $BACKUP_LOG 2>&1

    fi

    echo $CONFIRM_FILES_DELETE

    

    delete

    if [ $DELETED = 1 ]

    then

	    TEXT_DELETED='file.'    else

	    TEXT_DELETED='files.'

    fi

    echo " " >> $BACKUP_LOG

    echo Deleted $DELETED $TEXT_DELETED

    echo Deleted $DELETED $TEXT_DELETED >> $BACKUP_LOG

}

transport_volume()

{

    if [ $MIN_FILES = 0 ]

    then 

        echo "${RED}Transport the following files (y/n)?${NC}"

        echo "${RED}Transport the following files (y/n)?${NC}" >> $BACKUP_LOG

        ls -alF *"$SEARCH_STRING" >> $BACKUP_LOG 2>&1

    fi

    echo $CONFIRM_FILES_TRANSPORT

    

    transport

    if [ $REMOVED = 1 ]

    then

	    TEXT_TRANSPORTED='file.'

    else

	    TEXT_TRANSPORTED='files.'

    fi

    echo " " >> $BACKUP_LOG

    echo Transported $REMOVED $TEXT_TRANSPORTED

    echo Transported $REMOVED $TEXT_TRANSPORTED >> $BACKUP_LOG

}

# cleaner set args and handle help/unknown arguments with usage() function

while getopts  ":s:m:d:qh" flag

do

  #echo "$flag" $OPTIND $OPTARG

  case "$flag" in

    h)

      usage

      exit 0

      ;;

    q)

      QUIET=1

      ;;  

    s)

      SEARCH_STRING=$OPTARG

      ;;

    m)

      MIN_FILES=$OPTARG

      ;;

    d)

      BACKUP_BareOS=$OPTARG

      ;;

    ?)

      usage

      exit 1

  esac

done

# cleaner change to requested directory and perform delete with or without verbosity

cd $BACKUP_Local

CONFIRM_FILES_DELETE=`ls -1p *"$SEARCH_STRING"`

if [ $SEARCH_STRING = 'keyword' ]

then

    echo -e "${YELLOW}Usage:  cleaner.sh -s [Keyword]${NC}"

    echo -e "${YELLOW}Usage:  cleaner.sh -s [Keyword]${NC}" >> $BACKUP_LOG

    echo " " >> $BACKUP_LOG

    echo " " >> $BACKUP_LOG

    exit 0

fi

if [ ! -e *"$SEARCH_STRING" ]

then

    echo -e "${YELLOW}BareOS Local Backup Directory is empty! Please Wait until New Backup Volume Comes.${NC}"

    echo -e "${YELLOW}BareOS Local Backup Directory is empty! Please Wait until New Backup Volume Comes.${NC}" >> $BACKUP_LOG

    # cleaner change to requested directory and perform transport with or without verbosity

    cd $BACKUP_BareOS

    CONFIRM_FILES_TRANSPORT=`ls -1p *"$SEARCH_STRING"`

    if [ ! -e *"$SEARCH_STRING" ]

    then

        echo -e "${YELLOW}BareOS Backup Directory is empty! Please Wait until New Backup Volume Comes.${NC}"

        echo -e "${YELLOW}BareOS Backup Directory is empty! Please Wait until New Backup Volume Comes.${NC}" >> $BACKUP_LOG

        echo " ----- ----- Code being Executed End of Line ----- ----- " >> $BACKUP_LOG

        echo " " >> $BACKUP_LOG

        echo " " >> $BACKUP_LOG

        exit 0

    fi

    echo " ----- ----- Code being Executed Start of Line ----- ----- "

    echo " ----- ----- Code being Executed Start of Line ----- ----- " >> $BACKUP_LOG

    transport_volume

else

    echo " ----- ----- Code being Executed Start of Line ----- ----- "

    echo " ----- ----- Code being Executed Start of Line ----- ----- " >> $BACKUP_LOG

    delete_volume

    # cleaner change to requested directory and perform transport with or without verbosity

    cd $BACKUP_BareOS

    CONFIRM_FILES_TRANSPORT=`ls -1p *"$SEARCH_STRING"`

    if [ ! -e *"$SEARCH_STRING" ]

    then

        echo -e "${YELLOW}BareOS Backup Directory is empty! Please Wait until New Backup Volume Comes.${NC}"

        echo -e "${YELLOW}BareOS Backup Directory is empty! Please Wait until New Backup Volume Comes.${NC}" >> $BACKUP_LOG

        echo " ----- ----- Code being Executed End of Line ----- ----- " >> $BACKUP_LOG

        echo " " >> $BACKUP_LOG

        echo " " >> $BACKUP_LOG

        exit 0

    fi

    transport_volume

fi

# cleaner change back to the original directory

echo " ----- ----- Code being Executed End of Line ----- ----- "

echo " ----- ----- Code being Executed End of Line ----- ----- " >> $BACKUP_LOG

echo " " >> $BACKUP_LOG

echo " " >> $BACKUP_LOG

cd $OLDPWD

exit 0
