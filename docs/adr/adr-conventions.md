---
type: Reference
title: ADR Conventions
description: Numbering, header fields, body sections, supersession rules, and Brown M&M markers for Architecture Decision Records.
tags: [adr, conventions, documentation]
---

# ADR Conventions

This document defines the conventions for Architecture Decision Records
in this project. An ADR records the *why* behind an architectural
decision so it is not re-litigated from the code. When the README and an
ADR disagree, the ADR wins.

## Numbering and filenames

- ADRs are numbered with **4-digit zero-padded** integers: `0001`, `0002`,
  `0003`, and so on. Numbers are monotonic and never reused.
- Filenames follow `NNNN-kebab-case-title.md`, for example
  `0001-use-a-single-binary.md`.
- The H1 heading matches the filename title:
  `# ADR 0001: Use a single binary`.

## Header fields

Every ADR begins with a markdown bullet list of header fields, each on its
own line, using the bold-label format:

```
- **Status**: Accepted
- **Date**: 2026-06-20
- **Supersedes**: [ADR NNNN - Title](NNNN-title.md)
- **Superseded by**: none
- **Parent**: [ADR NNNN - Title](NNNN-title.md)
- **Related code**: [`path/`](../../path/)
```

- **Status** is one of `Accepted`, `Proposed`, `Deprecated`, or
  `Superseded by ADR NNNN`. When an ADR is superseded, change its Status
  to `Superseded by ADR NNNN` and add a `Supersedes` reference on the
  replacing ADR. The historical Decision and Consequences text stays
  intact; only the Status field changes.
- **Date** is `YYYY-MM-DD`, the date the ADR was accepted.
- **Supersedes** lists the ADRs this one replaces, or `none`.
- **Superseded by** names the ADR that replaces this one, or `none`.
- **Parent** names the ADR this one refines or elaborates, or `none`. Not
  every ADR has a parent; omit the line when it does not apply.
- **Related code** links to the packages, files, or docs the decision
  governs, as relative markdown links from the ADR's location.

## Body sections

Every ADR has these five body sections, in order:

1. **Context**: the problem and the forces at play. What is being decided,
   and why now. Reference prior ADRs or inline decision IDs (D1, J-3, ...)
   when this decision refines an existing one.
2. **Decision**: the choice made, with each sub-decision labelled (D1, D2,
   G1, G2, C1, C2, ...). Reference the inline code tags and decision IDs
   used in the source so the ADR and the code stay cross-referenceable.
3. **Consequences**: positive and negative outcomes, split into
   **Positive** and **Negative** subsections.
4. **Alternatives Considered**: the options rejected and why. Each
   alternative is labelled (A1, A2, ...) with a one- or two-sentence
   rejection reason.
5. **When this changes**: the triggers that would reopen this decision.
   Each trigger is a bullet starting with the decision ID it would affect.
   Close with the standing line: "Until one of these triggers fires, the
   decisions above are the intended design, not a temporary state."

## Supersession

When a new ADR replaces an old one:

1. The new ADR's `Supersedes` field names the old ADR.
2. The old ADR is removed from the repository once all live references to it
   are updated to plain text or removed.
3. Historical context required by the new ADR is summarized inline; do not
   keep a deleted ADR's body around for historical reference alone.

Supersession is a clean break, not a layered amendment. The replacing ADR owns
both the new decision and the rationale for why the old one was retired.

## Brown M&M markers

Some decisions carry a Brown M&M marker: a short string tagged at the
implementation site and used in commits and issues to flag changes that
touch a documented alignment boundary. The format is:

```
TAG-NAME-BROWN-MNM: short-scope-description
```

Example:

```
CONFIG-NOT-FLAGS-BROWN-MNM: all-runtime-config-via-yaml-file
```

A Brown M&M marker is not required on every ADR. Add one when the decision
draws a line that future changes must not silently cross. When the marker
appears in a commit or issue, reviewers know to check whether the change
respects that boundary.
