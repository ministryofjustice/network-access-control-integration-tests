#!/bin/bash

test_eap_tls() {
  eapol_test -r0 -t3 -c /test/config/eapol_test_tls.conf -a 10.5.0.5 -s testing

  if [ $? -ne 0 ]; then
    exit $?
  fi
}

test_eap_tls_ttls() {
  eapol_test -r0 -t3 -c /test/config/eapol_test_tls_ttls.conf -a 10.5.0.5 -s testing

  if [ $? -ne 0 ]; then
    exit $?
  fi
}

test_mab() {
  eapol_test -r0 -t3 -c /test/config/eapol_test_mab.conf -a 10.5.0.5 -s testing -M 00:11:22:33:44:55 -N30:s:00-11-22-33-44-55 #custom attr Called-Station-Id 

  if [ $? -ne 0 ]; then
    exit $?
  fi
}

test_mab_with_unauthorised_mac_address() {
  unauthorised_mac_address="55:44:33:22:11:00"
  eapol_test -r0 -t3 -c /test/config/eapol_test_mab.conf -a 10.5.0.5 -s testing -M ${unauthorised_mac_address} -N30:s:55-44-33-22-11-00 > /dev/null 

  if [[ $? == 252 ]]; then
    echo "SUCCESS"
  else
    echo "FAILURE"
  fi
}

test_crl() {
  eapol_test -r0 -t3 -c /test/config/eapol_test_crl.conf -a 10.5.0.5 -s testing >> /dev/null

  if [ $? == 252 ]; then
    echo "SUCCESS" 
  else
    echo "FAILURE" 
  fi
}

test_radsecproxy() {
  eapol_test -r0 -t3 -c /test/config/eapol_test_radsecproxy.conf -a 10.5.0.8 -p18120 -s radsec
}

assert_result() {
  echo "Results:"
  cat /results

  cat /results |grep "FAILURE"

  if [ $? == 0 ]; then
    exit 1
  fi
}

main() {
  test_eap_tls |grep '^SUCCESS$\|^FAILURE$' > /results
  test_eap_tls_ttls |grep '^SUCCESS$\|^FAILURE$' >> /results
  test_mab |grep '^SUCCESS$\|^FAILURE$' >> /results
  test_mab_with_unauthorised_mac_address |grep '^SUCCESS$\|^FAILURE$' >> /results
  test_radsecproxy |grep '^SUCCESS$\|^FAILURE$' >> /results
  # test_crl |grep '^SUCCESS$\|^FAILURE$' >> /results

  assert_result
}

main