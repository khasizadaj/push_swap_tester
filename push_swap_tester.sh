#!/bin/bash

POSITIONAL=()

DEBUG_MODE=0
STEPS=0

while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--debug)
            DEBUG_MODE=1
            shift
            ;;
        -s|--steps)
            STEPS=1
            shift
            ;;
        *)
            POSITIONAL+=("$1")
            shift
            ;;
    esac
done

# Restore positional parameters
set -- "${POSITIONAL[@]}"

if [ ${#POSITIONAL[@]} -lt 4 ]; then
    echo "Error: At least 4 positional arguments are required."
    echo "Usage: $0 start_range end_range count repeat_count [--debug] [--steps]"
    exit 1
fi

START_RANGE=$1
END_RANGE=$2
COUNT=$3
REPEATS=$4

make

for i in $(seq 1 $REPEATS)
do
    # Generate $COUNT unique random numbers within the specified range
    ARG=$(shuf -i $START_RANGE-$END_RANGE -n $COUNT | tr '\n' ' ')

    echo -ne "= Iteration $i\t| "
    output=$(./push_swap $ARG | ./checker_linux $ARG)
    if [ "$output" == "OK" ]; then
        echo -e "\033[32m$output\033[0m"
    else
        echo -e "\033[31m$output\033[0m"
    fi
 
    # Print the number of steps it took to sort the stack
    if [ $STEPS -eq 1 ]; then
        STEP_COUNT=$(./push_swap $ARG | wc -l)
        echo -e "== STEPS: $STEP_COUNT\n"    
    fi
    
    # Print the generated list of numbers
	if [ $DEBUG_MODE -eq 1 ]; then
    	echo -e "\nARG=\"$ARG\"\n"
	fi
done
