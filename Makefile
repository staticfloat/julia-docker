all:
	make -C buildworker
	make -C workerbase

clean:
	make -C buildworker clean
	make -C workerbase clean
