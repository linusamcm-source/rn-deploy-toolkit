---
name: store-readiness
description: This skill should be used when the user wants to check if their React Native Expo app is ready for App Store or Play Store submission. Triggers on store readiness checks, pre-submission audits, and release quality assessments.
version: 0.1.0
---

# Store Readiness QA Skill

Runs a comprehensive automated audit to verify a React Native Expo app is ready for submission to iOS App Store (TestFlight) and Google Play Store (internal testing) via EAS Build/Submit. Creates a team of specialized agents that run parallel test categories and produce a consolidated Markdown report.

**CRITICAL: This is a READ-ONLY audit. No code is edited.**

## Trigger Patterns

- `/rn-deploy-toolkit:store-qa` — Run full store readiness audit

## Architecture

The QA orchestrator spawns 5 parallel agents, each responsible for one test category. Results are collected and compiled into a single report.

| Agent | Role | Responsibility |
|-------|------|---------------|
| Inspector | Static Analysis | TypeScript, ESLint, bundle analysis, secrets scan |
| Guardian | App Config Audit | app.json, eas.json, privacy, compliance |
| Diver | Unit/Integration Tests | Jest suite, coverage, gap analysis |
| Lookout | Runtime Analysis | Console logs, warnings, performance MCP |
| Beacon | Codebase Quality | Large files, nesting, error boundaries, Sentry |

## Test Categories

### Category 1: Build & Compilation (Inspector)
- TypeScript compilation (zero errors)
- ESLint violations by severity
- Expo SDK compatibility
- Console.log in source (excluding tests)
- Hardcoded secrets scan
- TODO/FIXME in critical paths

### Category 2: App Store Configuration (Guardian)
- app.json required fields validation
- Deep linking scheme
- EAS project configuration
- Icon and splash assets exist
- eas.json submit configuration
- Environment variables cross-check
- Privacy policy and account deletion

### Category 3: Unit & Integration Tests (Diver)
- Full test suite pass/fail/skip counts
- Coverage report (target: 80%+)
- Untested critical paths
- Flaky test detection
- Test setup validation

### Category 4: Runtime Analysis (Lookout)
- Console log errors and warnings (if Metro running)
- Deprecated API usage
- Memory leak warnings
- Bundle performance analysis via MCP

### Category 5: Codebase Quality (Beacon)
- Large files (>800 lines)
- Deep nesting (>4 levels)
- Error monitoring configuration
- Error boundaries in layout
- Navigation structure validation

### Category 6: EAS Deployment (Guardian)
- EAS CLI version and auth
- Production environment variables
- Build/submit targets in Makefile
- OTA update configuration

## Report Output

```
_bmad-output/qa-reports/store-readiness-{ISO-date}.md
```

## Severity Guide

- **CRITICAL**: Will cause store rejection or build failure
- **HIGH**: Likely to cause issues in review or runtime
- **MEDIUM**: Should fix before production
- **LOW**: Nice to have
- **INFO**: Informational

## Prerequisites

- React Native Expo project
- MCP servers: `react-native-expo`, `react-native-debugger-mcp` (optional)
- Agent teams enabled for parallel execution
