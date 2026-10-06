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

*In progress. Day 1 notes so far, the full entry gets written on Sunday.*

**What I covered**

Day 1 was setup. Before writing any queries I wanted to be sure the environment was actually right, so today was about getting the practice database built and checking it.

I ran the seed file (`seed/sql_practice_seed.sql`) in the Supabase SQL editor. It builds five tables:

- `accounts` and `invoices`, the small set from my diagnostic, small enough to reason about by hand
- `users`, where `invited_by` points at another user
- `employees`, a reporting chain for the recursion week
- `events`, 200,000 generated rows with no indexes, saved for the performance weeks

The seed ends with a row count per table, so that was my check: 5 accounts, 8 invoices, 10 users, 8 employees and 200,000 events. Row level security is switched on with no policies, so none of this is exposed through the project's API. The SQL editor runs as the `postgres` role, which is why I can still query everything from there.

**What broke**


**What clicked**


**What changed in my approach**

Checking the setup first instead of jumping straight into queries. If the data is wrong, every answer after it is wrong too, and I'd have no way of knowing.
