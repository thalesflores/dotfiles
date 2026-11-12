# Common project commands by stack

Detect the stack from project files (`mix.exs`, `package.json`, `Gemfile`,
`go.mod`, `build.gradle.kts`, `Cargo.toml`), then use the matching commands.

**Always check `CLAUDE.md` / `CLAUDE.local.md` for project-specific commands
first — they take precedence over these defaults.**

| Stack | Format | Build/Compile | Test | Lint |
|-------|--------|---------------|------|------|
| Elixir | `mix format` | `mix compile --warnings-as-errors` | `mix test` | `mix credo --strict` |
| TypeScript/Next.js | `npm run biome:fix` | `npm run typecheck` | `npm test` | `npm run biome` |
| Ruby/Rails | — | — | `bundle exec rspec` | `bundle exec rubocop` |
| Go | `go fmt ./...` | `go build ./...` | `go test ./...` | `go vet ./...` |
| Kotlin/Android | — | `./gradlew build` | `./gradlew test` | `./gradlew lint` |
| Swift/iOS | `make format` | `make build` | `make test` | `make lint` |
| Rust | `cargo fmt` | `cargo build` | `cargo test` | `cargo clippy -- -D warnings` |
| Python | `ruff format .` | — | `pytest` | `ruff check .` |
