# Analytics

Files:
- src/analytics/analytics.js
- src/analytics/events.js
- src/analytics/EventsAPI.js
- src/analytics/db.js
- src/analytics/example.js
- gsClient usage across components (tracking events)

Modernization Plan:
- Replace with unified analytics SDK and event schema; add batching and retries
- Persist with IndexedDB via React Query cache or lightweight client
- Wire to BI pipeline (Segment/Snowplow or custom)

Action + Complexity:
- analytics SDK integration — replace; M
- event schema + mapping — refactor; M
- storage/queue — refactor; M
- instrumentation sweep — refactor; L
