# Mixins & Plugins

Mixins:
- MergeConfig.js
- isCardWithAttributes.js
- HasShopify.js
- HasProductsPaginated.js
- redirectEvent.js
- keyboardEvents.js
- offlineMixin.js
- aeropayEvent.js

Plugins:
- plugins/config.js

## Modernization Plan (Action + Complexity)

Mixins → Hooks/Context:
- MergeConfig.js — refactor to config context; complexity: M
- isCardWithAttributes.js — refactor to utility/hook; complexity: S
- HasShopify.js — refactor into provider adapter; complexity: M
- HasProductsPaginated.js — replace with React Query; complexity: M
- redirectEvent.js — refactor; complexity: S
- keyboardEvents.js — replace with hooks; complexity: M
- offlineMixin.js — replace (Workbox + React Query cache); complexity: L
- aeropayEvent.js — refactor or remove; complexity: M

Plugins:
- plugins/config.js — replace with React context/provider; complexity: M
