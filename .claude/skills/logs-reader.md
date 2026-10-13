---
name: logs-reader
description: Use this skill when reading, searching, tailing, or analyzing production logs via the SRE Logs API. Triggers on: read logs, search logs, investigate errors in production, log hit trends, top values for a log field, list available topics or applications, latency anomalies in production.
user-invocable: true
---

# logs-reader

Read and analyze production logs via the SRE Logs API (ClickHouse-backed).

## CRITICAL: Tool requirements

The API endpoint is on an internal network — only reachable via curl from the user's machine.

- **ALWAYS use the `Bash` tool** with `curl` for every API call.
- **NEVER use the `WebFetch` tool** — it does not support auth headers and will fail.
- If you catch yourself about to call WebFetch, stop and use Bash+curl instead.

The very first Bash call in every session must load the env file:
```bash
source ~/.config/zsh/.zshrc
echo "Base URL: $LOGS_API_BASE_URL"
echo "Token loaded: ${LOGS_API_TOKEN:0:20}..."
```

All subsequent curl calls use `$LOGS_API_BASE_URL` and `$LOGS_API_TOKEN` from that env file.

## Trigger

Use this skill when the user asks to:
- Read, search, or tail logs for an application
- Investigate errors, latency, or anomalies in production
- Get log hit trends or volume over time
- Find top values for a field or tag in logs
- List available topics or applications

## Setup

### Token and base URL

Source the `.env` file once at the start. It provides:
- `LOGS_API_TOKEN` — JWT bearer token
- `LOGS_API_BASE_URL` — API base URL (internal network)

```bash
source ~/.config/zsh/.zshrc
```

### Decode token claims

```bash
source ~/.config/zsh/.zshrc && \
echo $LOGS_API_TOKEN | cut -d. -f2 | base64 -d 2>/dev/null | python3 -m json.tool
```

Key claims:
| Claim | Meaning |
|---|---|
| `dc` | Datacenter this token is scoped to |
| `topics` | Array of Kafka topics the user may query |
| `rpm` | Rate limit — requests per minute |
| `exp` | Expiry (Unix timestamp) — check token is not expired |
| `is_admin` | Admin users may refresh metadata cache |

**Always use only the topics listed in the token's `topics` claim. Querying other topics will return 403.**

### Auth header

All API calls (except `/health`) require:
```
Authorization: Bearer $LOGS_API_TOKEN
```

---

## Workflow

### 1. Verify token is valid and not expired

```bash
source ~/.config/zsh/.zshrc
exp=$(echo $LOGS_API_TOKEN | cut -d. -f2 | base64 -d 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin)['exp'])")
now=$(date +%s)
[ "$now" -lt "$exp" ] && echo "Token valid" || echo "Token EXPIRED"
```

If expired, inform the user immediately — all API calls will fail with 401.

### 2. Discover available topics and applications

**List allowed topics** (filtered by token's `topics` claim):
```bash
source ~/.config/zsh/.zshrc
curl -s -H "Authorization: Bearer $LOGS_API_TOKEN" "$LOGS_API_BASE_URL/api/v1/metadata/topics"
```

**List applications for a topic:**
```bash
source ~/.config/zsh/.zshrc
curl -s -H "Authorization: Bearer $LOGS_API_TOKEN" \
"$LOGS_API_BASE_URL/api/v1/metadata/topics/{topic}/applications"
```

**List available JSON fields for an application** (ISO 8601 time range required):
```bash
source ~/.config/zsh/.zshrc
curl -s -H "Authorization: Bearer $LOGS_API_TOKEN" \
"$LOGS_API_BASE_URL/api/v1/metadata/topics/{topic}/applications/{application}/fields?from=2024-01-01T00:00:00Z&to=2024-01-02T00:00:00Z"
```

**List tag keys for an application:**
```bash
source ~/.config/zsh/.zshrc
curl -s -H "Authorization: Bearer $LOGS_API_TOKEN" \
"$LOGS_API_BASE_URL/api/v1/metadata/topics/{topic}/applications/{application}/tags?from=2024-01-01T00:00:00Z&to=2024-01-02T00:00:00Z"
```

### 3. Query logs

All query endpoints are `POST` and share a common request shape:

```json
{
"topic": "<from token claims>",
"application_name": "<app>",
"from": "<unix epoch seconds as string>",
"to": "<unix epoch seconds as string>",
"mode": "NORMAL",
"search_keyword": "<base64 encoded query or omit>"
}
```

**Time helpers:**
```bash
from=$(date -v-1H +%s 2>/dev/null || date -d '1 hour ago' +%s)
to=$(date +%s)
```

> **IMPORTANT CONSTRAINTS (verified against prod API):**
> - Maximum time range: **24 hours**. Queries spanning more than 24h return HTTP 400 `"querying time range more than 24 hours not allowed"`.
> - `from` and `to` must be **unix epoch seconds as strings** (not ISO 8601, not `now-Xh` notation).
> - `search_keyword` must be **base64 encoded**.
> - **Always use Python3 `python3 << 'PYEOF'` heredoc** for API calls — do NOT use curl with inline shell variable assignment (zsh parse errors). Example:
> ```python
> import urllib.request, json, time, base64
> token = '...'  # hardcode token directly
> base = 'logs-api-prod.internal.angelone.in'
> now = int(time.time())
> from_ts = str(now - 3600)   # last 1 hour
> to_ts = str(now)
> kw_b64 = base64.b64encode(b'your keyword').decode()
> payload = json.dumps({'topic': 'aws-prod-ecs-kyc', 'application_name': 'kyc2-int-adapter-prod',
>     'from': from_ts, 'to': to_ts, 'mode': 'NORMAL', 'search_keyword': kw_b64}).encode()
> req = urllib.request.Request(f'https://{base}/api/v1/rawlogs', data=payload,
>     headers={'Authorization': f'Bearer {token}', 'Content-Type': 'application/json'}, method='POST')
> with urllib.request.urlopen(req, timeout=30) as r:
>     d = json.load(r)
>     entries = (d.get('data') or {}).get('response') or []
>     print(f'hits: {len(entries)}')
> ```

---

## Endpoints

### Raw logs — `POST /api/v1/rawlogs`

Returns raw log entries matching the query. Use for detailed investigation.

```bash
source ~/.config/zsh/.zshrc
curl -s -X POST \
-H "Authorization: Bearer $LOGS_API_TOKEN" \
-H "Content-Type: application/json" \
-d "{\"topic\": \"$TOPIC\", \"application_name\": \"$APP\", \"from\": \"$FROM\", \"to\": \"$TO\", \"mode\": \"NORMAL\"}" \
"$LOGS_API_BASE_URL/api/v1/rawlogs"
```

### Hits trend — `POST /api/v1/hitstrend`

Returns time-series data of log counts over the requested window. Use for spotting spikes or drops in log volume.

```bash
source ~/.config/zsh/.zshrc
curl -s -X POST \
-H "Authorization: Bearer $LOGS_API_TOKEN" \
-H "Content-Type: application/json" \
-d "{\"topic\": \"$TOPIC\", \"application_name\": \"$APP\", \"from\": \"$FROM\", \"to\": \"$TO\"}" \
"$LOGS_API_BASE_URL/api/v1/hitstrend"
```

### Top tag values — `POST /api/v1/toptags`

Returns top 15 values (with counts) for a given tag key.

```bash
source ~/.config/zsh/.zshrc
curl -s -X POST \
-H "Authorization: Bearer $LOGS_API_TOKEN" \
-H "Content-Type: application/json" \
-d "{\"topic\": \"$TOPIC\", \"application_name\": \"$APP\", \"from\": \"$FROM\", \"to\": \"$TO\", \"tag\": \"$TAG\"}" \
"$LOGS_API_BASE_URL/api/v1/toptags"
```

### Top field values — `POST /api/v1/topvalues`

Returns top 15 values (with counts) for a JSON field in the message column.

```bash
source ~/.config/zsh/.zshrc
curl -s -X POST \
-H "Authorization: Bearer $LOGS_API_TOKEN" \
-H "Content-Type: application/json" \
-d "{\"topic\": \"$TOPIC\", \"application_name\": \"$APP\", \"from\": \"$FROM\", \"to\": \"$TO\", \"field\": \"$FIELD\"}" \
"$LOGS_API_BASE_URL/api/v1/topvalues"
```

---

## Search keyword encoding

The `search_keyword` field must be **base64 encoded**. Leave it out entirely when no filter is needed.

```bash
echo -n "'ERROR' AND 'AB1234'" | base64
```

---

## Query syntax

### NORMAL mode (default)

Use NORMAL mode for all standard searches. Default to this unless the user asks for EXPERT or the query requires SQL.

#### Basic text search

Wrap terms in single quotes. Combine with `AND`, `OR`, and parentheses.

```
'ERROR'
'ERROR' AND 'AB1223'
'ERROR' OR 'WARN'
'ERROR' AND ('AB1234' OR 'INFO')
```

#### JSON field search (`log.` prefix)

For logs in JSON format, prefix the key with `log.`. String values in single quotes; numeric values are bare.

```
log.userID = 'AB1234'
log.latency >= 1
log.gmID != 8
log.error = 'Invalid Token'
```

Supported operators: `=`, `!=`, `>`, `>=`, `<`, `<=`

#### Metadata / tag search (`tag.` prefix)

Server hostname, application name, and other infrastructure metadata live in the tags column.

```
tag.host = 'mds-ws11.gpx.prod.angelone.in'
tag.application_name = 'amx-golang-reports'
```

---

### EXPERT mode

Sends a raw SQL `WHERE` clause directly to ClickHouse. Use when NORMAL mode cannot express the query.

#### Text search

```sql
message LIKE '%ERROR%'
message LIKE '%ERROR%' AND message LIKE '%AB1234%'

-- Faster token-based search (exact word match)
hasToken(message, 'ERROR')
```

#### JSON field extraction

```sql
JSONExtractString(message, 'userID') = 'AB1234'
JSONExtractFloat(message, 'latency') > 10.0
```

#### Regex extraction

```sql
message LIKE '%OmneRespTime%'
AND toInt16(regexpExtract(message, '"OmneRespTime":(.*),"caller"')) > 1000
```

---

## Admin operations (is_admin only)

**Refresh metadata cache:**
```bash
source ~/.config/zsh/.zshrc
curl -s -X POST -H "Authorization: Bearer $LOGS_API_TOKEN" "$LOGS_API_BASE_URL/api/v1/metadata/refresh"
```

**Cache statistics:**
```bash
source ~/.config/zsh/.zshrc
curl -s -H "Authorization: Bearer $LOGS_API_TOKEN" "$LOGS_API_BASE_URL/api/v1/metadata/stats"
```

---

## Rate limiting

The token's `rpm` claim sets the requests-per-minute limit. Space out calls if running multiple queries. If you hit 429, wait before retrying.

---

## Error handling

| Status | Meaning | Action |
|---|---|---|
| 401 | Token missing or malformed | Check `Authorization` header |
| 403 | Topic not in token's `topics` claim, or token expired | Verify token claims; check expiry |
| 400 | Bad request (missing required field, bad timestamp) | Fix request body |
| 500 | Server error | Retry once; escalate if persistent |

---

## Example: investigate errors in the last 30 minutes

```bash
source ~/.config/zsh/.zshrc
from=$(date -v-30M +%s 2>/dev/null || date -d '30 minutes ago' +%s)
to=$(date +%s)
keyword=$(echo -n "'ERROR'" | base64)
topic=$(echo $LOGS_API_TOKEN | cut -d. -f2 | base64 -d 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin)['topics'][0])")

curl -s -X POST \
-H "Authorization: Bearer $LOGS_API_TOKEN" \
-H "Content-Type: application/json" \
-d "{\"topic\": \"$topic\", \"application_name\": \"<app>\", \"from\": \"$from\", \"to\": \"$to\", \"mode\": \"NORMAL\", \"search_keyword\": \"$keyword\"}" \
"$LOGS_API_BASE_URL/api/v1/rawlogs" | python3 -m json.tool
```
