# Day 2 (part 1): SELECT and WHERE

**Date:** Wed 7 Oct 2026
**Week 1:** Read before you write
**Status:** Paused partway. Finishing tomorrow before Day 3.

## Goal

Get comfortable picking columns with `SELECT` and filtering rows with `WHERE`, on my own practice data in Supabase.

## What I did

* Finished SQLBolt lessons 1 to 3 (SELECT, and filtering with conditions on numbers and text). These were fine.
* Moved into the Supabase SQL Editor and worked through edit-this-query drills on my `accounts` and `invoices` tables, changing one query a step at a time.

## A change to how I work

Partway in, I got a whole day's material in one message and couldn't tell where I was meant to be running things. That's a wall of information, and it's exactly what doesn't work for me. I asked for one step per message instead. That worked much better: one instruction, I do it, I paste my query, I get feedback, next step. This is the format from now on.

## The drills, including what I got wrong

### Starter

Ran the given query to see the data.

```sql
SELECT name, plan
FROM accounts;

```

5 rows.

### Add a column

Added `country` to the SELECT. Still 5 rows. Takeaway: `SELECT` controls columns, `WHERE` controls rows. Adding a column never changes the row count.

### Only accounts in Germany

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

### Accounts not on the free plan

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

### Invoices over 25

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

## Where I stopped

I got tired after the fourth drill and stopped rather than push through. Practising tired just teaches my brain that SQL feels hard, which is the thing I'm trying to undo. Picking up tomorrow with:

* Drill: invoices issued in September 2026, using `BETWEEN`
* Drill: accounts on the pro or team plan, using `IN`
* The check: predict the row count of three queries before running them, including one that tests whether `AND` or `OR` happens first
* One rewrite using brackets

## What I'm taking away so far

* Single quotes for text values. Double quotes are for column and table names.
* Use the operator that says what I mean: `=` for exact matches, `LIKE` only for patterns, `<>` for "not equal".
* Columns go in `SELECT`, conditions go in `WHERE`.
* My row-count reasoning is better than my syntax right now. The syntax is the easier half to fix.
