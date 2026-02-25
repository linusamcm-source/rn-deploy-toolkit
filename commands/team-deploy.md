---
name: team-deploy
description: Launch a Claude Code Agent Team to build, deploy, and debug the React Native Expo app. Modes: dev (local build + smoke test), release (EAS + store submit), ota (OTA update), debug (running app), status.
argument-hint: "dev | release android | release ios | ota | debug | status"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Glob
  - Task
  - TaskCreate
  - TaskUpdate
  - TaskList
  - TaskGet
  - TeamCreate
  - SendMessage
  - TeamDelete
---

IT IS CRITICAL THAT YOU FOLLOW THIS COMMAND: LOAD the FULL ${CLAUDE_PLUGIN_ROOT}/skills/team-deploy/team-deploy.md, READ its entire contents and follow its directions exactly!

ARGUMENTS: $ARGUMENTS
