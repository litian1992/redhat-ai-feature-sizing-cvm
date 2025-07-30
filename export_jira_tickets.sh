#!/bin/bash
# Takes multiple ticket numbers as arguments

# JIRA_API_TOKEN="<MY_JIRA_API_TOKEN>"
API_URL="https://issues.redhat.com/rest/api/2/issue"

if [ $# -eq 0 ]; then
    echo "export_jira.sh TICKET [TICKET...]"
    exit 1
fi
out_file="exported_jira_tickets.txt"
for issue_key in "$@"; do
    curl -s -X GET \
        -H "Authorization: Bearer $JIRA_API_TOKEN" \
        -H "Content-Type: application/json" \
        "$API_URL/$issue_key" | jq -r '
        {
         key: .key,
         summary: .fields.summary,
         issue_type: .fields.issuetype.name,
         description: .fields.description | gsub("\r\n"; ""),
         priority: .fields.priority.name,
         status: .fields.status.name,
         story_points: .fields.customfield_12310243,
         assignee: .fields.assignee.displayName,
         reporter: .fields.reporter.displayName,
        }' >> $out_file
    #out_file="$issue_key.json"
    #curl -s -X GET \
    #    -H "Authorization: Bearer $JIRA_API_TOKEN" \
    #    -H "Content-Type: application/json" \
    #    "$API_URL/$issue_key" | jq -r > $out_file
    [ $? == 0 ] && echo "Done exporting $issue_key"
done
