#!/bin/bash -e

cleanup_dummy0() {
    echo "Deleting interface dummy0"
    ip link del dummy0
    echo "Cleanup complete"
}

link=$(ip -br link | awk '{print $1}' | tail -n +2 | head -n 1 | cut -f1 -d@)
echo "Detected link $link"
ipv4=$(ip -4 -br addr show dev $link | awk '{print $3}' | cut -f1 -d/)
echo "Detected IPv4 address $ipv4"
ipv6=$(ip -6 -br addr show dev $link | awk '{print $3}' | cut -f1 -d/)
echo "Detected IPv6 address $ipv6"

echo 'Writing gobgpd.conf'
mkdir -p /gobgp
cat >/gobgp/gobgpd.conf <<EOF
[global.config]
  as = $SA_LOCAL_AS
  router-id = "$ipv4"
EOF

if [ ! -z ${SA_CONFED+x} ]
then
    cat >>/gobgp/gobgpd.conf <<EOF
  [global.confederation.config]
    enabled = true
    identifier = $SA_CONFED
    member-as-list = [ $SA_PEER_AS ]
EOF
fi

cat >>/gobgp/gobgpd.conf <<EOF
[[neighbors]]
  [neighbors.config]
    neighbor-address = "$SA_NEIGHBOR"
    peer-as = $SA_PEER_AS
  [neighbors.timers.config]
    connect-retry = 5
  [[neighbors.afi-safis]]
    [neighbors.afi-safis.config]
      afi-safi-name = "ipv4-unicast"
  [[neighbors.afi-safis]]
    [neighbors.afi-safis.config]
      afi-safi-name = "ipv6-unicast"
EOF

echo 'Creating dummy interface dummy0'
ip link add dummy0 type dummy
echo 'Bringing up dummy0'
ip link set dummy0 up
trap cleanup_dummy0 EXIT
echo "Assigning $SA_IPV4/32 to dummy0"
ip addr add "$SA_IPV4"/32 dev dummy0
echo "Assigning $SA_IPV6/128 to dummy0"
ip addr add "$SA_IPV6"/128 dev dummy0
echo 'Dropping CAP_NET_ADMIN'
exec capsh --drop=cap_net_admin \
    -- -c "/run-gobgp.sh \"$link\" \"$ipv4\" \"$ipv6\""
