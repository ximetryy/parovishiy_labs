#!/bin/bash

numbers=(42 17 89 3 56 21 74 9 63 28 91 5 38 12 67 24 80 15 49 31)

echo "Numbers befor sorting:"
echo "${numbers[@]}"
echo

echo "Sorting numbers..."
n=${#numbers[@]}

#Bubble short
for ((i = 0; i < n-1; i++)); do
    for ((j = 0; j < n-i-1; j++)); do
        if [ ${numbers[j]} -gt ${numbers[$((j+1))]} ]; then
            temp=${numbers[j]}
            numbers[j]=${numbers[$((j+1))]}
            numbers[$((j+1))]=$temp
        fi
    done
done

echo "Numbers after sorting (ascending .):"
echo "${numbers[@]}"
