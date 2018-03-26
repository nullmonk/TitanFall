#!/bin/bash
# Lets you choose which payloads to load into the script
# Only generates a config. Does not actually build the script

# Show a message given a title and message
show_message() {
    $TUI --title "$2" --msgbox "$1" 8 70 3>&1 1>&2 2>&3
}

# Reset the screen and then quit
quit() {
    reset
    exit
}
################################################################################
################################ INIT FUNCTIONS ################################
################################################################################

# Figure out whether we have dialog or whiptail
get_tui() {
    if [ "$(command -v dialog)" != "" ]; then
	TUI="dialog"
    elif [ "$(command -v whiptail)" != "" ]; then
	TUI="whiptail"
    else
	echo "[!] Install 'dialog' to use the TUI generator"
    fi
}

# Get the filename and validate that it works
get_filename() {
    file="" # File is blank by default
    loop=0  # Loop by default
    if [ "$1" != "" ]; then
	name="$1" # Set the file to the given filename
        file="$name"
    fi

    while [ "$loop" = "0" ]; do
	loop=1 # Dont loop incase of error
	# Ask for a filename if none is given
	if [ "$name" = "" ]; then
	    file=$($TUI --title "Name" \
	    --inputbox "Enter the output filename:" 0 0  3>&1 1>&2 2>&3)
	    # If its a blank name, exit
	    if [ "$file" = "" ]; then
		show_message "No file name given. Exiting" "ERROR"
		quit
	    fi
	fi
        name="$(echo $file | sed 's/.*\///; s/\.\w*$//').yml"
	if [ -f $name ]; then
	    $TUI --yesno "File exists. Choose a different file?" 10 30;
	    res="$?"
	    if [ "$res" = "0" ]; then
		# YES: Don't overwrite, clear the name and loop again
		file=""; name=""; loop=0;
	    elif [ "$res" = "1" ]; then
		# NO: Use this file, dont loop and jump to the end
		loop=1
	    else
		# Different escape code, hard exit
		return 1
	    fi
	fi
    done
    # Make sure that the file can be written to
    echo "---" > $name
    if [ ! -f $name ]; then
	show_message "File '$file' cannot be created" "ERROR"; quit;
    fi
    return 0
}

get_log() {
    # Get the logging level, Logging level 0 is nothing
    # Logging level 1 is no color, level > 1 is color
    options="0 'No logging' off 1 'Plain logging' off 2 'Color logging' off"
    com='--title "Choose verbosity type" --radiolist "Which level of verbosity would you like to use?" 0 0 15'
    # Keep looping through until we have answer
    while [ "$results" = "" ]; do
        # Redirect the stderr to normal output
        results=$(eval $TUI $com $options 3>&1 1>&2 2>&3)
        if [ "$results" = "" ]; then
	    show_message "Please pick a verbosity level" "ERROR";
	fi
	
        # If its using whiptail, remove the quotes from the files
        if [ "$TUI" = "whiptail" ]; then
            results=$(echo $results | sed 's/\"//g')
	fi
    done;
    echo $results
}

get_payloads() {
    # Find all the payload files
    payload_files=$(find $PAYLOADS_DIR -type f)
    
    arguments=""
    for p in $payload_files; do
        description=$(head -n 1 $p | sed -e 's/^#[[:space:]]*//' -e 's/[[:space:]]*$//')
	#name=$(echo $p | sed 's/.*\///')
	arguments="$arguments '$p' '$description' on"
    done
    com='--title "Test" --checklist "Which payloads would you like to use?" 0 0 15'
    # Redirect the stderr to normal output
    results=$(eval $TUI $com $arguments 3>&1 1>&2 2>&3)
    if [ "$TUI" = "whiptail" ]; then
	results=$(echo $results | sed 's/\"//g')
    fi
    echo $results
}

main() {
    name=$1
    file="$(echo $name | sed 's/.*\///; s/\.\w*$//').yml"
    # Get all the payloads to use
    payloads=$(get_payloads)
    # Get the level of logging to use in the scripts
    log_lev="$(get_log)"

    # Get a description for this configuration
    desc=$($TUI --title "Description" \
    --inputbox "Enter a description for the filename:" 0 0  3>&1 1>&2 2>&3)
    
    echo "name: $name" >> $file
    echo "description: \"$desc\"" >> $file
    echo "loglevel: $log_lev" >> $file
    echo "parse: true" >> $file
    echo "payloads:" >> $file
    for p in $payloads; do
         echo "  - \"$p\"" >> $file
    done
    
    show_message "Config generated! Your new dropper config is in '$file'"\
    "COMPLETE"
    clear
}

check_payloads_dir(){
    # TODO Add multiple payload directories to search
    PAYLOADS_DIR="../Titans/payloads";
    message="'$PAYLOADS_DIR' is not a real directory. Please enter a valid payload directory"
    if [ ! -d "$PAYLOADS_DIR" ]; then
        show_message "$message" "Error";
        quit;
    fi;
}

get_tui
check_payloads_dir
get_filename $1
main "$file"
