---
name: sqlito-query-optimizer
description: Optimize SQL queries for MySQL, MariaDB, PostgreSQL, SQLite, and SQL Server via sqli.to (SQLito) from a headless environment. Use when asked to optimize, tune, or speed up a SQL query, suggest indexes, or analyze an EXPLAIN plan.
---

# SQLito Query Optimizer (sqli.to)

Optimize SQL queries headlessly through the undocumented JSON API behind https://sqli.to.
No browser, no account, no API key registration required.

## Constraints

- Return only optimizations SQLito produces. Never invent, extend, or "improve" its output.
- The service does not execute SQL and has no access to a database. It reasons statically over the query text plus any diagnostics supplied.
- Every submitted query is stored server-side and is readable by anyone holding the returned `publicSlug`. Redact secrets, PII, and real identifiers before submitting.
- `performanceGain` is an estimate produced by the service, not a measurement. Report it as such.

## API

Two Supabase edge functions serve the site:

| Tier     | Endpoint                                      | Purpose                                           |
| -------- | --------------------------------------------- | ------------------------------------------------- |
| Standard | `POST {BASE}/functions/v1/analyze-query`      | Query text only                                   |
| Enhanced | `POST {BASE}/functions/v1/analyze-query-deep` | Query plus schema/EXPLAIN/index/stats diagnostics |

`BASE` is `https://nvmujctjmkqzyhnnvglb.supabase.co`.

Send these headers on every request:

```
apikey: <anon-key>
Authorization: Bearer <anon-key>
Content-Type: application/json
```

The anon key is public and embedded in the site bundle. Discover it at runtime rather than
hardcoding it, so key rotation does not break the skill:

```python
import re, urllib.request

def discover():
    html = urllib.request.urlopen("https://sqli.to").read().decode()
    bundle = re.search(r"/assets/index-[A-Za-z0-9_-]+\.js", html).group(0)
    js = urllib.request.urlopen("https://sqli.to" + bundle).read().decode()
    base = re.search(r"https://[a-z0-9]+\.supabase\.co", js).group(0)
    key = re.search(r"eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+", js).group(0)
    return base, key
```

### Request body

```json
{
  "query": "SELECT * FROM orders WHERE YEAR(created_at) = 2024;",
  "database": { "id": "mysql", "name": "MySQL" },
  "diagnosticData": {
    "schema": "CREATE TABLE orders (...);",
    "explainPlan": "type=ALL rows=1200000 key=NULL",
    "indexes": "PRIMARY KEY (id)",
    "stats": "orders: 1.2M rows, 480MB"
  }
}
```

Critical details:

- Pass `database` as an **object** keyed on `id`. A plain string fails with
  `500 {"error":"Database type is required"}`. This is the single most common mistake —
  the site's own JS bundle reads as if it sends a string.
- Valid `id` values: `mysql`, `mariadb`, `postgresql`, `sqlite`, `sqlserver`. Values are
  case-sensitive; `MySQL` is rejected.
- `diagnosticData` and all four of its sub-fields are optional. Send only what you have.
- Send `diagnosticData` only to `analyze-query-deep`; the standard endpoint ignores it.
- `diagnosticContext` and `userId` appear in the site's bundle but are optional. Omit them.

### Response

```json
{
  "original": "…",
  "optimized": "…",
  "performanceGain": "20-40%",
  "reasoning": "…",
  "recommendations": [{ "suggestion": "…", "confidence": "high" }],
  "indexSuggestions": [{ "suggestion": "CREATE INDEX …", "confidence": "high" }],
  "implementationSteps": ["…"],
  "reportId": "uuid",
  "publicSlug": "otknnxs9",
  "publicUrl": "https://sqli.to/report/otknnxs9"
}
```

`analyze-query-deep` may additionally return `explainAnalysis`, `schemaInsights`,
`indexAnalysis`, and `tableStatsAnalysis`. Which of these appear varies per request — treat
each as optional and skip any that is absent.

Errors return HTTP 500 with `{"error": "...", "details": "..."}`. Missing `query` yields
`Query is required`; a malformed `database` yields `Database type is required`.

## Procedure

1. Pick the dialect `id` from the five supported values. Default to `mysql` only when the user gives no hint.
2. Redact sensitive literals from the query.
3. Collect diagnostics if available (DDL, `EXPLAIN` output, index list, row counts). Use `analyze-query-deep` when any are present, otherwise `analyze-query`.
4. POST the request. Allow a 120 s timeout; typical latency is 3–5 s.
5. On HTTP 500, read `error` and correct the payload — do not retry unchanged.
6. Report `optimized`, `reasoning`, `recommendations`, `indexSuggestions`, and `performanceGain` verbatim. Add the `publicUrl` for the full report.

## Usage

Use `scripts/sqlito.py`. It handles discovery, payload construction, tier selection, and rendering.

```bash
# Standard analysis
python3 scripts/sqlito.py -d postgresql -q "SELECT * FROM users WHERE lower(email)='a@b.com';"

# Enhanced analysis — supplying any diagnostic auto-selects the deep endpoint
python3 scripts/sqlito.py -d mysql \
  -q "SELECT * FROM orders WHERE YEAR(created_at)=2024;" \
  --schema "CREATE TABLE orders(id INT PRIMARY KEY, created_at DATETIME);" \
  --explain "type=ALL rows=1200000 key=NULL" \
  --indexes "PRIMARY(id)" \
  --stats  "1.2M rows / 480MB"

# Read from a file or stdin; emit raw JSON for programmatic use
python3 scripts/sqlito.py -f query.sql -d sqlserver
cat query.sql | python3 scripts/sqlito.py -f - -d sqlite --json
```

Import it directly when composing with other steps. `scripts/` must be on `sys.path`,
so add it explicitly unless the interpreter already runs from that directory:

```python
import sys
sys.path.insert(0, "scripts")  # or the absolute path to this skill's scripts/ directory

from sqlito import optimize, render

result = optimize("SELECT * FROM t WHERE UPPER(name)='X';", database="mariadb")
print(render(result))
print(result["optimized"], result["performanceGain"])
```

Minimal dependency-free call, if the script is unavailable:

```python
import json, urllib.request

base, key = discover()
body = json.dumps({
    "query": "SELECT * FROM orders WHERE YEAR(created_at)=2024;",
    "database": {"id": "mysql", "name": "MySQL"},
}).encode()
req = urllib.request.Request(
    f"{base}/functions/v1/analyze-query", data=body, method="POST",
    headers={"apikey": key, "Authorization": f"Bearer {key}",
             "Content-Type": "application/json"},
)
result = json.loads(urllib.request.urlopen(req, timeout=120).read())
print(result["optimized"])
```

## Notes

- Batch queries by looping with a short pause. Five sequential calls triggered no rate limiting; back off on repeated non-200 responses.
- Retrieve any past report without auth:
  `GET {BASE}/rest/v1/query_analyses?public_slug=eq.<slug>&select=*` with the same headers.
