
-- =========================================
-- PLAYDAY DATABASE
-- =========================================

create extension if not exists pgcrypto;

-- =========================================
-- 1. WORKOUTS
-- =========================================

create table public.workouts (
  id uuid primary key default gen_random_uuid(),

  title text not null,
  slug text not null unique,
  description text not null,

  category text not null,

  mood_tags text[] not null default '{}',

  duration_minutes integer not null
    check (duration_minutes between 1 and 180),

  difficulty text not null
    check (difficulty in ('beginner', 'intermediate', 'advanced')),

  equipment text[] not null default '{}',

  image_path text,

  xp_reward integer not null default 20
    check (xp_reward between 1 and 100),

  is_featured boolean not null default false,

  is_published boolean not null default true,

  created_at timestamptz not null default now()
);

create index workouts_category_idx
on public.workouts(category);

create index workouts_published_idx
on public.workouts(is_published);

-- =========================================
-- 2. EXERCISES
-- =========================================

create table public.exercises (
  id uuid primary key default gen_random_uuid(),

  name text not null,

  instructions text not null,

  duration_seconds integer not null
    check (duration_seconds between 1 and 3600),

  image_path text,

  safety_note text,

  created_at timestamptz not null default now()
);

-- =========================================
-- 3. WORKOUT EXERCISES
-- =========================================

create table public.workout_exercises (
  id uuid primary key default gen_random_uuid(),

  workout_id uuid not null
    references public.workouts(id)
    on delete cascade,

  exercise_id uuid not null
    references public.exercises(id)
    on delete cascade,

  position integer not null,

  reps text,

  unique(workout_id, position)
);

create index workout_exercises_workout_idx
on public.workout_exercises(workout_id);

-- =========================================
-- 4. USER PROFILES
-- =========================================

create table public.profiles (
  id uuid primary key
    references auth.users(id)
    on delete cascade,

  display_name text not null default 'Playday Friend',

  avatar_url text,

  xp integer not null default 0
    check (xp >= 0),

  level integer not null default 1
    check (level >= 1),

  current_streak integer not null default 0
    check (current_streak >= 0),

  longest_streak integer not null default 0
    check (longest_streak >= 0),

  last_workout_date date,

  preferred_duration integer not null default 10,

  experience text not null default 'beginner'
    check (experience in ('beginner', 'intermediate', 'advanced')),

  equipment text[] not null default '{}',

  created_at timestamptz not null default now()
);

-- =========================================
-- 5. WORKOUT COMPLETIONS
-- =========================================

create table public.workout_completions (
  id uuid primary key default gen_random_uuid(),

  user_id uuid not null
    references auth.users(id)
    on delete cascade,

  workout_id uuid not null
    references public.workouts(id)
    on delete restrict,

  duration_seconds integer not null
    check (duration_seconds between 1 and 14400),

  xp_earned integer not null default 0,

  completed_at timestamptz not null default now()
);

create index completions_user_idx
on public.workout_completions(user_id);

create index completions_date_idx
on public.workout_completions(completed_at);

-- =========================================
-- 6. FAVORITES
-- =========================================

create table public.favorites (
  id uuid primary key default gen_random_uuid(),

  user_id uuid not null
    references auth.users(id)
    on delete cascade,

  workout_id uuid not null
    references public.workouts(id)
    on delete cascade,

  created_at timestamptz not null default now(),

  unique(user_id, workout_id)
);

create index favorites_user_idx
on public.favorites(user_id);

-- =========================================
-- 7. ACHIEVEMENTS
-- =========================================

create table public.achievements (
  id uuid primary key default gen_random_uuid(),

  slug text not null unique,

  name text not null,

  description text not null,

  icon_path text,

  xp_reward integer not null default 0
);

-- =========================================
-- 8. USER ACHIEVEMENTS
-- =========================================

create table public.user_achievements (
  id uuid primary key default gen_random_uuid(),

  user_id uuid not null
    references auth.users(id)
    on delete cascade,

  achievement_id uuid not null
    references public.achievements(id)
    on delete cascade,

  unlocked_at timestamptz not null default now(),

  unique(user_id, achievement_id)
);

create index user_achievements_user_idx
on public.user_achievements(user_id);

-- =========================================
-- AUTOMATIC PROFILE CREATION
-- =========================================

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin

  insert into public.profiles (
    id,
    display_name
  )

  values (
    new.id,
    coalesce(
      new.raw_user_meta_data ->> 'display_name',
      'Playday Friend'
    )
  );

  return new;

end;
$$;

create trigger on_auth_user_created
after insert on auth.users
for each row
execute function public.handle_new_user();

-- =========================================
-- ENABLE ROW LEVEL SECURITY
-- =========================================

alter table public.workouts enable row level security;
alter table public.exercises enable row level security;
alter table public.workout_exercises enable row level security;
alter table public.profiles enable row level security;
alter table public.workout_completions enable row level security;
alter table public.favorites enable row level security;
alter table public.achievements enable row level security;
alter table public.user_achievements enable row level security;

-- =========================================
-- REVOKE DEFAULT CLIENT PRIVILEGES
-- =========================================

revoke all on public.workouts from anon, authenticated;
revoke all on public.exercises from anon, authenticated;
revoke all on public.workout_exercises from anon, authenticated;
revoke all on public.profiles from anon, authenticated;
revoke all on public.workout_completions from anon, authenticated;
revoke all on public.favorites from anon, authenticated;
revoke all on public.achievements from anon, authenticated;
revoke all on public.user_achievements from anon, authenticated;

-- Public catalogue: read only
grant select on public.workouts to anon, authenticated;
grant select on public.exercises to anon, authenticated;
grant select on public.workout_exercises to anon, authenticated;
grant select on public.achievements to anon, authenticated;

-- User-specific information
grant select, update on public.profiles to authenticated;

grant select on public.workout_completions to authenticated;

grant select, insert, delete on public.favorites to authenticated;

grant select on public.user_achievements to authenticated;

-- =========================================
-- PUBLIC CATALOGUE POLICIES
-- =========================================

create policy "Anyone can view published workouts"
on public.workouts
for select
to anon, authenticated
using (is_published = true);

create policy "Anyone can view exercises"
on public.exercises
for select
to anon, authenticated
using (true);

create policy "Anyone can view workout exercise links"
on public.workout_exercises
for select
to anon, authenticated
using (
  exists (
    select 1
    from public.workouts w
    where w.id = workout_id
    and w.is_published = true
  )
);

create policy "Anyone can view achievements"
on public.achievements
for select
to anon, authenticated
using (true);

-- =========================================
-- PROFILE POLICIES
-- =========================================

create policy "Users can view their own profile"
on public.profiles
for select
to authenticated
using ((select auth.uid()) = id);

create policy "Users can update their own profile"
on public.profiles
for update
to authenticated
using ((select auth.uid()) = id)
with check ((select auth.uid()) = id);

-- =========================================
-- COMPLETION POLICIES
-- =========================================

create policy "Users can view their own completions"
on public.workout_completions
for select
to authenticated
using ((select auth.uid()) = user_id);

-- No direct client insert permission.
-- Completion will be handled by a database function.

-- =========================================
-- FAVORITE POLICIES
-- =========================================

create policy "Users can view their own favorites"
on public.favorites
for select
to authenticated
using ((select auth.uid()) = user_id);

create policy "Users can add their own favorites"
on public.favorites
for insert
to authenticated
with check ((select auth.uid()) = user_id);

create policy "Users can delete their own favorites"
on public.favorites
for delete
to authenticated
using ((select auth.uid()) = user_id);

-- =========================================
-- USER ACHIEVEMENT POLICIES
-- =========================================

create policy "Users can view their own achievements"
on public.user_achievements
for select
to authenticated
using ((select auth.uid()) = user_id);
