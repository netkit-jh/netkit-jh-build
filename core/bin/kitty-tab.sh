#!/bin/bash

# Locking: http://mywiki.wooledge.org/BashFAQ/045

if [ ! -S /tmp/nk_kitty ]
then
    if mkdir /tmp/nk_kitty_lock 2>/dev/null
    then
        trap 'rm -rf /tmp/nk_kitty_lock' 0

        kitty \
            --override allow_remote_control=yes \
            --detach \
            --listen-on unix:/tmp/nk_kitty \
            -- "$@"
        
        while [ ! -S /tmp/nk_kitty ]
        do
            sleep 1
        done

        exit 0
    else
        while [ ! -S /tmp/nk_kitty ]
        do
            sleep 1
        done
    fi
fi
    
kitty \
    @ \
    --to unix:/tmp/nk_kitty \
    launch \
    --type tab \
    -- "$@" \
    > /dev/null
