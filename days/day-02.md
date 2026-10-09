# Day 2: SELECT and WHERE

**Dates:** Wed 7 Oct 2026 (part 1), Thu 8 Oct 2026 (part 2)
**Week 1:** Read before you write
**Status:** Done. 2 of 3 check predictions right, rewrite correct.
**Confidence (1-5):** 3

## Goal

Get comfortable picking columns with `SELECT` and filtering rows with `WHERE`, on my own practice data in Supabase.

## What I did

- Finished SQLBolt lessons 1 to 3 (SELECT, and filtering with conditions on numbers and text). These were fine.
- Moved into the Supabase SQL Editor and worked through edit-this-query drills on my `accounts` and `invoices` tables, changing one query a step at a time.

## A change to how I work

Partway in, I got a whole day's material in one message and couldn't tell where I was meant to be running things. That's a wall of information, and it's exactly what doesn't work for me. I asked for one step per message instead. That worked much better: one instruction, I do it, I paste my query, I get feedback, next step. This is the format from now on.

## The drills, including what I got wrong

**Starter.** Ran the given query to see the data.

```sql
SELECT name, plan
FROM accounts;
```

5 rows.

**Add a column.** Added `country` to the SELECT. Still 5 rows.
Takeaway: `SELECT` controls columns, `WHERE` controls rows. Adding a column never changes the row count.

**Only accounts in Germany.**

My first attempt:

```sql
SELECT name, plan
FROM accounts WHERE country LIKE "DE%" ;
```

Two problems:
1. Double quotes. In Postgres, double quotes mean the name of a column or table, so this looks for a column called `DE%` and errors with `column "DE%" does not exist`. Text values always go in single quotes.
2. `LIKE 'DE%'` means "starts with DE". I wanted an exact match, so `=` says what I actually mean.

Fixed:

```sql
SELECT name, plan
FROM accounts WHERE country = 'DE' ;
```

2 rows (Acme, Dune).

**Accounts not on the free plan.**

I first tried `plan NOT = 'free'`, which is a syntax error. Then I tried this, which worked:

```sql
SELECT name, plan
FROM accounts WHERE plan NOT LIKE 'free' ;
```

3 rows. It works because `LIKE` with no `%` is just an exact match. But it says "doesn't match a pattern" when I mean "isn't equal to".

Why `NOT =` failed: `NOT` goes in front of a whole condition (`NOT plan = 'free'`), not in front of the `=`. The normal way to write "not equal" is `<>` (Postgres also accepts `!=`).

Final version:

```sql
SELECT name, plan
FROM accounts
WHERE plan <> 'free';
```

3 rows (Acme, Cobalt, Dune).

**Invoices over 25.**

My first attempt:

```sql
SELECT * from invoices WHERE id, amount >= 25;
```

Two problems:
1. The columns I want to see go after `SELECT`. `WHERE` only takes conditions, so `WHERE id, amount ...` is a syntax error.
2. "Over 25" is `>`, not `>=`.

What I did get right was the prediction. I reasoned that `> 25` would give 2 rows and `>= 25` would give 6, depending on whether 25 itself counts. That's correct for both. I also left out invoice 107 without thinking about it. Its amount is NULL, so it isn't "greater than" anything. That's Day 3.

Fixed:

```sql
SELECT id, amount FROM invoices WHERE amount > 25;
```

2 rows (105 and 106).

A trick for `>` and `<`, which I always mix up: read it out loud with the column first. "amount > 25" is "amount is greater than 25". If it sounds wrong, flip it.

## Where I stopped on day one

I got tired after the fourth drill and stopped rather than push through. Practising tired just teaches my brain that SQL feels hard, which is the thing I'm trying to undo. Picking up tomorrow with:

- Drill: invoices issued in September 2026, using `BETWEEN`
- Drill: accounts on the pro or team plan, using `IN`
- The check: predict the row count of three queries before running them, including one that tests whether `AND` or `OR` happens first
- One rewrite using brackets

## Takeaways from part 1

- Single quotes for text values. Double quotes are for column and table names.
- Use the operator that says what I mean: `=` for exact matches, `LIKE` only for patterns, `<>` for "not equal".
- Columns go in `SELECT`, conditions go in `WHERE`.
- My row-count reasoning is better than my syntax right now. The syntax is the easier half to fix.

---

# Part 2 (Thu 8 Oct)

Came back after sleeping on it and finished the last two drills and the check before starting Day 3. About 25 minutes.

## Drill: invoices issued in September 2026

Before writing anything I asked whether failed invoices should count, because that changes the answer (4 with failed, 3 without). The task didn't filter on status, so the answer was 4. Checking what should count before writing the query is a habit I want to keep, because it's the first question in a real ticket too.

Getting the syntax right took four goes:

```sql
-- Attempt 1: no WHERE, no column to check, no quotes on the dates
SELECT id, issued_at FROM invoices BETWEEN 2026-09-01 AND 2026-09-30;

-- Attempt 2: WHERE and column added, still no quotes.
-- Without quotes, 2026-09-01 is a sum (2026 minus 9 minus 1), so Postgres
-- complains about comparing a date with a number.
SELECT id, issued_at FROM invoices WHERE issued_at BETWEEN 2026-09-01 AND 2026-09-30;

-- Attempt 3: one pair of quotes around the whole range, so Postgres
-- reads it as a single (broken) date
SELECT id, issued_at FROM invoices WHERE issued_at BETWEEN '2026-09-01 AND 2026-09-30';

-- Final: each date gets its own quotes, AND stays outside them. 4 rows.
SELECT id, issued_at FROM invoices WHERE issued_at BETWEEN '2026-09-01' AND '2026-09-30';
```

The pattern to remember: `WHERE column BETWEEN 'start' AND 'end'`. Each value gets its own quotes, and keywords stay outside them.

## Drill: accounts on the pro or team plan

I got stuck on what "how many rows" meant here, because I was picturing the result grouped by plan. It isn't. `WHERE` goes down the table one row at a time and asks a yes or no question. Yes means the row stays, no means it's gone completely. The result is just the list of rows that said yes.

Doing that walk by hand gave me 3 (Acme, Cobalt, Dune), which was right.

```sql
SELECT * FROM accounts WHERE plan IN ('pro', 'team');
```

The `IN` part was correct. The task only asked for `name`, though, so `SELECT *` was more than asked for. Fine for exploring, but in an interview or a ticket I should return exactly what was asked.

## The check

I predicted the row count before running each one. I also asked for the data table to be shown with every question from now on, because I nearly worked off the wrong table.

| Query | My prediction | Actual | |
|---|---|---|---|
| `WHERE status = 'paid' AND amount > 20` | 5 | 5 | Right |
| `WHERE plan = 'free' OR plan = 'pro' AND country = 'DE'` | 1 | 3 | Wrong |
| `WHERE account_id = 1 OR status = 'pending'` | 4 | 4 | Right |

**Q2, the one I missed.** I read it as "(free or pro) and in Germany", which gives just Acme. But `AND` is applied before `OR`, so Postgres actually reads it as:

```
plan = 'free'  OR  (plan = 'pro' AND country = 'DE')
```

That keeps both free accounts wherever they are, plus Acme. 3 rows.

**Q3 reasoning.** Account 1 has three invoices, which pass the first condition, and invoice 107 is pending, which passes the second. With `OR` a row only needs one, so 4.

**The rewrite.** Make Q2 mean what I originally thought it meant:

```sql
SELECT * FROM accounts
WHERE (plan = 'free' OR plan = 'pro') AND country = 'DE';
```

1 row, Acme. Brackets force the order. `WHERE plan IN ('free', 'pro') AND country = 'DE'` does the same thing.

## Day 2 takeaways

- Single quotes for text and dates, one pair per value. Double quotes are for column and table names.
- Columns go in `SELECT`, conditions go in `WHERE`.
- Use the operator that says what I mean: `=` for exact matches, `LIKE` only for patterns, `<>` for "not equal".
- `AND` happens before `OR`. If I mix them, I add brackets so nobody has to remember.
- When I'm unsure what a query returns, I walk down the table row by row and ask yes or no.
