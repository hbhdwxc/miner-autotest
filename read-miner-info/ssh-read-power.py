#!/usr/bin/env python

from __future__ import print_function
import telnetlib
import sys
import time
import paramiko

def ssh_read_power(ip):
    passwd = '1'
    retry = 3
    for i in range(0, retry):
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        for k in range(0, retry):
            try:
                ssh.connect(ip, 22, 'root', passwd)
                break
            except:
                ssh.close()
                if k == retry - 1:
                    return None
        try:
            stdin, stdout, stderr = ssh.exec_command(
                'python /root/read-power.py')
            time.sleep(2)
        except:
            ssh.close()
            continue

        ssh.close()
        break

if __name__ == '__main__':
    ip = sys.argv[1]

    # Remote read power
    ssh_read_power(ip)
