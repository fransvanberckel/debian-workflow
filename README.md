# Debian workflow Tinkerbell

```
debian-workflow/
├── debian
│   ├── 00-base
│   │   ├── debian-cleanup.sh
│   │   ├── Dockerfile
│   │   ├── functions.sh
│   │   ├── get-package-list.sh
│   │   └── yq.list
│   ├── 01-disk-wipe
│   │   ├── Dockerfile
│   │   └── wipe.sh
│   ├── 02-disk-partition
│   │   ├── cpr.sh
│   │   ├── Dockerfile
│   │   └── partition.sh
│   ├── 03-install-root-fs
│   │   ├── chroot-script
│   │   ├── config
│   │   ├── Dockerfile
│   │   ├── packages
│   │   └── root-fs.sh
│   ├── 04-cloud-init
│   │   ├── cloud-init.sh
│   │   └── Dockerfile
│   ├── build_and_push_images.sh
│   ├── bullseye.yml
│   ├── create_tink_workflow.sh
│   ├── hardware.json
│   ├── pack_grml_tar_gz.sh
│   └── verify_json_tweaks.sh
├── LICENSE
└── README.md
```

## Compatibility

About the Tinkerbell Debian workflow it's based on Debootstrap. It doesn't try to process disk images any more. Just installing old plain Debian packages. Because of the need of setup the same packages over and over again (specifically in cace of installing multiple Debian instances) the workflow has a dependency on apt-cacher-ng.

This configuration has been tested with the following hardware and OS combinations:

  - HP ProBook 6560b and Ubuntu 18.04 (64-bit)
  - HP ProLiant DL2000 Node Rack Server module and Debian Bullseye (64-bit)

I am open for cloud instances to test, when they become available. 

## Usage

First, before you start running the workers workflow, you need to make adjustments to, where needed ...

- debian/bullseye.yml
- debian/hardware.json
- debian/verify_json_tweaks.sh
- debian/pack_grml_tar_gz.sh
- debian/build_and_push_images.sh
- debian/create_tink_workflow.sh

And install apt-cacher-ng. This workflow doesn't work without! It uses the default port 3142. And caches all the deb packages nicely.

$ sudo apt-get install apt-cacher-ng

## Author

The repository was created in 2020 by [Frans van Berckel](https://www.fransvanberckel.nl)
