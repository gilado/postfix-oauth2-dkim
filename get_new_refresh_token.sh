#!/bin/bash
#
# This script runs the authorization flow to obtain a brand new refresh token.
# Opens a browser for the user to log into Google and grant access.
# Prints the refresh token to the terminal.
#
# Usage: When setting up for the first time, or when the refresh token has been
# revoked and you need to re-authorize. Must be run on a machine with a browser.
#
# Before running for the first time you may need to install
#
# pip3 install google-auth-oauthlib
#
# Verify or correct the location of ca-bundle.crt
#
REQUESTS_CA_BUNDLE=/etc/pki/tls/certs/ca-bundle.crt python3 - <<'EOF'
from google_auth_oauthlib.flow import InstalledAppFlow
flow = InstalledAppFlow.from_client_secrets_file(
    'client_secret.json',
    scopes=['https://mail.google.com/']
)
creds = flow.run_local_server(port=0)
print("REFRESH TOKEN:", creds.refresh_token)
EOF
