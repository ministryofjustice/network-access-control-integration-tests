require 'spec_helper.rb'

describe 'Network Access Control Authentication Methods' do
  let(:secret_key) { 'testing' }
  let(:server_ip) { '10.5.0.5' }

  context 'EAP' do
    it 'Authenticates EAP-TLS' do
      test_command = 
      expect(test_command).to match(/^SUCCESS$/)`eapol_test -t2 -c /test/config/eapol_test_tls.conf -a #{server_ip} -s #{secret_key}`
    end

    it 'Authenticates EAP-TTLS and EAP-TLS as the inner authentication_method' do
      test_command = `eapol_test -t2 -c /test/config/eapol_test_tls_ttls.conf -a #{server_ip} -s #{secret_key}`
      expect(test_command).to match(/^SUCCESS$/)
    end


    context 'MAB' do
      let(:unauthorised_mac_address) { "55:44:33:22:11:00" }

      it 'Authenticates with MAC Address Bypass (MAB) without an EAP message' do
        test_command = `eapol_test -t2 -c /test/config/eapol_test_mab_no_eap.conf -a #{server_ip} -s #{secret_key} -M 00:11:22:33:44:55 -N30:s:00-11-22-33-44-55 `
        expect(test_command).to match(/^SUCCESS$/)
      end

      it 'Authenticates with MAC Address Bypass (MAB) within an EAP message' do
        test_command = `eapol_test -t2 -c /test/config/eapol_test_mab.conf -a #{server_ip} -s #{secret_key} -M 00:11:22:33:44:55 -N30:s:00-11-22-33-44-55 `
        expect(test_command).to match(/^SUCCESS$/)
      end

      it 'Does not authenticate with an unknown MAC Address (MAB)' do
        test_command = `eapol_test -t2 -c /test/config/eapol_test_mab.conf -a #{server_ip} -s #{secret_key} -M #{unauthorised_mac_address} -N30:s:00-11-22-33-44-55 `
        expect(test_command).to match(/^FAILURE$/)
      end
    end
  end

  context 'RADSEC' do
    let(:secret_key) { "radsec" }
    let(:server_ip) { '10.5.0.8' }

    it 'Establishes a RADSEC tunnel and does the authentication' do
      test_command = `eapol_test -r0 -t3 -c /test/config/eapol_test_radsecproxy.conf -a #{server_ip} -p18120 -s #{secret_key}`
      expect(test_command).to match(/^SUCCESS$/)
    end

    it 'Authenticates EAP-TLS' do
      test_command = `eapol_test -t2 -c /test/config/eapol_test_tls.conf -a #{server_ip} -p18120 -s #{secret_key} `
      expect(test_command).to match(/^SUCCESS$/)
    end

    it 'Authenticates EAP-TTLS and EAP-TLS as the inner authentication_method' do
      test_command = `eapol_test -t2 -c /test/config/eapol_test_tls_ttls.conf -a #{server_ip} -p18120 -s #{secret_key}`
      expect(test_command).to match(/^SUCCESS$/)
    end

    context 'MAB' do
      let(:unauthorised_mac_address) { "55:44:33:22:11:00" }

      it 'Authenticates with MAC Address Bypass (MAB)' do
        test_command = `eapol_test -t2 -c /test/config/eapol_test_mab.conf -a #{server_ip} -s #{secret_key} -p18120 -M 00:11:22:33:44:55 -N30:s:00-11-22-33-44-55`
        expect(test_command).to match(/^SUCCESS$/)
      end

      it 'Does not authenticate with an unknown MAC Address (MAB)' do
        test_command = `eapol_test -t2 -c /test/config/eapol_test_mab.conf -a #{server_ip} -s #{secret_key} -p18120 -M #{unauthorised_mac_address} -N30:s:00-11-22-33-44-55 `
        expect(test_command).to match(/^FAILURE$/)
      end
    end
  end

  context 'Revocation status' do
    it 'Does not authenticate with an OCSP revoked certificate' do
      test_command = `eapol_test -t2 -c /test/config/eapol_test_ocsp.conf -a #{server_ip} -s #{secret_key}`
      expect(test_command).to match(/^FAILURE$/)
    end

    it 'Does not authenticate with an CRL revoked certificate' do
      test_command = `eapol_test -t2 -c /test/config/eapol_test_crl.conf -a #{server_ip} -s #{secret_key}`
      expect(test_command).to match(/^FAILURE$/)
    end
  end
end
