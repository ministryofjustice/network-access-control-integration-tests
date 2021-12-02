#! /usr/bin/env python3

import policyengine

payload = (('EAP-Type', 'TLS'))
result = policyengine.post_auth(payload)
print(result)
assert result == ()
