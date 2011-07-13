#!/bin/sh

rails_root=/home/rails/audioserver
backup_dir=/flash/backup

rdiff-backup $rails_root/db/ $backup_dir/db/
rdiff-backup $rails_root/log/ $backup_dir/log/
rdiff-backup $rails_root/public/ $backup_dir/public/
