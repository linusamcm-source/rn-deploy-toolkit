# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [0.1.0] - 2026-02-25

### Added

- `team-deploy` command with dev, release, ota, debug, and status modes
- `store-qa` command for read-only store readiness audits
- Agent definitions:
  - `build-fixer` — build error resolution specialist
  - `deploy-engineer` — code bug fixes with mandatory TDD
  - `device-tester` — device automation and smoke testing via mobile-mcp
  - `perf-auditor` — performance analysis for release builds
  - `store-qa` — comprehensive App Store / Play Store readiness audit
- Skill documentation for team-deploy and store-readiness workflows
- Session hooks for automatic `logs/` directory creation
- TDD enforcement across all code fix workflows (RED → GREEN → REFACTOR)
- Structured timestamped logging for all agents
- `monitor-logs.sh` script for scanning deploy session logs
- `verify-tdd.sh` script for checking TDD compliance in logs
- Marketplace distribution support via `marketplace.json`
