# Day 4: ORDER BY and LIMIT

**Date:** Fri 9 Oct 2026
**Week 1:** Read before you write
**Status:** Done. Check passed.
**Confidence (1-5):** _fill in_

## Goal

Sort results on purpose, cut them down with `LIMIT`, and understand the two ways sorting goes quietly wrong in Postgres: NULLs and ties.

## The idea

Without `ORDER BY`, Postgres returns rows in whatever order is convenient for it, and that order can change from run to run. If order matters, I have to ask for it. `LIMIT` then keeps the first N rows of the result.

## SQLBolt

Lesson 4 (`DISTINCT`, `ORDER BY`, `LIMIT`, `OFFSET`). Done.

## Drills on my own data

| id | account_id | amount | status | issued_at |
|---|---|---|---|---|
| 101 | 1 | 25.00 | paid | 2026-07-03 |
| 102 | 1 | 25.00 | paid | 2026-08-03 |
| 103 | 1 | 25.00 | failed | 2026-09-03 |
| 104 | 3 | 25.00 | paid | 2026-08-15 |
| 105 | 3 | 30.00 | paid | 2026-09-15 |
| 106 | 4 | 599.00 | paid | 2026-09-01 |
| 107 | 4 | NULL | pending | 2026-10-01 |
| 108 | 6 | 10.00 | paid | 2026-09-20 |

### Where do NULLs go?

```sql
SELECT id, amount FROM invoices
ORDER BY amount DESC;
```

I predicted 106 (the 599) would come out on top. Wrong. **107, the NULL, comes first.**

When sorting, Postgres treats NULL as bigger than every real value:

- `DESC` (biggest first) puts NULLs at the **top**
- `ASC` (smallest first) puts NULLs at the **bottom**

Other databases, such as MySQL, do the opposite, so this is one to remember specifically for Postgres.

The fix:

```sql
SELECT id, amount FROM invoices
ORDER BY amount DESC nulls LAST;
```

### LIMIT: top 3 biggest invoices

Before writing this I asked whether `NULLS LAST` would affect the top 3, since Postgres "still thinks NULL is biggest". It does affect it, and working out why was the most useful part of the day:

**`LIMIT` never looks at values. It only looks at positions in the list after sorting.** Sort first, then cut.

| position | id | amount |
|---|---|---|
| 1 | 106 | 599.00 |
| 2 | 105 | 30.00 |
| 3 | a 25 | 25.00 |
| 4 | a 25 | 25.00 |
| 5 | a 25 | 25.00 |
| 6 | a 25 | 25.00 |
| 7 | 108 | 10.00 |
| 8 | 107 | NULL |

`NULLS LAST` puts 107 in position 8, so `LIMIT 3` never reaches it. Without `NULLS LAST`, the NULL would take one of the three slots.

I went back and forth on this before it clicked. At one point I answered "NULL, 599 and 30", which is the result *without* `NULLS LAST`.

```sql
SELECT id, amount FROM invoices
ORDER BY amount DESC nulls LAST LIMIT 3;
```

Result: 106, 105, 103.

### Why 103?

I wondered whether 103 coming third had something to do with it being the failed invoice. It didn't. The query only sorts by `amount` and never looks at status. All four 25s tie, and **when rows tie, Postgres can return them in any order**. 103 happened to come third this time. On another run, or with more data, it could be any of them.

That's a real bug pattern: a "top N" query with ties gives different answers on different runs, and a customer reports it as "my query keeps changing".

### Adding a tiebreaker

The task: among the 25s, the oldest invoice should win third place.

My prediction was 102, which was wrong. 101 is from July, which is earlier. I only compared the days and skipped the month.

My first attempt:

```sql
SELECT id, amount FROM invoices
ORDER BY issued_at DESC nulls LAST LIMIT 3;
```

This *replaced* the amount sort with a date sort, newest first. It returned 107, 108 and 105. 107 came first because 1 October is the newest date, not because of its NULL amount.

A tiebreaker gets **added** after the first column, separated by a comma, and only kicks in when the first column ties:

```sql
SELECT id, amount FROM invoices
ORDER BY amount DESC NULLS LAST, issued_at LIMIT 3;
```

Result: 106, 105, 101, the same every time. No direction on `issued_at` means ascending, so oldest first.

## The check

My diagnostic query from day 0 ended with `ORDER BY total DESC` and returned:

| name | invoice_count | total |
|---|---|---|
| Birch | 0 | NULL |
| Ember | 0 | NULL |
| Dune | 1 | 599.00 |
| Cobalt | 2 | 55.00 |
| Acme | 2 | 50.00 |

**Why are Birch and Ember on top?** Their totals are NULL, Postgres sorts NULL as the highest value, and `DESC` puts the highest first.

**How to move them to the bottom?** `ORDER BY total DESC NULLS LAST`.

Both right. Bonus point: Birch and Ember tie with each other, so their order relative to each other isn't guaranteed either.

On Monday I couldn't explain this result. Now I can.

## Takeaways

- No `ORDER BY` means no guaranteed order.
- In Postgres, NULL sorts as the biggest value: top with `DESC`, bottom with `ASC`. Use `NULLS LAST` or `NULLS FIRST` to choose.
- `LIMIT` cuts by position after sorting, never by value.
- Ties come back in any order. For results that don't change between runs, add a tiebreaker column after a comma.
- When scanning dates, check the month before the day.
