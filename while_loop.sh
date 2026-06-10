#! /bin/bash

# File that acts as a signal to stop the loop
SIGNAL_TO_STOP_FILE="stoploop"

# Keep looping as long as the file does NOT exist
while [[ ! -f "${SIGNAL_TO_STOP_FILE}" ]]; do
    echo "The file ${SIGNAL_TO_STOP_FILE} does not yet exist..."  # Notify the file hasn't been created yet
    echo "Checking again in 2 seconds..."                         # Notify it will check again soon
    sleep 2                                                       # Wait 2 seconds before checking again
done

echo "File was found! exiting..."  # The file was detected, loop ends and script exits