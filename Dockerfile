FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    python3 \
    python3-setuptools \
    python3-pip \
    python3-venv \
    libcairo2-dev \
    pkg-config \
    python3-dev \
    python3-flask \
    python3-cairocffi \
    python3-mysql.connector \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install --no-cache-dir \
    pyserial==3.5 \
    pycairo==1.20.1 \
    mysql-connector-python==2.1.6

COPY . /var/www/pyhome

WORKDIR /var/www/pyhome

EXPOSE 8083

CMD ["python3", "server/http_admin/http_admin_demon.py"]