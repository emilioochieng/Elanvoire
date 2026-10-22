// Public settings. The anon key is safe to expose: Row Level Security protects your data.
// Leave SUPABASE_URL blank to run the storefront in demo mode with sample products.
window.ELANVOIRE = {
  SUPABASE_URL: "",        // e.g. https://abcdxyz.supabase.co
  SUPABASE_ANON_KEY: "",   // Project Settings > API > anon public key
  DELIVERY_FEE: 300,       // flat delivery rate in KSh (display only; must match the DELIVERY_FEE_KES secret)
  WHATSAPP_NUMBER: "254705216347",  // digits only, e.g. 254712345678 (07... also works). Leave blank to hide the button
  WHATSAPP_MESSAGE: "Hello Elanvoire, I'd like some help.",
  EMAIL: "emilioochieng44@gmail.com",
  SUPPORT_PHONE: "+254748973405",   // shown in the footer as "Call ..."
  INSTAGRAM: "opre.ssure",       // username only (no spaces). CONFIRM this is your exact Instagram username
  TIKTOK: "O.PRESSURE",
  TELEGRAM: "O.PRESSURE"                      // username only (letters, digits, underscore; 5+ characters). Blank hides the link
};