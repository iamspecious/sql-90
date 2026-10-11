# SQL 90

A 90-day SQL challenge, learning Postgres in public.

## The goal

Go from foundational SQL to comfortable with complex Postgres queries, so I can work as a Support Engineer at a Postgres company like Supabase. That means reading a stranger's query and seeing what it does, writing joins, aggregates, CTEs and window functions without reaching for a reference, and debugging slow or wrong queries the way a support engineer would.

- **Start:** Tuesday 6 October 2026
- **End:** Sunday 3 January 2027
- **Schedule:** 90 days, Saturdays off, so 77 sessions
- **Rule:** every query in this repo is my own work, including the wrong ones

## Phases

| Week | Dates | Phase |
|---|---|---|
| 1 | 6 Oct to 11 Oct | Read before you write |
| 2 | 12 Oct to 18 Oct | Joins |
| 3 | 19 Oct to 25 Oct | Aggregation |
| 4 | 26 Oct to 1 Nov | Combining tools |
| 5 | 2 Nov to 8 Nov | Subqueries |
| 6 | 9 Nov to 15 Nov | CTEs |
| 7 | 16 Nov to 22 Nov | Window functions 1 |
| 8 | 23 Nov to 29 Nov | Window functions 2 |
| 9 | 30 Nov to 6 Dec | Recursion and Postgres features |
| 10 | 7 Dec to 13 Dec | Performance |
| 11 | 14 Dec to 20 Dec | Debugging like support |
| 12 | 21 Dec to 27 Dec | Interview drills |
| 13 | 28 Dec to 3 Jan | Mock rounds |

## Progress

Weeks run Monday to Sunday, with Sunday as the review day. Updated every Sunday. Confidence is my own rating, 1 (lost) to 5 (could explain it to a customer).

| Week | Sessions done | Avg confidence (1-5) | Takeaway |
|---|---|---|---|
| 1 | 5/5 | 3 | Can now predict how NULLs, AND/OR and sorting behave; still need to read the whole question back |
| 2 | 0/6 | | |
| 3 | 0/6 | | |
| 4 | 0/6 | | |
| 5 | 0/6 | | |
| 6 | 0/6 | | |
| 7 | 0/6 | | |
| 8 | 0/6 | | |
| 9 | 0/6 | | |
| 10 | 0/6 | | |
| 11 | 0/6 | | |
| 12 | 0/6 | | |
| 13 | 0/6 | | |

## Baseline

Before day 1 I took a diagnostic to see where I was starting from. The questions and my original answers, unedited, are in [baseline/diagnostic.md](baseline/diagnostic.md).

## Repo layout

| Path | What it holds |
|---|---|
| [days/](days/) | One file per session, `day-NN.sql`, with my queries and comments |
| [seed/](seed/) | The practice dataset I query against: [sql_practice_seed.sql](seed/sql_practice_seed.sql), run once in the Supabase SQL editor |
| [baseline/](baseline/) | The day-0 diagnostic |
| [DEVLOG.md](DEVLOG.md) | Weekly write-ups, newest first |
| [errors.md](errors.md) | Every mistake worth remembering and the rule it taught me |
