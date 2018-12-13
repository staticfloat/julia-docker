# Crossbuild images

The crossbuild images are used to create a docker image that contains GCC cross-compilers for every OS and architecture combination we officially support for use with [`BinaryBuilder.jl`](https://github.com/JuliaPackaging/BinaryBuilder.jl).  The `Dockerfile`s are normal except they have the added feature of an `INCLUDE` statement that pastes in another `Dockerfile`.

The cross compilation toolkits are all installed into triplet-specific subdirectories of `/opt`.  Because the overall cross-compilation environment is an `x86_64` Linux image, tools that are target-independent (such as `patchelf` or `cmake`) are installed straight to `/usr/local` and are always available.  This environment is intended for use with environment variables setup such that `/opt/<target>/bin` is on the `PATH`, so that naive calls to `gcc` will use the correct cross-compiler.  See [`BinaryBuilder.jl`](https://github.com/JuliaPackaging/BinaryBuilder.jl) for more detail in [which environment variables are defined](https://github.com/JuliaPackaging/BinaryBuilder.jl/blob/76a3073753bd017aaf522ed068ea29418f1059c0/src/DockerRunner.jl#L108-L133) for a particular target triplet.

The build result is uploaded as the `staticfloat/julia_crossbuild:x64` image [on DockerHub](https://hub.docker.com/r/staticfloat/julia_crossbuild/).

The main `make` targets are:

* `build-crossshard-${target}-x64` -- Build the BinaryBuilder shard `target`. Example: `make build-crossshard-i686-linux-gnu-x64`
* `buildsquash-crossshard-${target}-x64` -- Build a squashed version of `target`.
* `shell-crossshard-${target}-x64` -- Run the Docker container with the `target`.
* `push-${target}` -- Extract files from the `target` container, prep shard files, and upload to AWS.

There are also similar `make` targets for the base shard: `build-crossbase-x64`, `shell-crossbase-x64`, , `buildsquash-crossbase-x64`, and `push-base`.

Each shard update needs to be updated in [BinaryBuilder/src/RootfsHashTable.jl](https://github.com/JuliaPackaging/BinaryBuilder.jl/blob/master/src/RootfsHashTable.jl).
New targets need to be added in [BinaryProvider/src/PlatformNames.jl](https://github.com/JuliaPackaging/BinaryProvider.jl/blob/master/src/PlatformNames.jl)

