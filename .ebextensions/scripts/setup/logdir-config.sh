TODAY=$(date +%Y%m%d)
TARGET_DIR="/var/log/nginx"



logger -t "logdir-config" "Creating logging symlink ..."
OUTPUT=$(ln -v -s "${TARGET_DIR}" "/var/log/nginx")
logger -t "logdir-config" "$OUTPUT"