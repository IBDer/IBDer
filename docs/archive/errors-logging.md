# Error and Logging Specification

**Status: draft, pending review.**

## Two Iron Rules

1. **A failed write must not display success.** When persistence fails, the UI must clearly tell the user that it was not saved, and keep the content already entered.
2. **Health content does not go into logs.** Logs, crash reports, and analytics events must not contain symptoms, medication, blood in stool, notes, or any other health information.

## User-Visible Errors

- State three things clearly: what happened, what state the data is in now, and what the user can do.
- Do not blame the user, and do not surface technical terms or error codes (error codes may go in an expandable detail section).
- Do not lead the user into a medical judgment (for example, do not write "Save failed" as "Please retry or contact your doctor").

## Internal Logs

- Use `os.Logger`, split by subsystem / category.
- Log **actions and state**, not **content**: `saved toilet event, fields=[time, blood]` is fine; the specific degree of blood in stool is not.
- Release builds do not emit debug-level logs by default.

## Crashes and Analytics

- The first version **does not integrate** any third-party analytics or crash SDK. If one is to be added later, it requires a separate change + ADR, and proof that it will not send health content off the device.
- Telemetry is off by default; turning it on must be an explicit user choice.

## Data Corruption

- On a read failure: do not silently discard, and do not keep rendering empty data as "no records".
- Show it as "unable to read", keep the original file, and provide export for troubleshooting.
