# Day 1: Setting up a practice database

**Date:** Tue 6 Oct 2026
**Week 1:** Read before you write
**Time:** about 30 minutes
**Confidence (1-5):** 3

## Goal

Get a real Postgres database running that I can practise against for the next 90 days, so every query I write runs against the same kind of database a Supabase customer uses.

## What I set up

- A free Supabase project (Frankfurt region). Creating the project is what creates the Postgres database. There's no separate "make a database" step.
- A practice dataset, loaded by running a seed script (`seed/sql_practice_seed.sql`) once in the SQL Editor. It builds five tables in the `public` schema:

| Table | Rows | What it's for |
|---|---|---|
| accounts | 5 | Small customer table, small enough to reason about by hand |
| invoices | 8 | Joins and aggregation practice. Has two planted problems (see below) |
| users | 10 | Self-joins (who invited whom) |
| employees | 8 | A reporting chain for recursive queries later on |
| events | 200,000 | Generated data with no indexes, saved for the performance weeks |

- Row Level Security is switched on for every table with no policies, so none of this is reachable through the project's public API. The SQL Editor runs as the `postgres` role, which bypasses RLS, so I can still query everything from there.

## What confused me

**1. Was the snippet the database?**
After running the seed, it showed up on the left of the SQL Editor as a saved query called "SQL Sample Data". My worry was that this *was* the data, and if I edited or broke it, nothing would work any more. Surely the seed should live in the database and I'd query that instead?

**2. Where did the database even come from?**
None of the steps said "create a database". I just made a project and pasted a script in.

## How I worked through it

The seed script is a recipe, not the data. When I ran it, Postgres followed the instructions once:

- `DROP TABLE IF EXISTS ...` clears out any old copies
- `CREATE TABLE ...` builds each empty table
- `INSERT INTO ... VALUES ...` fills each one with rows

After that, the tables exist in the database on their own. The saved snippet is just text. Editing or deleting it does nothing to the data, because **the database only changes when a statement actually runs.**

The layers, top to bottom:

> project (sql-90) → database (comes with the project) → schema `public` → tables (made by the seed) → rows (inserted by the seed)

I proved it by opening a fresh query tab and running `SELECT * FROM accounts;`. All five accounts came back without the seed being open anywhere.

A useful side effect: running the whole seed again wipes and rebuilds the five tables, so it works as a reset button if I ever break my practice data. I renamed it so I only ever open it on purpose.

## How I checked the setup was right

Row counts only prove the data arrived, so I ran three more checks. These queries were given to me by my coach, and I ran them and compared the results. I haven't learned to write these yet.

**Security is on**

```sql
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY tablename;
```

All five tables show `rowsecurity = true`.

**The big table generated properly**

```sql
SELECT count(DISTINCT user_id)  AS users,
       min(created_at)::date    AS first_day,
       max(created_at)::date    AS last_day
FROM events;
```

10 users, starting 2026-01-01, ending late September 2026.

**The planted problems are there**

```sql
SELECT id, account_id, amount, status
FROM invoices
WHERE amount IS NULL
   OR account_id NOT IN (SELECT id FROM accounts);
```

| id | account_id | amount | status |
|---|---|---|---|
| 107 | 4 | NULL | pending |
| 108 | 6 | 10.00 | paid |

I found the first one myself by looking in the Table Editor: invoice 107 has no amount. I missed the second one, because nothing in the row looks wrong. Invoice 108 belongs to account 6, and there is no account 6. You can spot a NULL by eye, but a broken link between tables only shows up when you query across them.

## Self-check

**Q:** If I deleted the "SQL Sample Data" snippet, what would happen to the `accounts` table?

**My answer:** Nothing, because it's not running anything from the database.

**Correction:** Right answer, slightly off reasoning. The snippet is saved text, and the tables already exist on their own. Deleting text doesn't run any SQL, and only a statement that runs (like `DROP TABLE`) can change the database.

## What I'm taking into Day 2

- Saved queries are text. The database only changes when a statement runs.
- One new query tab per session, named by day, so my work stays separate from the reset script.
- Next up: SELECT and WHERE.
