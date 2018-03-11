include common.mk

all:
	$(MAKE) -C workerbase
	$(MAKE) -C tabularasa
	$(MAKE) -C buildworker

clean:
	$(MAKE) -C buildworker clean
	$(MAKE) -C workerbase clean
	$(MAKE) -C tabularasa clean
	$(MAKE) -C buildbot clean

