-- 프로필 사진(아바타): users.avatar_url + avatars 공용 버킷 + anon 정책
-- 라이브 1회 적용(재실행 안전).

alter table users add column if not exists avatar_url text;

insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do nothing;

drop policy if exists "avatars anon read"   on storage.objects;
drop policy if exists "avatars anon insert" on storage.objects;
drop policy if exists "avatars anon update" on storage.objects;
drop policy if exists "avatars anon delete" on storage.objects;
create policy "avatars anon read"   on storage.objects for select using (bucket_id = 'avatars');
create policy "avatars anon insert" on storage.objects for insert with check (bucket_id = 'avatars');
create policy "avatars anon update" on storage.objects for update using (bucket_id = 'avatars');
create policy "avatars anon delete" on storage.objects for delete using (bucket_id = 'avatars');
