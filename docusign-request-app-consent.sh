#!/usr/bin/bash

# 個別同意用のベースURI
CONSENT_URI="https://account-d.docusign.com/oauth/auth"

# OAuthの認証スコープ指定, インテグレーションキー, リダイレクトURI
REQUESTED_SCOPES="signature%20impersonation"
USER_KEY="${INTEGRATION_KEY:-}"
REDIRECT_URI="https://developers.docusign.com/platform/auth/consent"

echo "your input USER KEY : ${USER_KEY}"
start "${CONSENT_URI}?response_type=code&scope=${REQUESTED_SCOPES}&client_id=${USER_KEY}&redirect_uri=${REDIRECT_URI}"
