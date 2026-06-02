# Endeavor Tea Works — Take-Home Starter

This repo is the starting point for the junior data engineer take-home assignment. It's a minimal [Evidence.dev](https://evidence.dev) project with a DuckDB connection pre-wired to the Endeavor Tea Works dataset.

> **Read the full assignment brief first:** `docs/take-home-junior-de.md` (provided separately).

---

## Setup

### 1. Get the data

Download `endeavor_tea_works.duckdb.zip` from **[PLACEHOLDER: Google Drive link]**, unzip, and place `endeavor_tea_works.duckdb` in **the root of this repo** (alongside `package.json`). The connection config expects the file there by default.

### 2. Install dependencies

```bash
npm install
```

Requires Node.js 18+.

### 3. Run the dev server

```bash
npm run sources    # one-time: materialize source queries from DuckDB
npm run dev        # start the Evidence dev server on localhost:3000
```

Open [http://localhost:3000](http://localhost:3000). You should see a "Hello, Endeavor Tea Works" page with a product count (300) and a small table of product lines. If you do, your environment is good to go.

If the page loads but data doesn't appear, the `.duckdb` file probably isn't where the connection expects it. Check `sources/endeavor/connection.yaml`.

---

## Repo layout

```
take-home/
├── README.md                       # this file
├── package.json                    # Evidence + DuckDB connector
├── evidence.plugins.yaml           # Evidence plugin registry
├── sources/
│   └── endeavor/
│       ├── connection.yaml         # points at endeavor_tea_works.duckdb
│       └── products.sql            # source query used by the hello-world page
├── pages/
│   ├── index.md                    # hello-world (verify your setup)
│   ├── recall.md                   # Part D1 — you'll build this
│   └── ops.md                      # Part D2 — you'll build this
├── schema/
│   └── ddl.sql                     # full schema DDL for reference
├── queries/                        # put your SQL files here
└── outputs/                        # put query result CSVs here
```

Two empty page stubs (`pages/recall.md`, `pages/ops.md`) are provided. Edit them in place.

---

## Writing SQL against the database directly

You don't have to do everything through Evidence. For Parts A, B, and C, you'll likely want to write and iterate on queries in a SQL editor first, then drop the final versions into `queries/` and into the relevant Evidence page.

Open the database from the DuckDB CLI:

```bash
duckdb endeavor_tea_works.duckdb
```

Or connect from your editor of choice (DBeaver, DataGrip, TablePlus, VS Code's SQLTools extension all support DuckDB).

---

## Submitting

When you're done, zip up this directory **without `node_modules/`** and email it to **[PLACEHOLDER: hiring email]**, or share a link to a private GitHub repo.

Make sure to include:
- Your SQL in `queries/`
- Your CSVs in `outputs/`
- Your filled-in `pages/recall.md` and `pages/ops.md`
- `writeup.md` (create in repo root)
- A short note in this README if there's anything we need to know to run your submission

Good luck.
