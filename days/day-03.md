# Day 3: NULL

**Date:** Thu 8 Oct 2026
**Week 1:** Read before you write
**Status:** Done. Check passed.
**Confidence (1-5):** 3

## Goal

Understand what NULL is, why it makes rows quietly disappear from results, and how to handle it properly.

## The idea

NULL means "unknown". It doesn't mean zero and it doesn't mean empty. Because the value is unknown, any comparison with it is unknown too. Is unknown greater than 25? Unknown. Does unknown equal 25? Unknown.

`WHERE` only keeps rows where the answer is a definite yes. So rows with NULL in the column being tested drop out, with no error.

## SQLBolt lesson 8, and the question it raised

The lesson's answer used `IS NULL`. I wrote `= NULL` and wanted to know why that's wrong.

```sql
-- What I wrote
SELECT name, role FROM employees
WHERE building = NULL;

-- The correct version
SELECT name, role FROM employees
WHERE building IS NULL;
```

`=` asks "are these two values the same?" So `building = NULL` asks "is this building the same as something unknown?" The honest answer is always "don't know", even for rows where the building really is NULL. Two unknowns aren't known to be equal. If I don't know your age and I don't know someone else's, I can't say you're the same age.

`IS NULL` isn't a comparison. It asks a different question, "is this value missing?", which always gets a straight yes or no.

The dangerous part is that `= NULL` doesn't error. It just returns nothing. A customer whose query silently comes back empty may well have one of these buried in it.

## Seeing it on my own data

My `invoices` table has one NULL, invoice 107 (a pending invoice with no amount yet).

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

```sql
SELECT id, amount FROM invoices WHERE amount = NULL;   -- 0 rows
SELECT id, amount FROM invoices WHERE amount IS NULL;  -- 1 row (107)
```

I predicted 0 and 1 before running them. Both right.

## The less obvious version of the trap

```sql
SELECT id, amount FROM invoices WHERE amount <> 25;
```

It took me three tries to get this one.

1. First I said `<>` means "exactly 25". Wrong way round: it means **not** equal. I'd used it the day before (`plan <> 'free'`) and still flipped it. A way to remember: `<>` is "less than or greater than", so anything except that value.
2. Then I said "3 or 4, depending on whether we include NULL". That's not an option. The query decides, not me.
3. Then I applied the rule. Is unknown not equal to 25? Unknown. `WHERE` drops anything that isn't a yes, so 107 is gone. **3 rows** (105, 106, 108).

So someone asking for "every invoice that isn't 25" silently loses the pending one.

## The check: explain it to a customer

My first version:

> When we're looking for things that are not equal to 25 it looks for everything that is around that number and not the number itself. However that doesn't include things that we don't know. For example, if I have 10 marbles, you don't know how many are in each hand, you just know I told you I have 10. That's what NULL represents. Not knowing the amount in each hand.

The core idea was right, so this passed. The feedback:

- "Around that number" is wrong. `<>` means any different value, so 10 and 599 count as much as 24.
- The analogy sets up the unknown but never gets to the point, which is what gets left out and why. It needs a last step: if you're asked whether my left hand isn't holding 5 marbles, you can't say yes, so that hand gets left out.

I pushed back on the suggested rewrite, which was too technical for the customer I'd pictured. The useful part of that disagreement: there are two kinds of customer. A non-technical one needs plain language or an analogy. A Supabase customer is usually a developer who wrote the query and would find an analogy a bit patronising. Picking the register for the person is part of the job.

The version I'd use for either:

> Postgres skipped invoice 107 because it has no amount recorded. When it doesn't know a value, it can't say whether it's different from 25, so it leaves the row out. Adding `OR amount IS NULL` tells it to include those too.

The last sentence matters. Explaining why isn't enough in support. You give the fix too.

## Writing the fix

```sql
SELECT id, amount FROM invoices WHERE amount <> 25 OR amount IS null;
```

4 rows (105, 106, 107, 108). Lowercase `null` is fine, because SQL keywords aren't case-sensitive.

## COALESCE, and whether it's honest

`COALESCE(amount, 0)` means "use the amount, but if it's NULL, use 0".

My first reaction was that this is manipulating the data, because the NULL could stand for a real amount. That's the right worry. Choosing a fallback is a judgement call, not a technical one.

What makes it safe:

1. It never changes stored data. It only changes what that one query shows.
2. Only use it when the fallback is actually true. An account with no invoices really has paid 0, so `COALESCE(total, 0)` is honest. A pending invoice's amount isn't 0, it's undecided, so turning it into 0 makes totals lie.

The question to ask every time: is my fallback true, or just convenient?

```sql
SELECT id, amount, COALESCE(amount, 0) AS amount_or_zero
FROM invoices;
```

For invoice 107 I got `amount_or_zero` right (0). I didn't spell out that the original `amount` column still shows NULL. COALESCE only affects the column it wraps.

| id | amount | amount_or_zero |
|---|---|---|
| 107 | NULL | 0 |

## Takeaways

- NULL means unknown. Any comparison with it is unknown, and `WHERE` drops unknowns without saying anything.
- Find NULLs with `IS NULL` or `IS NOT NULL`. Never `= NULL` or `<> NULL`.
- If NULL rows should be kept, say so: `OR column IS NULL`.
- `COALESCE` changes what's shown, not what's stored, and the fallback has to be true.
- `<>` means not equal. I've now mixed this up once, so it goes in the errors log.
- Match the explanation to the person: plain language for non-technical customers, straight technical for developers, and always include the fix.
