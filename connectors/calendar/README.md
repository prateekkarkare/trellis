# Calendar connector

**Role**: locked external commitments + observed energy-pattern detection (when did you actually do the work?).

## Setup

Pick a provider:

- **Google Calendar** — use Google's API. Service-account JSON in `~/.config/trellis/google-cal.json`.
- **Apple Calendar (iCloud)** — CalDAV; requires an app-specific password.
- **Outlook / Microsoft 365** — Graph API.
- **CalDAV (Fastmail, ProtonMail Bridge, self-hosted)** — generic CalDAV client.

Edit `connectors/connectors.yml`:

```yaml
calendar:
  enabled: true
  type: api
  provider: google
  auth:
    credentials_path: ~/.config/trellis/google-cal.json
  options:
    calendars: [primary, work]
    lookahead_days: 14
```

## What the protocols use it for

- **WEEKLY_REVIEW Phase 1**: pull next week's locked slots — anything the coordinator must schedule around (meetings, kids' pickups, fixed obligations).
- **WEEKLY_REVIEW Phase 1, signal triage**: cross-reference completed tasks against calendar — *"the run scheduled 7am Tue happened, but you also had a 6:30am meeting block — that's a scheduling collision, not a willpower failure."*
- **SEASON_TRANSITION**: identify recurring locked slots that will persist into next season.

## What it does NOT do

- Doesn't write back to your calendar. The mentor proposes; you put it on the calendar yourself. (P2: the user writes by talking. Even calendar entries.)
- Doesn't poll continuously. Read happens at protocol time only.
