---
name: go-tdd-patterns
description: Go TDD Patterns & Best Practices
---

# Go TDD Patterns & Best Practices

Use `software-engineer` skill as well for the foundations of software design.

This skill provides Go-specific testing patterns and conventions.

## When to Use

Activates when:
- Writing Go code
- Creating or modifying Go tests
- Reviewing Go test coverage
- Refactoring Go code

## Test Organization

### File Naming
- Unit tests: `*_test.go`
- Integration tests: `e2e_test.go` or `integration_test.go`
- Place tests alongside the code they test

### Test Function Naming
```go
func TestFunctionName(t *testing.T)           // Basic test
func TestFunctionName_Scenario(t *testing.T)  // Specific scenario
func TestFunctionName_EdgeCase(t *testing.T)  // Edge case
```

## Table-Driven Tests

Use table-driven tests for multiple inputs/scenarios:

```go
func TestValidation(t *testing.T) {
    tests := []struct {
        name    string
        input   string
        want    bool
        wantErr error
    }{
        {
            name:    "valid input",
            input:   "test",
            want:    true,
            wantErr: nil,
        },
        {
            name:    "empty input",
            input:   "",
            want:    false,
            wantErr: ErrEmptyInput,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
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

## Testify Assertions

### require vs assert

**Use `testify/require`** - Stop test execution on failure:
```go
require.NoError(t, err)              // Stop if error
require.NotNil(t, result)            // Stop if nil
require.Equal(t, expected, actual)   // Stop if not equal
require.ErrorIs(t, err, ErrExpected) // Stop if wrong error
```

**Use `testify/assert`** - Continue test execution:
```go
assert.Equal(t, expected, actual)    // Continue on failure
assert.True(t, condition)            // Continue on failure
assert.Contains(t, slice, element)   // Continue on failure
```

**Pattern:** Use `require` for prerequisites, `assert` for multiple checks

## Mock External Dependencies

Mock external dependencies for unit tests:
- Network calls
- Filesystem operations
- Time-dependent code
- External services

```go
type mockClient struct {
    mock.Mock
}

func (m *mockClient) FetchData(ctx context.Context) ([]byte, error) {
    args := m.Called(ctx)
    return args.Get(0).([]byte), args.Error(1)
}
```

## Test Error Cases

Always test error cases and edge conditions:

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
            name: "invalid input",
            setup: func(m *mockDeps) {
                // No setup needed
            },
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

## Integration Test Patterns

Use build tags for integration tests:

```go
//go:build integration
// +build integration

package mypackage_test

func TestIntegration_RealDatabase(t *testing.T) {
    // Integration test code
}
```

Run with: `go test -tags=integration ./...`

## Test Coverage Standards

- Minimum coverage: 90% lines and branches
- Every exported function must have tests
- Critical paths need both positive and negative tests
- Edge cases must be explicitly tested

## Running Tests

```bash
# Run all tests
go test -v ./...

# Run with race detector
go test -v -race ./...

# Run with coverage
go test -v -cover ./...

# Run single test
go test -v ./path/to/package -run TestName

# Run with failfast
go test -v --failfast ./...
```

## Test Documentation

Tests serve as documentation:
- Use descriptive test names
- Use table-driven test `name` field to describe scenario
- Add comments only for complex setup or non-obvious behavior

## Refactor Candidates

After TDD cycle, look for:

- Duplication → Extract function/class
- Long methods → Break into private helpers (keep tests on public interface)
- Shallow modules → Combine or deepen
- Feature envy → Move logic to where data lives
- Primitive obsession → Introduce value objects
- Existing code the new code reveals as problematic
