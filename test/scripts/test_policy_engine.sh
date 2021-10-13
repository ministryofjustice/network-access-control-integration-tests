#!/bin/bash

populate_test_data() {
  mysql -u${DB_USER} -p${DB_PASS} -h${DB_HOST} ${DB_NAME} < /test/policy_engine_data/test_matching_policy.sql
}

populate_test_contains_data() {
  mysql -u${DB_USER} -p${DB_PASS} -h${DB_HOST} ${DB_NAME} < /test/policy_engine_data/test_contains_policy.sql
}

populate_test_ttls_data() {
  mysql -u${DB_USER} -p${DB_PASS} -h${DB_HOST} ${DB_NAME} < /test/policy_engine_data/test_ttls_policy_not_run.sql
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

test_contains_policy() {
  eapol_test -r0 -t3 -c /test/config/eapol_test_tls_ttls.conf -a 10.5.0.5 -s testing
}

test_policy_engine_not_run_on_ttls_only_tls() {
  eapol_test -r0 -t3 -c /test/config/eapol_test_tls_ttls.conf -a 10.5.0.5 -s testing
}

assert_policy_result() {
  grep "Attribute 64 (Tunnel-Type) length=6" /integration-results-policy
  grep "Value: 0000000d" /integration-results-policy
  grep "Attribute 65 (Tunnel-Medium-Type) length=6" /integration-results-policy
  grep "Value: 00000006" /integration-results-policy
  grep "Attribute 81 (Tunnel-Private-Group-Id) length=5" /integration-results-policy
  grep "Value: 373737" /integration-results-policy
}

assert_prioritised_policy_result() {
  grep "Attribute 18 (Reply-Message) length=24" /integration-results-priority
  grep "Value: 'Prioritised Policy hit'"  /integration-results-priority
}

assert_fallback_policy_result() {
  grep "Attribute 18 (Reply-Message) length=17" /integration-results-fallback
  grep "Value: 'Fallback Policy'" /integration-results-fallback
}

assert_contains_policy_result() {
  grep "Attribute 18 (Reply-Message) length=25" /integration-results-contains
  grep "Value: 'Contains Policy Matched'" /integration-results-contains
}

assert_policy_engine_does_not_run_for_ttls() {
  grep -v "Attribute 18 (Reply-Message) length=21" /integration-results-ttls
  grep -v "Value: 'TTLS Policy Matched'" /integration-results-ttls
}

main() {
  populate_test_data
  test_matching_policy > /integration-results-policy
  assert_policy_result
  
  test_fallback_policy > /integration-results-fallback
  assert_fallback_policy_result

  update_policy_priority
  test_matching_policy > /integration-results-priority
  assert_prioritised_policy_result

  # test_postauth_reject > /integration-results
  # assert_fallback_policy_result

  populate_test_contains_data
  test_contains_policy > /integration-results-contains
  assert_contains_policy_result

  populate_test_ttls_data
  test_policy_engine_not_run_on_ttls_only_tls > /integration-results-ttls
  assert_policy_engine_does_not_run_for_ttls
}

main
