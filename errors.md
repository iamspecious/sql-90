# Errors

My mistake log. Every query I got wrong in a way worth remembering, copied exactly as I wrote it. Newest at the bottom.

| Date | What I wrote | What was wrong | The rule I learned |
|---|---|---|---|
| 2026-10-07 | `SELECT name, plan FROM accounts WHERE country LIKE "DE%" ;` | Double quotes mean a column or table name, so Postgres looked for a column called `DE%` (`column "DE%" does not exist`). And `LIKE 'DE%'` means "starts with DE" when I wanted an exact match. | Single quotes for text values, double quotes for column and table names. Use `=` for exact matches, `LIKE` only for patterns. |
| 2026-10-07 | `plan NOT = 'free'` | Syntax error. `NOT` goes in front of a whole condition (`NOT plan = 'free'`), not in front of the `=`. My next try, `plan NOT LIKE 'free'`, worked but said "doesn't match a pattern" when I meant "isn't equal to". | "Not equal" is `<>` (Postgres also accepts `!=`). Use the operator that says what I mean. |
| 2026-10-07 | `SELECT * from invoices WHERE id, amount >= 25;` | Columns to show go after `SELECT`, and `WHERE` only takes conditions, so `WHERE id, amount ...` is a syntax error. Also "over 25" is `>`, not `>=`. | Columns go in `SELECT`, conditions go in `WHERE`. Read `>` and `<` out loud with the column first. |
