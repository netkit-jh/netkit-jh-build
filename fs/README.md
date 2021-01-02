# Netkit-JH Filesystem

## Building

To build the filesystem run:

```
$ cd netkit-jh-build/fs
$ sudo make
```

To build from within the root of the repository:
```
$ cd netkit-jh-build
$ sudo make fs
```

To build a distro other than debian, run:
```
$ cd netkit-jh-build
$ sudo make fs distro=DISTRO
```

## Adding a Distro

To add a distro, first create a directory in the `distros` directory.

Within this you will need:

- A directory called `filesystem-tweaks` (Optional)
- A file called `bootstrap.sh`
- A file called `pre-install-netkit-fs.sh`
- A file called `post-install-netkit-fs.sh`
- A file called `package-selections`
- A file called `enabled-services`
- A file called `disabled-services`
- A file called `distro.env`

If any of the files are missing, the build will not work. If the filesystem-tweaks directory is missing it will be created during the build process.

An easy way to start is by copying the [template](distros/template) directory.

### Filesystem Tweaks

`filesystem-tweaks` allows you to create files which will end up in the final filesystem image, with `filesystem-tweaks/` representing `/`. For example, you might want to add a config file to `/etc/test.conf`, so you would place the file at `filesystem-tweaks/etc/test.conf`.

There are global and per-distro filesystem tweaks. To add a file for all distros, place the file within
`netkit-jh-build/fs/filesystem-tweaks/...`, or to add a file for a specific distro, place it within
`netkit-jh-build/fs/distros/DISTRO/filesystem-tweaks/...`. The global changes are applied first then the
distro specific changes (this will overwrite global tweaks).

### Bootstrap

The file `netkit-jh-build/fs/distros/DISTRO/bootstrap.sh` needs to be a script that will bootstrap (build the base filesystem) for the distro. This can use tools like pacstrap, debootstrap, multistrap etc.

`bootstrap.sh` will be called with the following arguments:

- $1 - the mount directory (the path to where you should install the base OS)
- $2 - the distro directory (the path to `netkit-jh-build/fs/distros/DISTRO`)

Configuration options can be placed directly in the script but it is recommended to place them in `distro.env`, and then source this in the bootstrap script. This means you can then easily change things such as distro release and mirrors from the `distro.env` file.

### Custom Install Scripts

The script `pre-install-netkit-fs.sh` is run before the [global install script](install-netkit-fs.sh) and `post-install-netkit-fs.sh` is run afterwards.

The main (shared) install script contains key installation steps including:

- installing packages from the package-list
- copying the filesystem-tweaks to the filesystem
- setting up netkit specific services
- copying in kernel modules
- enabling and disabling systemd services

When deciding whether to put commands in the pre or the post install script, you should consider how the above operations would be affected by / would affect the commands.

These scripts are called with the following arguments:

- $1 - the work directory netkit-jh-build/fs (which contains global filesystem tweaks)
- $2 - the build directory (which contains the filesystem version file)
- $3 - the mount directory (where the filesystem is mounted)
- $4 - the kernel modules directory (where the built kernel modules are)
- $5 - the distro directory (the path to the distro files - netkit-jh/fs/distros/DISTRO)

### Package Selections

The file `package-selections` should contain a list of packages to be installed in the main install script.

When adding a package make sure the repository is enabled / added to the filesystem - it may be necessary to add to the `pre-install-netkit-fs.sh` script to add repos.
### Systemd Services

The file `enabled-services` should contain a list of services to enable, and `disabled-services` should contain a list of services to disable - quite self explanatory :)

You should consider disabling services that may be enabled by the packages you install - as we want to keep netkit machines lightweight, it is better to enable a service in a `.startup` file rather than have it enabled by default if its not going to be needed by the majority of netkit machines.

### Distro Config

`distro.env` MUST contain a variable INSTALL_COMMAND which should be set to the command to install a package on a distro.
During the main install script, the packages list will be looped through and for each package, it will run `$INSTALL_COMMAND packageN`.

You can also include other variables that may be useful - for example you might want to have variables for the distro release and mirror used in `bootstrap.sh`. This makes distro.env into a config file of sorts, meaning it is cleaner and easier to make changes as its all in one place.
