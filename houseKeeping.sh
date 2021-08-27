#!/bin/bash

# Color Output for CMD

YELLOW=$'\e[1;33m' # Yellow Color.

RED=$'\e[0;31m' # Red Color.

NC=$'\e[0m' # No Color.


# Basic Vars for Script and Logging.

TIMESTAMP=$(date +"%Y%m%d") # YYYYMMDD.

BACKUP_BareOS=/path/path/path # The Location where BareOS Puts the Backup Volumes at.

BACKUP_Local=/path/path/path # The Location where You Would Like to Store the Old Backup Volumes.

RETENTION="7" # Retention Period.

BACKUP_LOG=/path/path/${TIMESTAMP}_backup.log # The Location of Loggings.


# Logging Header

echo " \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/ " >> $BACKUP_LOG

echo " ----- ----- ----- " >> $BACKUP_LOG

echo "Date: $(date)" >> $BACKUP_LOG

echo "Hostname: $(hostname)" >> $BACKUP_LOG

echo "Backup script has run. " >> $BACKUP_LOG

echo " ----- ----- ----- " >> $BACKUP_LOG

# houseKeeping usage function -h

usage()

{

cat << EOF

houseKeeping.sh 
This script cleans directories.  It is useful for backup 
and log file directories, when you want to transport/delete older files. 
USAGE:  houseKeeping.sh [options]
OPTIONS:
   -h      Show this message
   -s      A search string to limit file deletion, defaults to '*' (All files).
   
EXAMPLES: 
   In the current directory, transport/delete everything but the 5 most recently touched 
   files: 
     houseKeeping.sh
         Same as:
     houseKeeping.sh -s *
   In the directory of bareos backup/house keeping folder, transport/delete all the files that match the vars including text "*"

EOF

}

# Set default values for VARS

SEARCH_STRING='keyword' # Default Search String.

MIN_FILES='0' # For while loop statement.

QUIET=0 # Useless VAR.

REMOVED=0 # For Counting File Transported Quantity.

DELETED=0 # For Counting FIle Deleted Quantity.

# houseKeeping transport files function.

transport()

{

FILES_TRANSPORT=`ls -1p *"$SEARCH_STRING" 2>/dev/null | grep -vc "/$"` # For Couting the Total Number of Existed Files.

while [ $FILES_TRANSPORT -gt $MIN_FILES ]

do

  ls -tr *"$SEARCH_STRING" 2>/dev/null | head -1 | xargs -i mv {} $BACKUP_Local # Move New Volumes to the House Keeping Folder.

  FILES_TRANSPORT=`ls -1p *"$SEARCH_STRING" 2>/dev/null | grep -vc "/$"` # While Loop, see line 94.

  let "REMOVED+=1" # Counting Feature.

done

}

# houseKeeping delete files function

delete()

{

FILES_DELETE=`ls -1p *"$SEARCH_STRING" 2>/dev/null | grep -vc "/$"` # For Couting the Total Number of Existed Files.

while [ $FILES_DELETE -gt $MIN_FILES ]

do

  ls -tr *"$SEARCH_STRING" 2>/dev/null | head -1 | xargs -i rm {} # Delete Old Volumes in the House Keeping Folder.

  FILES_DELETE=`ls -1p *"$SEARCH_STRING" 2>/dev/null | grep -vc "/$"` # While Loop, see line 94.

  let "DELETED+=1" # Counting Feature.

done

}

# Main Delete Function.

delete_volume()

{

    if [ $MIN_FILES = 0 ]

    then 

        echo "${RED}Delete the following files (y/n)?${NC}"

        echo "${RED}Delete the following files (y/n)?${NC}" >> $BACKUP_LOG

        ls -alF *"$SEARCH_STRING" >> $BACKUP_LOG 2>&1 # For Sending the "ll" Outputs to the Logging File.

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

        ls -alF *"$SEARCH_STRING" >> $BACKUP_LOG 2>&1 # For Sending the "ll" Outputs to the Logging File.

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

# houseKeeping set args and handle help/unknown arguments with usage() function

while getopts  ":s:h" flag

do

  #echo "$flag" $OPTIND $OPTARG

  case "$flag" in

    h)

      usage

      exit 0

      ;;

    s)

      SEARCH_STRING=$OPTARG

      ;;

    ?)

      usage

      exit 1

  esac

done

# houseKeeping change to requested directory and perform delete with or without verbosity

cd $BACKUP_Local

CONFIRM_FILES_DELETE=`ls -1p *"$SEARCH_STRING"`

if [ $SEARCH_STRING = 'keyword' ]

then

    echo -e "${YELLOW}Usage:  houseKeeping.sh -s [Keyword]${NC}"

    echo -e "${YELLOW}Usage:  houseKeeping.sh -s [Keyword]${NC}" >> $BACKUP_LOG

    echo " " >> $BACKUP_LOG

    echo " " >> $BACKUP_LOG

    exit 0

fi

if [ ! -e *"$SEARCH_STRING" ]

then

    echo -e "${YELLOW}BareOS Backup Directory for House Keeping is empty! Please Wait until House Keeping Volume Comes.${NC}"

    echo -e "${YELLOW}BareOS Backup Directory for House Keeping is empty! Please Wait until House Keeping Volume Comes.${NC}" >> $BACKUP_LOG

    # houseKeeping change to requested directory and perform transport with or without verbosity

    cd $BACKUP_BareOS

    CONFIRM_FILES_TRANSPORT=`ls -1p *"$SEARCH_STRING"`

    if [ ! -e *"$SEARCH_STRING" ]

    then

        echo -e "${YELLOW}BareOS Backup Directory for House Keeping is empty! Please Wait until the House Keeping Volume Comes.${NC}"

        echo -e "${YELLOW}BareOS Backup Directory for House Keeping is empty! Please Wait until the House Keeping Volume Comes.${NC}" >> $BACKUP_LOG

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

    # houseKeeping change to requested directory and perform transport with or without verbosity

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

# houseKeeping change back to the original directory

echo " ----- ----- Code being Executed End of Line ----- ----- "

echo " ----- ----- Code being Executed End of Line ----- ----- " >> $BACKUP_LOG

echo " " >> $BACKUP_LOG

echo " " >> $BACKUP_LOG

cd $OLDPWD

exit 0
