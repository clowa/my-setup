#!/usr/bin/env python3
"""Headless client for the sqli.to (SQLito) SQL query optimizer."""
import argparse
import json
import re
import sys
import urllib.request

SITE = "https://sqli.to"
FALLBACK_URL = "https://nvmujctjmkqzyhnnvglb.supabase.co"
FALLBACK_KEY = (
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9."
    "eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im52bXVqY3RqbWtxenlobm52Z2xiIiwicm9sZSI6"
    "ImFub24iLCJpYXQiOjE3NTE0MjUwNDgsImV4cCI6MjA2NzAwMTA0OH0."
    "6rErOHVW71OmBp5IuCGcawTktD4qcY3uE4qBv9MDgn4"
)
DATABASES = {
    "mysql": "MySQL",
    "mariadb": "MariaDB",
    "postgresql": "PostgreSQL",
    "sqlite": "SQLite",
    "sqlserver": "SQL Server",
}


def _get(url, timeout=30):
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
    with urllib.request.urlopen(req, timeout=timeout) as r:
        return r.read().decode("utf-8", "replace")


def discover():
    """Resolve API base URL and anon key from the live JS bundle.

    Falls back to known-good constants when discovery fails, so a change to the
    site's bundle naming degrades gracefully instead of breaking the caller.
    """
    try:
        bundle = re.search(r"/assets/index-[A-Za-z0-9_-]+\.js", _get(SITE)).group(0)
        js = _get(SITE + bundle)
        url = re.search(r"https://[a-z0-9]+\.supabase\.co", js).group(0)
        key = re.search(r"eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+", js).group(0)
        return url, key
    except Exception:
        return FALLBACK_URL, FALLBACK_KEY


def optimize(query, database="mysql", deep=False, diagnostics=None, timeout=120):
    """Send one query to SQLito and return the parsed analysis."""
    if database not in DATABASES:
        raise ValueError(f"database must be one of {sorted(DATABASES)}")
    base, key = discover()
    fn = "analyze-query-deep" if deep else "analyze-query"
    # `database` MUST be an object; the edge function validates database.id.
    payload = {
        "query": query,
        "database": {"id": database, "name": DATABASES[database]},
    }
    if diagnostics:
        payload["diagnosticData"] = diagnostics
    req = urllib.request.Request(
        f"{base}/functions/v1/{fn}",
        data=json.dumps(payload).encode(),
        headers={
            "apikey": key,
            "Authorization": f"Bearer {key}",
            "Content-Type": "application/json",
        },
        method="POST",
    )
    try:
        with urllib.request.urlopen(req, timeout=timeout) as r:
            return json.loads(r.read().decode())
    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8", "replace")
        raise RuntimeError(f"SQLito HTTP {e.code}: {body[:400]}") from None


def render(res):
    """Format an analysis result as plain text."""
    out = [
        "=== OPTIMIZED QUERY ===",
        res.get("optimized", "").strip(),
        "",
        f"Estimated performance gain: {res.get('performanceGain', 'n/a')}",
        "",
        "=== REASONING ===",
        res.get("reasoning", "").strip(),
    ]
    for title, field in (
        ("RECOMMENDATIONS", "recommendations"),
        ("INDEX SUGGESTIONS", "indexSuggestions"),
    ):
        items = res.get(field) or []
        if items:
            out += ["", f"=== {title} ==="]
            for i in items:
                out.append(f"- [{i.get('confidence', '?')}] {i.get('suggestion', '')}")
    steps = res.get("implementationSteps") or []
    if steps:
        out += ["", "=== IMPLEMENTATION STEPS ==="]
        out += [f"{n}. {s}" for n, s in enumerate(steps, 1)]
    # Deep-tier sections, present only when diagnostics were supplied.
    for title, field in (
        ("EXPLAIN PLAN ANALYSIS", "explainAnalysis"),
        ("SCHEMA INSIGHTS", "schemaInsights"),
        ("INDEX ANALYSIS", "indexAnalysis"),
        ("TABLE STATS ANALYSIS", "tableStatsAnalysis"),
    ):
        if res.get(field):
            out += ["", f"=== {title} ===", res[field].strip()]
    if res.get("publicUrl"):
        out += ["", f"Report: {res['publicUrl']}"]
    return "\n".join(out)


def main():
    p = argparse.ArgumentParser(description="Optimize a SQL query via sqli.to")
    p.add_argument("-q", "--query", help="SQL query text")
    p.add_argument("-f", "--file", help="read SQL from file ('-' for stdin)")
    p.add_argument("-d", "--database", default="mysql", choices=sorted(DATABASES))
    p.add_argument("--deep", action="store_true", help="enhanced analysis")
    p.add_argument("--schema", help="DDL / CREATE TABLE statements")
    p.add_argument("--explain", help="EXPLAIN plan output")
    p.add_argument("--indexes", help="existing index definitions")
    p.add_argument("--stats", help="table statistics (row counts, sizes)")
    p.add_argument("--json", action="store_true", help="raw JSON output")
    a = p.parse_args()

    if a.file:
        query = sys.stdin.read() if a.file == "-" else open(a.file).read()
    elif a.query:
        query = a.query
    else:
        p.error("provide --query or --file")

    diagnostics = {
        k: v
        for k, v in (
            ("schema", a.schema),
            ("explainPlan", a.explain),
            ("indexes", a.indexes),
            ("stats", a.stats),
        )
        if v
    }
    # Diagnostics are only consumed by the deep endpoint.
    deep = a.deep or bool(diagnostics)
    res = optimize(query, a.database, deep=deep, diagnostics=diagnostics or None)
    print(json.dumps(res, indent=2) if a.json else render(res))


if __name__ == "__main__":
    main()
