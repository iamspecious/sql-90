-- SQL coaching practice dataset
-- Run once in the Supabase SQL editor (Dashboard > SQL Editor > New query > paste > Run).
-- Safe to re-run: it drops and rebuilds everything.
-- RLS is switched on with no policies, so nothing is exposed through your project's API.
-- The SQL editor runs as the postgres role, which bypasses RLS, so you can still query everything.

DROP TABLE IF EXISTS events, users, invoices, accounts, employees CASCADE;

-- 1. accounts + invoices: the exact diagnostic data. Small on purpose, so you can reason by hand.
CREATE TABLE accounts (
  id      int PRIMARY KEY,
  name    text NOT NULL,
  plan    text NOT NULL,
  country text NOT NULL
);

INSERT INTO accounts VALUES
  (1, 'Acme',   'pro',  'DE'),
  (2, 'Birch',  'free', 'IE'),
  (3, 'Cobalt', 'pro',  'US'),
  (4, 'Dune',   'team', 'DE'),
  (5, 'Ember',  'free', 'US');

-- No foreign key on account_id on purpose: invoice 108 points at an account that doesn't exist.
CREATE TABLE invoices (
  id         int PRIMARY KEY,
  account_id int NOT NULL,
  amount     numeric(10,2),
  status     text NOT NULL,
  issued_at  date NOT NULL
);

INSERT INTO invoices VALUES
  (101, 1,  25.00, 'paid',    '2026-07-03'),
  (102, 1,  25.00, 'paid',    '2026-08-03'),
  (103, 1,  25.00, 'failed',  '2026-09-03'),
  (104, 3,  25.00, 'paid',    '2026-08-15'),
  (105, 3,  30.00, 'paid',    '2026-09-15'),
  (106, 4, 599.00, 'paid',    '2026-09-01'),
  (107, 4,   NULL, 'pending', '2026-10-01'),
  (108, 6,  10.00, 'paid',    '2026-09-20');

-- 2. users: one account has many users; invited_by points at another user (self-join practice).
CREATE TABLE users (
  id         int PRIMARY KEY,
  account_id int NOT NULL REFERENCES accounts(id),
  email      text NOT NULL UNIQUE,
  invited_by int REFERENCES users(id),
  created_at timestamptz NOT NULL
);

INSERT INTO users VALUES
  (1,  1, 'ana@acme.io',      NULL, '2026-06-01 09:00+00'),
  (2,  1, 'ben@acme.io',      1,    '2026-06-03 14:20+00'),
  (3,  1, 'cara@acme.io',     2,    '2026-07-11 08:45+00'),
  (4,  2, 'dev@birch.dev',    NULL, '2026-06-15 17:30+00'),
  (5,  3, 'eli@cobalt.com',   NULL, '2026-07-01 10:00+00'),
  (6,  3, 'fay@cobalt.com',   5,    '2026-07-02 11:15+00'),
  (7,  4, 'gus@dune.co',      NULL, '2026-08-20 13:00+00'),
  (8,  4, 'hana@dune.co',     7,    '2026-08-21 09:10+00'),
  (9,  4, 'ivo@dune.co',      7,    '2026-08-21 09:40+00'),
  (10, 5, 'jo@ember.app',     NULL, '2026-09-30 22:05+00');

-- 3. employees: a reporting chain for recursive CTE practice.
CREATE TABLE employees (
  id         int PRIMARY KEY,
  name       text NOT NULL,
  title      text NOT NULL,
  manager_id int REFERENCES employees(id)
);

INSERT INTO employees VALUES
  (1, 'Rosa',  'CEO',                 NULL),
  (2, 'Sam',   'Head of Support',     1),
  (3, 'Tariq', 'Head of Engineering', 1),
  (4, 'Uma',   'Support Lead EMEA',   2),
  (5, 'Vik',   'Support Engineer',    4),
  (6, 'Wren',  'Support Engineer',    4),
  (7, 'Xia',   'Backend Engineer',    3),
  (8, 'Yusuf', 'Support Engineer',    2);

-- 4. events: 200,000 generated rows, deliberately with NO index on user_id or created_at.
-- This is the table for the indexes and EXPLAIN weeks. setseed makes the random data repeatable.
CREATE TABLE events (
  id         bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id    int NOT NULL,
  event_type text NOT NULL,
  properties jsonb NOT NULL,
  created_at timestamptz NOT NULL
);

SELECT setseed(0.42);

INSERT INTO events (user_id, event_type, properties, created_at)
SELECT
  1 + floor(random() * 10)::int,
  (ARRAY['login', 'query_run', 'api_call', 'export'])[1 + floor(random() * 4)::int],
  jsonb_build_object(
    'duration_ms', floor(random() * 2000)::int,
    'client',      (ARRAY['web', 'cli', 'js-sdk', 'python-sdk'])[1 + floor(random() * 4)::int],
    'ok',          random() > 0.05
  ),
  timestamptz '2026-01-01 00:00+00' + random() * interval '270 days'
FROM generate_series(1, 200000);

ANALYZE events;

-- Lock everything down from the public API (see note at top).
ALTER TABLE accounts  ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoices  ENABLE ROW LEVEL SECURITY;
ALTER TABLE users     ENABLE ROW LEVEL SECURITY;
ALTER TABLE employees ENABLE ROW LEVEL SECURITY;
ALTER TABLE events    ENABLE ROW LEVEL SECURITY;

-- Sanity check: should return accounts 5, invoices 8, users 10, employees 8, events 200000.
SELECT 'accounts' AS table_name, count(*) FROM accounts
UNION ALL SELECT 'invoices',  count(*) FROM invoices
UNION ALL SELECT 'users',     count(*) FROM users
UNION ALL SELECT 'employees', count(*) FROM employees
UNION ALL SELECT 'events',    count(*) FROM events;
