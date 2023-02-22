# Pulls the backup files from the server 
# This assumes u have a valid ssh certificate for the user in your ssh config

USER=ubuntu
SERVER=grtnr.de
BACKUP_DIR_SERVER=/ghost_backup
TARGET_DIR=./backups/$SERVER

rsync -avz --remove-source-files -e ssh $USER@$SERVER:$BACKUP_DIR_SERVER $TARGET_DIR