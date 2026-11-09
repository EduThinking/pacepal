-- 페이스팔 Supabase 스키마. Supabase 대시보드 > SQL Editor 에 붙여넣고 Run.

create table if not exists profiles (
  id uuid primary key references auth.users on delete cascade,
  nick text not null,
  level text default '초급자',
  pace int default 390,
  pacer text default 'rabbit',
  tier int default 0,
  created_at timestamptz default now()
);

create table if not exists runs (
  id bigint generated always as identity primary key,
  user_id uuid not null references profiles(id) on delete cascade,
  course text not null,
  km numeric not null,
  time_sec int not null,
  avg_pace numeric not null,
  run_type text,
  vib int default 0,
  created_at timestamptz default now()
);

create table if not exists posts (
  id bigint generated always as identity primary key,
  user_id uuid not null references profiles(id) on delete cascade,
  cat text not null,
  title text not null,
  body text not null,
  created_at timestamptz default now()
);

create table if not exists comments (
  id bigint generated always as identity primary key,
  post_id bigint not null references posts(id) on delete cascade,
  user_id uuid not null references profiles(id) on delete cascade,
  body text not null,
  created_at timestamptz default now()
);

create table if not exists likes (
  post_id bigint not null references posts(id) on delete cascade,
  user_id uuid not null references profiles(id) on delete cascade,
  primary key (post_id, user_id)
);

create table if not exists messages (
  id bigint generated always as identity primary key,
  room text not null,
  user_id uuid not null references profiles(id) on delete cascade,
  body text not null,
  created_at timestamptz default now()
);
create index if not exists messages_room_idx on messages(room, created_at desc);

create table if not exists reservations (
  id bigint generated always as identity primary key,
  course text not null,
  run_date date not null,
  slot text not null,
  user_id uuid not null references profiles(id) on delete cascade,
  unique (course, run_date, slot, user_id)
);

create table if not exists conditions (
  user_id uuid not null references profiles(id) on delete cascade,
  day date not null,
  mood int,
  note text,
  primary key (user_id, day)
);

-- RLS: 로그인한 사용자는 모두 읽기, 본인 것만 쓰기
alter table profiles enable row level security;
alter table runs enable row level security;
alter table posts enable row level security;
alter table comments enable row level security;
alter table likes enable row level security;
alter table messages enable row level security;
alter table reservations enable row level security;
alter table conditions enable row level security;

create policy "read all" on profiles for select to authenticated using (true);
create policy "own insert" on profiles for insert to authenticated with check (auth.uid() = id);
create policy "own update" on profiles for update to authenticated using (auth.uid() = id);

create policy "read all" on runs for select to authenticated using (true);
create policy "own insert" on runs for insert to authenticated with check (auth.uid() = user_id);

create policy "read all" on posts for select to authenticated using (true);
create policy "own insert" on posts for insert to authenticated with check (auth.uid() = user_id);
create policy "own delete" on posts for delete to authenticated using (auth.uid() = user_id);

create policy "read all" on comments for select to authenticated using (true);
create policy "own insert" on comments for insert to authenticated with check (auth.uid() = user_id);
create policy "own delete" on comments for delete to authenticated using (auth.uid() = user_id);

create policy "read all" on likes for select to authenticated using (true);
create policy "own insert" on likes for insert to authenticated with check (auth.uid() = user_id);
create policy "own delete" on likes for delete to authenticated using (auth.uid() = user_id);

create policy "read all" on messages for select to authenticated using (true);
create policy "own insert" on messages for insert to authenticated with check (auth.uid() = user_id);

create policy "read all" on reservations for select to authenticated using (true);
create policy "own insert" on reservations for insert to authenticated with check (auth.uid() = user_id);
create policy "own delete" on reservations for delete to authenticated using (auth.uid() = user_id);

create policy "own all" on conditions for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- 실시간 채팅: messages 테이블을 realtime 에 추가
alter publication supabase_realtime add table messages;
