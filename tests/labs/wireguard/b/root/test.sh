#!/bin/bash

# Repeatedly attempt to ping until successful
while true; do
    if ping -c 1 100.0.0.1; then
        touch /hostlab/ping_successful_b
        exit 0;
    fi
done
