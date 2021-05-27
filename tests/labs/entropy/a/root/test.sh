#!/bin/bash

required_bits=128

# Wait 10 seconds then check whether the entropy pool is above $required_bits bits
sleep 10

if [ "${required_bits}" -lt "$(cat /proc/sys/kernel/random/entropy_avail)" ]; then
    touch /hostlab/entropy_successful
fi
