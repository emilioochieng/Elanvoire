-- Run after 0001_init.sql

-- Product badge shown on the storefront ("New", "Best-loved"...)
alter table products add column if not exists tag text;

-- Newsletter sign-ups (anyone can subscribe, only admins can read)
create table if not exists newsletter_subscribers (
  id uuid primary key default gen_random_uuid(),
  email text not null check (length(email) <= 254 and email ~* '^[^@\s]+@[^@\s]+\.[^@\s]+$'),
  created_at timestamptz not null default now()
);
create unique index if not exists newsletter_email_key on newsletter_subscribers (lower(email));
alter table newsletter_subscribers enable row level security;
create policy "anyone can subscribe" on newsletter_subscribers for insert with check (true);
create policy "admin read subscribers" on newsletter_subscribers for select using (is_admin());

-- Lets a guest's browser poll ONE order's payment status using its unguessable id.
create or replace function order_status(p_id uuid)
returns table(status text, mpesa_receipt text, total_kes integer, payment_result_desc text)
language sql stable security definer set search_path = public as $$
  select o.status, o.mpesa_receipt, o.total_kes, o.payment_result_desc from orders o where o.id = p_id
$$;
grant execute on function order_status(uuid) to anon, authenticated;

-- Create a profile row automatically for every new sign-up
create or replace function handle_new_user() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into profiles (id, full_name) values (new.id, new.raw_user_meta_data->>'full_name')
  on conflict do nothing;
  return new;
end $$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
  for each row execute function handle_new_user();
insert into profiles (id) select id from auth.users on conflict do nothing;

-- Admins can replace / remove product images
create policy "admin update product images" on storage.objects for update
  using (bucket_id = 'product-images' and is_admin());
create policy "admin delete product images" on storage.objects for delete
  using (bucket_id = 'product-images' and is_admin());

-- Sample catalogue (replace with your real brands and products from the admin dashboard)
insert into brands (name) values ('Elanvoire Edit'), ('Beauty Ritual'), ('Modern Heirloom'), ('Elanvoire Living'), ('Form & Flow')
on conflict (name) do nothing;
insert into categories (name, slug) values ('Fashion','fashion'), ('Beauty','beauty'), ('Accessories','accessories'), ('Lifestyle','lifestyle')
on conflict (name) do nothing;

insert into products (brand_id, category_id, name, slug, price_kes, stock, tag, image_url)
select b.id, c.id, v.name, v.slug, v.price, 20, v.tag, v.img
from (values
 ('Elanvoire Edit','Fashion','The Everyday Tailored Blazer','everyday-tailored-blazer',6500,'The edit','https://images.unsplash.com/photo-1591047139829-d91aecb6caea?auto=format&fit=crop&w=700&q=80'),
 ('Beauty Ritual','Beauty','Glow Essentials Set','glow-essentials-set',2800,'Best-loved','https://images.unsplash.com/photo-1608248543803-ba4f8c70ae0b?auto=format&fit=crop&w=700&q=80'),
 ('Modern Heirloom','Accessories','Sculptural Gold Earrings','sculptural-gold-earrings',1900,'New','https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?auto=format&fit=crop&w=700&q=80'),
 ('Elanvoire Living','Lifestyle','The Sunday Scent Candle','sunday-scent-candle',2200,'A little luxury','https://images.unsplash.com/photo-1603006905003-be475563bc59?auto=format&fit=crop&w=700&q=80'),
 ('Form & Flow','Accessories','Soft Structure Shoulder Bag','soft-structure-shoulder-bag',4200,'Customer favourite','https://images.unsplash.com/photo-1584917865442-de89df76afd3?auto=format&fit=crop&w=700&q=80'),
 ('Beauty Ritual','Beauty','Daily Hydration Serum','daily-hydration-serum',1750,'Everyday essential','https://images.unsplash.com/photo-1620916566398-39f1143ab7be?auto=format&fit=crop&w=700&q=80'),
 ('Elanvoire Edit','Fashion','Relaxed Linen Co-ord','relaxed-linen-co-ord',4800,'New','https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=700&q=80'),
 ('Elanvoire Living','Lifestyle','The Ritual Trinket Tray','ritual-trinket-tray',1600,'Thoughtful gift','https://images.unsplash.com/photo-1610701596007-11502861dcfa?auto=format&fit=crop&w=700&q=80')
) as v(brand, cat, name, slug, price, tag, img)
join brands b on b.name = v.brand
join categories c on c.name = v.cat
on conflict (slug) do nothing;