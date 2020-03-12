#!/bin/bash

if [ $1 -lt "10" ]
then
    echo "input $1 is less than 10"
else
    echo "input $1 is not less than 10"
fi

if [ $1 -lt "10" ]
then
    echo "input $1 is less than 10"
elif [ $1 -lt "20" ]
then
    echo "input $1 is not less than 10 but less than 20"
else
    echo "input $1 is not less than 20"
fi

case $1 in
    "10")
        echo "input $1 is 10"
        ;;
    "20")
        echo "input $1 is 20"
        ;;
    "30")
        echo "input $1 is 30"
        ;;
    *)
        echo "input $1 other than 10, 20 or 30"
esac

