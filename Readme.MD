# Elanvoire: storefront + admin + backend

```
storefront/index.html   the shop (works in demo mode with no setup)
storefront/admin.html   admin dashboard: products, images, stock, orders
storefront/config.js    your Supabase URL + anon key (the only file you edit)
supabase/migrations/    0001_init.sql, 0002_storefront.sql
supabase/functions/     create-order (prices cart, sends M-Pesa prompt), payment-callback
```

## 1. Database
1. Create a Supabase project.
2. In the SQL editor run `0001_init.sql`, then `0002_storefront.sql` (adds 8 sample products you can edit or hide).

## 2. M-Pesa functions
Get Daraja sandbox keys at developer.safaricom.co.ke (sandbox shortcode 174379 and its passkey).
```bash
supabase link --project-ref <ref>
supabase secrets set MPESA_ENV=sandbox MPESA_CONSUMER_KEY=... MPESA_CONSUMER_SECRET=... \
  MPESA_SHORTCODE=174379 MPESA_PASSKEY=... MPESA_CALLBACK_SECRET=$(openssl rand -hex 24)
supabase functions deploy create-order
supabase functions deploy payment-callback --no-verify-jwt
```

## 3. Connect the storefront
Edit `storefront/config.js`: paste your project URL and anon key (Project Settings, API).
Open `storefront/index.html` through any static host. Products now load from the database and checkout sends a real M-Pesa prompt.

## 4. Become admin
1. Supabase dashboard, Authentication, Users: add a user (your email and a strong password).
2. SQL editor: `update profiles set is_admin = true where id = (select id from auth.users where email = 'you@example.com');`
3. Open `storefront/admin.html` and sign in. Add products, upload images, set stock, and move orders through paid, shipped, delivered.

## 5. Host it
Any static host works (GitHub Pages, Netlify, Cloudflare Pages). Then, in `create-order/index.ts`, change `Access-Control-Allow-Origin` from `*` to your site's address and redeploy.
Keep `admin.html` unlinked from the shop; it is protected by login and row-level security, not by its URL.

## Before taking real money
- Safaricom Go-Live: a Paybill or Till plus Daraja approval, then `MPESA_ENV=production`. For a Till also set `MPESA_TXN_TYPE=CustomerBuyGoodsOnline` and `MPESA_PARTY_B=<till>`.
- Delivery fees live in two places that must match: `create-order/index.ts` (authoritative) and `config.js` (display only).
- Replace the placeholder footer messages (delivery, returns, contact, policies, social links) in `index.html` with real details.
- Card payments need a Kenyan gateway (Pesapal, Flutterwave, Paystack). Not included.
- No confirmation emails or customer accounts yet. Customers see their M-Pesa receipt and order ref on screen; you manage orders in the admin.
- Stock is reduced when payment is confirmed, so two buyers can briefly hold the last item. For high-demand drops, reserve stock at order creation.
- Publish privacy, returns and terms pages, and check your obligations under the Kenya Data Protection Act.
- Test: wrong PIN, cancelled prompt, insufficient funds, a tampered cart price, and a double callback.