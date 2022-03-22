#!/bin/bash

set -e

prefix=/etc/raddb/

append_ocsp_endpoints() {
  echo "authorityInfoAccess = OCSP;URI:http://www.example.com:8080" >> ca.cnf
}

generate_certs() {
  make
}

generate_revoked_client_certs() {
  # generate crl pem file
  openssl ca -batch -gencrl -keyfile ca.key -cert ca.pem -config ca.cnf -passin pass:"whatever" -out crl.pem

  # create a revoked crl certificate
  if ! [ -f $prefix/certs/revoked_client_crl.pem ]; then
    openssl req -batch -passin pass:"whatever" -config client_crl.cnf -new -nodes -keyout client_crl.key -out client_crl.csr
    openssl ca  -batch -passin pass:"whatever" -config ca.cnf -in client_crl.csr -out revoked_client_crl.pem -keyfile ca.key -cert ca.pem

    cat client_crl.key >> revoked_client_crl.pem

    openssl ca -batch -revoke revoked_client_crl.pem -keyfile ca.key -cert ca.pem -config ca.cnf -passin pass:"whatever"

    # regenerate crl pem file
    openssl ca -batch -gencrl -keyfile ca.key -cert ca.pem -config ca.cnf -passin pass:"whatever" -out crl.pem
  fi

  # create a revoked ocsp certificate
  if ! [ -f $prefix/certs/revoked_client_ocsp.pem ]; then
    openssl req -batch -passin pass:"whatever" -config client_ocsp.cnf -new -nodes -keyout client_ocsp.key -out client_ocsp.csr
    openssl ca  -batch -passin pass:"whatever" -config ca.cnf -in client_ocsp.csr -out revoked_client_ocsp.pem -keyfile ca.key -cert ca.pem

    cat client_ocsp.key >> revoked_client_ocsp.pem

    # generate ocsp
    openssl req -new -nodes -out ocsp.csr -keyout ocsp.key -config ocsp.cnf
    openssl ca -batch -passin pass:"whatever" -config ocsp.cnf -in ocsp.csr -out ocsp.pem -keyfile ca.key -cert ca.pem

    cat ocsp.key >> ocsp.pem

    # revoke certificate
    openssl ca -batch -revoke revoked_client_ocsp.pem -keyfile ca.key -cert ca.pem -config ca.cnf -passin pass:"whatever"
  fi
}

main() {
  append_ocsp_endpoints
  generate_certs
  generate_revoked_client_certs
  sleep infinity
}

main
