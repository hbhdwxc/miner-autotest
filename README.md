# miner-automate-test-scripts

Usage:

1、设置DDS238-2 ZN/S型多功能电能表设置ID：
进入目录set-device-id下有个脚本文件，执行脚本: sudo ./set-device-id.py，
提示输入当前设备ID的值，之后再次提示输入需要设置设备ID的值。
脚本执行完成后设备ID设置成功，同时可以通过查看多功能电能表设备ID值是否为设置值。

2、读取矿机信息（Log信息和功率）：
进入目录read-miner-info下，需要先对ip-freq-voltlevel.config文件进行修改，修改对应IP地址、频率和电压等级并保存。
执行脚本: ./auto-system.sh, 提示检测多功能电能表的DEVICE ID范围，先提示开始设备ID值，再提示结束设备ID值。
脚本执行完成后，会生成对应需要的.log和.csv文件。

Python3 running(defalut python2):
1. Install pyserial lib for python3
   git clone pyserial-lib
   sudo python3 setup.py install

2. Changed python file
   #!/usr/bin/env python2 -> #!/usr/bin/env python3
