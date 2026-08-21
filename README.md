# Zwix

[![License: MIT](https://img.shields.io/github/license/mustafaunall/zwix)](LICENSE)
[![Swift](https://img.shields.io/badge/Swift-5.10%2B-orange?logo=swift)](https://swift.org)
[![Platform](https://img.shields.io/badge/platform-macOS%2013%2B-lightgrey?logo=apple)](https://www.apple.com/macos/)
[![GitHub last commit](https://img.shields.io/github/last-commit/mustafaunall/zwix)](https://github.com/mustafaunall/zwix/commits/main)
[![GitHub stars](https://img.shields.io/github/stars/mustafaunall/zwix?style=social)](https://github.com/mustafaunall/zwix/stargazers)

A native macOS menu bar app for context switching. Define profiles that open and close specific apps — manually, or automatically when a "trigger app" launches.

## Why

Running a local LLM, entering a focused coding session, or joining a meeting all want a different set of apps open (and a different set closed to free up RAM). Zwix lets you define that as a profile once and switch into it with a click, or let it happen automatically.

## Features

- **Profiles**: each profile has an *Opens* list, a *Closes* list, and an optional *icon*.
- **Trigger apps**: assign an app (e.g. VS Code) to a profile so launching it activates the profile automatically. Quitting the trigger app deactivates it.
- **One active profile at a time**: activating a profile does a full context switch — apps from the previous profile that aren't needed by the new one are closed.
- **Menu bar only**: no Dock icon, lives entirely in the menu bar. A separate Settings window handles profile editing.
- **Local-only**: no network calls, no telemetry. Profiles persist to a JSON file in `~/Library/Application Support/Zwix`.

## Requirements

- macOS 13+
- Swift 5.10+ / Xcode 15+ (for building)

## Building

```bash
swift build            # debug build
swift run               # run directly (menu bar icon appears)
./Scripts/build-app.sh   # release build, produces dist/Zwix.app (ad-hoc signed)
```

## Status

Early stage — built and used daily by the author, not yet notarized or distributed as a signed release.

## License

MIT — see [LICENSE](LICENSE).
