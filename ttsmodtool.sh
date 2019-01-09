#!/bin/bash
# TTS Mod links
# Author: Fábio Rodrigues
# E-mail: anfabio@gmail.com
# Version 1.0

# Procedures

# Usage
usage() {	
	echo "Usage: $(basename $0) [-r] [-l] [-t TARGET] MOD_NAME"
	echo "Create symbolic links to the last mod assets downloaded for Tabletop Simulator. It makes easier to delete the mod files after an unsubscribe or just to reload all the files again"
	echo "	-t TARGET	the TTS Mod path. Default is '\$HOME/.local/share/Tabletop Simulator/Mod'"
	echo "	-r		remove the Mod and its links"
	echo "	-l		remove the last downloaded mod as well as all the files that are not a symbolic link found in the asset directories"
}


#Create links
create_links () {
	for WORKINGDIR in ${ASSET_DIRS[@]}
	do
		echo "Processing  $WORKINGDIR Directory"
	
		echo "--------------------------------------------"
		cd "$TARGET/$WORKINGDIR"
	
		# Create directory	
		if [ -d "$MOD" ]; then
			echo "Directory '$MOD' already exists!"
		else
			echo "Creating directory '$MOD' ..."
			mkdir "$MOD"
		fi
	
		# Find the current files
		TMPFILE=$(mktemp)
		find . -maxdepth 1 -type f -exec basename {} ';' > "$TMPFILE"	
	
		# Make the links
		while read FILE
		do
			echo "Moving $FILE to $MOD directory"		
			mv "$FILE" "$MOD"			
			echo "Creating symbolic link to $FILE"
			ln -s "$MOD/$FILE" "$FILE"
		done < "$TMPFILE"	
		echo
	done
	
	echo "All done! Enjoy"
}

#Remove mod
remove_mod () {
	for WORKINGDIR in ${ASSET_DIRS[@]}
	do
		echo "Processing  $WORKINGDIR Directory"	
		echo "--------------------------------------------"
		cd "$TARGET/$WORKINGDIR"
	
		# Find the current files
		TMPFILE=$(mktemp)
		find "$MOD" -maxdepth 1 -type f -exec basename {} ';' > "$TMPFILE"

		# Remove files		
		while read FILE
		do
			echo "Removing link to $FILE"
			rm "$FILE"
		done < "$TMPFILE"

		# Remove directory
		echo "Removing directory $MOD"
		rm -rf "$MOD"

		echo
	done	
	echo "$MOD removed!"
}


#Remove last downloaded mod as well as all the files that are not a symbolic link found  in the asset directories
remove_last_mod () {
	for WORKINGDIR in ${ASSET_DIRS[@]}
	do
		echo "Processing  $WORKINGDIR Directory"	
		echo "--------------------------------------------"
		cd "$TARGET/$WORKINGDIR"
	
		# Find and remove the current files
		find . -maxdepth 1 -type f -exec rm {} ';'

		echo
	done	
	echo "Files removed!"
}


######
# MAIN # 
######

# test number of given arguments
if [ $# == 0 ] ; then usage; exit 0 ; fi

# initial values
TARGET="$HOME/.local/share/Tabletop Simulator/Mods"
ASSET_DIRS=("Assetbundles" "Images" "Models")
REMOVE=false
REMOVE_LAST=false

#getopt loop
while getopts 't:rlh?' opt
do
	case $opt in
    t) TARGET="${OPTARG}" ;;
   	r) REMOVE=true ;; 
   	l) REMOVE_LAST=true ;; 
    h|?) usage; exit 0 ;; esac
done

#shift to get the last arguments
shift $((OPTIND-1))

if [ $REMOVE_LAST = false ]; then
	if [ $# == 0 ] ; then echo "ERROR: Please provide a MOD NAME"; echo; usage; exit 0 ; fi
	MOD="$1"
fi

# Print the options
echo "Mod Name:  $MOD"
echo "TTS Target: $TARGET"

if [ $REMOVE_LAST = true ]; then
	read -p "This will remove the last downloaded mod as well as all the files that are not a symbolic link found in the asset directories. Are you sure? (y/N) " RESPONSE
	RESPONSE=${RESPONSE,,}	
	if [[ "$RESPONSE" != "y"  ]]; then
		echo "Aborting...";
		exit 0;
	else
		echo "========================"
		echo
		remove_last_mod;
		exit 0;		
	fi
elif [ $REMOVE = true ]; then
	read -p "Removing $MOD. Are you sure? (y/N) " RESPONSE
	RESPONSE=${RESPONSE,,}	
	if [[ "$RESPONSE" != "y"  ]]; then
		echo "Aborting...";
		exit 0;
	else
		echo "========================"
		echo
		remove_mod;
		exit 0;		
	fi
else	
	read -p "Create links for $MOD? (y/N) " RESPONSE
	RESPONSE=${RESPONSE,,}
	if [[ "$RESPONSE" != "y"  ]]; then
		echo "Aborting...";
		exit 0;
	else
		echo "========================"
		echo		
		create_links;
		exit 0;		
	fi	
fi
