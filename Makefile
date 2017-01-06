include common.mk

all:
	make -C workerbase
	make -C buildworker

clean:
	make -C buildworker clean
	make -C workerbase clean
