#!/usr/bin/env bash

# --- UTILITIES CHECK ---

[ ! -x "$(which jq)" ] && apt update && apt install jq -y
[ ! -x "$(which http)" ] && apt update && apt install httpie -y
[ ! -x "$(which python3)" ] && apt update && apt install python3 -y
[ ! -x "$(which pip3)" ] && apt update && apt install python3-pip -y && pip install veracode-api-signing


# ---- VARIABLES ---- 

APP=$2
APIBASE="https://api.veracode.com/appsec/v1"
HELP="
    How to use: ./application_infos.sh <parameter1> <application name>

    Parameters available:

    -h  - Help menu
    -g  - Application GUID
    -i  - Application ID
    -pn - Security Policy name applied to app
    -ps - Security status of app based on last scan
    -tn - Team name added to app
    -sn - Sandboxes names created into app
"

# --- INPUT VALIDATION ---

if [ "$2" == "" ]
then
    echo -e "\nYou must include the Veracode app profile name. Use ./application_infos.sh -h to help\n" & exit 1
fi

# --- HTTP REQUESTS & FILTER ---

GUID=$(http --auth-type=veracode_hmac GET "${APIBASE}/applications/?name="${APP} | jq '._embedded.applications' | jq .'[] | .guid' | sed 's/\"//g')
APP_ID=$(http --auth-type=veracode_hmac GET "${APIBASE}/applications/?name="${APP} | jq '._embedded.applications' | jq .'[] | .id')
POLICY_NAME=$(http --auth-type=veracode_hmac GET "${APIBASE}/applications/?name="${APP}  | jq '._embedded.applications' | jq .'[] | .profile.policies | .[].name' | sed 's/\"//g')
POLICY_STATUS=$(http --auth-type=veracode_hmac GET "${APIBASE}/applications/?name="${APP}  | jq '._embedded.applications' | jq .'[] | .profile.policies | .[].policy_compliance_status' | sed 's/\"//g')
TEAM_NAME=$(http --auth-type=veracode_hmac GET "${APIBASE}/applications/?name="${APP}  | jq '._embedded.applications | .[] | .profile.teams | .[].team_name' | sed 's/\"//g')
SANDBOXES_NAMES=$(http --auth-type=veracode_hmac GET "${APIBASE}/applications/${GUID}/sandboxes" | jq '._embedded.sandboxes | .[] | .name' | sed 's/\"//g')

# --- EXECUTION ---

case "$1" in 
    -h)  echo "Help:                                         $HELP" && 0                    ;;
    -g)  echo "App GUID:                                     $GUID"                         ;;
    -i)  echo "App ID:                                       $APP_ID"                       ;;
    -pn) echo "Security policy name:                         $POLICY_NAME"                  ;;
    -ps) echo "Security compliance status:                   $POLICY_STATUS"                ;;
    -tn) echo "Teams:                                        $TEAM_NAME"                    ;;
    -sn) echo "$SANDBOXES_NAMES"                                                            ;;
    *)  echo -e "\nOption unavailable. Use ./application_infos.sh -h to help\n" & exit 1    ;;
esac

