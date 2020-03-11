#!/bin/bash

## for loop
for v in "zero" "one" "two" "three" "four" "five"
do
    echo "found value $v"
done

list=( "zero" "one" "two" "three" "four" "five" )

for v in "${list[@]}"
do
    echo "found value $v"
done

## while

count=0
limit=10

while [ "$count" -lt "$limit" ]
do
    echo "count is $count, has not reached limit $limit"
    (( count += 1 ))
done

echo "count is $count, has reached limit $limit"

## until

count=0
limit=10

until [ "$count" -gt "$limit" ]
do
    echo "count is $count, has not reached limit $limit"
    (( count += 1 ))
done

echo "count is $count, has reached limit $limit"

