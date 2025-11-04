FROM python:3.12-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       tcpdump iptables iproute2 libpcap-dev \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir flask scapy paramiko

WORKDIR /app
COPY . /app

RUN mkdir -p /app/logs

CMD ["tail", "-f", "/dev/null"]

