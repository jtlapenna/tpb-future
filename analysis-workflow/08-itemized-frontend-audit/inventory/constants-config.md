# Constants & Config

Files:
- src/const/globals.js
- static/js/config.js
- functions/config.js

Modernization Plan:
- Replace with typed config (env-based) and React context/provider
- Remove globals; enforce per-domain config modules

Action + Complexity:
- typed config module — replace; S
- context/provider — replace; S
- deglobalize usage — refactor; M
