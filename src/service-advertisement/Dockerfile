FROM alpine:3.15.2

RUN apk add --no-cache bash bind-tools iproute2 libcap
RUN mkdir /usr/local/sbin \
    && (wget -O - https://github.com/osrg/gobgp/releases/download/v3.0.0/gobgp_3.0.0_linux_amd64.tar.gz \
        | tar -C /usr/local/sbin -zxf - gobgp gobgpd)
COPY entrypoint.sh run-gobgp.sh /

ENTRYPOINT ["/entrypoint.sh"]
