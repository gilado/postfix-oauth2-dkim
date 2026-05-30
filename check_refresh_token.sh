#!/bin/bash
#
# This script reads the token file and calls Google's OAuth2 endpoint
# to test whether the refresh token is still valid. 
#
# Prints the HTTP response code and response body.
#
# Usage: When diagnosing authentication failures, reports whether the
# refresh token is valid (200) or revoked (400 invalid_grant).
#
python3 << 'EOF'
import json, requests

with open('/etc/sasl-xoauth2/gmail-token.json') as f:
    tok = json.load(f)

r = requests.post('https://oauth2.googleapis.com/token', data={
    'client_id': tok['client_id'],
    'client_secret': tok['client_secret'],
    'refresh_token': tok['refresh_token'],
    'grant_type': 'refresh_token'
}, verify='/etc/pki/tls/certs/ca-bundle.crt')

print(r.status_code, r.json())
EOF
