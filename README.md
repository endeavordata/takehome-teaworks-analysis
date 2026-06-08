# Endeavor Tea Works — Take-Home Starter Repo

This is the starter repo for the Endeavor Labs data engineer take-home assignment.

**👉 Read [`ASSIGNMENT.md`](./ASSIGNMENT.md) first — that's the full brief.**

It walks you through setup, the company context, the data model, and the actual tasks. Plan for about 3–4 hours. AI assistance (we recommend Claude Code) is strongly encouraged — see the "Using AI" section in the brief.

---

## Quick reference

- **Setup** — see `ASSIGNMENT.md` § 1.
- **Tasks** — see `ASSIGNMENT.md` § 5.
- **Submission** — see `ASSIGNMENT.md` § 6.
- **Evaluation** — see `ASSIGNMENT.md` § 7.

## Repo layout

```
.
├── ASSIGNMENT.md                # the full brief — start here
├── README.md                    # this file
├── package.json                 # Evidence + DuckDB connector
├── evidence.plugins.yaml
├── sources/
│   └── endeavor/
│       ├── connection.yaml      # DuckDB connection, points at the data file
│       └── products_by_line.sql # source query used by the hello-world page
├── pages/
│   ├── index.md                 # hello-world — verify your setup
│   ├── recall.md                # Part D1 — you'll build this
│   └── ops.md                   # Part D2 — you'll build this
├── schema/
│   └── ddl.sql                  # full schema DDL for reference
├── queries/                     # put your SQL files here
└── outputs/                     # put query result CSVs here
```

If you get stuck, email us — see `ASSIGNMENT.md` for the address.
