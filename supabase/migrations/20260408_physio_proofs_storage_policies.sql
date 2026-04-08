-- Physio proof uploads must be possible before physiotherapists row exists.
-- This keeps onboarding secure by limiting each user to their own folder:
--   physio_proofs / physios/<auth.uid()>/...

-- Ensure bucket exists (private by default)
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'physio_proofs',
  'physio_proofs',
  false,
  10485760,
  array['image/jpeg', 'image/png', 'image/jpg', 'application/pdf']
)
on conflict (id) do update
set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

-- Remove old policies if they exist (idempotent migration)
drop policy if exists "Physio proofs upload own folder" on storage.objects;
drop policy if exists "Physio proofs read own folder" on storage.objects;
drop policy if exists "Physio proofs update own folder" on storage.objects;
drop policy if exists "Physio proofs delete own folder" on storage.objects;

-- INSERT: only authenticated user into own folder
create policy "Physio proofs upload own folder"
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'physio_proofs'
  and split_part(name, '/', 1) = 'physios'
  and split_part(name, '/', 2) = auth.uid()::text
);

-- SELECT: user can only read own proofs
create policy "Physio proofs read own folder"
on storage.objects
for select
to authenticated
using (
  bucket_id = 'physio_proofs'
  and split_part(name, '/', 1) = 'physios'
  and split_part(name, '/', 2) = auth.uid()::text
);

-- UPDATE: user can only update own proofs
create policy "Physio proofs update own folder"
on storage.objects
for update
to authenticated
using (
  bucket_id = 'physio_proofs'
  and split_part(name, '/', 1) = 'physios'
  and split_part(name, '/', 2) = auth.uid()::text
)
with check (
  bucket_id = 'physio_proofs'
  and split_part(name, '/', 1) = 'physios'
  and split_part(name, '/', 2) = auth.uid()::text
);

-- DELETE: user can only delete own proofs
create policy "Physio proofs delete own folder"
on storage.objects
for delete
to authenticated
using (
  bucket_id = 'physio_proofs'
  and split_part(name, '/', 1) = 'physios'
  and split_part(name, '/', 2) = auth.uid()::text
);
