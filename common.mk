# BUILD_OS and BUILD_ARCH are the actual OS and architecture of the machine we're running on
BUILD_OS=$(shell uname -s)
BUILD_ARCH=$(shell uname -m)

# Given a BUILD_ARCH, we can determine which architecures we can build images for
ifeq ($(BUILD_ARCH),x86_64)
BUILD_ARCHS=x64 x86
else ifeq ($(BUILD_ARCH),ppc64le)
BUILD_ARCHS=ppc64le
else ifeq ($(BUILD_ARCH),aarch64)
BUILD_ARCHS=aarch64 armv7l
endif
ARCH_FILTER=$(addprefix %-,$(BUILD_ARCHS))

# Begin by listing all the Dockerfiles in the `workerbase/` directory, and
# storing those into $(HFS). Many of our rules will be built from these names
HFS=$(notdir $(basename $(wildcard $(dir $(MAKEFILE_LIST))/workerbase/*.Dockerfile)))

# Build a second list that is filtered by our build architecture and OS, because
# win can't build for non-win (and vice versa) and x86 can't build for ppc64le.
ifneq (,$(findstring MINGW,$(BUILD_OS)))
define BUILD_FILT
$(filter win%,$(filter $(ARCH_FILTER),$(1)))
endef
else
define BUILD_FILT
$(filter-out win%,$(filter $(ARCH_FILTER),$(1)))
endef
endif

# Helper function that adds $(2) as a dependency to rule $(1)
define add_dep
$(1): $(2)
endef

# Helper function that takes in an arch or an OS-arch tuple and
# prefixes it with the appropriate prefix
define worker_tag_name
$(strip staticfloat/julia_workerbase:$(1))
endef
define tabularasa_tag_name
$(strip staticfloat/julia_tabularasa:$(1))
endef
define crossbuild_tag_name
$(strip staticfloat/julia_$(patsubst %-$(lastword $(subst -, ,$(1))),%, $(1)):$(lastword $(subst -, ,$(1))))
endef

# If we have `--squash` support, then use it!
ifneq ($(shell docker build --help 2>/dev/null | grep squash),)
DOCKER_BUILD = docker build --squash
else
DOCKER_BUILD = docker build
endif


# If we're on windows, plop a `winpty` onto the front of DOCKER_BUILD
ifneq (,$(findstring MINGW,$(BUILD_OS)))
DOCKER_BUILD := winpty $(DOCKER_BUILD)
endif

print-%:
	@echo '$*=$($*)'
