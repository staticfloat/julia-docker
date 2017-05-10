include common.mk

all:
	make -C workerbase
	make -C tabularasa
	make -C buildworker

clean:
	make -C buildworker clean
	make -C workerbase clean
	make -C tabularasa clean
	make -C buildbot clean
