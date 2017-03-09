include ../common.mk

ifeq ($(BUILD_ARCH),x86_64)
ARCH_FLAGS="MARCH=core2"
else ifeq ($(BUILD_ARCH),i686)
ARCH_FLAGS="JULIA_CPU_TARGET=pentium4 MARCH=pentium4"
else ifeq ($(BUILD_ARCH),ppc64le)
ARCH_FLAGS="JULIA_CPU_TARGET=pwr8"
else ifeq ($(BUILD_ARCH),aarch64)
ARCH_FLAGS="JULIA_CPU_TARGET=generic MARCH=armv8-a"
else ifeq ($(BUILD_ARCH),armvl)
ARCH_FLAGS="JULIA_CPU_TARGET=generic MARCH=armv7-a"
endif

build:
	$(DOCKER_BUILD) --pull --build-arg "ARCH_FLAGS=$(ARCH_FLAGS)" -t staticfloat/julia:$(BUILD_ARCH)
