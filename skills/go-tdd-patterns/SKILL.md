---
name: go-tdd-patterns
description: Go TDD patterns, test organization, concurrency/HTTP testing, and Go 1.27 practices
---

# Go TDD Patterns & Best Practices

Use `software-engineer` skill for software-design foundations.

This skill defines Go-specific testing patterns. Target Go 1.27+ unless module constraints require older behavior.

## When to Use

Activates when:
- Writing Go code
- Creating or modifying Go tests
- Reviewing test coverage or test design
- Refactoring Go code
- Testing concurrency, HTTP handlers, retries, timeouts, or external dependencies

## Test Organization

### File Naming

- Unit tests: `*_test.go`
- Integration tests: `integration_test.go`
- End-to-end tests: `e2e_test.go`
- Place tests beside code under test

### Test Function Naming

```go
func TestFunctionName(t *testing.T)
func TestFunctionName_Scenario(t *testing.T)
func TestFunctionName_EdgeCase(t *testing.T)
func TestFunctionName_Error(t *testing.T)
```

Prefer behavior-oriented names:

```go
func TestValidate_EmptyInput_ReturnsErrEmptyInput(t *testing.T)
```

## Table-Driven Tests

Use table tests for input/output variants, validation, parsing, mapping, and error paths.

```go
func TestValidate(t *testing.T) {
    tests := []struct {
        name    string
        input   string
        want    bool
        wantErr error
    }{
        {name: "valid input", input: "test", want: true, wantErr: nil},
        {name: "empty input", input: "", want: false, wantErr: ErrEmptyInput},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            t.Parallel()

            got, err := Validate(tt.input)

            if tt.wantErr != nil {
                require.ErrorIs(t, err, tt.wantErr)
                return
            }

            require.NoError(t, err)
            assert.Equal(t, tt.want, got)
        })
    }
}
```

Use `t.Parallel()` only when cases have no shared mutable state.

## Testify Assertions

Use `require` for preconditions; use `assert` for independent postconditions.

```go
require.NoError(t, err)
require.NotNil(t, result)
require.ErrorIs(t, err, ErrExpected)

assert.Equal(t, expected, actual)
assert.True(t, condition)
assert.Contains(t, items, item)
```

Rules:

- `require` -> stop when later assertions depend on prior result
- `assert` -> collect multiple failures in one test
- Prefer `require.ErrorIs` over string error comparison
- Avoid `assert.Nil` for errors; use `require.NoError`

## Mock External Dependencies

Mock only boundaries:
- Network calls
- Filesystem operations
- Clock/time
- External services
- Non-deterministic randomness

Define narrow interfaces at consumer side.

```go
type DataFetcher interface {
    FetchData(ctx context.Context) ([]byte, error)
}

type mockFetcher struct {
    mock.Mock
}

func (m *mockFetcher) FetchData(ctx context.Context) ([]byte, error) {
    args := m.Called(ctx)
    return args.Get(0).([]byte), args.Error(1)
}
```

Do not mock:
- Value types
- Pure functions
- Types owned by same package unless boundary is genuinely awkward
- Standard library unless wrapping it in a small adapter

## Error Cases

Always cover:
- Invalid input
- Missing dependencies
- Upstream failure
- Context cancellation
- Timeout
- Partial success where relevant

```go
func TestHandler_Errors(t *testing.T) {
    tests := []struct {
        name    string
        setup   func(*mockDeps)
        wantErr error
    }{
        {
            name: "database connection failed",
            setup: func(m *mockDeps) {
                m.db.On("Connect").Return(ErrConnFailed)
            },
            wantErr: ErrConnFailed,
        },
        {
            name:    "invalid input",
            setup:   func(m *mockDeps) {},
            wantErr: ErrInvalidInput,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            m := newMockDeps()

            if tt.setup != nil {
                tt.setup(m)
            }

            err := Handler(m)
            require.ErrorIs(t, err, tt.wantErr)
        })
    }
}
```

## Concurrency Testing

Use `testing/synctest` for deterministic concurrent tests. It provides a synthetic clock and goroutine-settling semantics.

```go
func TestWorker_ProcessesAfterDelay(t *testing.T) {
    synctest.Test(t, func(t *testing.T) {
        var processed atomic.Bool

        go func() {
            time.Sleep(time.Hour)
            processed.Store(true)
        }()

        synctest.Sleep(time.Hour)

        assert.True(t, processed.Load())
    })
}
```

Rules:
- Use `synctest.Test` for time-dependent logic
- Use `synctest.Sleep` for simulated delay plus wait for goroutines to settle
- Do not use real sleeps in unit tests
- Test cancellation, deadline, retry, backoff, and queue-drain behavior explicitly

## HTTP Testing

Use `httptest.NewTestServer` for in-memory HTTP tests. It avoids real TCP ports and works with `testing/synctest`.

```go
func TestClient_FetchUser(t *testing.T) {
    synctest.Test(t, func(t *testing.T) {
        srv := httptest.NewTestServer(t, http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
            w.Header().Set("Content-Type", "application/json")
            _, _ = w.Write([]byte(`{"id":"1"}`))
        }))

        client := NewClient(srv.URL)

        user, err := client.FetchUser(context.Background(), "1")

        require.NoError(t, err)
        require.Equal(t, "1", user.ID)
    })
}
```

Use `httptest.NewServer` only when real network behavior, TLS, ports, or client transport details matter.

## Deterministic Randomness

For deterministic crypto-related tests, use:

```go
testing/cryptotest.SetGlobalRandom
```

Avoid deprecated `tls.Config.Rand` for new deterministic test setups.

Do not seed production randomness for tests; inject randomness only where testability requires it.

## Goroutine Leak Checks

Treat leaked goroutines as test failures.

- Run race-sensitive tests with `-race`
- Inspect `/debug/pprof/goroutineleak` in services with long-lived goroutines
- Use `runtime/pprof` goroutine-leak profile when diagnosing blocked goroutines
- Ensure every goroutine has explicit shutdown path: context cancellation, channel close, or `sync.WaitGroup`

Go 1.27 makes `goroutineleak` generally available; it detects goroutines blocked on unreachable concurrency primitives, though not every possible leak. [2]

## Integration Tests

Use build tags for tests requiring real dependencies.

```go
//go:build integration

package mypackage_test

func TestIntegration_RealDatabase(t *testing.T) {
    // Integration test code
}
```

Run:

```bash
go test -tags=integration ./...
```

Rules:
- Integration tests may use containers, DBs, queues, or real network
- Unit tests must not require external services
- Keep integration setup idempotent
- Prefer testcontainers or ephemeral instances over shared stateful environments

## Coverage Standards

- Minimum: 90% statement and branch coverage for changed production code
- Every exported function needs tests
- Critical paths need positive and negative tests
- Edge cases need explicit tests
- Do not chase coverage with meaningless assertions

Coverage commands:

```bash
go test -cover ./...
go test -coverprofile=coverage.out ./...
go tool cover -func=coverage.out
go tool cover -html=coverage.out
```

## Running Tests

```bash
# All tests
go test ./...

# Verbose
go test -v ./...

# Race detector
go test -race ./...

# Coverage
go test -cover ./...

# Single test
go test -run '^TestName$' ./path/to/package

# Stop after first failure
go test -failfast ./...

# JSON output for CI
go test -json ./...
```

Go 1.27 enables `stdversion` vet check by default during `go test`; it flags standard-library symbols newer than module's declared Go version. [2]

## Go 1.27 Practices

- Set minimum supported version explicitly in `go.mod`
- Use `go fix` modernizers before review: `atomictypes`, `embedlit`, `slicesbackward`, `unsafefuncs`
- Use generic methods where they improve local API ergonomics; do not use them to bypass interfaces
- Remember: interface methods cannot declare type parameters and cannot be implemented by generic methods. [2]
- For JSON tests, account for stricter `encoding/json` v2 behavior: invalid UTF-8 and duplicate object names rejected by default. [2]
- Use `encoding/json/v2` for new JSON APIs; retain `encoding/json` for compatibility-sensitive existing contracts. [2]

## Test Documentation

Tests document behavior.

- Use descriptive table-test names
- Name scenarios after observable behavior
- Comment only non-obvious setup or invariants
- Keep assertions close to behavior under test
- Avoid brittle assertions on internal implementation details

## Refactor Candidates

After TDD cycle, look for:
- Duplication -> extract function
- Long methods -> split into private helpers; keep tests on public API
- Shallow modules -> combine or deepen
- Feature envy -> move logic near data
- Primitive obsession -> introduce value types
- Hidden temporal coupling -> inject clock or use `synctest`
- Leaked goroutines -> add explicit lifecycle ownership
