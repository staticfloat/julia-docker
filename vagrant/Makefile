include ../common.mk

# Default target: build all Vagrantfiles
buildall:

# all the boxes we know about
BOXES = osx10_9-x64 osx10_10-x64 osx10_11-x64 osx10_12-x64 win6_3-x64 win6_3-x86

# Makefile method of a switch statement
BOX_NAME_osx10_9-x64 = stopiccot/osx-10.9
BOX_NAME_osx10_10-x64 = jhcook/osx-yosemite-10.10
BOX_NAME_osx10_11-x64 = jhcook/osx-elcapitan-10.11
BOX_NAME_osx10_12-x64 = jhcook/macos-sierra
BOX_NAME_win6_3-x64 = opentable/win-2012r2-standard-amd64-nocm
BOX_NAME_win6_3-x86 = opentable/win-2012r2-standard-amd64-nocm

define vagrantfile
$(shell echo -n $(1) | cut -c1-3).Vagrantfile
endef

define arch
$(shell echo -n $(1) | tail -c 3)
endef

define build_vagrantfile
build/$(1)/lib:
	@mkdir -p build/$(1)
	@ln -sf ../../lib build/$(1)/lib

build/$(1)/Vagrantfile: Makefile $(call vagrantfile,$(1)) build/$(1)/lib
	@if [ ! -f $(call vagrantfile,$(1)) ]; then \
		echo "Target $(1) is invalid, reheck your spelling good sir."; \
		exit 1; \
	fi

	@rm -f build/$(1)/Vagrantfile
	@sed -e 's&{buildworker_name}&$(1)&g; s&{box_name}&$(BOX_NAME_$(1))&g; s&{arch}&$(call arch,$(1))&g' $(call vagrantfile,$(1)) > build/$(1)/Vagrantfile
	@echo $(1)


build-$(1): build/$(1)/Vagrantfile

up-$(1): build/$(1)/Vagrantfile
	cd build/$(1) && vagrant up
deploy-$(1): up-$(1)

down-$(1): build/$(1)/Vagrantfile
	cd build/$(1) && vagrant destroy -f

shell-$(1): build/$(1)/Vagrantfile
	cd build/$(1) && vagrant ssh

# Add this vagrantfile to our big deployall and downall targets
buildall: build-$(1)
deployall: deploy-$(1)
downall: down-$(1)
endef

# Construct all the build-* targets 
$(foreach f,$(BOXES),$(eval $(call build_vagrantfile,$(f))))

clean: downall
	rm -rf build/
