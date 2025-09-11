# Scoring & Estimation Rubric

## Fields per Item
- category: pages | components | state | api | mixins | styling | build | router | analytics | firebase | pwa
- item: primary identifier (e.g., ScreenHome.vue)
- route (optional): for pages
- action: replace | port | refactor | delete
- complexity: S | M | L | XL
- difficulty: 1-5 (maps from complexity: S=2, M=3, L=4, XL=5; adjust as needed)
- human_min/human_max: hour range for human-only dev
- ai_min/ai_max: hour range with AI-assisted dev (0.6x-0.7x of human)
- risk: low | medium | high
- deps: key dependencies (state, API, POS, etc.)
- notes: clarifying context

## Complexity → Human Hours
- S: 4-8h
- M: 12-24h
- L: 32-64h
- XL: 80-120h

## AI Assistance Adjustment
- ai_min = human_min × 0.6
- ai_max = human_max × 0.7

## Prioritization (optional)
- priority = business_impact (1-5) × (risk_weight 0.5 + effort_weight 0.5) with lower effort favored
- Use tags: core-flow, kiosk-only, admin-only to batch scheduling
