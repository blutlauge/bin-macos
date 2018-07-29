#!/usr/bin/env bash

##############################################################################
#
# Script for automated incremental rsync backups (adapted from the script
# found on rsync.samba.org)
#
##############################################################################

# Options
##############################

# NAS user
USER=marc

# NAS
HOST=DiskStation
HWADDR=08:86:3B:E0:AD:67

# ssh public key
KEY=$HOME/.ssh/id_rsa

# rsync excludes
EXCLUDES=$HOME/.rsbp-excludes.txt

# path to the directory to backup
SRC=$HOME

# root directory to backup to
BACKUP=/volume1/BackupShare

# directory which holds the current datastore
CURRENT=current

# directory which holds incremental changes
INCREMENTDIR=$(date +%Y-%m-%d--%H-%M-%S)

# backups older than X days are deleted
X=60

# rsync options
OPTS="--force \
      --ignore-errors \
      --delete \
      --delete-excluded \
      --exclude=".*" \
      --exclude=".*/" \
      --exclude-from=$EXCLUDES \
      --backup \
      --backup-dir=$BACKUP/$INCREMENTDIR \
      -aP"

# Sync
##############################
# rsync function
do_rsync()
{
  /usr/bin/logger -t $0 "Backup started.";
  /usr/bin/rsync $OPTS -e "ssh -i $KEY" $SRC $USER@$HOST:$BACKUP/$CURRENT;
  /usr/bin/logger -t $0 "Backup complete.";
}

# delete backups older than X days
delete_old_backups()
{
  # find options
  FIND_OPTS="-type d -maxdepth 1 -user $USER -mtime +$X -regex '.*[1234567890]'";

  /usr/bin/logger -t $0 "Delete old backups.";
  ssh $USER@$HOST "find $BACKUP/ $FIND_OPTS -exec rm -rf {} \;";
}

# do the backup
delete_old_backups;
if [ -f $EXCLUDES ]; then
  do_rsync;
else
  /usr/bin/logger -t $0 "Can't find exclude file "$EXCLUDES".";
  exit 0;
fi

