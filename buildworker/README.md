buildworker docker images
=========================

This repository auto-generates a bunch of [docker-compose](https://docs.docker.com/compose/) configurations to run the julia buildworker instances on top of the worker base images generated in the `workerbase` directory in the root of this repository.  `docker-compose` is used as a convenient way to run docker images with some slight modification (E.g. the installation of the `buildbot-worker` python application, the configuration of the image with sensitive information such as the buildbot authentication password).

The configuration is contained within the two template files sitting in this directory, the templates are generated using the `Makefile`, which auto-generates a template for each worker base image defined in the `workerbase` directory in the root of this repository.

As usual, after building the configurations with `make`, all will be contained within the `build` directory.  To run a buildworker, simply enter the directory and run `docker-compose up --build`.
