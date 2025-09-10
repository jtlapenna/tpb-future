// Const use to set time kiosk waits until next update
export const WAIT_TIME = 3 * 60000
export const RETRY_TIMES = 5
export const RETRY_LAPSUS = 2
export const SETTINGS_TIME = 180000
export const WAIT_TIME_VERIFY_EXPIRED = 1000 * 60 * 10

export const RETRY_COOLDOWN = 5 * 1000
export const PRODUCTS_PAGE_SIZE = 25

export const API_ENVIROMENTS =
[
  {
    name: 'prod',
    url: 'https://api-prod.thepeakbeyond.com/api/v1'
  },
  {
    name: 'dev',
    url: 'https://tpb-api.aimservices.tech/api/v1'
  },

  {
    name: 'staging',
    url: 'https://tpb-api-stage.thepeakbeyond.com/api/v1'
  }
]
export const CATEGORIES_WITH_PRIORITY = [
  { name: 'flower',
    order: 1
  },
  {
    name: 'pre-rolls',
    order: 2
  },
  {
    name: 'vapes',
    order: 3
  },
  {
    name: 'cardtridge',
    order: 4
  },
  {
    name: 'edibles',
    order: 5
  },
  {
    name: 'concentrate',
    order: 6
  },
  {
    name: 'concentrates',
    order: 6
  },
  {
    name: 'drink',
    order: 7
  },
  {
    name: 'drinks',
    order: 7
  },
  {
    name: 'capsules',
    order: 8
  },
  {
    name: 'tincture',
    order: 8
  },
  {
    name: 'tinctures',
    order: 8
  },
  {
    name: 'topical',
    order: 9
  },
  {
    name: 'topicals',
    order: 9
  },
  {
    name: 'merch',
    order: 10
  }
]

export const firebaseConfig = {
  apiKey: 'AIzaSyCz9dleLp1Gi6Lp2uFbO7_gWh3CkeID9Qc',
  authDomain: 'aim-tpb.firebaseapp.com',
  databaseURL: 'https://aim-tpb-default-rtdb.firebaseio.com',
  projectId: 'aim-tpb',
  storageBucket: 'aim-tpb.appspot.com',
  messagingSenderId: '32483309252',
  appId: '1:32483309252:web:63fa6d94373d7e91443b91',
  measurementId: 'G-79PHZ2TW17'
}

export const VAPID_KEY = 'BNVJJbc2eyG242hsdchlyC1Ptq7Z56OCSR0pXxpFK4oBbxB3TML6Vdb5XYdcqvm2kzp8Ql7bIwQpK9pAgzViFiw'
export const SERVER_KEY = 'AAAAVIUQtMI:APA91bHovGU46VCvvq5rS5QXeAh_7zpR1p4xNq7iVynisjT0r4cdP6_aulxAjEC7CouveEDNVLYEk9a_8WxJwpOzWQUS_RK9bKJ2fKhvD1kWkyEmZywvYSKmVZewztams24c_7SKzITl'

export const SYNONYMOUS = [
  ['concentrates', 'concentrate', 'extract', 'extracts'],
  ['fragrance', 'fragrances'],
  ['doughnut', 'doughnuts'],
  ['petcare', 'petcares'],
  ['candy', 'candies'],
  ['food', 'foods'],
  ['spirits', 'spirit'],
  ['wildcard', 'wildcards'],
  ['charity', 'charities'],
  ['cannabier', 'cannabiers'],
  ['accessories', 'accessory'],
  ['clubs', 'club'],
  ['hops', 'Hop'],
  ['plants', 'plant'],
  ['beer', 'beers'],
  ['drinks', 'drink'],
  ['capsules', 'capsule'],
  ['merch', 'merchandising', 'merchant'],
  ['flavor line', 'flavor lines'],
  ['strain collection', 'strain collections'],
  ['interactive displays', 'interactive display'],
  ['vapes', 'vape'],
  ['tinctures', 'tincture'],
  ['topicals', 'topical'],
  ['pre rolls', 'pre roll'],
  ['flowers', 'flower'],
  ['edible', 'edibles'],
  ['pain reilef', 'pain', 'pain relief', 'reilef pain']
]
// Animations start and gap times
export const GSAP_ANIMATION = {
  duration: 0.5,
  tween: 0.2,
  append: 0.2
}
