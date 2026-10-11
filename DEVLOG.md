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

## Week 1: Read before you write (6 to 11 Oct 2026)

**Sessions:** 5 of 5 done
**Review result:** 3 of 4

**What I covered**

Setting up a real Postgres database in Supabase and loading my own practice data. Then the basics I'd got rusty on: `SELECT`, `WHERE`, comparison operators, `IN`, `BETWEEN`, NULL and how it behaves, `COALESCE`, `ORDER BY`, `LIMIT`, and tiebreakers.

**Where I started**

On day 0 I did a diagnostic. I could partly read a query but couldn't explain its output: I didn't know why two accounts with no invoices came out at the top. I couldn't write the other two tasks at all. I froze on a blank page, which is the same thing that happened in a real interview the week before.

**What broke**

* Quotes. I used double quotes for text. In Postgres, double quotes mean a column name, so `"DE"` makes it look for a column called DE. Text and dates take single quotes, one pair per value.
* `<>`. I read it as "equal". It means "not equal".
* `= NULL`. It never matches anything and doesn't error. You need `IS NULL`.
* AND and OR. I assumed they run left to right. `AND` happens first. I got this wrong on Thursday and right on Sunday.
* NULL in sorting. I assumed the biggest real number would come first with `DESC`. In Postgres, NULL sorts as the biggest value, so it comes first unless you add `NULLS LAST`.
* Reading the whole question. In the review I wrote a correct filter and forgot the sort the question asked for.

**What clicked**

* The yes/no walk. `WHERE` goes down the table one row at a time and asks yes or no. Only a definite yes survives. That one idea explains most of the week, including why NULL rows disappear: unknown isn't yes.
* `LIMIT` cuts by position, not value. Sort first, then cut.
* Ties come back in any order. A top-3 query gave me invoice 103 in third place for no real reason. Adding a tiebreaker column makes the answer the same every time.
* `COALESCE` is a judgement call. I questioned whether swapping NULL for 0 was honest. It changes what's shown, not what's stored, and it's only right when the fallback is actually true.

**What changed in how I work**

* One step per message. Getting a whole day's material at once didn't work for me. Switching to one instruction, do it, get feedback, next step was the biggest improvement of the week.
* Always show the data next to the question. I nearly worked off the wrong table once. Every question now comes with its table.
* Stop when I'm tired. I stopped partway through Day 2 and finished the next day. Practising tired just teaches my brain that SQL feels hard.
* Predict before running. Writing down what I expect before I hit Run is what exposed most of my mistakes.
* Explaining to customers depends on the customer. A non-technical person needs plain language or an analogy. A developer on Supabase would find an analogy patronising. Either way, give the fix, not just the reason.

**Next week**

Joins. That's where the diagnostic tripped me up most, especially LEFT JOIN, and filters in `ON` versus `WHERE`.
