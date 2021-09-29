#!/bin/bash

populate_test_data() {
  mysql -u${DB_USER} -p${DB_PASS} -h${DB_HOST} ${DB_NAME} < /test/policy_engine_data/test_matching_policy.sql
}

update_policy_priority() {
  mysql -u${DB_USER} -p${DB_PASS} -h${DB_HOST} ${DB_NAME} -e "UPDATE site_policies SET priority = 1 where id = 3;"
}

test_matching_policy() {
  eapol_test -r0 -t3 -c /test/config/eapol_test_tls.conf -a 10.5.0.5 -s testing
}

test_fallback_policy() {
  eapol_test -r0 -t3 -c /test/config/eapol_test_tls.conf -a 10.5.0.5 -s testing \
  -N4:x:0x0a090807 # random octet IP address to cause fallback to initiate 
}

test_postauth_reject() {
  # broken copied client cert can be used to reject the authorisation
  openssl req -new -newkey rsa:4096 -nodes -keyout broken_cert.key -out broken_cert.csr -config /test/certs/client.cnf
  openssl x509 -req -sha256 -days 365 -in  broken_cert.csr -signkey broken_cert.key -out broken_cert.pem
  cat broken_cert.key >> broken_cert.pem
  cp broken_cert.pem /test/certs/broken_cert.pem
  eapol_test -r0 -t3 -c /test/config/eapol_test_broken_cert.conf -a 10.5.0.5 -s testing 
} 

assert_policy_result() {
  grep "Attribute 64 (Tunnel-Type) length=6" /integration-results
  grep "Value: 0000000d" /integration-results
  grep "Attribute 65 (Tunnel-Medium-Type) length=6" /integration-results
  grep "Value: 00000006" /integration-results
  grep "Attribute 81 (Tunnel-Private-Group-Id) length=5" /integration-results
  grep "Value: 373737" /integration-results
}

assert_prioritised_policy_result() {
  grep "Attribute 18 (Reply-Message) length=24" /integration-results
  grep "Value: 'Prioritised Policy hit'"  /integration-results
}

assert_fallback_policy_result() {
  grep "Attribute 18 (Reply-Message) length=17" /integration-results
  grep "Value: 'Fallback Policy'" /integration-results
}

main() {
  # populate_test_data
  # test_matching_policy > /integration-results
  # assert_policy_result
  
  # test_fallback_policy >> /integration-results
  # assert_fallback_policy_result

  # update_policy_priority
  # test_matching_policy >> /integration-results
  # assert_prioritised_policy_result

  test_postauth_reject >> /integration-results
  assert_fallback_policy_result
}

main