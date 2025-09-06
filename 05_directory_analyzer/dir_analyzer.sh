#Create a script called dir_analyzer.sh that analyzes directory sizes and finds the largest directories in a given path.
#Consider default directory as / if any argument is not given

#!/bin/bash

if [ -z "$1" ]; then
    DIRECTORY="/"
else    
    DIRECTORY="$1"
fi

if [ ! -d "$DIRECTORY" ]; then
    echo "Target Directory $DIRECTORY is not present"
    exit 1
fi

TOTAL_SIZE=$(du -sh $DIRECTORY 2>/dev/null | awk '{print$1}')
echo "Total size of Directory is $TOTAL_SIZE"
#2>/dev/null (2> redirect standard error to /dev/null which can be called a blackhole where the output disappears)
#awk will extract the first column which size of the directory


echo "Top 5 largest directory under $DIRECTORY:"

du -h --max-depth=1 "$DIRECTORY" 2>/dev/null | sort -hr | head -n 6 
#--max-depth=1 only look one level deep inside the directory. don't go inside nested subdirectories
#if --max-depth=1 is not specified it will traverse inside all the subdirectories
#sort -hr (sort in reverse order based on size)
#head -n 6 (First 6 lines consisting of the title row and 5 output rows)