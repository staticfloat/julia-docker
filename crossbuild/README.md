# Crossbuild images

The crossbuild images are used to create a docker image that contains GCC cross-compilers for every OS and architecture combination we officially support for use with [`BinaryBuilder.jl`](https://github.com/JuliaPackaging/BinaryBuilder.jl).  The `Dockerfile`s are normal except they have the added feature of an `INCLUDE` statement that pastes in another `Dockerfile`.

The cross compilation toolkits are all installed into triplet-specific subdirectories of `/opt`.  Because the overall cross-compilation environment is an `x86_64` Linux image, tools that are target-independent (such as `patchelf` or `cmake`) are installed straight to `/usr/local` and are always available.  This environment is intended for use with environment variables setup such that `/opt/<target>/bin` is on the `PATH`, so that naive calls to `gcc` will use the correct cross-compiler.  See [`BinaryBuilder.jl`](https://github.com/JuliaPackaging/BinaryBuilder.jl) for more detail in [which environment variables are defined](https://github.com/JuliaPackaging/BinaryBuilder.jl/blob/76a3073753bd017aaf522ed068ea29418f1059c0/src/DockerRunner.jl#L108-L133) for a particular target triplet.

The build result is uploaded as the `staticfloat/julia_crossbuild:x64` image [on DockerHub](https://hub.docker.com/r/staticfloat/julia_crossbuild/).
