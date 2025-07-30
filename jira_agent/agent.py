import os
from google.adk.agents import Agent
from google.adk.tools.mcp_tool.mcp_toolset import MCPToolset, StdioServerParameters

root_agent = Agent(
    name="jira_agent",
    model="gemini-2.0-flash",
    description=(
        "Agent connect to Jira."
    ),
    instruction=(
        """You are helpful Jira task assistant. Your goal
           is to help analyze Jira ticket contents and provide detailed summary.
           Meanwhile you should be able to create Jira tickets with given information.
           1. When you are asked to add "Story Points" it's field 'customfield_12310243'.
           2. When creating ticket, default assignee is "litian@redhat.com"
           3. When creating ticket, every ticket's summary should start with "[Azure][CVM]"
           4. "Assigned Team" is field 'customefield_12326540'. And the default is 'rhel-sst-virtualization-cloud'.
           5. The only possible project is 'RHELOPC' to do read/write.
           6. You should assign "Story Points" field after the ticket is created, not at creation.
           7. After done assigning story points, print the link to the tickets.
        """
    ),
    tools=[
        MCPToolset(
            connection_params=StdioServerParameters(
                command='uvx',
                args=[
                    "mcp-atlassian",
                    "--transport", "stdio",
                    "--jira-url", "https://issues.redhat.com",
                    "--jira-personal-token", "<MY_JIRA_API_TOKEN>",
                ]
            ),
        )
    ],
)
