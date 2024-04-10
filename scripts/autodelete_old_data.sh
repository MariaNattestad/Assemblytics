# This script automatically deletes old user data to free up space on the server.

# Run with crontab: `crontab -e`:
# 0 0 * * 1 /bin/bash /var/www/assemblytics/scripts/autodelete_old_data.sh
# Set the permissions on user_data and user_uploads to allow the cron job to delete files:
# sudo chmod -R 755 user_data
# sudo chmod -R 755 user_uploads

# Set the timezone to Pacific time
export TZ="America/Los_Angeles"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

ANALYTICS_DIR=/home/lunexa/assemblytics_analytics/
LOG_FILE="${ANALYTICS_DIR}/autodelete_logs/${TIMESTAMP}.txt"

mkdir -p "${ANALYTICS_DIR}/autodelete_logs"
mkdir -p "${ANALYTICS_DIR}/autodelete_lists"

# Define a function to delete old user data and redirect output to $LOG_FILE
delete_old_data() {
    # Set the path to the directory where the user data is stored.
    DIR=/var/www/assemblytics/public/user_uploads/
    

    echo "--------------- ${DIR} ---------------"

    echo "Space available on the server before deleting files:"
    df -h $DIR
    
    # If we later want to check it programmatically:
    # df --output=avail $DIR | tail -1

    # Find files older than ___ days.
    DAYS_OLD=7

    # Find files whose names are exactly 20 characters long because
    # user data has randomly generated names, e.g. TVRqwD7xfgQTh1dbJRP9,
    # while some special files like .htaccess and example data should not be deleted.
    find $DIR -type f -mtime +${DAYS_OLD} -name '????????????????????' -exec ls -l {} \; > $ANALYTICS_DIR/autodelete_lists/${TIMESTAMP}.txt

    # And remove them:
    find $DIR -type f -mtime +${DAYS_OLD} -name '????????????????????' -exec rm {} \;

    echo "Space available on the server after deleting files:"
    df -h $DIR


    DIR=/var/www/assemblytics/public/user_data/
    echo "--------------- ${DIR} ---------------"

    # Find files older than ___ days.
    DAYS_OLD=30

    # Find files whose names are exactly 20 characters long because
    # user data has randomly generated names, e.g. TVRqwD7xfgQTh1dbJRP9,
    # while some special files like .htaccess and example data should not be deleted.
    find $DIR -type d -mtime +${DAYS_OLD} -name '????????????????????'  -exec ls -ld {} \; >> $ANALYTICS_DIR/autodelete_lists/${TIMESTAMP}.txt

    # And remove them:
    find $DIR -type d -mtime +${DAYS_OLD} -name '????????????????????' -exec rm -r {} \;


    echo "Space available on the server after deleting more files:"
    df -h $DIR

}

# Redirect all output to $LOG_FILE and console
delete_old_data 2>&1 | tee $LOG_FILE
