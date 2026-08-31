-- STUDY RATS ONLINE: execute AFTER the original schema.
-- This adds safe group creation/join RPCs and a profile trigger.

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, display_name)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'display_name', split_part(new.email,'@',1))
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute procedure public.handle_new_user();

create or replace function public.create_study_group(p_name text)
returns public.groups
language plpgsql
security definer set search_path = public
as $$
declare
  g public.groups;
  code text;
begin
  if auth.uid() is null then raise exception 'Você precisa estar logada.'; end if;
  code := 'RATS-' || upper(substr(encode(gen_random_bytes(4),'hex'),1,4));
  insert into public.groups(name,invite_code,owner_id) values(trim(p_name),code,auth.uid()) returning * into g;
  insert into public.group_members(group_id,user_id,role) values(g.id,auth.uid(),'owner');
  insert into public.point_rules(group_id) values(g.id);
  return g;
end;
$$;

create or replace function public.join_study_group(p_code text)
returns public.groups
language plpgsql
security definer set search_path = public
as $$
declare g public.groups;
begin
  if auth.uid() is null then raise exception 'Você precisa estar logada.'; end if;
  select * into g from public.groups where upper(invite_code)=upper(trim(p_code)) limit 1;
  if g.id is null then raise exception 'Código de grupo não encontrado.'; end if;
  insert into public.group_members(group_id,user_id,role) values(g.id,auth.uid(),'member')
  on conflict (group_id,user_id) do nothing;
  return g;
end;
$$;

grant execute on function public.create_study_group(text) to authenticated;
grant execute on function public.join_study_group(text) to authenticated;

-- Allow the RPC functions to work without exposing group lookup by code.
-- The returned group is limited to the group the user just joined/created.
