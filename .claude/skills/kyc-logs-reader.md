---
name: kyc-logs-reader
description: Use this skill when reading and analyzing KYC production logs (kyc2 services, fulfilment, user-journey, services-prod, workflow). Triggers on: KYC logs, kyc2 logs, app number lookup, EMOD journey logs, onboarding errors, Camunda task failures, Hyperverge errors, kyc2-kyc-user-journey-prod, kyc2-fulfilment-prod, kyc2-services-prod.
user-invocable: true
---

# kyc-logs-reader

A specialised skill for reading and analysing KYC production logs.
Internally uses `logs-reader` for all API mechanics — read that skill first if you haven't already.

## Setup (do this first every session)

```bash
source ~/.config/zsh/.zshrc
```

Then validate the token is not expired (see `logs-reader` §Workflow step 1).

---

## KYC Topics

The token grants access to four KYC Kafka topics:

| Topic | Purpose |
|---|---|
| `aws-prod-ecs-kyc` | Primary KYC topic — all core KYC2 services |
| `aws-prod-ecs-kyc2-web` | KYC2 web frontend service |
| `aws-prod-ecs-kyc2-workflow` | KYC2 workflow engine |
| `aws-prod-ecs-kyc-sb` | KYC sandbox environment |

**Default topic for most queries:** `aws-prod-ecs-kyc`

---

## All KYC Applications

### Topic: `aws-prod-ecs-kyc` (primary)

| Application | Role |
|---|---|
| `kyc2-kyc-user-journey-prod` | **Core journey API** — handles onboarding status, emod journey, flow eligibility, JWT auth |
| `kyc2-fulfilment-prod` | **Fulfilment engine** — Camunda BPM workflows, post-submission processing |
| `kyc2-services-prod` | **Services layer** — journey status, admin APIs, whatsapp docs, identity |
| `kyc2-core-service-prod02` | Core KYC data service |
| `kyc2-core-identity-prod02` | Identity verification service |
| `kyc2-ext-adapter-prod` | External adapter (third-party integrations) |
| `kyc2-int-adapter-prod` | Internal adapter |
| `kyc2-prism-prod` | Prism analytics/events |
| `kyc2-prism-be-prod` | Prism backend |
| `kyc2-emitter-prod02` | Event emitter |
| `kyc2-clcm-prod` | CLCM (Client Lifecycle Management) |
| `kyc2-clcm-jobs-prod` | CLCM batch jobs |
| `kyc2-clcm-critical-prod` | CLCM critical path |
| `kyc2-pdf-utils-prod` | PDF generation/utilities |
| `kyc2-angel-esign-prod02` | eSign service (Angel/Digio) |
| `kyc2-admin-ui-prod` | Admin UI backend |
| `kyc2-refresh-job-prod02` | Scheduled refresh jobs |

### Topic: `aws-prod-ecs-kyc2-web`
| Application | Role |
|---|---|
| `kyc2-web-service-prod` | Web frontend service |

### Topic: `aws-prod-ecs-kyc2-workflow`
| Application | Role |
|---|---|
| `kyc2-workflow-prod` | Workflow engine |

### Topic: `aws-prod-ecs-kyc-sb`
| Application | Role |
|---|---|
| `kycsb-kycsb-prod` | Sandbox KYC service |

---

## Log Structure

All KYC services are written in Go and share a common structured JSON log format emitted via `go-pii-utils`.

### Response shape

Logs live at `data.response[]` (NOT `data.logs[]`):

```json
{
  "data": {
    "response": [
      {
        "time": "<ISO 8601 UTC timestamp>",
        "message": "<JSON string — parse to get fields>",
        "tags": "<JSON string — application_name, container_id, topic>"
      }
    ]
  }
}
```

### CRITICAL — Log entries have multiple schemas. Always read ALL fields.

**Do NOT only read `message`, `correlationId`, `level`, `error`, and `OriginalCaller`.**

KYC services emit several distinct log entry types, each carrying their important data in different fields. If you only print known fields, you will silently drop the most useful information for root cause analysis.

**There are at least three distinct log schemas in use:**

#### Schema 1 — Application event log (most common)
Emitted for business logic events. Key data is inside `message`.

```json
{
  "level": "info",
  "correlationId": "EQ40470833",
  "message": "Status - Populated statusDTO",
  "OriginalCaller": "/go/src/app/business/v1/status/onboarding/status.go:109",
  "statusDTO": "...",
  "statusResponse": "..."
}
```

#### Schema 2 — Outbound HTTP call log (message = `"HTTP Request and Response"`)
Emitted by `utils/http/client.go` for EVERY external API call (Hyperverge, Digio, Setu, Decentro, CLCM, CAMS, KRA, CDSL, etc.). **The root cause of partner/vendor failures lives here.** The `message` field says nothing useful — the real data is in:

```json
{
  "level": "info",
  "message": "HTTP Request and Response",
  "correlationId": "AABJ471979",
  "url": "https://ind-verify.hyperverge.co/api/checkBankAccount",
  "latency": 1616,
  "requestBody": "...",
  "responseStatus": 422,
  "responseBody": "{\"status\":\"failure\",\"error\":\"Invalid value passed for an input: Account number\"}"
}
```

Key fields: `url`, `responseStatus`, `responseBody`, `latency`, `requestBody`

#### Schema 3 — Inbound HTTP request/response log
Emitted by the middleware for every API call received by the service. Contains the full request and response visible from the service boundary.

```json
{
  "level": "info",
  "statusCode": 500,
  "method": "POST",
  "path": "/v1/emod/single-emod/submit",
  "latency": 743.5,
  "clientIP": "10.3.57.28",
  "requestBody": "{...}",
  "responseBody": "{\"code\":\"ERR-GETTING-IMPS-INFO\",...}",
  "requestHeaders": {},
  "responseHeaders": {}
}
```

Key fields: `statusCode`, `path`, `requestBody`, `responseBody`, `latency`, `clientIP`

---

### Common `message` JSON fields (all schemas)

| Field | Type | Description |
|---|---|---|
| `level` | string | `"info"`, `"debug"`, `"error"` |
| `id` | string | **Request UUID** — all log lines for the same HTTP request share this value. Use it to expand results when the 100-entry cap cuts off entries (see §CRITICAL). |
| `correlationId` | string | **Either app number OR client code** depending on flow and log type. On onboarding flows it is the app number (e.g. `"EQ40470833"`). On EMOD flows it may be the client code (e.g. `"AABJ471979"`) — particularly on outbound `"HTTP Request and Response"` entries. Always try both when searching. |
| `client_code` | string | Client code — always present on EMOD logs (e.g. `"AABJ471979"`). Use this as the primary search key for EMOD journeys. |
| `app_number` | string | App/EMOD number — may differ from correlationId on EMOD flows (e.g. `"EM56559097"`). Present alongside `client_code` on EMOD entries. |
| `log_type` | string | Always `"application"` for app logs |
| `time` | string | Local timestamp (IST, `+05:30`) |
| `caller` | string | Always `go-pii-utils/log/piileventlog.go` |
| `OriginalCaller` | string | Actual Go source file and line |
| `message` | string | Human-readable log message — **not always where the root cause is** |

### PII handling

All PII is SHA-256 hashed before logging. Never expect plaintext values.

| PII field | Appearance in logs |
|---|---|
| `mobile` | 64-char hex hash |
| `pan` | 64-char hex hash |
| `email` | 64-char hex hash |

PII decryption events emit dedicated log lines with: `field`, `entity`, `piiType`, `piiValue` (hashed).

Common `piiType` values: `mobile`, `pan`, `email`, `address`, `bank`, `dob`, `json`, `composite`

---

## App-specific Log Patterns

### `kyc2-kyc-user-journey-prod`

**What it does:** Serves the KYC onboarding journey API — status checks, flow eligibility, JWT auth, GORM DB queries.

**Extra fields:**
| Field | Description |
|---|---|
| `appNumber` | App number (also in `correlationId`) |
| `statusDTO` | Full serialised status struct |
| `statusResponse` | JSON-encoded status response sent to client |
| `requestBody` | Parsed request headers + metadata |
| `X-source` | Caller source: `"spark"` (mobile app), `"kyc-admin"` (admin UI) |
| `sql` / `duration` / `rows` / `source` | GORM query details |
| `finalPiiRule` / `calculatedPiiRule` | PII masking rule applied |

**Key log messages to search for:**

| Message | Meaning |
|---|---|
| `"JWT claims values"` | JWT parsed — request authenticated |
| `"handleGenericStatusRoute - request validated successfully"` | Status API request validated |
| `"Status - Populated statusDTO"` | Full status DTO assembled from DB |
| `"Status - Received status response"` | Status response ready to send |
| `"kycType is X for Y"` | KYC type resolved for app number |
| `"eligible flow for appNumber"` | Eligible KYC flows calculated |
| `"checkForMobileHash - Using mobileHash to fetch start entity"` | Mobile hash lookup |
| `"[GORM] query"` | SQL query executed |
| `"decrypted text"` | PII field decryption event |
| `"GetCommonAuthMiddleware: authentication general"` | Auth middleware invoked |

**Common KYC types seen:**
- `DEM_EQ_DEM_MF` — Demat + Equity + Demat + Mutual Fund
- Others: set via `kyc_type` field in `start` table

**KYC journey flows** (in order):
`register → email → panV3 → rpd → bank → digio → poa → selfie → signature → cams → derivatives → brokerage-plan → client-details → nominee → pan-validate → esign`

Flow statuses: `COMPLETE` (green), `INCOMPLETE` (red)

**Outbound partner calls — always check these `"HTTP Request and Response"` entries:**

| `url` pattern | Partner | What it checks |
|---|---|---|
| `ind-verify.hyperverge.co/api/checkBankAccount` | Hyperverge | Bank account IMPS/penny-drop verification |
| `ind-verify.hyperverge.co/api/...` | Hyperverge | Selfie / liveness / OCR |
| `*.digio.in/...` | Digio | e-Sign / document upload |
| `*.setu.co/...` | Setu | e-Sign / NACH |
| `*.decentro.tech/...` | Decentro | Bank account verification |
| `*.cams.com/...` | CAMS | Mandate / consent |
| `*.cvlkra.com/...` | CVL KRA | KRA data push / status |

When any of these return a non-200 `responseStatus`, read the full `responseBody` — that is the root cause.

---

### `kyc2-fulfilment-prod`

**What it does:** Runs the post-submission fulfilment pipeline using Camunda BPM. Processes Camunda service tasks, handles brokerage, CNS callbacks, and sends events to SQS.

**Extra fields:**
| Field | Description |
|---|---|
| `path` | Camunda topic/task name or Go handler path |
| `process` | Camunda process name: `"kyc-fulfilment"`, `"kyc-tracker-scheduler"` |
| `processId` | Camunda process instance UUID |
| `funcName` | DB function: `QueryRaw`, `ExecRaws`, `Save` |
| `traceId` | UUID for DB trace |
| `entity` | Serialised DB entity |
| `query` / `args` | SQL query and parameters |
| `audit` | Audit event details (Name, Origin, Platform, Data) |
| `data` | Prism event payload (JSON string) |

**Key log messages:**

| Message | Meaning |
|---|---|
| `"service task received for topic X with variables ..."` | Camunda task picked up |
| `"service task processed for topic X with latency Y ms"` | Camunda task completed |
| `"Executing DB query"` | SQL about to be run |
| `"Query Result"` | SQL result returned |
| `"Audit Event"` | Audit trail entry written |
| `"FetchCNSCallbackData: response data"` | CNS (Client Notification Service) callback processed |
| `"HandleFetchCNSCallbackData: request payload"` | CNS callback request received |
| `"SendDataToQueue: Sent Prism metadata event to SQS successfully"` | Prism event queued |

**Common Camunda task names (the `path` field):**

| Task | Description |
|---|---|
| `handleBrokerage` | Assigns brokerage plan from pincode/state lookup |
| `generateBatchForKycTracker` | Generates a batch for the KYC tracker scheduler |
| `pushTradeReadyDateAsync` | Pushes trade-ready date asynchronously |

**Fulfilment variables (in Camunda task logs):**
`appNumber`, `mobile`, `kycType`, `clientType`, `platform`, `device`, `appVersion`, `source`, `processId`, `correlationId`, `esignType`, `isCvlKRA`, `isIMPS`, `isSelfieValid`, `isAadhaarDigilocker`, `shouldSendToDIY`, `shouldSendToScrutiny`, `scrutinyStatus`

---

### `kyc2-services-prod`

**What it does:** Shared services layer — journey status, admin document retrieval, identity middleware, rate limiting, WhatsApp document fetch.

**Extra fields:**
| Field | Description |
|---|---|
| `path` | Full Go handler path (e.g. `github.com/angel-one/kyc-services/api/v1.HandleJourneyStatus`) |
| `user` | Admin user ID (e.g. `"E77268"`) |
| `email` | Hashed email of authenticated user |
| `mobile` | Hashed mobile |
| `token` | `"Bearer ***TOKEN***"` (always masked) |
| `header` | Full HTTP request headers (map) |
| `funcName` | Middleware/DB function name |
| `traceID` | UUID trace for DB calls |
| `Query` / `Args` | SQL and parameters |
| `category` / `subCategory` | `"DB"` / `"DbGetByUniqueKey"` for timer logs |
| `elapsedTime` | Time in ms for timed operations |
| `stack` | Goroutine stack trace (error logs only) |
| `error` | Error message string |
| `startTime` / `endTime` / `latency` | HTTP request timing |
| `method` / `uri` / `statusCode` / `clientIP` | HTTP request details |

**Key log messages:**

| Message | Meaning |
|---|---|
| `"request received by user"` | Authenticated user identified (emits `user` and `email`) |
| `"UnifiedAuthMiddleware: authentication general"` | Unified auth started |
| `"UnifiedAuthMiddleware: authentication via default"` | Falling back to default auth (old trade JWT disabled) |
| `"Identified as Journey Pending"` | Journey status determined as pending |
| `"v1 HandleJourneyStatus - request token"` | Journey status API token logged |
| `"Executing DB query"` | SQL about to run |
| `"Query Result"` | SQL result returned |
| `"Run Error"` | DB query returned an error (non-fatal) |
| `"api-requestThreshold not configured for X"` | Rate limiter: no threshold for this route |
| `"finalPiiRule rule_access_all"` | PII masking determined |
| `"error checking isForceUpdateEligible, allowing journey unblocked"` | Force-update check failed, journey continues |
| `"timerLog"` | Performance timing log (check `elapsedTime`) |

**Known API handlers (the `path` field):**

| Handler | Route |
|---|---|
| `HandleJourneyStatus` | `POST /v1/ui/journey-status` |
| `HandleGetWhatsappDocument` | `GET /v1/infobip/whatsapp/fetch/document` |

---

## Domain Concepts

| Concept | Description |
|---|---|
| **App number** | Primary KYC application identifier. Format: `EQ<8 digits>` (equity) |
| **correlationId** | Same as app number in most log contexts |
| **KYC type** | E.g. `DEM_EQ_DEM_MF` — combination of segments applied for |
| **Journey type** | `onboarding`, `correction`, `rekra`, `nri` |
| **Flow** | A discrete step in the KYC journey (register, panV3, bank, selfie, etc.) |
| **Source** | Who triggered: `spark` (Angel One app), `kyc-admin` (admin panel), `web` |
| **Client type** | `B2C` (retail), `B2B` (partner/sub-broker) |
| **SB tag** | Sub-broker tag (e.g. `SEDIY`, `RCIW`) |
| **Camunda** | BPMN workflow engine driving the fulfilment pipeline |
| **Process** | `kyc-fulfilment` or `kyc-tracker-scheduler` |
| **PII rule** | `rule_access_all` = full PII access, others = masked |

---

## CRITICAL — Two bugs that will silently miss log entries

### Bug 1 — UTC vs IST epoch confusion when hardcoding timestamps

**All log timestamps are UTC (`Z` suffix, e.g. `2026-05-20T07:56:16.591Z`).** Epoch values in `from`/`to` must also be UTC.

**Dangerous (local-time trap):**
```python
# On an IST machine, this gives 2026-05-20 07:55 IST = 02:25 UTC — WRONG
FROM=$(python3 -c "import datetime; t=datetime.datetime(2026,5,20,7,55,0); print(int(t.timestamp()))")
```

**Safe — use `calendar.timegm` to force UTC:**
```python
FROM=$(python3 -c "import datetime, calendar; t=datetime.datetime(2026,5,20,7,55,0); print(calendar.timegm(t.timetuple()))")
```

**Safest — use relative offsets from `date +%s` (always UTC-correct):**
```bash
FROM=$(date -v-30M +%s 2>/dev/null || date -d '30 minutes ago' +%s)
TO=$(date +%s)
```

> **Rule:** Never hardcode a narrow window with `datetime.datetime(y,m,d,h,min)` + `.timestamp()` unless the machine runs UTC. Always use `calendar.timegm` or relative offsets.

---

### Bug 2 — 100-entry result cap silently drops entries on broad queries

The API returns at most 100 log entries per request. When a broad query (e.g. full-day range with a client code keyword) hits the cap, **entries are silently dropped**. A Hyperverge HTTP call or a critical error log can be among the dropped entries even though it exists.

**Symptoms:**
- Single-keyword search returns exactly 100 entries but AND search returns 0.
- You see the final error event (e.g. `ERR-GETTING-IMPS-INFO`) but not the upstream HTTP call that caused it.

**Fix — narrow the time window to the specific failure period (using correct UTC epoch):**
```bash
# Find the failure timestamp from an entry you already have, e.g. "2026-05-20T07:59:12.986Z"
# Then build a tight ±60-second UTC window around it:
FROM=$(python3 -c "import datetime, calendar; t=datetime.datetime(2026,5,20,7,58,0); print(calendar.timegm(t.timetuple()))")
TO=$(python3 -c "import datetime, calendar; t=datetime.datetime(2026,5,20,8,0,30); print(calendar.timegm(t.timetuple()))")
```
A narrow window typically returns < 30 entries for a single client, well under the cap.

**Decision rule when you cannot find an expected log entry:**
```
1. Check: did the broad search return exactly 100 entries?
   → YES: the entry is likely cut off. Options:
      a. Narrow the window to ±60–120s around the known failure timestamp
         (using UTC calendar.timegm epochs).
      b. Use the `id` field technique below to expand around a known entry.
2. Check: are you using a hardcoded narrow window with datetime.timestamp()?
   → YES: recalculate with calendar.timegm — you are probably searching the
         wrong 6-hour window due to IST offset.
3. Try the single-term search first, THEN AND with secondary terms once
   you confirm the single-term search finds < 100 entries in the window.
```

### Technique — expand results using the `id` field

Every log entry has an `id` field (UUID, e.g. `"b4854d8c-5290-11f1-a757-0a58a9feac02"`). This UUID is the **request correlation ID** — all log lines emitted during the same HTTP request share the same `id`. When a broad search is capped at 100 entries and you can see a log entry near the failure but suspect more lines exist for that same request:

1. Extract the `id` from a log entry you already have.
2. Search for that exact `id` in a tight time window — this retrieves only the lines for that one request, well under the 100-entry cap.

```bash
source ~/.config/zsh/.zshrc

# Step 1: note the id from an existing entry, e.g.:
REQUEST_ID="b4854d8c-5290-11f1-a757-0a58a9feac02"

# Step 2: build a ±2 minute UTC window around the entry's timestamp
FROM=$(python3 -c "import datetime, calendar; t=datetime.datetime(2026,5,20,7,57,0); print(calendar.timegm(t.timetuple()))")
TO=$(python3 -c "import datetime, calendar; t=datetime.datetime(2026,5,20,7,59,30); print(calendar.timegm(t.timetuple()))")
KEYWORD=$(echo -n "'$REQUEST_ID'" | base64)

# Step 3: query — returns ALL lines for that single request
curl -s -X POST \
  -H "Authorization: Bearer $LOGS_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"topic\": \"aws-prod-ecs-kyc\", \"application_name\": \"kyc2-kyc-user-journey-prod\", \"from\": \"$FROM\", \"to\": \"$TO\", \"mode\": \"NORMAL\", \"search_keyword\": \"$KEYWORD\"}" \
  "https://$LOGS_API_BASE_URL/api/v1/rawlogs" | python3 -m json.tool
```

This is the most reliable way to get every log line for a specific request without hitting the cap.

---

## Common Query Patterns

### Query time helper

```bash
FROM=$(date -v-1H +%s 2>/dev/null || date -d '1 hour ago' +%s)
TO=$(date +%s)
```

### Look up all logs for a specific app number

```bash
source ~/.config/zsh/.zshrc
FROM=$(date -v-4H +%s 2>/dev/null || date -d '4 hours ago' +%s)
TO=$(date +%s)
KEYWORD=$(echo -n "'EQ40470833'" | base64)

curl -s -X POST \
  -H "Authorization: Bearer $LOGS_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"topic\": \"aws-prod-ecs-kyc\", \"application_name\": \"kyc2-kyc-user-journey-prod\", \"from\": \"$FROM\", \"to\": \"$TO\", \"mode\": \"NORMAL\", \"search_keyword\": \"$KEYWORD\"}" \
  "https://$LOGS_API_BASE_URL/api/v1/rawlogs" | python3 -m json.tool
```

### Find errors in the last 30 minutes across an app

```bash
source ~/.config/zsh/.zshrc
FROM=$(date -v-30M +%s 2>/dev/null || date -d '30 minutes ago' +%s)
TO=$(date +%s)
KEYWORD=$(echo -n "'error'" | base64)

curl -s -X POST \
  -H "Authorization: Bearer $LOGS_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"topic\": \"aws-prod-ecs-kyc\", \"application_name\": \"kyc2-services-prod\", \"from\": \"$FROM\", \"to\": \"$TO\", \"mode\": \"NORMAL\", \"search_keyword\": \"$KEYWORD\"}" \
  "https://$LOGS_API_BASE_URL/api/v1/rawlogs" | python3 -m json.tool
```

### Search by hashed mobile across user-journey

```bash
source ~/.config/zsh/.zshrc
FROM=$(date -v-2H +%s 2>/dev/null || date -d '2 hours ago' +%s)
TO=$(date +%s)
MOBILE_HASH="7fd3eb7ffb2e34b3722d14307566bc7a48dbcfe6777b72a8290c1b94344c87d2"
KEYWORD=$(echo -n "'$MOBILE_HASH'" | base64)

curl -s -X POST \
  -H "Authorization: Bearer $LOGS_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"topic\": \"aws-prod-ecs-kyc\", \"application_name\": \"kyc2-kyc-user-journey-prod\", \"from\": \"$FROM\", \"to\": \"$TO\", \"mode\": \"NORMAL\", \"search_keyword\": \"$KEYWORD\"}" \
  "https://$LOGS_API_BASE_URL/api/v1/rawlogs" | python3 -m json.tool
```

### Check Camunda fulfilment task failures

```bash
source ~/.config/zsh/.zshrc
FROM=$(date -v-1H +%s 2>/dev/null || date -d '1 hour ago' +%s)
TO=$(date +%s)
KEYWORD=$(echo -n "'error' AND 'kyc-fulfilment'" | base64)

curl -s -X POST \
  -H "Authorization: Bearer $LOGS_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"topic\": \"aws-prod-ecs-kyc\", \"application_name\": \"kyc2-fulfilment-prod\", \"from\": \"$FROM\", \"to\": \"$TO\", \"mode\": \"NORMAL\", \"search_keyword\": \"$KEYWORD\"}" \
  "https://$LOGS_API_BASE_URL/api/v1/rawlogs" | python3 -m json.tool
```

### Get log volume trend for an app (spot spikes)

```bash
source ~/.config/zsh/.zshrc
FROM=$(date -v-3H +%s 2>/dev/null || date -d '3 hours ago' +%s)
TO=$(date +%s)

curl -s -X POST \
  -H "Authorization: Bearer $LOGS_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"topic\": \"aws-prod-ecs-kyc\", \"application_name\": \"kyc2-kyc-user-journey-prod\", \"from\": \"$FROM\", \"to\": \"$TO\"}" \
  "https://$LOGS_API_BASE_URL/api/v1/hitstrend" | python3 -m json.tool
```

### Top error types in services-prod

```bash
source ~/.config/zsh/.zshrc
FROM=$(date -v-1H +%s 2>/dev/null || date -d '1 hour ago' +%s)
TO=$(date +%s)

curl -s -X POST \
  -H "Authorization: Bearer $LOGS_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"topic\": \"aws-prod-ecs-kyc\", \"application_name\": \"kyc2-services-prod\", \"from\": \"$FROM\", \"to\": \"$TO\", \"field\": \"message\"}" \
  "https://$LOGS_API_BASE_URL/api/v1/topvalues" | python3 -m json.tool
```

### Search using EXPERT mode (raw SQL WHERE clause)

Use when NORMAL mode isn't enough — e.g. latency thresholds, regex patterns.

```bash
source ~/.config/zsh/.zshrc
FROM=$(date -v-1H +%s 2>/dev/null || date -d '1 hour ago' +%s)
TO=$(date +%s)
# Find requests with latency > 5000ms in fulfilment
KEYWORD=$(echo -n "JSONExtractFloat(message, 'latency') > 5000" | base64)

curl -s -X POST \
  -H "Authorization: Bearer $LOGS_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"topic\": \"aws-prod-ecs-kyc\", \"application_name\": \"kyc2-fulfilment-prod\", \"from\": \"$FROM\", \"to\": \"$TO\", \"mode\": \"EXPERT\", \"search_keyword\": \"$KEYWORD\"}" \
  "https://$LOGS_API_BASE_URL/api/v1/rawlogs" | python3 -m json.tool
```

---

## Parsing logs in Python

### MANDATORY — Always dump ALL fields of every entry

**Never cherry-pick a fixed set of fields.** Different log schemas carry their root cause in different places (`responseBody`, `responseStatus`, `url`, `statusCode`, `requestBody`, `error`, `statusDTO`, etc.). Printing only `message` + `correlationId` will silently drop the most important lines.

**Standard full-dump parser — use this for all troubleshooting:**

```python
import sys, json

data = json.load(sys.stdin)
entries = data.get('data', {}).get('response', [])
print(f'Total entries: {len(entries)}')

for e in entries:
    try:
        msg = json.loads(e.get('message', '{}'))
    except Exception:
        print(f"[{e.get('time','')}] RAW: {e.get('message','')[:300]}")
        continue

    level = msg.get('level', '')
    log_msg = msg.get('message', '')
    ts = e.get('time', '')

    # Print header line
    print(f"\n[{ts}] [{level}] {log_msg}")

    # Print EVERY non-empty field except noisy/redundant ones
    skip = {'level', 'message', 'time', 'log_type', 'caller',
            'id', 'correlationId', 'OriginalCaller'}
    for k, v in msg.items():
        if k in skip or not v:
            continue
        val = str(v)
        # Truncate very long values but show enough to find the error
        print(f"  {k}: {val[:600]}{'...' if len(val) > 600 else ''}")

    # Always show identity fields
    for k in ('correlationId', 'client_code', 'app_number', 'OriginalCaller'):
        if msg.get(k):
            print(f"  {k}: {msg[k]}")
```

### When to use a lighter summary parser

Only after confirming there are no `"HTTP Request and Response"` or inbound HTTP entries in the result set. Use the summary parser for high-volume scans only, then switch to the full-dump parser on the relevant entries.

```python
# Light summary — for initial scan only, NOT for root cause analysis
for entry in response["data"]["response"]:
    msg = json.loads(entry["message"])
    # Flag entries that need full inspection
    needs_drill = msg.get('message') in ('HTTP Request and Response',) \
                  or msg.get('statusCode', 0) >= 400 \
                  or msg.get('responseStatus', 0) >= 400 \
                  or msg.get('level') == 'error'
    marker = ' <<<' if needs_drill else ''
    print(f"[{entry['time']}] [{msg.get('level','')}] {msg.get('message','')} | "
          f"corr={msg.get('correlationId','')} | caller={msg.get('OriginalCaller','')}{marker}")
```

Always follow up `<<<` flagged lines with the full-dump parser.

---

## Tips

- **Always use the full-dump parser during troubleshooting** — never print only `message` + `correlationId`. The root cause is frequently in `responseBody`, `responseStatus`, `url`, `statusCode`, or `requestBody`, none of which appear in `message`.
- **`"HTTP Request and Response"` entries are the most important lines for partner/vendor failures** — these are emitted for every outbound call (Hyperverge, Digio, Setu, Decentro, CLCM, CAMS, KRA, CDSL, and any other external system). Always check `url`, `responseStatus`, and `responseBody` on these entries.
- **A non-200 `responseStatus` on an outbound call is almost always the real root cause** — the application-level error (e.g. `ERR-GETTING-IMPS-INFO`) is a consequence; the upstream vendor's response is the cause.
- **`correlationId` can be either app number or client code** — on onboarding flows it is the app number (`EQ…`); on EMOD flows it varies by log type: business-logic logs may carry the app number, but outbound `"HTTP Request and Response"` entries (Hyperverge, CLCM, Digio, etc.) often carry the **client code** as `correlationId`. When a vendor call log is missing, try searching by client code instead of app number.
- **On EMOD flows, always search by `client_code`** — `client_code` and `app_number` are both present as separate structured fields. Use `client_code` (e.g. `'AABJ471979'`) as the primary search keyword for EMOD troubleshooting.
- **Use the `id` field to expand past the 100-entry cap** — every line from the same HTTP request shares the same `id` UUID. When a broad search is capped, extract the `id` from a nearby log entry and re-query with just that `id` in a tight UTC window to retrieve all lines for that request. See §CRITICAL.
- **Watch for the 100-entry cap** — if a broad search returns exactly 100 entries, critical log lines (e.g. the Hyperverge HTTP call that caused ERR-GETTING-IMPS-INFO) may have been cut off. Narrow to a ±60s UTC window around the known failure timestamp. See §CRITICAL above.
- **Always use UTC-safe epoch arithmetic** — log timestamps are UTC. Hardcoded narrow windows with `datetime.datetime(...).timestamp()` on an IST machine shift the window by 5h30m. Use `calendar.timegm` or relative `date -v-Xm +%s` offsets. See §CRITICAL above.
- **User-journey is the entry point** — start there when debugging a user's KYC journey.
- **Fulfilment logs are Camunda-heavy** — look for `"service task received"` and `"service task processed"` pairs to trace task execution.
- **Services-prod surfaces latency** — the `latency` field in HTTP log lines (in ms) is reliable for SLA checks.
- **PII is always hashed** — you can search by the hash to correlate across services, but you cannot recover the original value.
- **`OriginalCaller` pinpoints the code** — use it to find exact Go source location when debugging errors.
- **`path` in fulfilment = Camunda task name** — filter by `path` field to isolate a specific workflow step.
