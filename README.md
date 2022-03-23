# The Sesquialtera Network on DN42

This repository contains source code and configuration for the
[Sesquialtera Network] (AS4242420703) on the [DN42] dynamic VPN.

For more information on the network and its design, see
[this page][Sesquialtera Network details].

## What is in this repository?

Configuration is primarily managed with [Ansible]. All of that lives
in the `ansible` subdirectory.

[Prometheus] is used for monitoring and [Grafana] is used for
visualizing the data. The `grafana` subdirectory contains my dashboards
exported to JSON, in case I ever need to reinstall Grafana.

The `src` subdirectory contains the source code for various utilities
I use. Currently, the only thing there is the source for a
`service-advertisement` Docker image, used to inject a dummy network
interface into another Docker container and advertise its addresses into
BGP. (In particular, this is used to run anycast services.)

[Ansible]: https://www.ansible.com/
[Grafana]: https://grafana.com/
[DN42]: https://dn42.us/
[Prometheus]: https://prometheus.io/
[Sesquialtera Network]: https://dn42.sesquialtera.net/
[Sesquialtera Network details]: https://dn42.sesquialtera.net/about.html
