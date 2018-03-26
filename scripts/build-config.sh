#!/bin/bash
stripq() {
    echo $@ | sed "s:[\"']::g"
}


encrypt() {
    file=$1
    encrypt=$2
    if [ "$encrypt" != "" ]; then
        echo Encrypting dropper $file...
	mv $file $file.bak
	openssl aes-256-cbc -salt -k "$encrypt" -in $file.bak \
	 | openssl base64 -out $file.enc
        linec=$(wc -l $file.enc | cut -d' ' -f1)
	# TODO THis needs to pipe directly to bash
	# openssl dry run feature?
	cat lib/encrypt.sh > $file
	sed -i "s:__COUNT__:$linec:g" $file;
	cat $file.enc >> $file
#	rm -f $file.enc
	echo Encrypted dropper created with pass $2
    fi
}

main() {
    file=$1
    # Get all the core functions 
    core_functions=$(find core_functions/ -not -name '*init*' -not -name\
    "log_*"  -type f 2>/dev/null)
    func=$(find "../Titans/functions" -type f 2>/dev/null)
    if [ "$?" != "0" ]; then
        echo error finding core_functions;
        exit
    fi
    # Get all the payloads to use
    # Total list of all the files
    files=""
    # Functions to call at the end of the script
    loaded="INIT"
    # Get the log level to add to the script
    files="$files $log"
    # Add all the core functions to the files list
    for c in $core_functions; do
	files="$files $c"
    done
     
    for c in $func; do
	files="$files $c"
    done
    
    for p in $payloads; do
	files="$files $p"
	# get the filename without the extension or folder
	name=$(echo $p | sed -e 's/.*\///' -e 's/\.\w*$//')
	# call each function at the end of the script
	loaded="$loaded\n$name"
    done
    count=$(echo $files | wc -w) # The total number of files to load  
    completed=0 # The number of payloads processed
    message=""  # Print out all the completed payloads
    
    echo "#!/bin/bash" > $file
    # loop through the files and add them to the output
    for fil in $files; do
	cat $fil >> $file
    done
    # Add the functions to call at the end of the script
    printf "$loaded\n" >> $file
    printf "FINISH\n" >> $file
    if [ "$encrypt" != "" ] && [ "$encrypt" != "false" ]; then
	encrypt "$file" "$encrypt"
    fi
    echo "Finished! Your new dropper is in '$file'" "COMPLETE"
}


if [ "$1" == "" ]; then
    echo "Usage: $0 <filename>"
    exit
fi

name=`grep "name:" $1 | sed 's/name:\s*\(.*\)$/\1/'`
desc=`grep "description:" $1 | sed 's/description:\s*\(.*\)$/\1/'`
log=`grep "logfunction:" $1 | sed 's/logfunction:\s*\(.*\)$/\1/'`
encrypt=`grep "encrypt:" $1 | sed 's/encrypt:\s*\(.*\)$/\1/'`
encrypt=`stripq $encrypt`
parse=`grep "parse:" $1 | sed 's/parse:\s*\(.*\)$/\1/'`
payloads=`cat $1 | sed -n '/payloads:/,/^[^ ]/p' | grep "^  -" \
| sed -n 's/.*"\(.*\)".*/\1/p'`

main "$name"
