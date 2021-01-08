# Tinkerbell Debian workflow

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

About the Tinkerbell Debian workflow it's based on Grml-debootstrap. It doesn't try to process disk images any more. Just installing old plain deb packages. Because of the need to setup the same packages over and over again, (especifically in cace of installing multiple Debian instances) this workflow has a dependency on apt-cacher-ng. It doesn't work without! It uses the default port 3142. And cache all the deb packages nicely.

There's one available writen for [Ubuntu](https://github.com/fransvanberckel/ubuntu-workflow) as well.

## Compatibility

This configuration has been tested with the following hardware and OS combinations:

- HP ProBook 6560b and Ubuntu 18.04 (64-bit)
- HP ProLiant DL2000 Node Rack Server module and Debian Bullseye (64-bit)

I am open for cloud instances to test, when they become available.

## Usage

First, before you start running the workers workflow, you need to make adjustments to, where needed ...

- debian/bullseye.yml
- debian/hardware.json
- debian/build_and_push_images.sh
- debian/create_tink_workflow.sh

Next verify, build, pack & create the environment.
```
$ ./verify_json_tweaks.sh
$ sudo ./build_and_push_images.sh
$ sudo ./pack_grml_tar_gz.sh
$ sudo cp ./grml-debian.tar.gz /var/tinkerbell/state/webroot/misc/osie/current/
$ sudo ./create_tink_workflow.sh

Enter new root password:
Enter new user password:
Enter new password salt:
Creating new Tinkerbell worker environment
2020/08/07 05:56:07 Hardware data pushed successfully
Created Template: 95f948b6-cf87-4d64-bb56-1f5087ae6588
Created Workflow: 508569a3-0275-4f50-b957-51d4de6c21ae
```

You can also execute tink-cli without `create_tink_workflow.sh` script by individually inserting the template and hardware. You can modifiy `hw_data_hardcoded.json` as per you requirement and then create the workflow.
```
$ docker exec -i deploy_tink-cli_1 tink template create --name bullseye < ./bullseye.yml
Created Template:  7e8b59b5-4ce2-448a-a4a8-1aa5db7dd519
$ docker exec -i deploy_tink_cli_1 tink hardware push < ./hw_data_hardcoded.json
$ docker exec -i deploy_tink-cli_1 tink workflow create \
    -t 7e8b59b5-4ce2-448a-a4a8-1aa5db7dd519  \
    -r '{"device_1":"08:00:27:00:00:01"}'
```

## Notes
* Vagrant users: To boot to Debian after workflow is completed, reboot the machine, go to the boot menu and select Debian boot loader.
* All workflow actions run as `--privileged` Docker containers.

## Author

The repository was created in 2020 by [Frans van Berckel](https://www.fransvanberckel.nl)
