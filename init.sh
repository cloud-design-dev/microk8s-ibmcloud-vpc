#!/usr/bin/env bash

set -eu

# All the code is wrapped in a main function that gets called at the bottom of the file.
main() {
    LOGFILE="/tmp/packer-installer.log"

    echo "Hello from Packer template: `hostname -s`" | tee -a "$LOGFILE"

# disable the auto update
systemctl stop apt-daily.service
systemctl kill --kill-who=all apt-daily.service

# wait until `apt-get updated` has been killed
while ! (systemctl list-units --all apt-daily.service | egrep -q '(dead|failed)')
do
  sleep 1;
done

## Update the package list and upgrade all packages.
    export NEEDRESTART_MODE=a
    export DEBIAN_FRONTEND=noninteractive
    export DEBIAN_PRIORITY=critical
    apt-get -qy clean
    apt-get -qy update
    apt-get -qy -o "Dpkg::Options::=--force-confdef" -o "Dpkg::Options::=--force-confold" upgrade
    apt-get -qy -o "Dpkg::Options::=--force-confdef" -o "Dpkg::Options::=--force-confold" install linux-headers-$(uname -r) curl wget apt-transport-https ca-certificates software-properties-common

## Add DNS updates 
cat > /etc/netplan/99-custom-dns.yaml << EOF
network:
  version: 2
  ethernets:
    ens3:
      nameservers:
        addresses: [ "161.26.0.10", "161.26.0.11" ]
      dhcp4-overrides:
        use-dns: false
EOF

netplan apply

dhclient -v -r; dhclient -v

echo "Installation complete!"

}

main