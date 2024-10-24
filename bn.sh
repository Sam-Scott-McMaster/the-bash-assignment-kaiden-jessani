#!/bin/bash

echo $1

if [[ $1 == "--help" ]]
then
    help

elif [[ $# -ne 2 ]]
then
	echo "bn <year> <assigned gender f|F|m|M|b|B>"
	exit 1

fi

help()
{
    echo "Baby Names Utility - Version 1.0"
    echo "This utility allows users to search for the rankings of baby names."
    echo
    echo "Usage:"
    echo "  bn <year> <assigned gender: f|F|m|M|b|B>"
    echo
    echo "Arguments:"
    echo "  year           A four-digit year between 1880 and 2022"
    echo "  assigned gender Can be f, m, F, M, b (for both genders)."
    echo
    echo "Example:"
    echo "  bn 2022 b"
    
    exit 0
}

if [[ ! "$2" =~ ^[a-zA-Z]+$ ]]
then
	echo "Badly formatted name: $1"
	exit 3
fi
if [[ ! $2 =~ ^[bBmMfF] ]]
then
    echo "Badly formatted assigned gender: $2"
    echo "bn <year> <assigned gender f|F|m|M|b|B>"
    exit 2
fi
list_male=$(cat 2XC3-data/us_baby_names/yob$1.txt | grep ",M")
total_male=$(cat 2XC3-data/us_baby_names/yob$1.txt | grep ",M" | wc -l)
list_female=$(cat 2XC3-data/us_baby_names/yob$1.txt | grep ",F")
total_female=$(cat 2XC3-data/us_baby_names/yob$1.txt | grep ",F" | wc -l)

if [[ -z $list ]]
then
	echo "No data for $1"
fi

highest_rank_male=$total_male
highest_rank_female=$total_female

highest_name_male=""
highest_name_female=""

gender=$2

rank()
{
    if [[ $gender =~ [mMbB] ]]
    then
        echo "Highest ranking spot for female names: $highest_rank_male, for the name $highest_name_male"
    fi
    if [[ $gender =~ [fFbB] ]]
    then
        echo "Highest ranking spot for female names: $highest_rank_female, for the name $highest_name_female"
    fi
}

while read line; do
    IFS=' ' read -r -a words <<< "$line"
    for word in "${words[@]}"; do
        number_male=$(echo "$list_male" | grep -ni "^$word," | cut -d: -f1)
        number_female=$(echo "$list_female" | grep -ni "^$word," | cut -d: -f1)
        if [[ highest_rank_male -gt number_male ]]
        then
            highest_rank_male=$number_male
            highest_name_male=$word
        fi
        if [[ highest_rank_female -gt number_female ]]
        then
            highest_rank_female=$number_female
        fi
        if [[ -z "$number_male" &&  $2 =~ [mMbB] ]]
        then
            echo "$1: $word not found among male names."
            if [[ -z "$number_female" && $2 =~ [bB] ]]
            then
                echo "$1: $word not found among female names."
            else
                echo "$1: $word ranked $number_female out of $total_female female names."
            fi
        elif [[ -z "$number_female" &&  $2 =~ [fFbB] ]]	
        then
            echo "$1: $word not found among female names."
            if [[ -z "$number_male" && $2 =~ [bB] ]]
            then
                echo "$1: $word not found among male names."
            else
                echo "$1: $word ranked $number_male out of $total_male male names."
            fi
        else
            if [[ $2 =~ [mMbB] ]]
            then
                echo "$1: $word ranked $number_male out of $total_male male names."
            fi
            if [[ $2 =~ [fFbB] ]]
            then
                echo "$1: $word ranked $number_female out of $total_female female names."
            fi
        fi
        rank
    done
    
done
