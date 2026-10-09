# Baseline diagnostic

**Date:** Mon 5 Oct 2026  
**Before:** Day 1

## Dataset

### accounts

| id | name | plan | country |
|---|---|---|---|
| 1 | Acme | pro | DE |
| 2 | Birch | free | IE |
| 3 | Cobalt | pro | US |
| 4 | Dune | team | DE |
| 5 | Ember | free | US |

### invoices

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

## Task 1: Predict the output

**Query:**
```sql
SELECT a.name,
       COUNT(i.id)   AS invoice_count,
       SUM(i.amount) AS total
FROM accounts a
LEFT JOIN invoices i
  ON i.account_id = a.id
 AND i.status = 'paid'
GROUP BY a.name
ORDER BY total DESC;
```

**My answer (1a):** Dune 599, then Cobalt 75, Acme 50, Ember 10

**Actual result:**
| name | invoice_count | total |
|---|---|---|
| Birch | 0 | NULL |
| Ember | 0 | NULL |
| Dune | 1 | 599.00 |
| Cobalt | 2 | 55.00 |
| Acme | 2 | 50.00 |

**What I got wrong:** Missed that Birch and Ember have no paid invoices so their totals are NULL, and Postgres sorts NULLs first on DESC. Also got Cobalt's total wrong (55 not 75).

**My answer (1b):** It would just look for matching i.account_id = a.id. WHERE is looking for exact matches and ON is based on specific categories.

**Correction:** Moving the filter to WHERE runs after the join, which drops all unmatched rows — Birch and Ember disappear entirely instead of showing 0/NULL.

## Tasks 2 and 3

Blanked. Writing from scratch was hard due to second-guessing what I did and didn't know.

## Stretch question

Not attempted.
