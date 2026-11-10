# marksheet API reference

Base URL: `https://vtu.drshn.tech`

Every endpoint returns JSON. Every endpoint is CORS enabled, so it can be
called from a browser on any origin. Every response carries
`Cache-Control: public, max-age=86400, s-maxage=86400`.

There is no authentication. There is no key to request.

```bash
curl https://vtu.drshn.tech/api/schemes/2022/branches/cs/semesters/3
```

## Contents

- [GET /api](#get-api)
- [GET /api/schemes](#get-apischemes)
- [GET /api/schemes/{scheme}](#get-apischemesscheme)
- [GET /api/schemes/{scheme}/branches](#get-apischemesschemebranches)
- [GET /api/schemes/{scheme}/branches/{branch}](#get-apischemesschemebranchesbranch)
- [GET /api/schemes/{scheme}/branches/{branch}/semesters/{semester}](#get-apischemesschemebranchesbranchsemesterssemester)
- [Rules](#rules)
- [Errors](#errors)

## GET /api

The index of every scheme, with its regulation code, the semesters it covers
and the size of the dataset.

```bash
curl https://vtu.drshn.tech/api
```

```json
{
  "schemes": [
    {
      "scheme": "2022",
      "name": "VTU 2022 Scheme",
      "regulation": "22OB",
      "stats": { "branches": 43, "courses": 1604, "credits": 4784 },
      "semesters": ["3", "4", "5", "6", "7", "8"]
    },
    {
      "scheme": "2025",
      "name": "VTU 2025 Scheme",
      "regulation": "25OB",
      "stats": { "branches": 44, "courses": 1202, "credits": 3407 },
      "semesters": ["3", "4", "5", "6", "7", "8"]
    }
  ]
}
```

## GET /api/schemes

The same index, with the grade scale and the percentage rule attached to every
scheme. Use this if you want a client to read the rules from the API instead
of hardcoding them.

```bash
curl https://vtu.drshn.tech/api/schemes
```

```json
{
  "schemes": [
    {
      "scheme": "2022",
      "name": "VTU 2022 Scheme",
      "regulation": "22OB",
      "stats": { "branches": 43, "courses": 1604, "credits": 4784 },
      "semesters": ["3", "4", "5", "6", "7", "8"],
      "gradeScale": [
        { "grade": "O", "points": 10, "min": 90, "max": 100, "label": "Outstanding" },
        { "grade": "A+", "points": 9, "min": 80, "max": 89, "label": "Excellent" },
        { "grade": "A", "points": 8, "min": 70, "max": 79, "label": "Very good" },
        { "grade": "B+", "points": 7, "min": 60, "max": 69, "label": "Good" },
        { "grade": "B", "points": 6, "min": 55, "max": 59, "label": "Above average" },
        { "grade": "C", "points": 5, "min": 50, "max": 54, "label": "Average" },
        { "grade": "P", "points": 4, "min": 40, "max": 49, "label": "Pass" },
        { "grade": "F", "points": 0, "min": 0, "max": 39, "label": "Fail" }
      ],
      "percentage": {
        "formula": "Percentage = CGPA × 10",
        "note": "VTU 22OB 6.7 and 25OB 26.0 define the percentage as CGPA multiplied by 10.",
        "cgpa": "CGPA = Σ(semester credits × semester SGPA) / Σ(semester credits), using the SGPA values shown to two decimal places.",
        "sgpa": "SGPA = Σ(course credits × grade points) / Σ(course credits)."
      },
      "source": "https://vtu.ac.in/b-e-scheme-syllabus/ (2022 scheme PDFs) and VTU B.E./B.Tech. Regulations, 2022",
      "notes": "CBCS scheme effective from 2022-23. Semesters 3 to 8. Mandatory non-credit courses are listed in the source PDFs but excluded here."
    }
  ]
}
```

## GET /api/schemes/{scheme}

Every branch, every semester and every course of one scheme. This is the
largest response and is meant for bulk use. If you only need part of a scheme,
use the branch and semester endpoints instead.

Parameters:

- `scheme` The scheme id. Either `2022` or `2025`.

```bash
curl https://vtu.drshn.tech/api/schemes/2022
```

```json
{
  "scheme": "2022",
  "name": "VTU 2022 Scheme",
  "regulation": "22OB",
  "semesters": ["3", "4", "5", "6", "7", "8"],
  "branches": {
    "cs": {
      "key": "cs",
      "name": "Computer Science",
      "semesters": {
        "3": [
          {
            "code": "BCS301",
            "title": "Mathematics for Computer Science",
            "credits": 4,
            "type": "PCC/BS C"
          }
        ]
      },
      "stats": { "semesters": 6, "courses": 40, "credits": 120 }
    }
  }
}
```

## GET /api/schemes/{scheme}/branches

The branch list of a scheme, sorted by name, with the semesters each branch
has and the course and credit totals of the branch.

Parameters:

- `scheme` The scheme id. Either `2022` or `2025`.

```bash
curl https://vtu.drshn.tech/api/schemes/2022/branches
```

```json
{
  "scheme": "2022",
  "name": "VTU 2022 Scheme",
  "regulation": "22OB",
  "count": 43,
  "branches": [
    {
      "key": "cs",
      "name": "Computer Science",
      "semesters": ["3", "4", "5", "6", "7", "8"],
      "stats": { "semesters": 6, "courses": 40, "credits": 120 }
    }
  ]
}
```

## GET /api/schemes/{scheme}/branches/{branch}

One branch, with the course count and the credit total of each of its
semesters. This is the call to make when you want to show a student how many
credits a semester is worth before they start.

Parameters:

- `scheme` The scheme id. Either `2022` or `2025`.
- `branch` The branch key, exactly as it appears in the branch list.

```bash
curl https://vtu.drshn.tech/api/schemes/2022/branches/cs
```

```json
{
  "scheme": "2022",
  "key": "cs",
  "name": "Computer Science",
  "stats": { "semesters": 6, "courses": 40, "credits": 120 },
  "semesters": {
    "3": { "courses": 8, "credits": 21 },
    "4": { "courses": 8, "credits": 19 },
    "5": { "courses": 8, "credits": 22 },
    "6": { "courses": 7, "credits": 18 },
    "7": { "courses": 6, "credits": 24 },
    "8": { "courses": 3, "credits": 16 }
  }
}
```

## GET /api/schemes/{scheme}/branches/{branch}/semesters/{semester}

The courses of one semester, with the credits and the course type. This is
the call to make when you want the subject list of a semester.

Parameters:

- `scheme` The scheme id. Either `2022` or `2025`.
- `branch` The branch key, exactly as it appears in the branch list.
- `semester` The semester number, exactly as it appears in the branch response.

```bash
curl https://vtu.drshn.tech/api/schemes/2022/branches/cs/semesters/3
```

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
    },
    {
      "code": "BCS302",
      "title": "Digital Design & Computer Organization",
      "credits": 4,
      "type": "IPCC"
    },
    {
      "code": "BCS303",
      "title": "Operating Systems",
      "credits": 4,
      "type": "IPCC"
    },
    {
      "code": "BCS304",
      "title": "Data Structures and Applications",
      "credits": 3,
      "type": "PCC"
    },
    {
      "code": "BCS306X",
      "title": "ESC/ETC/PLC",
      "credits": 3,
      "type": "ESC"
    },
    {
      "code": "BCS358X",
      "title": "Ability Enhancement Course/Skill Enhancement Course - III",
      "credits": 1,
      "type": "AEC/ SEC"
    },
    {
      "code": "BCSL305",
      "title": "Data Structures Lab",
      "credits": 1,
      "type": "PCCL"
    },
    {
      "code": "BSCK307",
      "title": "Social Connect and Responsibility",
      "credits": 1,
      "type": "UHV"
    }
  ]
}
```

## Rules

**Grade scale.** O 90 to 100 is 10 points, A+ 80 to 89 is 9, A 70 to 79 is 8,
B+ 60 to 69 is 7, B 55 to 59 is 6, C 50 to 54 is 5, P 40 to 49 is 4 and F below
40 is 0. The scale is the same in both schemes.

**SGPA.** SGPA is the sum of course credits times grade points, divided by the
sum of the course credits of the semester. Courses with no credits are left
out of the average.

**CGPA.** CGPA is the sum of semester credits times semester SGPA, divided by
the sum of the semester credits. Each semester SGPA is rounded to two decimals
first, the way the marks card prints it.

**Percentage.** Percentage is CGPA times ten. Regulation 22OB clause 6.7 and
regulation 25OB clause 26.0 define it that way.

**Course types.** The `type` field carries the category printed in the scheme,
such as `PCC`, `IPCC`, `PCCL`, `ESC`, `AEC/ SEC` or `UHV`. It is a label, not
a key. Do not branch on it without checking what a given scheme actually uses.

**Placeholder electives.** Elective slots that the scheme prints with a
placeholder code, such as `BCS306X`, carry the credits the elective will be
worth once the student picks one. The credits are fixed, so they belong in the
SGPA denominator.

## Errors

An unknown scheme, branch or semester returns a `404` with a JSON body that
names the missing value.

```json
{
  "error": "Unknown scheme \"2030\""
}
```

A `503` means the scheme dataset is not loaded on the server at that moment.
A `200` always carries the requested data.

## Response headers

| Header | Value |
| --- | --- |
| `Access-Control-Allow-Origin` | `*` |
| `Access-Control-Allow-Methods` | `GET, HEAD, OPTIONS` |
| `Access-Control-Allow-Headers` | `Content-Type` |
| `Cache-Control` | `public, max-age=86400, s-maxage=86400` |
| `Content-Type` | `application/json; charset=utf-8` |

## Machine readable

[`openapi.json`](openapi.json) describes every endpoint in OpenAPI 3.1, with
the request parameters and the response schemas. Use it to generate a client
or to power developer tooling.
