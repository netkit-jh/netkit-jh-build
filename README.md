# Netkit UML build

# Introduction

I am using Netkit for self-learning and teaching network security. But netkit development has stalled
since some time and the scripts to build the fs and the kernel are now broken due to a bug in deboostrap which
is not going to be fixed (the fs is based on the now deprecated debian Sid).

I found a lot of scripts to build a kernel and an fs image for UML machines, but most are not maintenable
(and are not maintened). I was looking for a generic way to build and expand kernel and image for Netkit.

Hence, the build scripts leverage build tools in debian. More specifically:

- kernel is build from source using patched debian package
- rootstrap build the fs with new modules dedicated to netkit

## Installation

The build is developped and tested on debian Wheezy.

It is recommanded to use a non-critical virtual machine, as the build script requires root user.

The build requires several tools which can be installed with the following commands (using root user):

    apt-get install build-essentials rootstrap

Launch the build with the command make in the root directory of the project.

## Configuration

The following files can help an user to configure the build.


