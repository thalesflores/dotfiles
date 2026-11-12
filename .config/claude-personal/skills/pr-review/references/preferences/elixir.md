# Personal preferences: Elixir

The user's own Elixir conventions, applied on top of the repo's own rules. A
finding backed only by these is `basis: "preference"`.

## intent

- A migration goes in its own commit, never with app code.
- Generated code to exclude from line counts: `lib/generated/**`.

## simplicity

- Check Ecto, Absinthe and Oban before accepting hand-rolled query, schema or
  job plumbing.

## correctness

- Transactions: nesting, savepoints, what is and is not atomic, lock order,
  work done inside a transaction that should not be.
- Idempotency: replayed Kafka messages, retried Oban jobs, duplicate commands.
  Is the dedup key actually unique on the thing being deduped?
- Cost: `acc ++ new` inside a walk, N+1 queries, unbatched external calls.
- Error paths: `rescue` that hides a real error, an error tuple nobody
  matches, a raise that reaches a consumer and parks the partition.
- Data: changeset validation vs DB constraint, `Ecto.Enum` values vs what the
  DB column accepts, money as anything but `:decimal`.
- Migration safety: locks, unqualified `ALTER TYPE ... ADD VALUE`, backfills on
  large tables, reversibility.
- Tests: `Mimic.stub/3` asserting nothing, order-dependent tests, a test that
  pins a log line instead of a return value.

## Known consequences

Each of these satisfies point 3 of the blocking test on its own (the other
three points still apply):

- an unqualified `ALTER TYPE ... ADD VALUE`
- a migration in the same commit as app code
- `Mimic.stub/3` in a test
- a direct write to an Oban table
- money held as anything but `:decimal`
