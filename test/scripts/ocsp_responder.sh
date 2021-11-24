#!/bin/sh

cd test/certs
openssl ocsp -port 8080 -index index.txt -rsigner ocsp.pem -rkey ocsp.key -CA ca.pem -text -out /tmp/ocsp.log &
