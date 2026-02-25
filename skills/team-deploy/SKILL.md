---
name: team-deploy
description: This skill should be used when the user wants to build, deploy, debug, or smoke test a React Native Expo app using a coordinated agent team. Triggers on deploy requests, build commands, device testing, store submissions, OTA updates, and debug sessions.
version: 0.1.0
---

# Team Deploy Skill

Orchestrates React Native build, deploy, and debug workflows using Claude Code's **native Agent Team framework** (TeamCreate, SendMessage, shared TaskList). Creates a coordinated multi-agent team that builds the app, runs smoke tests on device, fixes errors with TDD, and handles store submissions — all through shared task state.

## Trigger Patterns

- `/rn-deploy-toolkit:team-deploy` or `/rn-deploy-toolkit:team-deploy dev` — Local build + install + smoke test + debug loop
- `/rn-deploy-toolkit:team-deploy release android` — EAS prod build + quality reviews + Play Store submit
- `/rn-deploy-toolkit:team-deploy release ios` — EAS prod build + quality reviews + App Store submit
- `/rn-deploy-toolkit:team-deploy ota` — OTA update via EAS (lead-only, no team needed)
- `/rn-deploy-toolkit:team-deploy debug` — Debug a running app (no build step)
- `/rn-deploy-toolkit:team-deploy status` — Show current team/task state

## Architecture

The team lead (you) creates a team, spawns specialized teammates, creates tasks, and coordinates work. Teammates are full Claude Code sessions that:

1. Read the shared task list
2. Claim unassigned, unblocked tasks
3. Work independently with their own context
4. Message the lead (and each other) when done or blocked
5. Go idle when waiting for new work

## MCP Tool Integration

The team leverages three MCP servers for build, deploy, and debug operations.

### react-native-expo MCP

Dev server management, builds, diagnostics, submissions, and OTA updates.

| Tool | Used By | Purpose |
|------|---------|---------|
| `expo_dev_start` | Lead | Start Expo dev server (returns session_id) |
| `expo_dev_send` | Lead, device-tester | Send reload/clear_cache commands |
| `expo_dev_read` | Lead, build-fixer | Read Metro bundler logs |
| `expo_dev_stop` | Lead | Stop dev server during cleanup |
| `expo_build_local_start` | Lead | Start local native build |
| `expo_build_local_read` | Lead, build-fixer | Read build progress and logs |
| `expo_build_local_stop` | Lead | Cancel a stuck build |
| `expo_doctor` | build-fixer | Diagnose project issues |
| `expo_install` | build-fixer | Install Expo-compatible packages |
| `resolve_dependencies` | build-fixer | Analyze and fix dependency conflicts |
| `remediate_code` | build-fixer | Auto-fix detected code issues |
| `debug_issue` | build-fixer | Get debugging guidance |
| `analyze_codebase_performance` | perf-auditor | Codebase-wide performance analysis |
| `analyze_component` | perf-auditor | Component-level performance analysis |
| `audit_packages` | security-check | Security audit of dependencies |
| `eas_build` | Lead | Trigger EAS cloud build (release mode) |
| `eas_build_status` | Lead | Poll EAS build status |
| `eas_submit` | Lead | Submit to App Store / Play Store |
| `eas_update` | Lead | Publish OTA update |
| `eas_update_status` | Lead | Check OTA update status |

### react-native-debugger-mcp

Runtime console log inspection from connected React Native apps.

| Tool | Used By | Purpose |
|------|---------|---------|
| `getConnectedApps` | Lead, device-tester, build-fixer | Discover apps connected to Metro |
| `readConsoleLogsFromApp` | device-tester, build-fixer | Read console output |

### mobile-mcp

Device automation for smoke testing and UI verification.

| Tool | Used By | Purpose |
|------|---------|---------|
| `mobile_list_available_devices` | Lead | Verify device/emulator availability |
| `mobile_take_screenshot` | device-tester | Capture screen state |
| `mobile_list_elements_on_screen` | device-tester | Verify accessibility tree |
| `mobile_click_on_screen_at_coordinates` | device-tester | Tap UI elements |
| `mobile_type_keys` | device-tester | Enter text input |
| `mobile_swipe_on_screen` | device-tester | Scroll and gesture interaction |
| `mobile_launch_app` | device-tester | Launch the app |
| `mobile_terminate_app` | device-tester | Close the app |
| `mobile_press_button` | device-tester | Press device buttons |
| `mobile_get_screen_size` | device-tester | Get screen dimensions |

## Team Roles & Agent Mapping

| Teammate Name | Role | Agent Type | MCP Tools | Spawned When |
|---------------|------|------------|-----------|--------------|
| **device-tester** | Smoke testing + UI verification | `rn-deploy-toolkit:device-tester` | mobile-mcp all, expo_dev_*, debugger-mcp | dev, release, debug |
| **build-fixer** | Build errors + runtime debugging | `rn-deploy-toolkit:build-fixer` | expo_doctor, resolve_dependencies, remediate_code, debug_issue, debugger-mcp, expo_dev_read | Always |
| **engineer** | Code bug fixes | `rn-deploy-toolkit:deploy-engineer` | standard | When code bugs found |
| **perf-auditor** | Performance review | `rn-deploy-toolkit:perf-auditor` | analyze_codebase_performance, analyze_component | Release mode only |
| **security-check** | Security audit | `security-reviewer` | audit_packages | Release mode only |

### Team Size by Mode

| Mode | Teammates | Notes |
|------|-----------|-------|
| dev | 2 | device-tester + build-fixer |
| release | 5 | all roles |
| ota | 0 | Lead-solo |
| debug | 2 | device-tester + build-fixer |

## Workflow Phases

```
Phase 1: Environment Assessment
    ├── TeamCreate("deploy-{mode}-{timestamp}")
    ├── Check devices (mobile_list_available_devices)
    ├── Project health (expo_doctor)
    ├── Port conflicts (lsof -ti:8081)
    ├── TypeScript check (npx tsc --noEmit)
    ├── EAS auth check (release mode: eas whoami)
    └── Create Phase 2 tasks based on mode

Phase 2: Build (mode-dependent)
    ├── DEV: clean cache → expo_build_local_start → monitor
    ├── RELEASE: tests → tsc+eslint → eas_build → poll status
    ├── OTA: skip (jump to Phase 5)
    └── DEBUG: skip (verify Metro running)

Phase 3: Install & Smoke Test
    ├── Start dev server (expo_dev_start) if not running
    ├── Connect debugger (getConnectedApps + readConsoleLogsFromApp)
    ├── Spawn device-tester
    ├── Screenshot + navigate each screen + check a11y tree
    └── Check console logs after each interaction

Phase 4: Debug Loop (max 3 iterations)
    ├── Collect: console errors, Metro errors, visual bugs
    ├── Triage by severity (FATAL > ERROR > WARN)
    ├── Create FIX tasks for FATAL/ERROR
    ├── Spawn build-fixer or engineer
    └── After fixes: reload and re-verify

Phase 5: Deploy / Release (mode-dependent)
    ├── DEV: report success
    ├── RELEASE: perf-auditor + security-check → eas_submit
    ├── OTA: eas_update → status
    └── DEBUG: report findings

Phase 6: Cleanup & Report
    ├── Stop dev server
    ├── Generate deploy report
    ├── SendMessage shutdown_request to all
    └── TeamDelete
```

## Task Metadata

```
metadata: {
  mode,         // dev | release | ota | debug
  phase,        // env | build | smoke | fix | deploy | cleanup
  platform,     // android | ios | all
  severity,     // FATAL | ERROR | WARN (for fix tasks)
  attempt,      // Fix retry count (max 3)
  sessionId,    // expo dev server session_id
  buildId,      // EAS build ID
  screenName    // For smoke test tasks
}
```

## Configuration

| Setting | Default | Description |
|---------|---------|-------------|
| Core teammates | 2 (dev/debug), 5 (release) | Based on mode |
| Max teammates | 6 | Including on-demand engineer |
| Max debug iterations | 3 | Before escalating to user |
| Metro port | 8081 | Default port for dev server |
| Platform | android | Default build platform |

## Prerequisites

Agent teams must be enabled:
```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```
