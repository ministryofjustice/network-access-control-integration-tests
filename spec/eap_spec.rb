require 'spec_helper.rb'

describe 'Network Access Control Authentication Methods' do
  let(:secret_key) { 'testing' }
  let(:server_ip) { '10.5.0.5' }
  let(:radsec_proxy_ip) { '10.5.0.8' }

  context 'EAP' do
    it 'Authenticates EAP-TLS' do
      test_command = `eapol_test -t2 -c /test/config/eapol_test_tls.conf -a #{server_ip} -s #{secret_key}`
      expect(test_command).to match(/^SUCCESS$/)
    end

    it 'Authenticates EAP-TTLS and EAP-TLS as the inner authentication_method' do
      test_command = `eapol_test -t2 -c /test/config/eapol_test_tls_ttls.conf -a #{server_ip} -s #{secret_key}`
      expect(test_command).to match(/^SUCCESS$/)
    end

    xit 'CRL'

    context 'RADSEC' do
      it 'Establishes a RADSEC tunnel and does the authentication' do
        test_command = `eapol_test -r0 -t3 -c /test/config/eapol_test_radsecproxy.conf -a #{radsec_proxy_ip} -p18120 -s radsec`
        expect(test_command).to match(/^SUCCESS$/)
      end
    end
  end

  context 'MAB' do
    let(:unauthorised_mac_address) { "55:44:33:22:11:00" }

    it 'Authenticates with Mac Address Bypass (MAB)' do
      test_command = `eapol_test -t2 -c /test/config/eapol_test_mab.conf -a #{server_ip} -s #{secret_key} -M 00:11:22:33:44:55 -N30:s:00-11-22-33-44-55 `
      expect(test_command).to match(/^SUCCESS$/)
    end

    it 'Does not authenticate with an unknown Mac Address (MAB)' do
      test_command = `eapol_test -t2 -c /test/config/eapol_test_mab.conf -a #{server_ip} -s #{secret_key} -M #{unauthorised_mac_address} -N30:s:00-11-22-33-44-55 `
      expect(test_command).to match(/^FAILURE$/)
    end
  end
end
