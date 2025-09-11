export type NavLink = {
  title: string;
  label?: string;
  description?: string;
  path: string;
  order?: number; // negative for featured
  image?: string;
};

export const NAV: NavLink[] = [
  { title: "Products", label: "Browse", description: "All products", path: "/products", order: 1 },
  { title: "Brands", label: "Explore", description: "Shop by brand", path: "/brands", order: 2 },
  { title: "On Sale", label: "Deals", description: "Promotions", path: "/on-sale", order: 3 },
];
