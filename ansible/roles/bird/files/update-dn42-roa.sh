#!/bin/sh -e

sudo -nu bird sh -c "umask 077 && wget -qNP /etc/bird https://dn42.burble.com/roa/dn42_roa_bird2_4.conf"
sudo -nu bird sh -c "umask 077 && wget -qNP /etc/bird https://dn42.burble.com/roa/dn42_roa_bird2_6.conf"
sudo -nu bird sh -c "systemctl is-active --quiet bird && birdc configure >/dev/null"
