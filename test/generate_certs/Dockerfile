FROM alpine:3.18.4

ENV TZ UTC
ENV PYTHONUNBUFFERED=1

RUN apk update && apk upgrade && apk --no-cache --update add --virtual \
    build-dependencies gnupg && \
    apk --no-cache add tzdata nettle-dev openssl-dev curl \
    bash wpa_supplicant make freeradius freeradius-eap \
    openssl build-base gcc libc-dev

COPY client_crl.cnf /etc/raddb/certs
COPY client_ocsp.cnf /etc/raddb/certs
COPY xpextensions /etc/raddb/certs
COPY ocsp.cnf /etc/raddb/certs
COPY bootstrap.sh /

WORKDIR /etc/raddb/certs
