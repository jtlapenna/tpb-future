# Firebase Functions & Messaging

Files:
- functions/index.js, functions/config.js (cloud functions)
- static/js/firebase-messaging-sw.js (messaging SW)
- src/api/messaging/* (fb.js, index.js)

Modernization Plan:
- Re-evaluate need; move backend cron/async tasks server-side
- If kept, isolate to admin app; replace messaging with service worker strategy aligned with PWA

Action + Complexity:
- functions migration — refactor/replace; M-L
- messaging SW update — replace; M
