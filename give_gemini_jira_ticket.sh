#!/bin/bash

#GEMINI_API_KEY="<MY_GEMINI_API_KEY>"
GEMINI_MODEL_ID="gemini-2.5-flash"
GEMINI_API_URL="https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL_ID}:generateContent"
JIRA_API_URL="https://issues.redhat.com/rest/api/2/issue"
#JIRA_API_TOKEN="<MY_JIRA_API_TOKEN>"

if [ -z "$1" ]; then
    echo -e "Must provide Jira issue number\ngive_gemini_jira_ticket.sh RHEL-0000"
    exit 1
fi
issue_key=$1
out_file="$1.json"

https_status=$(curl -s -X GET \
    -H "Authorization: Bearer $JIRA_API_TOKEN" \
    -H "Content-Type: application/json" \
    -o "$1.raw" \
    "$JIRA_API_URL/$issue_key")

cat $1.raw | jq -r > $out_file
rm $1.raw -f
summary=$(jq -c '.fields.summary' $out_file)
description=$(jq -c '.fields.description' $out_file)
comments=$(jq -c '.fields.comment.comments[].body' $out_file)

JSON=$(jq -n --arg msg "\
    Below are some information of an Jira ticket. \
    Help me plan some sub-tasks with story points from it in Jira ticket format. \
    summary: $summary\ndescription: $description\ncomments: $comments" \
    '{contents: [{parts: [{text: $msg}]}]}')

RESPONSE=$(curl -s -X POST -H "x-goog-api-key: $GEMINI_API_KEY" \
    -H "Content-Type: application/json" \
    -d "$JSON" "$GEMINI_API_URL")

  echo -n "Gemini: "
  echo "$RESPONSE" | jq -r '.candidates[0].content.parts[0].text'
