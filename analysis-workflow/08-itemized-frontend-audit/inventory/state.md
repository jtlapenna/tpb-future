# State (Vuex)

Store:
- store.js

Modules:
- cart.js
- products.js

Notes:
- Consider additional modules (user, settings) if present elsewhere.

## Modernization Plan (Action + Complexity)

Legend: action = replace | port | refactor | delete; complexity = S | M | L | XL

- store.js — replace (Redux Toolkit store + React Query); complexity: M
- modules/cart.js — replace (port Redux Toolkit cart from e-comm); complexity: L
- modules/products.js — replace (React Query + RTK slices); complexity: L
- (new) user module — port from e-comm user slice; complexity: M
