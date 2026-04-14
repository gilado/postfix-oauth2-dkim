# Postfix with OAuth2 & DKIM on PCLinuxOS

## Background

I run an old mail server that lacks some newer additions such as OAuth2 authentication when relaying through another SMTP server, and DKIM signing of outgoing mail. Over time, other mail servers stopped accepting my outgoing emails due to missing DKIM signatures. My workaround was to relay through `smtp.gmail.com` using basic authentication (username/password) — until Google disabled that authentication method, at which point my emails stopped going through entirely.

## Solution

Run **Postfix** on the same machine as the mail server. Postfix supports OAuth2 via the **sasl-xoauth2** plugin.
DKIM signing of outgoing mail is also implemented using **perl-Mail-DKIM**.

### Components

| Component | Purpose | Available in PCLinuxOS repo |
|---|---|---|
| Postfix | SMTP relay with OAuth2 support | ✅ Yes |
| perl-Mail-DKIM | DKIM signing of outgoing mail | ✅ Yes |
| sasl-xoauth2 | OAuth2 SASL plugin for Postfix | ❌ No (build from source) |

> **Note:** Although `sasl-xoauth2` is not in the PCLinuxOS repository, all of its dependencies are — making it straightforward to build and install from source.

## About This Guide

This guide documents the full setup process as a reference for future reinstallation.
