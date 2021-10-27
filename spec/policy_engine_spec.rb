require 'spec_helper.rb'

describe 'Network Access Control Policy Engine' do
  let(:secret_key) { 'testing' }
  let(:server_ip) { '10.5.0.5' }
  let(:radsec_proxy_ip) { '10.5.0.8' }

  before do
    db[:sites].insert(id: 1, tag: 'test_client', name: 'Some Site')
    db[:policies].insert(id: 1, name: 'First policy', description: 'First policy', fallback: false, rule_count: 1)
    db[:clients].insert({id: 1, shared_secret: 'test', ip_range: '10.5.0.6/32', site_id: 1})
    db[:site_policies].insert(site_id: 1, policy_id: 1, priority: 1)
    db[:responses].insert(response_attribute: 'Reply-Message', value: 'First Response', policy_id: 1)
  end

  it 'Gets a Fallback policy' do
    db[:policies].insert(id: 2, name: 'Fallback', description: 'Some fallback policy', fallback: true)
    db[:site_policies].insert(id: 2, site_id: 1, policy_id: 2)
    db[:responses].insert(response_attribute: 'Reply-Message', value: 'Fallback Policy', policy_id: 2)

    result = `eapol_test -t2 -c /test/config/eapol_test_tls.conf -a #{server_ip} -s #{secret_key} -N4:x:0x0a090807`

    expect(result).to include("Reply-Message")
    expect(result).to include("Value: 'Fallback Policy'")
  end

  it 'Prioritises policies' do
    db[:policies].insert(id: 2, name: 'Second policy', description: 'Second policy', fallback: false, rule_count: 1)
    db[:responses].insert(response_attribute: 'Reply-Message', value: 'Second Response', policy_id: 2)
    db[:rules].insert(operator: 'equals', value: 'user@example.org', policy_id: 1, request_attribute: 'User-Name')
    db[:rules].insert(operator: 'equals', value: 'user@example.org', policy_id: 2, request_attribute: 'User-Name')
    db[:site_policies].insert(site_id: 1, policy_id: 2, priority: 2)

    result = `eapol_test -t2 -c /test/config/eapol_test_tls.conf -a #{server_ip} -s #{secret_key}`

    expect(result).to include("Reply-Message")
    expect(result).to include("Value: 'First Response'")

    db[:site_policies].where(id: 2).update(priority: 1)
    db[:site_policies].where(id: 1).update(priority: 2)

    result = `eapol_test -t2 -c /test/config/eapol_test_tls.conf -a #{server_ip} -s #{secret_key}`

    expect(result).to include("Reply-Message")
    expect(result).to include("Value: 'Second Response'")
  end

  it 'supports "contains" syntax' do
    db[:rules].insert(operator: 'contains', value: 'example.org', policy_id: 1, request_attribute: 'User-Name')

    result = `eapol_test -t2 -c /test/config/eapol_test_tls.conf -a #{server_ip} -s #{secret_key}`

    expect(result).to include("Reply-Message")
    expect(result).to include("Value: 'First Response'")
  end

  it 'does not run the policy engine when TTLS tunnel is established, only for TLS authentication' do
    db[:responses].insert(response_attribute: 'Reply-Message', value: 'TTLS Policy Matched', policy_id: 1)
    db[:rules].insert(operator: 'equals', value: 'TTLS', policy_id: 1, request_attribute: 'EAP-Type')

    result = `eapol_test -t2 -c /test/config/eapol_test_tls_ttls.conf -a #{server_ip} -s #{secret_key}`

    expect(result).to_not include("Reply-Message")
    expect(result).to_not include("Value: 'TTLS Policy Matched'")
  end

  xcontext 'REJECT' do
    before do
      `openssl req -new -newkey rsa:4096 -nodes -keyout broken_cert.key -out broken_cert.csr -config /test/certs/client.cnf`
      `openssl x509 -req -sha256 -days 365 -in  broken_cert.csr -signkey broken_cert.key -out broken_cert.pem`
      `cat broken_cert.key >> broken_cert.pem`
      `cp broken_cert.pem /test/certs/broken_cert.pem`
    end

    it 'Does not change the outcome of a Reject in post auth' do
      result = `eapol_test -t2 -c /test/config/eapol_test_broken_cert.conf -a #{server_ip} -s #{secret_key}`
      expect(result).to match(/^SUCCESS$/)
    end
  end
end
