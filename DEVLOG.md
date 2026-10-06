# Devlog

One entry per week, written on Sunday. Newest first.

<!--
Template. Copy this block to the top of the entries and fill it in.

## Week N: Phase name (D Mon to D Mon)

**What I covered**


**What broke**


**What clicked**


**What changed in my approach**

-->

<!-- Entries start below this line -->

## Week 1: Read before you write (6 Oct to 12 Oct)

*In progress. Day 1 notes so far, the full entry gets written on Sunday. Full notes: [days/day-01.md](days/day-01.md).*

**What I covered**

Day 1 was setup. Before writing any queries I wanted to be sure the environment was actually right, so the whole session was getting a practice database built and checking it.

I made a free Supabase project (Frankfurt) and ran the seed file (`seed/sql_practice_seed.sql`) once in the SQL Editor. It builds five tables: accounts, invoices, users, employees, and events, which has 200,000 generated rows saved for the performance weeks. Row Level Security is on for every table with no policies, so none of it is reachable through the project's public API. The SQL Editor runs as the `postgres` role, so I can still query everything from there.

Row counts only prove the data arrived, so I ran three more checks my coach gave me: RLS is on for all five tables, the events table covers 10 users from 1 January to late September, and the two planted problems in invoices are there.

**What broke**

Nothing in the setup, but my understanding wobbled. After running the seed it showed up as a saved query called "SQL Sample Data", and I thought that might be the data itself, so editing it would break everything. I also couldn't work out where the database came from, because no step ever said "create a database".

And I missed one of the planted problems. I spotted invoice 107 with no amount in the Table Editor, but not invoice 108, which belongs to an account that doesn't exist. Nothing in that row looks wrong on its own.

**What clicked**

The seed is a recipe, not the data. It ran once, built the tables and filled them, and now the tables exist on their own. The saved snippet is just text. The database only changes when a statement actually runs. I proved it by running `SELECT * FROM accounts;` in a fresh tab with the seed closed.

Also: you can spot a NULL by eye, but a broken link between two tables only shows up when you query across them.

**What changed in my approach**

Checking the setup properly before writing any queries, not just trusting the row counts. One new query tab per session, named by day, and the seed renamed so I only open it on purpose. Running it again wipes and rebuilds everything, so it's my reset button.
