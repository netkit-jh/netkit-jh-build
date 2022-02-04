#!/bin/bash

# Repeatedly attempt to ping until successful
while true; do
    if ping -c 1 200.0.0.1; then
        touch /hostlab/ping_successful_a
        exit 0;
    fi
done
