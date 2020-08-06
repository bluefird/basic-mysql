#!/bin/bash
DIR=$1
if [ "$(ls -A $DIR)" ]; then
    echo "$DIR is not Empty"
else
    echo "$DIR is Empty"
fi