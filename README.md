# rn-deploy-toolkit

Deploy, debug, and store-submit React Native Expo apps with coordinated agent teams.

## What It Does

Orchestrates a team of specialized Claude Code agents to build, test, deploy, and debug React Native Expo applications. Supports local dev builds, EAS cloud builds, store submissions, OTA updates, and live device debugging — all through shared task state with TDD enforcement and structured logging.

## Installation

### From the marketplace

Add the marketplace to Claude Code:

```
/plugin marketplace add linus/rn-deploy-toolkit
```

Then install the plugin:

```
/plugin install rn-deploy-toolkit@rn-deploy-toolkit-marketplace
```

### From GitHub (direct)

```
/plugin install github:linus/rn-deploy-toolkit
```

### Local development

```bash
claude --plugin-dir /path/to/rn-deploy-toolkit
```

## Prerequisites

### Claude Code Agent Teams

Agent teams must be enabled for the `team-deploy` command to work. Add this to your Claude Code `settings.json`:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

You can find your settings file at `~/.claude/settings.json` (global) or `.claude/settings.json` (project-level).

### MCP Servers

This plugin requires several MCP servers for build, device, and debug operations. Install and configure each one in your project's `.mcp.json` or Claude Code settings.

| MCP Server | Purpose | Required |
|------------|---------|----------|
| `react-native-expo` | Build, deploy, diagnostics, EAS operations | Yes |
| `mobile-mcp` | Device automation, screenshots, smoke testing | Yes |
| `react-native-debugger-mcp` | Console log inspection from running apps | Yes |
| `react-native-guide` | Performance analysis and best practices | No (optional) |

Refer to each MCP server's own documentation for installation instructions. Once installed, register them in your project's `.mcp.json`:

```json
{
  "mcpServers": {
    "react-native-expo": {
      "command": "npx",
      "args": ["-y", "@anthropic/react-native-expo-mcp"]
    },
    "mobile-mcp": {
      "command": "npx",
      "args": ["-y", "@anthropic/mobile-mcp"]
    },
    "react-native-debugger-mcp": {
      "command": "npx",
      "args": ["-y", "@anthropic/react-native-debugger-mcp"]
    }
  }
}
```

> **Note:** The exact package names and arguments above are illustrative. Check each server's documentation for the correct installation command.

### Platform Tooling

**For Android:**
- Android SDK installed and configured
- An Android emulator running, or a physical device connected via `adb`
- Verify with: `adb devices`

**For iOS:**
- Xcode installed with iOS Simulator
- A simulator booted, or a physical device registered

**For release/store submission:**
- EAS CLI installed: `npm install -g eas-cli`
- Authenticated with Expo: `npx expo login`
- EAS project configured: `eas init`

### React Native Expo Project

The plugin expects to be used within an existing React Native Expo project. It does not scaffold new projects.

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

### Log Monitoring

```bash
# Scan for errors and warnings
bash scripts/monitor-logs.sh

# Verify TDD compliance
bash scripts/verify-tdd.sh
```

## Configuration

| Setting | Default | Description |
|---------|---------|-------------|
| Core teammates | 2 (dev/debug), 5 (release) | Based on mode |
| Max teammates | 6 | Including on-demand engineer |
| Max debug iterations | 3 | Before escalating to user |
| Metro port | 8081 | Default port for dev server |
| Platform | android | Default build platform |

## Contributing

Contributions are welcome. Please open an issue or pull request on the [GitHub repository](https://github.com/linus/rn-deploy-toolkit).

## License

MIT
