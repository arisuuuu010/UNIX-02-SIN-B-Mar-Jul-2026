#! /bin/bash
check_if_root(){
    # Check if the effective user ID (EUID) is 0 (root)
    if [[ "${EUID}" -eq "0" ]]; then
        echo 0   # Print 0 to stdout to indicate the user IS root
    else
        echo 1   # Print 1 to stdout to indicate the user is NOT root
    fi
}

# Call the function and capture what it prints to stdout (0 or 1)
is_root=$(check_if_root)

# Compare the captured value: if it's 0, the user is root
if [[ "${is_root}" -eq "0" ]]; then
    echo "user is root!"
else
    echo "user is not root!"
fi