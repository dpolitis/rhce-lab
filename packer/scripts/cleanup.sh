#!/bin/bash -eux

#stop logging services
service rsyslog stop
service auditd stop

#remove old kernels
package-cleanup --oldkernels --count=1 -y

#clean yum cache
yum clean all

#force logrotate to shrink logspace and remove old logs as well as truncate logs
logrotate -f /etc/logrotate.conf
rm -f /var/log/*-???????? /var/log/*.gz
rm -f /var/log/dmesg.old
rm -rf /var/log/anaconda
cat /dev/null > /var/log/audit/audit.log
cat /dev/null > /var/log/wtmp
cat /dev/null > /var/log/lastlog
cat /dev/null > /var/log/grubby

#remove udev hardware rules
rm -f /etc/udev/rules.d/70*

#remove uuid from ifcfg scripts
grep -v HWADDR /etc/sysconfig/network-scripts/ifcfg-eth0 > /tmp/ifcfg-eth0
mv -f /tmp/ifcfg-eth0 /etc/sysconfig/network-scripts/ifcfg-eth0
sed -i".bak" '/UUID/d' /etc/sysconfig/network-scripts/ifcfg-eth0 

#remove SSH host keys
rm -f /etc/ssh/*key*

#remove root users shell history
rm -f ~root/.bash_history
unset HISTFILE

#remove root users SSH history
rm -rf ~root/.ssh/

# Zero out the rest of the free space using dd, then delete the written file.
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

# Add `sync` so Packer doesn't quit too early, before the large file is deleted.
sync
