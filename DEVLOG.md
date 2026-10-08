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

*In progress. Days 1 to 3 so far, the full entry gets written on Sunday. Full notes: [day 1](days/day-01.md), [day 2](days/day-02.md), [day 3](days/day-03.md).*

**What I covered**

Day 1 was setup. Before writing any queries I wanted to be sure the environment was actually right, so the whole session was getting a practice database built and checking it.

I made a free Supabase project (Frankfurt) and ran the seed file (`seed/sql_practice_seed.sql`) once in the SQL Editor. It builds five tables: accounts, invoices, users, employees, and events, which has 200,000 generated rows saved for the performance weeks. Row Level Security is on for every table with no policies, so none of it is reachable through the project's public API. The SQL Editor runs as the `postgres` role, so I can still query everything from there.

Row counts only prove the data arrived, so I ran three more checks my coach gave me: RLS is on for all five tables, the events table covers 10 users from 1 January to late September, and the two planted problems in invoices are there.

Day 2 was `SELECT` and `WHERE`. I finished SQLBolt lessons 1 to 3, then did edit-this-query drills on my own `accounts` and `invoices` tables: adding a column, filtering by country, "not on the free plan", and invoices over 25. I stopped after four drills and finished the rest the next morning: `BETWEEN` for a date range, `IN` for a list of plans, and a check where I predicted row counts before running three queries. I got 2 of 3.

Day 3 was NULL. NULL means unknown, not zero or empty, so any comparison with it is unknown too, and `WHERE` quietly drops those rows. I saw it on my own invoices, where the pending invoice 107 disappears from "every invoice that isn't 25". Then I explained it to an imaginary customer, wrote the fix, and looked at `COALESCE`.

**What broke**

Nothing in the setup, but my understanding wobbled. After running the seed it showed up as a saved query called "SQL Sample Data", and I thought that might be the data itself, so editing it would break everything. I also couldn't work out where the database came from, because no step ever said "create a database".

And I missed one of the planted problems. I spotted invoice 107 with no amount in the Table Editor, but not invoice 108, which belongs to an account that doesn't exist. Nothing in that row looks wrong on its own.

On day 2 my syntax broke a lot. I used double quotes around a text value, which Postgres reads as a column name. I wrote `NOT =`, which isn't a thing. I put columns in the `WHERE` instead of the `SELECT`. All three are in [errors.md](errors.md).

The `BETWEEN` drill took four goes, all about quotes. No quotes means Postgres reads 2026-09-01 as a sum. One pair of quotes round the whole range means it reads it as one broken date. In the check I got the `AND` and `OR` one wrong, because `AND` happens first. On day 3 I wrote `= NULL` in SQLBolt, and I flipped `<>` to mean "exactly" a day after using it correctly. Those are in the errors log too.

My first customer explanation of NULL had the right idea but said `<>` means "around that number", and my marbles analogy never got to the point.

**What clicked**

The seed is a recipe, not the data. It ran once, built the tables and filled them, and now the tables exist on their own. The saved snippet is just text. The database only changes when a statement actually runs. I proved it by running `SELECT * FROM accounts;` in a fresh tab with the seed closed.

Also: you can spot a NULL by eye, but a broken link between two tables only shows up when you query across them.

`SELECT` controls columns, `WHERE` controls rows. Adding a column never changes the row count. And my row-count predictions were right even when my syntax wasn't: I called 2 rows for `> 25` and 6 for `>= 25`, and both were correct. My reasoning is ahead of my syntax, and the syntax is the easier half to fix.

`WHERE` goes down the table one row at a time and asks yes or no. Yes stays, no is gone. When I'm unsure what a query returns, I walk the table by hand. And `WHERE` only keeps a definite yes, which is exactly why NULL rows vanish without an error. A customer whose query silently comes back empty may well have `= NULL` buried in it.

`COALESCE` changes what's shown, not what's stored, and the fallback has to be true. The question every time: is my fallback true, or just convenient?

**What changed in my approach**

Checking the setup properly before writing any queries, not just trusting the row counts. One new query tab per session, named by day, and the seed renamed so I only open it on purpose. Running it again wipes and rebuilds everything, so it's my reset button.

The big one: one step per message. Partway through day 2 I got a whole day's material at once and couldn't tell where I was meant to be running things. One instruction, I do it, I paste my query, I get feedback, next step. That's the format from now on.

I also stopped when I got tired instead of pushing through. Practising tired teaches my brain that SQL feels hard, and that's the thing I'm trying to undo.

Before writing a query I ask what should count. Should failed invoices be in September's list? That's the first question in a real ticket too. I also asked for the data table to be shown with every question, because I nearly worked off the wrong one.

And I pushed back on a rewrite that was too technical for the customer I'd pictured. A non-technical customer needs plain language. A Supabase customer is usually a developer who'd find an analogy a bit patronising. Pick the register for the person, and always give the fix, not just the reason.
