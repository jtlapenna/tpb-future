# API Integrations

Core:
- api/api.js
- api/http.js
- api/urls.js
- api/LocalRepo.js / RemoteRepo.js / repo.js
- api/db.js / dbconfig.js (IndexedDB/Dexie)

Domains:
- products: ProductsLocal.js / ProductsRemote.js / ProductsRepo.js
- categories: CategoriesLocal.js / CategoriesRemote.js / CategoriesRepo.js
- brands: BrandsLocal.js / BrandsRemote.js / BrandsRepo.js
- feature-tags: FeatureTagsLocal.js / FeatureTagsRemote.js / FeatureTagsRepo.js
- articles: ArticlesLocal.js / ArticlesRemote.js / ArticlesRepo.js
- rfid: RFIDLocal.js / RFIDRemote.js / RFIDRepo.js
- messaging: messaging/index.js, messaging/fb.js


## Modernization Plan (Action + Complexity)

Core:
- api/http.js — replace (typed axios/fetch wrapper, interceptors); complexity: M
- api/urls.js — replace (env-based config); complexity: S
- LocalRepo/RemoteRepo/repo.js — replace (React Query + normalized APIs); complexity: M
- db.js / dbconfig.js — refactor (local cache strategy); complexity: M

Domains:
- products — replace; complexity: L
- categories — replace; complexity: M
- brands — replace; complexity: M
- feature-tags — replace; complexity: M
- articles — refactor/move to CMS; complexity: M
- rfid — refactor/port (hardware abstraction); complexity: L
- messaging (fb) — refactor/move to admin; complexity: M
