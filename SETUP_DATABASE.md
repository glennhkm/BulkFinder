# SETUP DATABASE SUPABASE

## 0. IMPORTANT - Disable Email Confirmation untuk Development

**Supabase Dashboard → Authentication → Settings:**
- Set **Enable email confirmations** = `OFF/Disabled`

Atau jalankan SQL ini:
```sql
-- Disable email confirmation
UPDATE auth.config 
SET email_confirm_changes = false;

-- Auto-confirm existing users yang belum confirmed
UPDATE auth.users 
SET email_confirmed_at = now(), 
    updated_at = now() 
WHERE email_confirmed_at IS NULL;
```

## 1. Setup Storage Buckets (Sudah dibuat dengan nama: profilepictures, ktp, storepictures)

Karena bucket sudah dibuat dengan nama:
- `profilepictures` (Public) - untuk foto profil
- `ktp` (Public) - untuk foto KTP seller  
- `storepictures` (Public) - untuk foto toko

Skip langkah ini dan lanjut ke setup policies.

## 2. SIMPLE SOLUTION - Disable RLS untuk semua table

```sql
-- Disable RLS on users table untuk testing
ALTER TABLE users DISABLE ROW LEVEL SECURITY;

-- Disable RLS on sellers table untuk testing
ALTER TABLE sellers DISABLE ROW LEVEL SECURITY;

-- Disable RLS on storage.objects untuk testing
ALTER TABLE storage.objects DISABLE ROW LEVEL SECURITY;
```

## 3. ALTERNATIVE - Setup permissive policies (jika ingin tetap pakai RLS)

```sql
-- Drop existing policies if any untuk users table
DROP POLICY IF EXISTS "Enable insert during registration" ON users;
DROP POLICY IF EXISTS "Users can read own profile" ON users;
DROP POLICY IF EXISTS "Users can update own profile" ON users;
DROP POLICY IF EXISTS "Allow all operations on users" ON users;

-- Enable RLS dan buat policy permissive untuk users
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all operations on users" ON users
USING (true) WITH CHECK (true);

-- Drop existing policies if any untuk sellers table
DROP POLICY IF EXISTS "Sellers can read own data" ON sellers;
DROP POLICY IF EXISTS "Sellers can update own data" ON sellers;
DROP POLICY IF EXISTS "Enable insert for seller registration" ON sellers;
DROP POLICY IF EXISTS "Allow all operations on sellers" ON sellers;

-- Enable RLS dan buat policy permissive untuk sellers
ALTER TABLE sellers ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all operations on sellers" ON sellers
USING (true) WITH CHECK (true);

-- Drop existing storage policies if any
DROP POLICY IF EXISTS "Anyone can view profile pictures" ON storage.objects;
DROP POLICY IF EXISTS "Users can upload own profile picture" ON storage.objects;
DROP POLICY IF EXISTS "Users can upload own KTP" ON storage.objects;
DROP POLICY IF EXISTS "Users can upload own store pictures" ON storage.objects;
DROP POLICY IF EXISTS "Allow all storage operations" ON storage.objects;

-- Very permissive storage policies
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all storage operations" ON storage.objects
USING (true) WITH CHECK (true);
```

## 4. Test Registration

1. Run: `flutter run`
2. Navigate to registration
3. Fill all required fields
4. Check Supabase Dashboard → Authentication → Users
5. Check Supabase Dashboard → Table Editor → users
6. Check Supabase Dashboard → Table Editor → sellers 

## Supabase RLS Policy untuk Notifikasi

Agar aplikasi bisa insert notifikasi saat stok barang diperbarui, tambahkan policy berikut di tabel `notifications`:

```sql
-- Izinkan semua user insert notifikasi (untuk testing/dev)
CREATE POLICY "Allow all insert on notifications"
  ON public.notifications
  FOR INSERT
  USING (true);
```

> Untuk produksi, sebaiknya batasi policy, misal hanya user login:
```sql
CREATE POLICY "Allow insert for authenticated users"
  ON public.notifications
  FOR INSERT
  USING (auth.uid() IS NOT NULL);
```

Setelah policy ini aktif, fitur update stok & notifikasi akan berjalan lancar. 