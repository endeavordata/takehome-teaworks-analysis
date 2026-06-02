---
title: Hello, Endeavor Tea Works
---

If you can read the numbers below, your environment is wired up correctly. You're ready to start the assignment.

```sql product_count
SELECT COUNT(*) AS n_products FROM endeavor.products_by_line
```

<BigValue data={product_count} value=n_products title="SKUs in the catalog" />

## SKUs by product line

```sql by_line
SELECT product_line, sku_count FROM endeavor.products_by_line ORDER BY sku_count DESC
```

<DataTable data={by_line} />

---

Next steps:
- Open `pages/recall.md` and build the Part D1 dashboard there.
- Open `pages/ops.md` and build the Part D2 dashboard there.
- Put your SQL files in `queries/` and CSV outputs in `outputs/`.
- Create `writeup.md` in the repo root with your findings.
