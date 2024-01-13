#!/usr/bin/bash

set -eo pipefail

# 設定ファイルの配置先フォルダ
conf="./docusign_config"

# DocuSign ユーザーID, 作成したapp integration keyを持つ各ファイル読み込み
user_id="$(cat ${conf}/docusign_user_id.txt)"
integration_key="$(cat ${conf}/signature_demo_integration_key.txt)"
account_uri="account-d.docusign.com"

# OAuth のscope設定, トークン有効期間(unix time, 3600sec=1h)
scope="signature impersonation"
expire_seconds="3600"

# DocuSignアカウントで作成したapp integration の RSA キーファイル読み込み
private_key="${conf}/rsa_key_file"

# JWT のheader, payloadの各情報
header='{
  "alg": "RS256",
  "typ": "JWT"
}'
payload="{
  \"iss\": \"${integration_key}\",
  \"sub\": \"${user_id}\",
  \"aud\": \"${account_uri}\",
  \"iat\": $(date +%s),
  \"exp\": $(($(date +%s)+expire_seconds)),
  \"scope\": \"${scope}\"
}"

base64_urlencode() { openssl enc -base64 -A | tr '+/' '-_' | tr -d '='; }

# JWT Token生成
header_base64=$(printf %s "$header" | base64_urlencode)
payload_base64=$(echo -n "$payload" | base64_urlencode)
signed_content="${header_base64}.${payload_base64}"
signature=$(printf %s "$signed_content" | openssl dgst -sha256 -sign "$private_key" | base64_urlencode)
web_token=$(printf %s "${signed_content}.${signature}")

# OAuth トークン発行依頼 REST APIをたたく
curl -s \
  --data "grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=$web_token" \
  --request POST https://account-d.docusign.com/oauth/token
