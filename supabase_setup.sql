-- ═══════════════════════════════════════════
-- SONARA — Supabase Setup
-- Ejecuta esto en: Supabase → SQL Editor → New query
-- ═══════════════════════════════════════════

-- 1. TAREAS
create table if not exists fd_tasks (
  id          text primary key,
  user_id     uuid references auth.users(id) on delete cascade,
  text        text not null,
  cat         text not null default 'work',
  type        text not null default 'daily',
  done        boolean not null default false,
  subtasks    jsonb not null default '[]',
  timer_min   integer,
  created_at  timestamptz not null default now()
);

-- 2. HORARIO
create table if not exists fd_schedule (
  user_id  uuid primary key references auth.users(id) on delete cascade,
  config   jsonb not null default '{}'
);

-- 3. ESTADÍSTICAS (racha)
create table if not exists fd_stats (
  user_id  uuid primary key references auth.users(id) on delete cascade,
  streak   integer not null default 0,
  last_day date
);

-- 4. SEGURIDAD: solo cada usuario ve sus datos
alter table fd_tasks    enable row level security;
alter table fd_schedule enable row level security;
alter table fd_stats    enable row level security;

-- Políticas fd_tasks
create policy "usuario ve sus tareas"
  on fd_tasks for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- Políticas fd_schedule
create policy "usuario ve su horario"
  on fd_schedule for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- Políticas fd_stats
create policy "usuario ve sus stats"
  on fd_stats for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
