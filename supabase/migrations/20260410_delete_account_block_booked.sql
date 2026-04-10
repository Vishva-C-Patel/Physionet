create or replace function public.delete_my_account_data()
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
begin
  if uid is null then
    raise exception 'Not authenticated';
  end if;

  -- Block deletion if there are active booked appointments.
  if exists (
    select 1
    from public.customers c
    where c.id = uid
  ) and exists (
    select 1
    from public.appointments a
    where a.customer_id = uid
      and a.status = 'booked'
  ) then
    raise exception 'Cannot delete account while booked appointments exist. Please cancel or complete them first.';
  end if;

  if exists (
    select 1
    from public.physiotherapists p
    where p.id = uid
  ) and exists (
    select 1
    from public.appointments a
    where a.physio_id = uid
      and a.status = 'booked'
  ) then
    raise exception 'Cannot delete account while booked appointments exist. Please cancel or complete them first.';
  end if;

  -- User-scoped article activity
  delete from public.article_interactions where user_id = uid;
  delete from public.user_article_feed where user_id = uid;
  delete from public.user_interest_events where user_id = uid;

  -- Customer path
  if exists (select 1 from public.customers c where c.id = uid) then
    update public.physio_availability_slots s
    set is_booked = false
    where s.id in (
      select a.slot_id
      from public.appointments a
      where a.customer_id = uid
    );

    delete from public.exercise_progress where customer_id = uid;
    delete from public.program_redemptions where customer_id = uid;
    delete from public.appointments where customer_id = uid;
    delete from public.customers where id = uid;
  end if;

  -- Physiotherapist path
  if exists (select 1 from public.physiotherapists p where p.id = uid) then
    update public.physio_availability_slots s
    set is_booked = false
    where s.id in (
      select a.slot_id
      from public.appointments a
      where a.physio_id = uid
    );

    delete from public.program_redemptions
    where code_id in (select pac.id from public.program_access_codes pac where pac.physio_id = uid)
       or program_id in (select pp.id from public.physio_programs pp where pp.physio_id = uid);

    delete from public.exercise_progress
    where exercise_id in (select pv.id from public.physio_videos pv where pv.physio_id = uid)
       or program_id in (select pp.id from public.physio_programs pp where pp.physio_id = uid);

    delete from public.program_exercises
    where exercise_id in (select pv.id from public.physio_videos pv where pv.physio_id = uid)
       or program_id in (select pp.id from public.physio_programs pp where pp.physio_id = uid);

    delete from public.appointments where physio_id = uid;
    delete from public.program_access_codes where physio_id = uid;
    delete from public.physio_reviews where physio_id = uid;
    delete from public.physio_specializations where physio_id = uid;
    delete from public.physio_availability_templates where physio_id = uid;
    delete from public.physio_availability_slots where physio_id = uid;
    delete from public.physio_videos where physio_id = uid;
    delete from public.physio_programs where physio_id = uid;
    delete from public.physiotherapists where id = uid;
  end if;
end;
$$;

revoke all on function public.delete_my_account_data() from public;
grant execute on function public.delete_my_account_data() to authenticated;
