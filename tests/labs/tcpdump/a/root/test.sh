#!/bin/bash

# TCPdump, write up to 10 packets and once finished, create packet_capture_successful
tcpdump -w /hostlab/machine_a.pcap -c 10 && touch /hostlab/packet_capture_successful
