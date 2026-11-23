-- 페이스팔 v3.0 기록 추가 (Supabase SQL Editor에 붙여넣고 Run, 여러 번 실행해도 중복 없음)
-- 1) 제이님 기록: 특수체육교육과 로드웍 3.55km 26:36 (2026-11-23 14:41) → 이 코스를 만든 계정(created_by)으로 저장
-- 2) 더미 러너 '달린이 지석'(기존 1위보다 조금 빠름), '정인feel'(조금 느림) → 천호지 한 바퀴 + 로드웍
do $$
declare
  rw text; me uuid; js uuid := '11111111-0000-4000-8000-00000000a001'; jf uuid := '11111111-0000-4000-8000-00000000a002';
  c record; best int; km numeric;
begin
  select id, created_by into rw, me from courses where name like '%로드웍%' order by created_at limit 1;
  if rw is null then raise exception '로드웍 코스를 찾지 못했어요'; end if;

  -- 더미 계정 (로그인 불가, 표시용)
  insert into auth.users (id, instance_id, aud, role, email, encrypted_password, created_at, updated_at, raw_app_meta_data, raw_user_meta_data)
  values (js,'00000000-0000-0000-0000-000000000000','authenticated','authenticated','jiseok.dummy@pacepal.local','',now(),now(),'{"provider":"email"}','{}'),
         (jf,'00000000-0000-0000-0000-000000000000','authenticated','authenticated','jeongin.dummy@pacepal.local','',now(),now(),'{"provider":"email"}','{}')
  on conflict (id) do nothing;
  insert into profiles (id, nick, level, pace, pacer, tier) values
    (js,'달린이 지석','중급자',330,'rabbit',2),(jf,'정인feel','초급자',420,'turtle',1)
  on conflict (id) do update set nick = excluded.nick;

  -- 제이님 로드웍 기록
  if me is not null and not exists (select 1 from runs where user_id = me and course = rw and time_sec = 1596) then
    insert into runs (user_id, course, km, time_sec, avg_pace, run_type, vib, created_at, mode)
    values (me, rw, 3.55, 1596, 449, 'metro', 0, '2026-11-23 14:41:00+09', 'gps');
  end if;

  -- 더미 기록: 코스별 현재 1위 기록 기준 ±
  for c in select id, coalesce((select km from courses where id = x.id), x.dkm) as km from (values ('ch1', 1.9::numeric), (rw, 3.55::numeric)) as x(id, dkm) loop
    select min(time_sec) into best from runs where course = c.id and user_id not in (js, jf) and coalesce(mode,'') not like '%part%';
    best := coalesce(best, round(c.km * 400));
    if not exists (select 1 from runs where user_id = js and course = c.id) then
      insert into runs (user_id, course, km, time_sec, avg_pace, run_type, vib, created_at, mode)
      values (js, c.id, c.km, round(best * 0.97), round(best * 0.97 / c.km, 1), 'late', 0, now() - interval '2 days', 'gps');
    end if;
    if not exists (select 1 from runs where user_id = jf and course = c.id) then
      insert into runs (user_id, course, km, time_sec, avg_pace, run_type, vib, created_at, mode)
      values (jf, c.id, c.km, round(best * 1.05), round(best * 1.05 / c.km, 1), 'glue', 1, now() - interval '1 day', 'gps');
    end if;
  end loop;
end $$;

-- 확인
select p.nick, r.course, r.km, r.time_sec, r.created_at from runs r join profiles p on p.id = r.user_id
where p.nick in ('달린이 지석','정인feel') or r.time_sec = 1596 order by r.course, r.time_sec;
