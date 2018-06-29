Miner-Automate-Test-Scripts

Usage:

	Set DDS238-2 ZN/S Power instrument ID value:
	cd ./set-dev-id/python2/3

	sudo ./set-device-id.py
	Prompting input current device id value: 1 ~ 247
	Prompting input setting new device id value: 1 ~ 247
	After running finish it will prompt done.

	Read Miner Power value and Miner debuglog messages:
	cd ./read-datas

	vim miner-options.conf
	Setting options

	./mds.sh
	After done it will generate cvs files and log files.
