# Deprecated

This repository is **deprecated** and no longer maintained.

All Loxone Intercom Gen.2 integration work has moved to:

> **https://github.com/markuslaube/loxone-intercom2**

## What moved

| Old (this repo) | New (loxone-intercom2) |
|---|---|
| `poc_makeoffer.sh` | `rtc-bridge/` and `rtc-directbridge/` |
| `poc_makeanswer.sh` | `rtc-bridge/` and `rtc-directbridge/` |
| `intercom-gen2-last-picture.sh` | Not migrated (superseded by WebRTC video bridge) |
| `intercom-gen2-backup-pictures.sh` | Not migrated (superseded by WebRTC video bridge) |

## Why

The old PoC shell scripts from 2022 were experimental approaches to grab
snapshots and test WebRTC signaling. The new repository contains production-ready
Docker containers for streaming video (WebRTC) and audio (SIP) from the
Loxone Intercom Gen.2 (audio via SIP coming soon).
