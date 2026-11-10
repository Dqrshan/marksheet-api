# marksheet API docs

Base address: `https://dev.vtu.drshn.tech/api`

Every endpoint returns JSON. The metadata answers are CORS enabled and cached
for a day. The course answers carry `Cache-Control: private, no-store`, so a
shared cache cannot hand a course list to somebody who was not allowed to read
it.

The data is the same scheme table the calculator uses. A semester response
carries the course codes, titles, credits and course types, which is enough to
compute an SGPA without asking the site for anything else.

```bash
curl https://dev.vtu.drshn.tech/api/schemes/2022/branches/cs \
  -H "X-API-Key: your-key"
```

## Access

| Route | What it needs |
| --- | --- |
| `/api`, `/api/schemes`, `/api/schemes/{scheme}` | Nothing |
| `/api/schemes/{scheme}/branches`, `/api/schemes/{scheme}/branches/{branch}` | Nothing |
| `/api/schemes/{scheme}/branches/{branch}/semesters/{semester}` | A key or a calculator session |
| `/api/schemes/{scheme}/export` | A key, five times a day |
| `/api/session` | A page token from the calculator page |

A key is sent in the `X-API-Key` header. A calculator session is sent in the
`X-Marksheet-Session` header, and the answer comes back encrypted for that
session.

## Endpoints

### GET /api

The list of schemes with their regulation code, semester range and totals.

```json
{
  "schemes": [
    {
      "scheme": "2022",
      "name": "VTU 2022 Scheme",
      "regulation": "22OB",
      "stats": { "branches": 43, "courses": 1604, "credits": 4784 },
      "semesters": ["3", "4", "5", "6", "7", "8"]
    }
  ]
}
```

### GET /api/schemes

The scheme index with the grade scale and the percentage rule attached to
every scheme.

```json
{
  "schemes": [
    {
      "scheme": "2022",
      "name": "VTU 2022 Scheme",
      "regulation": "22OB",
      "gradeScale": [
        { "grade": "O", "points": 10, "min": 90, "max": 100, "label": "Outstanding" },
        { "grade": "A+", "points": 9, "min": 80, "max": 89, "label": "Excellent" }
      ],
      "percentage": {
        "formula": "Percentage = CGPA x 10",
        "note": "Regulation 22OB clause 6.7 and regulation 25OB clause 26.0."
      }
    }
  ]
}
```

### GET /api/schemes/{scheme}

The rules, the totals and the semester list of one scheme. The courses are
not in this answer. They are read one branch and one semester at a time, so
that no single call can hand over the whole dataset.

Parameters:

| Name | Description |
| --- | --- |
| scheme | The scheme id. Either `2022` or `2025`. |

```json
{
  "scheme": "2022",
  "name": "VTU 2022 Scheme",
  "regulation": "22OB",
  "source": "Official VTU scheme PDFs",
  "notes": "...",
  "gradeScale": [],
  "percentage": {},
  "semesters": ["3", "4", "5", "6", "7", "8"],
  "stats": { "branches": 43, "courses": 1604, "credits": 4784 },
  "branchCount": 43,
  "branches": "/api/schemes/2022/branches"
}
```

### GET /api/schemes/{scheme}/branches

The branch list of a scheme with the course and credit totals of each branch.
The list is paginated.

Parameters:

| Name | Description |
| --- | --- |
| scheme | The scheme id. Either `2022` or `2025`. |
| limit | How many branches to return. 50 by default, 200 at most. |
| offset | Where to start in the list. 0 by default. |

```json
{
  "scheme": "2022",
  "name": "VTU 2022 Scheme",
  "regulation": "22OB",
  "count": 43,
  "limit": 50,
  "offset": 0,
  "branches": [
    {
      "key": "cs",
      "name": "Computer Science",
      "semesters": ["3", "4", "5", "6", "7", "8"],
      "stats": { "semesters": 6, "courses": 40, "credits": 120 }
    }
  ],
  "next": null
}
```

`next` is the address of the next page, or null when the list has ended.

### GET /api/schemes/{scheme}/branches/{branch}

A branch with the course count and the credit total of each of its semesters.

Parameters:

| Name | Description |
| --- | --- |
| scheme | The scheme id. Either `2022` or `2025`. |
| branch | The branch key, exactly as it appears in the branch list. |

```json
{
  "scheme": "2022",
  "key": "cs",
  "name": "Computer Science",
  "stats": { "semesters": 6, "courses": 40, "credits": 120 },
  "semesters": {
    "3": { "courses": 8, "credits": 21 },
    "4": { "courses": 9, "credits": 19 }
  }
}
```

### GET /api/schemes/{scheme}/branches/{branch}/semesters/{semester}

The courses of one semester with the credits and the course type. Only
courses with credits above zero count towards the SGPA.

This route needs a developer key or a calculator session.

Parameters:

| Name | Description |
| --- | --- |
| scheme | The scheme id. Either `2022` or `2025`. |
| branch | The branch key, exactly as it appears in the branch list. |
| semester | The semester number, exactly as it appears in the branch response. |

```json
{
  "scheme": "2022",
  "branch": "cs",
  "semester": "3",
  "count": 8,
  "credits": 21,
  "courses": [
    {
      "code": "BCS301",
      "title": "Mathematics for Computer Science",
      "credits": 4,
      "type": "PCC/BS C"
    }
  ]
}
```

### GET /api/schemes/{scheme}/export

Every branch, every semester and every course of a scheme in one answer. A key
may take it five times a day.

This route exists so that a developer who needs the whole dataset takes it in
one request with a budget, instead of walking every branch and every semester
and looking like a scraper.

```json
{
  "scheme": "2022",
  "regulation": "22OB",
  "branches": {
    "cs": {
      "key": "cs",
      "name": "Computer Science",
      "semesters": { "3": [] }
    }
  },
  "export": {
    "name": "your-key",
    "takenAt": "2026-01-01T00:00:00.000Z",
    "remainingToday": 4
  }
}
```

### POST /api/session

Exchanges the token from the calculator page for a session id and a key. Every
later answer for that session is encrypted with AES-GCM.

The token arrives in the `X-Marksheet-Page-Token` header. It is issued by the
calculator page, it is short lived, and it is what separates the calculator
from a script.

```json
{
  "sessionId": "9f2c...",
  "key": "base64 of 32 bytes",
  "expiresAt": 1767225600000,
  "limits": { "requests": 150, "bytes": 98304 }
}
```

An answer for a session looks like this:

```json
{
  "v": 1,
  "alg": "A256GCM",
  "iv": "base64 of 12 bytes",
  "ct": "base64 of the ciphertext with the tag"
}
```

The path of the request is used as additional data, so an answer cannot be
moved to another endpoint.

## Limits

| Caller | Calls |
| --- | --- |
| An address, no key | 120 a minute, 10000 a day |
| A calculator session | 150 calls and 96 KB of data, for 30 minutes |
| A developer key | 600 a minute, 100000 a day, and five bulk exports a day |

Every answer carries these headers:

| Header | Meaning |
| --- | --- |
| `X-RateLimit-Limit` | How many calls are allowed in the window |
| `X-RateLimit-Remaining` | How many calls are left |
| `X-RateLimit-Reset` | When the window ends, as a unix time in seconds |
| `Retry-After` | How long to wait, only sent with a 429 |

## Errors

Every error has the same shape.

```json
{
  "error": {
    "code": "unknown_branch",
    "message": "That branch does not exist in this scheme."
  }
}
```

| Status | When |
| --- | --- |
| 401 | A key or a session is needed for this route |
| 403 | The page token or the origin was not accepted |
| 404 | The scheme, branch or semester does not exist |
| 413 | The answer would be larger than the service will send in one piece |
| 429 | The limit was reached |
| 500 | Something went wrong while building the answer |

The message names the missing value and nothing else. No file path, no stack,
no server detail.

## Rules

**Grade scale.** O 90 to 100 is 10 points, A+ 80 to 89 is 9, A 70 to 79 is 8,
B+ 60 to 69 is 7, B 55 to 59 is 6, C 50 to 54 is 5, P 40 to 49 is 4 and F below
40 is 0. The scale is the same in both schemes.

**SGPA.** The sum of course credits times grade points, divided by the sum of
the course credits of the semester. Courses with no credits are left out of
the average.

**CGPA.** The sum of semester credits times semester SGPA, divided by the sum
of the semester credits. Each semester SGPA is rounded to two decimals first,
the way the marks card prints it.

**Percentage.** CGPA times ten. Regulation 22OB clause 6.7 and regulation
25OB clause 26.0 define it that way.

**CORS.** A browser may read the metadata answers from any origin that is on
the allow list. CORS is not a security boundary and is not treated as one.
The key and the limits are the controls.
