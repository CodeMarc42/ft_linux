#!/bin/sh

if [ -z "$DISPLAY" ]; then
    exec xinit
else
    echo "X is already running on $DISPLAY"
fi