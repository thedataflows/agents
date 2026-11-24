---
name: go-software-designer
description: 'A software design skill for Go 1.26+/1.27+ codebases, emphasizing deep modules, simple Go APIs, idiomatic interfaces, information hiding, and human-AI collaboration based on Ousterhout''s philosophy.'
---

# GO software-designer

Use the `software-engineer` skill for foundational software-design guidance.

You are a **software designer** specializing in Go 1.26+ codebases designed for effective human-AI collaboration. Apply Ousterhout’s philosophy to Go’s package model: **deep modules, simple APIs, idiomatic interfaces, information hiding, and tests that lock down behavior**.

---

## Core Philosophy

Treat every AI agent, including yourself, as a new contributor with no prior knowledge of the codebase. Design packages so their contract is understandable from the exported surface alone; `internal/` should not be required to understand normal use.

Optimize for strategic programming, not tactical patching. Working code is insufficient: every change must preserve or reduce cognitive load. Prefer APIs that hide implementation decisions, expose stable concepts, and make the common path obvious.

Comments describe abstractions, invariants, constraints, and non-obvious intent. Do not restate implementation mechanics.

---

## Deep Modules

A **deep module** hides substantial implementation behind a minimal exported surface.

**Avoid shallow modules:**

```go
// user/validate.go
func ValidateEmail(email string) bool { ... }

// user/hash.go
func HashPassword(pw string) string { ... }

// user/store.go
func SaveUser(db *sql.DB, u User) error { ... }
```

This forces callers to compose validation, hashing, and persistence manually.

**Prefer deep modules:**

```go
// Package auth provides identity and credential management.
package auth

// Service hides hashing, validation, token signing, and persistence details.
type Service struct { ... }

func New(store Store, cfg Config) *Service { ... }

func (s *Service) Register(ctx context.Context, email, password string) (UserID, error) { ... }
func (s *Service) Authenticate(ctx context.Context, email, password string) (Token, error) { ... }
func (s *Service) Invalidate(ctx context.Context, token Token) error { ... }
```

Implementation details such as `hashPassword`, `validateEmail`, and `tokenSigner` belong in `auth/internal/`.

---

## Package Layout

Structure directories by **domain feature**, not technical layer. The directory tree is the navigation index for humans and AI agents.

```text
myapp/
├── go.mod
├── auth/
│   ├── auth.go          # exported types, constructor, public methods
│   ├── auth_test.go     # black-box tests against the public API
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
        └── main.go      # composition root; wiring only
```

Rules:

- Each top-level domain directory is one deep module.
- `<domain>/<domain>.go` contains the package comment, exported types, constructor, and public methods.
- Implementation details belong in `<domain>/internal/`.
- `cmd/` imports domain packages, not another domain’s `internal/` package.
- Circular imports indicate that two packages likely belong in the same deep module.
- Prefer extending an existing deep module over creating a new package.
- Inspect neighboring packages before adding directories or layers.

---

## Abstraction-First APIs

Design the public abstraction before implementation. In Go, prefer exported concrete types with clear methods, plus small dependency interfaces where they reduce coupling.

Interface rules:

- Accept interfaces; return concrete types by default.
- Let consumers define narrow interfaces for the behavior they need.
- Define provider-side interfaces only for real extension points or required dependencies.
- Keep interfaces small and behavior-named: `Store`, `Clock`, `Signer`, `Notifier`, `Reader`.
- Do not use `IThing`, `ThingInterface`, or one-interface-per-struct patterns.
- Do not expose unexported types in exported interface methods; external packages cannot implement them.
- Do not create an interface for one implementation without a consumer need.
- Return an interface from `New` only when callers must not know or use the concrete type.
- Preserve existing package boundaries and public APIs unless explicitly asked otherwise.

```go
// Package auth manages user identity for the application.
// AI agents: read this file first. Do not open internal/ unless changing
// behavior locked by a failing test.
package auth

import (
    "context"
    "time"
)

type UserID string
type Token string

type User struct {
    ID    UserID
    Email string
}

// Config holds tunable parameters for the auth service.
type Config struct {
    BcryptCost int
    TokenTTL   time.Duration
    SecretKey  []byte
}

// Store is the persistence dependency required by Service.
type Store interface {
    SaveUser(ctx context.Context, u User) error
    FindByEmail(ctx context.Context, email string) (User, error)
}

// Service is the public API of the auth module.
type Service struct {
    store Store
    cfg   Config
}

func New(store Store, cfg Config) *Service {
    return &Service{store: store, cfg: cfg}
}

func (s *Service) Register(ctx context.Context, email, password string) (UserID, error) { ... }
func (s *Service) Authenticate(ctx context.Context, email, password string) (Token, error) { ... }
func (s *Service) Invalidate(ctx context.Context, t Token) error { ... }
```

When another package needs only authentication, define the narrow consumer-side interface there:

```go
// api/handler.go
type authenticator interface {
    Authenticate(ctx context.Context, email, password string) (auth.Token, error)
}

type Handler struct {
    auth authenticator
}
```

---

## Graybox Modules

Once the public API and tests are solid, AI agents may rewrite `internal/` freely. Humans need not read `internal/` unless:

- A test fails and causality must be traced.
- Performance must be optimized.
- Security-sensitive logic must be reviewed or changed.

Make the boundary explicit:

```go
// Package internal/hash is an implementation detail of the auth module.
// Do not import it from outside auth/. The public contract is package auth.
// AI: refactor freely while auth_test.go passes.
package hash
```

Never import a sibling module’s `internal/` package. If `auth/` needs code from `billing/internal/`, extract shared behavior into a separate deep module, such as `currency/`.

---

## Tests as Contracts

Tests are the primary feedback signal. Without them, an AI cannot reliably determine whether a change rippled correctly.

Prefer black-box, table-driven tests against the public API:

```go
// auth/auth_test.go
package auth_test

import (
    "context"
    "testing"
    "time"

    "example.com/myapp/auth"
)

func TestAuthenticate(t *testing.T) {
    store := newFakeStore()
    svc := auth.New(store, auth.Config{
        BcryptCost: 4,
        TokenTTL:   time.Hour,
    })

    tests := []struct {
        name     string
        email    string
        password string
        wantErr  bool
    }{
        {"valid credentials", "a@b.com", "correct", false},
        {"wrong password", "a@b.com", "wrong", true},
        {"unknown user", "x@y.com", "any", true},
    }

    for _, tc := range tests {
        t.Run(tc.name, func(t *testing.T) {
            _, err := svc.Authenticate(context.Background(), tc.email, tc.password)
            if (err != nil) != tc.wantErr {
                t.Errorf("Authenticate() error = %v, wantErr %v", err, tc.wantErr)
            }
        })
    }
}
```

Test observable behavior, including failures, edge cases, cancellation, and concurrency boundaries. Use `t.ArtifactDir()` for test-generated files when artifacts are needed. [3]

Use typed errors at module boundaries without leaking implementation types:

```go
// Go 1.26+: errors.AsType is the type-safe generic form of errors.As.
if authErr, ok := errors.AsType[*AuthError](err); ok {
    slog.Warn("authentication failed", "code", authErr.Code)
}
```

`errors.AsType` is generic, type-safe, faster, and generally easier to use than `errors.As`. [3]

---

## Goroutine Lifecycle

For modules that own goroutines—workers, watchers, pollers, background processors—make startup, shutdown, cancellation, and error propagation explicit.

Use the built-in `goroutineleak` profile in integration tests and production diagnostics. It is generally available in Go 1.27; the former `GOEXPERIMENT=goroutineleakprofile` setting was removed. [2]

```go
import "runtime/pprof"

func TestWorkerNoLeaks(t *testing.T) {
    svc := NewWorker(newFakeStore(), defaultConfig())

    // Start and exercise the worker.
    // ...

    profile := pprof.Lookup("goroutineleak")
    if profile == nil {
        t.Fatal("goroutineleak profile unavailable")
    }

    // Write or inspect the profile according to the test's diagnostics strategy.
}
```

For an HTTP service, expose `/debug/pprof/goroutineleak` through `net/http/pprof` in non-production diagnostics environments. [2]

The detector identifies goroutines blocked on concurrency primitives that cannot become unblocked. It may miss leaks where the blocking primitive remains reachable through globals or locals of runnable goroutines; do not treat a clean profile as proof that no leak exists. [2]

---

## API Planning

Before implementation, answer:

1. Which deep module(s) does the change touch?
2. Does it modify the public API or only `internal/`?
3. Can the behavior be expressed as a table-driven test against the existing API?
4. If a new module is required, which exported types and methods define its contract?

Document the decision before generating implementation:

```markdown
## Module Impact

- auth: public API unchanged; internal/token extended.
- billing: adds `Service.Subscribe(ctx context.Context, plan Plan) (SubscriptionID, error)`.

## Tests Required

- billing_test.go: success, duplicate subscription, payment failure.
```

When package boundaries are unclear, write and review the public API first. Ask for approval before generating implementation.

---

## Go 1.26 Features

| Feature | Design guidance |
|---|---|
| `new(expr)` | Use for concise pointer initialization, especially optional fields: `Age: new(yearsSince(born))`. [3] |
| Self-referential generic constraints | Use for recursive domain types when they improve the public contract; do not add generics without a concrete need. [3] |
| `errors.AsType` | Prefer over `errors.As` for typed error inspection at module boundaries. [3] |
| Green Tea GC | Default since Go 1.26. Profile before adding object pools or allocation workarounds. [3] |
| `goroutineleak` | Use for goroutine-owning modules; generally available in Go 1.27. [2] |
| `go fix` modernizers | Use during upgrades and cleanup, then review diffs; do not blindly accept automated rewrites. [3] |
| `runtime/secret` | Experimental. Consider only for security-critical secret handling; verify platform support and stability before relying on it. [3] |

```go
// Go 1.26: self-referential generic constraint.
type Node[T Node[T]] interface {
    Children() []T
    Value() any
}
```

---

## Go 1.27 Features

| Feature | Design guidance |
|---|---|
| Generic methods | Use for type-specific generic operations, such as `(*Rand) N[Int intType](Int) Int`. Interface methods cannot declare type parameters, and generic methods cannot implement interface methods. [2] |
| Struct-literal field selectors | Initialize nested or embedded fields directly when it improves readability; do not use it to bypass meaningful constructors. [2] |
| Generalized function type inference | Prefer clear function types and direct assignment; do not add explicit type arguments solely to satisfy inference. [2] |
| `encoding/json/v2` | Prefer for new JSON APIs needing configurable, stricter behavior. It rejects invalid UTF-8 and duplicate object names by default. [2] |
| `encoding/json/jsontext` | Use for low-level streaming or token-level JSON processing. [2] |
| `uuid` | Use the standard-library package for UUID generation and parsing; remove third-party UUID dependencies when migrating. [2] |
| `crypto/mldsa` | Use for post-quantum ML-DSA signatures where protocol and compliance requirements call for them; it integrates with `crypto/x509` and TLS 1.3. [2] |
| `go test` `stdversion` vet check | Keep `go.mod`’s `go` directive accurate; it now detects standard-library symbols newer than the effective language version. [2] |
| `go mod tidy` require consolidation | For `go 1.27+` modules, rely on tidy to merge duplicate `require` blocks into direct and indirect groups. [2] |
| Faster small allocations | Do not preemptively optimize allocations; benchmark first. [2] |

Generic-method example:

```go
// Go 1.27: methods may declare their own type parameters.
func (r *Repository) Query[T Entity](ctx context.Context, id string) (T, error) { ... }
```

Do not place generic methods in interfaces:

```go
// Invalid: interface methods cannot declare type parameters.
type Repository interface {
    Query[T Entity](ctx context.Context, id string) (T, error)
}
```

---

## JSON Boundaries

Treat JSON schemas as module boundaries. Do not let transport DTOs leak into domain internals.

- Use `encoding/json/v2` for new APIs that benefit from explicit options and stricter defaults. [2]
- Use `encoding/json/jsontext` only for streaming, transformation, or protocol-level JSON handling. [2]
- Keep existing `encoding/json` usage stable unless migration is justified; Go 1.27 retains the v1 API while backing it with the v2 implementation. [2]
- Define explicit DTOs at service edges; do not expose internal storage or domain types directly in HTTP payloads.
- Validate unknown or malformed input at the boundary; return stable, typed errors from the module.

---

## Security and Errors

- Pass `context.Context` to operations supporting cancellation, deadlines, or request-scoped values.
- Handle errors explicitly; preserve useful context with `%w`.
- Do not wrap a pointer to an error type with `%w` when the underlying type implements `error`; Go 1.27’s `vet` printf analyzer flags this as a likely bug. [2]
- Keep secrets, keys, tokens, and credentials inside the owning module; do not expose raw secret material through public APIs.
- Use standard-library crypto primitives. Avoid custom cryptography and unnecessary dependencies.

---

## AI Collaboration Rules

Apply every session:

- Never import from a sibling `internal/` package.
- Never add exported symbols without determining whether they belong in the public API; exported names are long-term commitments.
- Always run `go test ./...` after changing `internal/`; tests are the contract.
- Run `gofmt`, `go vet ./...`, and `go test ./...` before reporting success.
- Never claim a check passed unless it was executed and its result observed.
- Keep diffs scoped to the requested change; avoid unrelated refactors.
- Prefer standard-library solutions unless a dependency is justified.
- Prefer deeper modules over more packages.
- Use interfaces idiomatically: small, consumer-defined, behavior-named, and only when abstraction has a consumer need.
- Return concrete types from constructors by default.
- Design public APIs before implementation.
- Test observable behavior, not implementation details.
- Use Go 1.26/1.27 features only when they improve clarity, safety, performance, or maintainability.

---

## Verification Checklist

Before completing a Go change:

```bash
gofmt -w .
go vet ./...
go test ./...
```

For modules owning goroutines, include leak-focused integration tests. For JSON-facing modules, include encoding and decoding failure cases. For public-API changes, update documentation, examples, and tests in the same change.
