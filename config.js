// Public settings. The anon key is safe to expose: Row Level Security protects your data.
// Leave SUPABASE_URL blank to run the storefront in demo mode with sample products.
window.ELANVOIRE = {
  SUPABASE_URL: "",        // e.g. https://abcdxyz.supabase.co
  SUPABASE_ANON_KEY: "",   // Project Settings > API > anon public key
  DELIVERY_NAIROBI: 300,   // display-only estimate; must match create-order/index.ts
  DELIVERY_OTHER: 500
};