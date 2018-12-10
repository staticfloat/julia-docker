# BUILD_OS and BUILD_ARCH are the actual OS and architecture of the machine we're running on
BUILD_OS=$(shell uname -s)
BUILD_ARCH=$(shell uname -m)

# Given a BUILD_ARCH, we can determine which architecures we can build images for
ifeq ($(BUILD_ARCH),x86_64)
BUILD_ARCHS=x86_64 i686
else ifeq ($(BUILD_ARCH),i686)
BUILD_ARCHS=i686
else ifeq ($(BUILD_ARCH),ppc64le)
BUILD_ARCHS=ppc64le
else ifeq ($(BUILD_ARCH),aarch64)
BUILD_ARCHS=aarch64 armv7l
else ifeq ($(BUILD_ARCH),armv7l)
BUILD_ARCHS=armv7l
endif

# Begin by listing all the Dockerfiles in the `workerbase/` directory, and
# storing those into $(HFS). Many of our rules will be built from these names
HFS=$(notdir $(basename $(wildcard $(dir $(MAKEFILE_LIST))/workerbase/*.Dockerfile)))

# Filter a list of inputs to select only ones that contain the build archs we're interested in
define arch_filt
$(foreach ARCH,$(1),$(foreach w,$(2),$(if $(findstring $(ARCH),$(w)),$(w),)))
endef

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

print-%:
	@echo '$*=$($*)'
