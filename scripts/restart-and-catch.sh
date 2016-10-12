#!/bin/bash

# Expects
# - SERVER_IP_ADDRESS
# - DO_KEY
# to be set.

export INTERVAL=10

# Restart the server
ssh root@$SERVER_IP_ADDRESS -i $DO_KEY 'bash -c "shutdown --reboot now"'
echo "Reboot initiated. Attempting reconnect every $INTERVAL seconds..."
sleep $INTERVAL

# Right about now server is shutting down
# Retry an SSH connection every 5 seconds

export RETVAL=1
export TRIES=1

while [ $RETVAL -ne 0 ]; do
    ssh root@$SERVER_IP_ADDRESS -i $DO_KEY 'bash -c "echo \"dank gods\" > fsociety.dat"'
    RETVAL=$?

    [ $RETVAL -eq 0 ] && echo "Success after $(( TRIES * INTERVAL )) seconds"
    [ $RETVAL -ne 0 ] && echo "..." && let "TRIES++" && sleep INTERVAL
done
