#!/bin/bash
arc=$(uname -a)
pcpu=$(grep "physical id" /proc/cpuinfo | sort | uniq | wc -l)
vcpu=$(grep -c "^processor" /proc/cpuinfo)
tcpu=$(sensors | awk '$1 == "Package" {print $4}')
fram=$(free -m | awk '$1 == "Mem:" {print $2}')
uram=$(free -m | awk '$1 == "Mem:" {print $3}')
pram=$(free | awk '$1 == "Mem:" {printf("%.2f"), $3/$2*100}')
fdisk=$(df -Bg | grep '^/dev/' | grep -v '/boot$' | awk '{ft += $2} END {print ft}')
udisk=$(df -Bg | grep '^/dev/' | grep -v '/boot$' | awk '{ut += $3} END {print ut}')
pdisk=$(df -Bg | grep '^/dev/' | grep -v '/boot$' | awk '{ut += $3} {ft+= $2} END {printf("%.2f"), ut/ft*100}')
cpul=$(top -bn1 | grep '^%Cpu' | cut -c 9- | xargs | awk '{printf("%.1f%%"), $1 + $3}')
lb=$(who -b | awk '$1 == "system" {print $3 " " $4 " " $5 }')
ut=$(uptime -p)
praid=$(lsblk | grep -c "raid")
praidu=$(if [ "$praid" -eq 0 ]; then echo no; else echo yes; fi)
hdd1t=$(hddtemp SATA:/dev/sda | awk '$1 == "/dev/sda:" {print $4 "C"}')
hdd2t=$(hddtemp SATA:/dev/sdb | awk '$1 == "/dev/sdb:" {print $4 "C"}')
#You need to install net tools for the next step [$ sudo apt install net-tools]
ctcp=$(cat /proc/net/sockstat{,6} | awk '$1 == "TCP:" {print $3}')
cudp=$(cat /proc/net/sockstat{,6} | awk '$1 == "UDP:" {print $3}')
ulog=$(users | wc -w)
ip=$(hostname -I)
mac=$(ip link show | awk '$1 == "link/ether" {print $2}' | tr '\n' ' ')
cmds=$(journalctl _COMM=sudo | grep -c COMMAND) # journalctl should be running as sudo but our script is running as root so we don't need in sudo here
wall "#Architecture: $arc
        #CPU physical: $pcpu
        #vCPU: $vcpu
        #CPU temperature: $tcpu
        #Memory Usage: $uram/${fram}MB ($pram%)
        #Disk Usage: $udisk/${fdisk}GB ($pdisk%)
        #CPU load: $cpul
        #Last boot: $lb, running $ut
        #Programm RAID use: $praidu
        #HDD1 temperature: $hdd1t
        #HDD2 temperature: $hdd2t
        #Connections: TCP: $ctcp UDP: $cudp ESTABLISHED
        #User log: $ulog
        #Network: IP $ip (${mac::-1})
        #Sudo: $cmds cmd" # broadcast our system information on all terminals