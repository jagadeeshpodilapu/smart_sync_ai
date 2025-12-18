## 0.0.1 — Initial Release

Initial offline-first sync engine foundation for Flutter applications.

## ✨ Features

Offline-first data architecture with local SQLite (Drift) as the source of truth

Transactional local writes with durable operation queue

Background sync mechanism (push / pull) with retry and exponential backoff

Incremental sync support using sequence-based deltas

Basic conflict detection with last-writer-wins strategy

Reactive data updates via streams for seamless UI integration

Pluggable backend sync API contract (HTTP-based)

🧱 Architecture

Repository pattern separating UI, local persistence, and sync logic

Persistent operation log to guarantee eventual consistency

Explicit conflict modeling for safe concurrent edits

Network-independent read and write paths

## 🧪 Testing

Unit-testable repository and sync components

Deterministic sync behavior for predictable integration testing

⚠️ Known Limitations

Conflict resolution limited to last-writer-wins

Background execution optimized for foreground usage (platform schedulers planned)

Single-device conflict resolution UI not included