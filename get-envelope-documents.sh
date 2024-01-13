#!/usr/bin/bash

set -eo pipefail

# 設定ファイルの配置先フォルダ
conf="./docusign_config"

# アカウント情報各種
account_id="$(cat ${conf}/docusign_api_account_id.txt)"
base_path="https://demo.docusign.net/restapi"

# OAuth トークン発行依頼 REST APIをたたき, web token取得
# (事前に jq 導入しておくこと)
ACCESS_TOKEN="$(./create-oauth-jwt-token.sh | jq -r .access_token)"

# APIヘッダ情報を生成
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}" \
					'--header' "Accept: application/json" \
					'--header' "Content-Type: application/json")

# envelope id その他は現状決め打ち
envelope_id="enter your envelope ID you want get some info."

# REST API実行, 指定したenvelope ID のドキュメント取得
# document id は現状(エンベロープごとに1ドキュメントのため) '1' で固定
Status=$(curl -s -w '%{http_code}' \
-i --request \
GET ${base_path}/v2.1/accounts/${account_id}/envelopes/${envelope_id}/documents/certificate \
"${Headers[@]}" \
--output certificate_signed.pdf)

echo $Status
