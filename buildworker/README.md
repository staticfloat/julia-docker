buildworker docker images
=========================

To build Julia buildworker base docker images, first install [harbor](https://github.com/leethomas/harbor) with `gem install harbordock`, then run `make` in this directory.  The result will be docker images named things like `buildworker_centos5:64` and `buildworker_ubuntu16.04:32`.

To generate all the `Dockerfile`s without actually building the docker images, run `make all-Dockerfiles`.

To generate a `Dockerfile` and then build the result, run something like `make centos5-32`, or `make ubuntu16.04-64`.

**NOTE:** This repository uses the new experimental `--squash` command introduced in Docker 1.13 in order to cut down on image sizes.  (Without `--squash` support, the `centos5-32` image is ~6.5 GB, with it it is ~1 GB)
