# Feature ideas

Unordered backlog of ideas for future versions. Nothing here is committed to — just a running list to pull from.

## Triggers & automation

- **Multiple trigger apps per profile** — activate a profile if *any* of several apps launches, not just one.
- **Project/workspace-aware triggers** — e.g. only trigger "Coding" when VS Code opens a specific folder, not on any launch.
- **Time-based schedules** — e.g. "Coding" 09:00–18:00 on weekdays, "None" outside that window.
- **Wi-Fi network trigger** — switch profile based on which network you're connected to (home vs. office).
- **Power state trigger** — unplugging from charger auto-closes heavy apps (Docker, Xcode, VMs) to save battery.
- **macOS Focus Mode integration** — map a Focus (Do Not Disturb, Work, Personal, etc.) to a Zwix profile.

## Safety & control

- **Never-close allowlist** — apps (Finder, Terminal, etc.) that are never auto-terminated regardless of profile.
- **Configurable grace period** — the current hardcoded 2s wait before force-terminating a stuck app should be per-profile or global setting.
- **Dry-run / preview mode** — show what would open/close before committing to a switch.
- **Undo last switch** — bring back the previous profile's closed apps within a short window.

## Quick actions & UX

- **Global keyboard shortcut** — Spotlight-style quick switcher (⌥⌘Z or similar), no need to reach for the menu bar.
- **Per-profile keyboard shortcut** — activate "Coding" directly via its own shortcut.
- **Snapshot current state as a new profile** — one click to turn "whatever's open right now" into a profile's open list.
- **Toast notification on switch** — brief "Coding activated — 3 apps opened, 2 closed" confirmation.
- **Active profile shown in the menu bar glyph** — not just inside the dropdown.
- **Live RAM-freed counter** — show an estimate right after a close action.

## Distribution & sync

- **Profile export/import** — plain JSON, shareable between machines or people.
- **iCloud sync** — keep profiles in sync across multiple Macs.
- **Starter profile templates** — built-in presets ("Coding", "Meeting", "Gaming") users can adopt and tweak instead of starting from scratch.
- **CLI companion** — `zwix activate coding` for scripting, Raycast, or Alfred integration.

## Stats & insight

- **Per-profile activation count** — "activated 42 times this month."
- **Lightweight window layout memory** — remember position/size of opened apps, not just open/closed state.
