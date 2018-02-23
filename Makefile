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

# This is useful when we are on a system where we can't install ruby, like the powerpc buildbot
bootstrap:
	cd harbordock && docker build -t staticfloat/harbordock .
	docker run -u $(shell id -u):$(shell id -g) -v $(shell pwd):/app -w /app -ti staticfloat/harbordock make
