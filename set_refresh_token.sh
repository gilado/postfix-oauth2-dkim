#!/bin/bash
#
# Creates the Gmail OAuth2 token files required by sasl-xoauth2 and Postfix.
# Reads client_id and client_secret from client_secret.json in the current directory.
# Writes token to both /etc/sasl-xoauth2/gmail-token.json and /etc/tokens/<account>.
#
# Usage: set_gmail_token.sh <gmail_account> <refresh_token>
#
# Example: set_refresh_token.sh name@gmail.com 1//0g...
#
# Nore: Run get_new_refresh_token.sh first to obtain the refresh token.
#

export GMAIL_ACCOUNT=$1
export REFRESH_TOKEN=$2

if [ -z "$GMAIL_ACCOUNT" ] || [ -z "$REFRESH_TOKEN" ]; then
    echo "Usage: $0 <gmail_account> <refresh_token>"
    exit 1
fi

if [ ! -f client_secret.json ]; then
    echo "ERROR: client_secret.json not found in current directory"
    exit 1
fi

python3 << 'PYEOF'
import json, os

with open('client_secret.json') as f:
    secret = json.load(f)

# client_secret.json structure has a top-level key (e.g. "installed" or "web")
creds = list(secret.values())[0]
client_id = creds['client_id']
client_secret = creds['client_secret']

token = {
    "client_id": client_id,
    "client_secret": client_secret,
    "refresh_token": os.environ['REFRESH_TOKEN']
}

token_files = [
    '/etc/sasl-xoauth2/gmail-token.json',
    f'/etc/tokens/{os.environ["GMAIL_ACCOUNT"]}'
]

os.makedirs('/etc/sasl-xoauth2', exist_ok=True)
os.makedirs('/etc/tokens', exist_ok=True)

for path in token_files:
    with open(path, 'w') as f:
        json.dump(token, f, indent=2)
    os.chmod(path, 0o660)
    print(f"Written: {path}")

PYEOF

chown postfix:postfix /etc/sasl-xoauth2/gmail-token.json
chown postfix:postfix /etc/tokens/$GMAIL_ACCOUNT
echo "Done."
