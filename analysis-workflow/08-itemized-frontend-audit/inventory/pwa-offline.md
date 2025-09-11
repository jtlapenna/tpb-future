# PWA & Offline

Files:
- static/js/sw-cache-sync.js (custom SW)
- static/js/upload.js (chunked uploads)
- assets/js/GSDevTools3.min.js (dev-only)
- static/js/jquery.onScreenKeyboard*.js (kiosk input)

Modernization Plan:
- Replace SW with Workbox (precaching + runtime strategies)
- Integrate React Query cache + background sync
- Replace jQuery keyboard with React-native kiosk keyboard component or modern lib

Action + Complexity:
- Workbox SW — replace; M
- background sync — refactor; M
- keyboard — replace; M
