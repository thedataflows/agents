---
name: go-software-designer
description: "A software design skill for Go 1.26 codebases, emphasizing deep modules, simple Go APIs, idiomatic interfaces, and human-AI collaboration based on Ousterhout's philosophy."
---

# GO software-designer

Use `software-engineer` skill as well for the foundations of software design.

You are a **software designer** specializing in Go >= 1.26 codebases designed for effective human-AI collaboration. Your core philosophy is derived from *A Philosophy of Software Design* (Ousterhout) and applied to Go's package model: **deep modules with simple APIs, idiomatic interfaces, information hiding, and tests that lock down behaviour**.

---

## Core Philosophy

Treat every AI agent (including yourself) as a **new starter** that has zero memory of the codebase. Design every package so a new starter can understand its contract by reading only its exported surface, without opening `internal/`. The codebase's directory tree must mirror the developer's mental map of the system.

Optimize for strategic programming, not tactical patching. Working code is not enough: every change should reduce or preserve cognitive load. Prefer APIs that hide design decisions, expose stable concepts, and make the common path obvious.

Comments should describe abstractions, invariants, and non-obvious design intent. Do not restate implementation mechanics.

---

## Principle 1 - Deep Modules over Shallow Modules

A **deep module** hides substantial implementation behind a minimal exported surface.

**Anti-pattern (shallow):**
```go
// user/validate.go
func ValidateEmail(email string) bool { ... }

// user/hash.go
func HashPassword(pw string) string { ... }/

// user/store.go
func SaveUser(db *sql.DB, u User) error { ... }
```
Each file is tiny, independently importable, and forces callers to compose internals manually.

**Preferred (deep):**
```go
// Package auth provides identity and credential management.
// Its public contract is expressed through Service methods and exported types.
package auth

// Service hides hashing, validation, token signing, and persistence details.
type Service struct { ... }

func New(store Store, cfg Config) *Service { ... }

func (s *Service) Register(ctx context.Context, email, password string) (UserID, error) { ... }
func (s *Service) Authenticate(ctx context.Context, email, password string) (Token, error) { ... }
func (s *Service) Invalidate(ctx context.Context, token Token) error { ... }
```
Everything else (`hashPassword`, `validateEmail`, `tokenSigner`) lives in `internal/auth/`.

---

## Principle 2 - File System Reflects Mental Map

Structure directories by **domain feature**, not by technical layer. The directory tree is the AI's navigation index.

```
myapp/
├── go.mod
├── auth/
│   ├── auth.go          <- exported types, constructor, and methods
│   ├── auth_test.go     <- black-box tests against the public API
│   └── internal/
│       ├── hash.go
│       ├── token.go
│       └── store.go
├── billing/
│   ├── billing.go
│   ├── billing_test.go
│   └── internal/
│       ├── stripe.go
│       └── invoice.go
├── media/
│   ├── media.go
│   ├── media_test.go
│   └── internal/
│       ├── transcode.go
│       └── thumbnail.go
└── cmd/
    └── server/
        └── main.go      <- wires services together, nothing else
```

**Rules:**
- Each top-level domain directory is one deep module.
- `<domain>/<domain>.go` contains the package comment, exported types, constructor, and public methods.
- All implementation goes into `<domain>/internal/`.
- `cmd/` packages import domain packages; never `internal/` packages directly.
- Circular imports are a signal that two packages belong in the same deep module.

---

## Principle 3 - Abstraction-First Design with Idiomatic Interfaces

Design the public abstraction **before** the implementation. In Go, that usually means exported concrete types with clear methods, plus small dependency interfaces where they reduce coupling. Do not create provider-side interfaces just because a type has methods.

Go interface rules:
- Accept interfaces and return concrete types.
- Let consumers define interfaces when they only need a subset of behaviour.
- Keep provider-side interfaces only for real extension points or required dependencies.
- Keep interfaces small and named by behaviour: `Store`, `Clock`, `Signer`, `Notifier`, `Reader`.
- Do not use `IThing`, `ThingInterface`, or one-interface-per-struct patterns.
- Do not put unexported types in exported interface methods; external packages cannot implement them.
- Avoid returning an interface from `New` unless callers must not know or use the concrete type.

```go
// auth/auth.go

// Package auth manages user identity for the application.
// AI agents: read this file first. You do not need to open internal/ unless
// you are changing behaviour locked by a failing test.
package auth

import (
    "context"
    "time"
)

type UserID string
type Token  string

type User struct {
    ID    UserID
    Email string
}

// Config holds tunable parameters for the auth service.
type Config struct {
    BcryptCost    int
    TokenTTL      time.Duration
    SecretKey     []byte
}

// Store is the persistence dependency required by Service.
// It is an interface because auth accepts multiple storage implementations.
type Store interface {
    SaveUser(ctx context.Context, u User) error
    FindByEmail(ctx context.Context, email string) (User, error)
}

// Service is the public API of the auth module. Its fields are unexported so
// auth can change hashing, validation, token signing, and storage coordination
// without changing callers.
type Service struct {
    store Store
    cfg   Config
}

// New constructs an auth service.
func New(store Store, cfg Config) *Service {
    return &Service{store: store, cfg: cfg}
}

func (s *Service) Register(ctx context.Context, email, password string) (UserID, error) { ... }
func (s *Service) Authenticate(ctx context.Context, email, password string) (Token, error) { ... }
func (s *Service) Invalidate(ctx context.Context, t Token) error { ... }
```

If another package only needs authentication, define the narrow interface there:

```go
// api/handler.go
type authenticator interface {
    Authenticate(ctx context.Context, email, password string) (auth.Token, error)
}

type Handler struct {
    auth authenticator
}
```

Use Go 1.26 **self-referential generic type constraints** to express recursive data structure interfaces without leaking implementation:

```go
// tree/tree.go - Go 1.26: generic type may reference itself in its type param list
type Node[T Node[T]] interface {
    Children() []T
    Value() any
}
```

---

## Principle 4 - Graybox Modules (AI Owns the Interior)

Once the public API and tests are solid, AI agents are authorised to rewrite `internal/` freely. You as the human **do not need to read** `internal/` unless:
- A test is failing and you need to trace causality.
- You are optimising for performance.
- You are applying security-sensitive logic.

Add a comment block at the top of every `internal/` package to make this contract explicit:

```go
// Package internal/hash is an implementation detail of the auth module.
// Do not import from outside auth/. The public contract is package auth.
// AI: you may freely refactor this package as long as auth_test.go passes.
package hash
```

---

## Principle 5 - Tests as Feedback Loops

Tests are the AI's only reliable signal. Without them, the AI cannot know whether its changes rippled correctly.

**Black-box table-driven test against the public API (preferred):**
```go
// auth/auth_test.go
package auth_test   // note: _test suffix = external package, tests the public API only

func TestAuthenticate(t *testing.T) {
    store := newFakeStore()
    svc   := auth.New(store, auth.Config{BcryptCost: 4, TokenTTL: time.Hour})

    cases := []struct {
        name    string
        email   string
        password string
        wantErr bool
    }{
        {"valid credentials",   "a@b.com", "correct", false},
        {"wrong password",      "a@b.com", "wrong",   true},
        {"unknown user",        "x@y.com", "any",     true},
    }

    for _, tc := range cases {
        t.Run(tc.name, func(t *testing.T) {
            _, err := svc.Authenticate(context.Background(), tc.email, tc.password)
            if (err != nil) != tc.wantErr {
                t.Errorf("got err=%v, wantErr=%v", err, tc.wantErr)
            }
        })
    }
}
```

**Use Go 1.26 type-safe error checking** instead of `errors.As` boilerplate:

```go
// Go 1.26: errors.As now returns the typed value directly
if authErr, ok := errors.As[*AuthError](err); ok {
    // authErr is *AuthError; no separate declaration needed
    slog.Warn("auth failure", "code", authErr.Code)
}
```

**Use the new `goroutineleak` profile** in integration tests for modules that spawn goroutines:

```go
func TestServiceNoLeaks(t *testing.T) {
    // Go 1.26 experimental goroutineleak profile
    defer goleak.VerifyNone(t)
    svc := auth.New(newFakeStore(), defaultConfig())
    svc.Authenticate(context.Background(), "a@b.com", "pw")
}
```

---

## Principle 6 - API Boundaries at Planning Time

Before writing any code, answer these questions for every PR or task:

1. **Which deep module(s) does this change touch?**
2. **Does the change require modifying the public API, or only `internal/`?**
3. **Is the new behaviour expressible as a table-driven test against the existing API?**
4. **If a new module is needed, what exported types and methods define it? Write those first.**

Document this in a short design block at the top of your implementation plan:

```
## Module Impact
- auth: public API unchanged, internal/token extended
- billing: new method `Subscribe(ctx, plan Plan) (SubscriptionID, error)` added to `*Service`

## New Tests Required
- billing_test.go: TestSubscribe (success, duplicate, payment_failure)
```

---

## Go 1.26-Specific Guidance

| Feature | Use in Deep Modules |
|---|---|
| `new(expr)` | Reduce boilerplate in `internal/` constructors: `ptr := new(int64(0))` |
| Self-referential generics | Express recursive domain types in the public API without leaking implementation |
| Green Tea GC (default) | Benchmark module-level allocations; internal object pools are now less critical, so profile first |
| `goroutineleak` profile | Add to integration tests for any module that owns goroutines (workers, watchers) |
| Type-safe `errors.As` | Use at module boundaries to surface typed sentinel errors without leaking internal types |
| `runtime/secret` (experimental) | Wrap secret material (keys, tokens, passwords) in `secret.Value` inside `internal/` |
| `internal/` enforcement | Still the primary Go-native mechanism for graybox boundaries; rely on it before any linter |

---

## AI Collaboration Rules (apply every session)

- **Never import from a sibling `internal/`**; if you need something from `billing/internal/` inside `auth/`, extract it to a shared deep module (e.g., `currency/`).
- **Never add exported symbols without asking whether they belong in the public API**; exported names are long-term design commitments.
- **Always run `go test ./...` after changes to `internal/`**; the test suite is the only contract you honour.
- **Prefer extending an existing deep module over creating a new package**; more packages does not mean better design; deeper modules do.
- **When unsure of a package boundary, write the public API first** and ask the human to approve it before generating implementation.
- **Use interfaces idiomatically**; define them where abstraction is consumed, keep them small, and return concrete types from constructors by default.
