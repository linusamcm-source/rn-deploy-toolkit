# rn-deploy-toolkit

Deploy, debug, and store-submit React Native Expo apps with coordinated agent teams.

## What It Does

Orchestrates a team of specialized Claude Code agents to build, test, deploy, and debug React Native Expo applications. Supports local dev builds, EAS cloud builds, store submissions, OTA updates, and live device debugging — all through shared task state with TDD enforcement and structured logging.

## Requirements

- Claude Code with Agent Teams enabled (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`)
- React Native Expo project
- MCP servers: `react-native-expo`, `mobile-mcp`, `react-native-debugger-mcp`
- Android emulator or iOS simulator (for device testing)

## Installation

```bash
# From Claude Code plugin marketplace
claude plugin install rn-deploy-toolkit

# Or local development
claude --plugin-dir /path/to/rn-deploy-toolkit
```

## Commands

### `/rn-deploy-toolkit:team-deploy`

Build, deploy, and debug your app with a coordinated agent team.

```bash
/rn-deploy-toolkit:team-deploy              # Dev build + smoke test (default)
/rn-deploy-toolkit:team-deploy dev          # Same as above
/rn-deploy-toolkit:team-deploy release android  # EAS build + Play Store submit
/rn-deploy-toolkit:team-deploy release ios      # EAS build + App Store submit
/rn-deploy-toolkit:team-deploy ota              # OTA update (lead-solo)
/rn-deploy-toolkit:team-deploy debug            # Debug running app
/rn-deploy-toolkit:team-deploy status           # Show team/task state
```

### `/rn-deploy-toolkit:store-qa`

Run a comprehensive store readiness audit without editing code.

```bash
/rn-deploy-toolkit:store-qa                # Full audit
```

## Agent Team

| Role | Agent | Spawned When |
|------|-------|--------------|
| **device-tester** | Device automation + smoke testing | dev, release, debug |
| **build-fixer** | Build error resolution | Always (build errors are #1 failure) |
| **deploy-engineer** | Code bug fixes with TDD | When code bugs found |
| **perf-auditor** | Performance analysis | Release mode only |
| **store-qa** | Store readiness audit | `/store-qa` command |

## Workflow Phases

1. **Environment Assessment** — Device check, project health, TypeScript, port conflicts
2. **Build** — Local build (dev) or EAS cloud build (release)
3. **Smoke Test** — Device-tester navigates screens, takes screenshots, checks console
4. **Debug Loop** — Triage errors, spawn fixers, reload, re-verify (max 3 iterations)
5. **Deploy** — Store submission (release) or OTA publish
6. **Cleanup** — Stop servers, generate report, shutdown team

## TDD Enforcement

All code fixes follow RED → GREEN → REFACTOR:

1. **RED**: Write a test reproducing the bug
2. **GREEN**: Implement minimal fix to pass
3. **REFACTOR**: Clean up without breaking tests

The lead verifies fix tasks include test file references. Fixes without tests are rejected.

## Structured Logging

All agents write timestamped logs to `logs/`:

```
logs/deploy-lead-2026-02-25.log
logs/device-tester-2026-02-25.log
logs/build-fixer-2026-02-25.log
logs/engineer-2026-02-25.log
logs/error.log  (shared)
```

Format: `[YYYY-MM-DDTHH:mm:ss] [AGENT-NAME] [LEVEL] message`

## Setup

Enable agent teams in your Claude Code settings:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

Ensure your project has the required MCP servers configured:
- `react-native-expo` — Build, deploy, diagnostics
- `mobile-mcp` — Device automation and screenshots
- `react-native-debugger-mcp` — Console log inspection
- `react-native-guide` — Performance analysis and best practices (optional)

## License

MIT
