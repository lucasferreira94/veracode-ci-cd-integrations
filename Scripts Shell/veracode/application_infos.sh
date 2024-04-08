#!/usr/bin/env bash

# --- CHECAGEM DE UTILITARIOS ---

[ ! -x "$(which jq)" ] && apt update && apt install jq -y
[ ! -x "$(which http)" ] && apt update && apt install httpie -y
[ ! -x "$(which python3)" ] && apt update && apt install python3 -y
[ ! -x "$(which pip3)" ] && apt update && apt install python3-pip -y && pip install veracode-api-signing

# ---- VARIAVEIS ---- 

read -p "Informe o nome do app profile: " APP

GUID=$(http --auth-type=veracode_hmac GET "https://api.veracode.com/appsec/v1/applications/?name="$APP | jq '._embedded.applications' | jq .'[] | .guid' | sed 's/\"//g')
APP_ID=$(http --auth-type=veracode_hmac GET "https://api.veracode.com/appsec/v1/applications/?name="$APP | jq '._embedded.applications' | jq .'[] | .id')
POLICY_NAME=$(http --auth-type=veracode_hmac GET "https://api.veracode.com/appsec/v1/applications/?name="$APP | jq '._embedded.applications' | jq .'[] | .profile.policies | .[].name' | sed 's/\"//g')
POLICY_STATUS=$(http --auth-type=veracode_hmac GET "https://api.veracode.com/appsec/v1/applications/?name="$APP | jq '._embedded.applications' | jq .'[] | .profile.policies | .[].policy_compliance_status' | sed 's/\"//g')
TEAM_NAME=$(http --auth-type=veracode_hmac GET "https://api.veracode.com/appsec/v1/applications/?name="$APP | jq '._embedded.applications | .[] | .profile.teams | .[].team_name' | sed 's/\"//g')
SANDBOXES_NAMES=$(http --auth-type=veracode_hmac GET "https://api.veracode.com/appsec/v1/applications/${GUID}/sandboxes" | jq '._embedded.sandboxes | .[] | .name' | sed 's/\"//g')

# --- ---

echo "App GUID:                                 $GUID"
echo "App ID:                                   $APP_ID"
echo "Nome de política:                         $POLICY_NAME"
echo "Status de compliance da política:         $POLICY_STATUS"
echo "Time:                                     $TEAM_NAME"
echo -e "Sandboxes:\b                            
$SANDBOXES_NAMES"
