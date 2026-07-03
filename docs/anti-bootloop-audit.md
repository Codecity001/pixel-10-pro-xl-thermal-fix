# Anti-bootloop audit

Status: audit-only.

Current state:

- `service.sh` writes boot health evidence and waits for boot completion.
- `collect-debug.sh` records module flags, pTune state, mounts and thermal evidence.
- Automatic self-disable after repeated boot failures is not implemented yet.

Decision:

Do not add automatic self-disable in the same step as an unknown boot-crash report.

Future guarded design should add pending boot markers, a fail counter, thresholded self-disable, a clear disabled reason and evidence preservation.

Run:

```text
tools/anti-bootloop-audit.sh .
```

Expected current result:

```text
RESULT: ANTI_BOOTLOOP_AUDIT_DONE auto_disable=absent
```
