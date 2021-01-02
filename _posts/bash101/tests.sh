#!/bin/bash

# if file exists

if [ -e "$1" ]
then
    echo "$1 exists"
else
    echo "$1 does not exist"
fi
