#!/bin/bash
# This script enables chat with Gemini AI in terminal.
# GEMINI_API_KEY="<MY_GEMINI_API_KEY>"
MODEL_ID="gemini-2.5-flash"
API_URL="https://generativelanguage.googleapis.com/v1beta/models/${MODEL_ID}:generateContent"

format_markdown() {
  while IFS= read -r line; do
    # Headers
    if [[ $line =~ ^###\ (.*) ]]; then
      echo -e "\e[4;36m${BASH_REMATCH[1]}\e[0m"  # Cyan underlined
    # Bullet points
    elif [[ $line =~ ^\*\ (.*) ]]; then
      echo -e "  • \e[33m${BASH_REMATCH[1]}\e[0m"  # Yellow bullets
    # Inline bold (**text**)
    elif [[ $line =~ \*\*(.*)\*\* ]]; then
      line=$(echo "$line" | sed -E 's/\*\*(.*?)\*\*/\\e[1m\1\\e[0m/g')
      echo -e "$line"
    # Inline code: `code`
    elif [[ $line =~ \`(.*)\` ]]; then
      line=$(echo "$line" | sed -E 's/\`(.*?)\`/\\e[2m\1\\e[0m/g')
      echo -e "$line"
    else
      echo "$line"
    fi
  done
}

while true; do
  read -p "You: " USER_INPUT
  [[ -z "$USER_INPUT" ]] && break

  JSON=$(jq -n --arg msg "$USER_INPUT" '{
    contents: [{parts: [{text: $msg}]}]
  }')

  RESPONSE=$(curl -s -X POST -H "x-goog-api-key: $GEMINI_API_KEY" \
    -H "Content-Type: application/json" \
    -d "$JSON" "$API_URL")

  echo -n "Gemini: "
  echo "$RESPONSE" | jq -r '.candidates[0].content.parts[0].text' | format_markdown
done
