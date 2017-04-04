FROM buildpack-deps:jessie-curl
LABEL maintainer="Hugo Areias <hugo@moonfruit.com>"
LABEL based-on1="tutum/influxdb" \
      based-on2="library/influxdb"

RUN useradd -r -U influxdb

RUN gpg \
    --keyserver hkp://ha.pool.sks-keyservers.net \
--recv-keys 05CE15085FC09D18E99EFB22684A14CF2582E0C5

# Install InfluxDB
ENV INFLUXDB_VERSION 1.2.2
RUN wget -q https://dl.influxdata.com/influxdb/releases/influxdb_${INFLUXDB_VERSION}_amd64.deb.asc && \
    wget -q https://dl.influxdata.com/influxdb/releases/influxdb_${INFLUXDB_VERSION}_amd64.deb && \
    gpg --batch --verify influxdb_${INFLUXDB_VERSION}_amd64.deb.asc influxdb_${INFLUXDB_VERSION}_amd64.deb && \
    dpkg -i influxdb_${INFLUXDB_VERSION}_amd64.deb && \
    rm -f influxdb_${INFLUXDB_VERSION}_amd64.deb* && \
    rm -rf /var/lib/apt/lists/*

COPY influxdb_config.toml /etc/influxdb/influxdb_config.toml
ADD run.sh /run.sh
RUN chmod +x /*.sh

ENV PRE_CREATE_DB **None**

# HTTP API
EXPOSE 8086

# InfluxDB healthcheck
HEALTHCHECK CMD curl -sl -I -f localhost:8086/ping || exit 1

VOLUME ["/var/lib/influxdb", "/etc/influxdb"]

ENTRYPOINT ["/run.sh", "-config", "/etc/influxdb/influxdb_config.toml"]
