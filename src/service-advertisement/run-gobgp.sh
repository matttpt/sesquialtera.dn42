#!/bin/bash -e

cleanup_dummy0() {
    echo "Deleting interface dummy0"
    ip link del dummy0
    echo "Cleanup complete"
}

trap cleanup_dummy0 EXIT

link="$1"
ipv4="$2"
ipv6="$3"

echo 'Starting gobgpd'
gobgpd --config-file=/gobgp/gobgpd.conf &
sleep 1

if [ ! -z ${SA_HEALTHCHECK_COMMAND+x} ]
then
    fail_count=$(($SA_HEALTHCHECK_MAX_FAIL_COUNT+1))
    while :
    do
        if [ ! -d "/sys/class/net/$link" ]
        then
            echo 'The original network interface is gone; shutting down'
            exit 1
        fi

        if timeout -s KILL "$SA_HEALTHCHECK_TIMEOUT" sh -c "$SA_HEALTHCHECK_COMMAND"
        then
            if (( fail_count > 0 ))
            then
                echo 'The service appears to be back up; restoring advertisements'
                gobgp global rib add -a ipv4 "$SA_IPV4/32" nexthop "$ipv4"
                gobgp global rib add -a ipv6 "$SA_IPV6/128" nexthop "$ipv6"
            fi
            fail_count=0
        else
            fail_count=$((fail_count+1))
            if (( fail_count < SA_HEALTHCHECK_MAX_FAIL_COUNT ))
            then
                echo "Health check failed ($fail_count/$SA_HEALTHCHECK_MAX_FAIL_COUNT)"
            elif (( fail_count == SA_HEALTHCHECK_MAX_FAIL_COUNT ))
            then
                echo "Now $fail_count health checks have failed; disabling advertisements"
                gobgp global rib del -a ipv4 "$SA_IPV4/32" nexthop "$ipv4"
                gobgp global rib del -a ipv6 "$SA_IPV6/128" nexthop "$ipv6"
            fi
        fi
        sleep "$SA_HEALTHCHECK_INTERVAL"
    done
else
    gobgp global rib add -a ipv4 "$SA_IPV4/32" nexthop "$ipv4"
    gobgp global rib add -a ipv6 "$SA_IPV6/128" nexthop "$ipv6"
    while :
    do
        if [ ! -d "/sys/class/net/$link" ]
        then
            echo 'The original network interface is gone; shutting down'
            exit 1
        fi
        sleep 15
    done
fi
wait
