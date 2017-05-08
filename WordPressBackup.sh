#!/bin/bash
# Author Roger Gentry (jamesrascal) - Host Kraken
# WP BACKUPS V1.9
# Build date 07/14/2014

# Adjust this to where you websites are stored.
FINDDIR=/var/www/

# Searches for the backup.profile in the web directory.
profile=$(find ${FINDDIR} -wholename "*backup.profile" )

for backupprofile in $profile ; do
echo "********************************************************************";
echo "Using Profile: ${backupprofile}";
. $backupprofile
                
    if [ "${backup_enabled}" = "1" ]; then
                        wp_config=${wp_root}/wp-config.php
                                # Verifing that wp-config is in the location
          if [ ! -f "$wp_config" ]; then
           echo "No WP-Config.php Found Attempting to find one";
                       # Checks the directory above WP_root
           cd $wp_root
           wp_config=../wp-config.php
                                   # IF wp-configstill not found
                                   if [ ! -f "$wp_config" ]; then
            echo "FATAL ERROR: wp-config.php is missing from a readable state";
              echo "Does $wp_domain still work?";
                 
             fi
        fi
                                
                                # Verifing wp_config exists
        if [ -f "$wp_config" ]; then
                    # BackupName Date and time
                                backupname=$(date +%Y%m%d)
    
                                # Pulls Database info from WP-config
                                db_name=$(grep DB_NAME "${wp_config}" | cut -f4 -d"'")
                                db_user=$(grep DB_USER "${wp_config}" | cut -f4 -d"'")
                                db_pass=$(grep DB_PASSWORD "${wp_config}" | cut -f4 -d"'")
                                table_prefix=$(grep table_prefix "${wp_config}" | cut -f2 -d"'")

                                # Creates a Backup Directory if one does not exist.
                                mkdir -p ${backup_location}/${user}/
                                mkdir -p ${backup_location}/${user}/${wp_domain}/
                                
                                # Make Backup location the current directory
                                cd ${backup_location}/${user}/${wp_domain}


                                # MySQL Takes a Dump and compress the Home Directory
                                mysqldump -u ${db_user} -p${db_pass} ${db_name} | gzip > ./${wp_domain}-${backupname}-DB.sql.gz &&
                                tar zcPf ./${wp_domain}-${backupname}-FILES.tar.gz ${wp_root}

                                chmod 600 ./*.gz

                                # Generates the Backup Size
                                FILENAME=${backup_location}/${user}/${wp_domain}/${wp_domain}-${backupname}-*.gz
                                FILESIZE=$(du -h $FILENAME)
                                echo "$FILESIZE"

                                #Deletes any Backup older than X days
                              find ${backup_location}/${user}/${wp_domain}/ -type f -mtime +${keepdays} -exec rm {} \;
                    fi
        fi
                if [ "${backupenabled}" = "0" ]; then
                                echo "Backups NOT enabled for ${wp_root}";
                fi
done
echo " ";
echo "********************************************************************";
echo "This script is licensed under GPL https://github.com/jamesrascal/wordpress-backup/";
echo "Run Date: $(date +%Y%m%d%k%M)";