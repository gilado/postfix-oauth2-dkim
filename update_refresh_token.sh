#!/bin/bash
#
# This script reads the token file, calls Google to get a new access token, and
# if Google returns a new refresh token, updates both token files 
# (/etc/sasl-xoauth2/gmail-token.json and /etc/tokens/<gmail_account>).
#
# Usage: Run automatically via cron every few days to keep the token alive.
#
export GMAIL_ACCOUNT=$1
python3 << 'PYEOF'
import json
import requests
import os
from datetime import datetime

TOKEN_FILES = [
    '/etc/sasl-xoauth2/gmail-token.json',
    f'/etc/tokens/{os.environ["GMAIL_ACCOUNT"]}'
]

CA_BUNDLE = '/etc/pki/tls/certs/ca-bundle.crt'

# Read from first file
with open(TOKEN_FILES[0]) as f:
    tok = json.load(f)

r = requests.post('https://oauth2.googleapis.com/token', data={
    'client_id': tok['client_id'],
    'client_secret': tok['client_secret'],
    'refresh_token': tok['refresh_token'],
    'grant_type': 'refresh_token'
}, verify=CA_BUNDLE)

if r.status_code != 200:
    print(f"ERROR: {r.status_code} {r.json()}")
    exit(1)

new_token = r.json().get('refresh_token')
if new_token:
    tok['refresh_token'] = new_token

# Write to both files
for path in TOKEN_FILES:
    with open(path, 'w') as f:
        json.dump(tok, f, indent=2)
    os.chmod(path, 0o660)

print(f"{datetime.now()} Token refreshed successfully")
PYEOF

chown postfix:postfix /etc/sasl-xoauth2/gmail-token.json
chown postfix:postfix /etc/tokens/$GMAIL_ACCOUNT
echo "$(date) Updated refresh token"
