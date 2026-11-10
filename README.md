# marksheet API

VTU scheme tables as JSON, for the 2022 and 2025 regulations.

[Calculator](https://vtu.drshn.tech/calculator) | [Endpoint reference](DOCS.md) | [OpenAPI spec](openapi.json) | [Terms of use](TERMS.md)

---

## Why

Visvesvaraya Technological University publishes its scheme as PDFs. A branch,
a semester and a subject list live across dozens of pages, and the credits sit
in a table you have to read by eye.

If you are building a marks tracker, a results portal, a student club tool, a
Telegram bot or a spreadsheet, you do not want to write a PDF parser. You want
JSON.

This API gives you the same tables the [marksheet calculator](https://vtu.drshn.tech/calculator)
uses, extracted from the official scheme PDFs and checked against the credit
totals those PDFs print.

## The calculator too

The web app at [vtu.drshn.tech/calculator](https://vtu.drshn.tech/calculator)
runs on the same API, and it has three calculators:

| Calculator | What you give it | What you get |
| --- | --- | --- |
| SGPA | The marks of one semester | The credit weighted SGPA |
| CGPA | The SGPA of each semester you finished | The running CGPA up to every one of them |
| Percentage | A CGPA or an SGPA | The percentage, as regulation 22OB 6.7 and 25OB 26.0 define it |

Every result can be exported as JSON or as a one page PDF. The calculator is
free to use and needs no account.

## Quick start

No key, no signup, no token.

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
    }
  ]
}
```

That is enough to compute an SGPA. The course list already carries the credits.

## What you get

| Scheme | Regulation | Branches | Courses | Credits | Semesters |
| --- | --- | --- | --- | --- | --- |
| 2022 | 22OB | 43 | 1604 | 4784 | 3 to 8 |
| 2025 | 25OB | 44 | 1202 | 3407 | 3 to 8 |

Every branch is listed with its semesters. Every semester is listed with its
courses. Every course carries a code, a title, a credit count and the course
category printed in the scheme.

## Endpoints at a glance

| Method | Path | Returns |
| --- | --- | --- |
| GET | `/api` | The schemes and their totals |
| GET | `/api/schemes` | The same, with the grade scale and the percentage rule |
| GET | `/api/schemes/{scheme}` | One scheme, complete |
| GET | `/api/schemes/{scheme}/branches` | The branch list of a scheme |
| GET | `/api/schemes/{scheme}/branches/{branch}` | One branch, with its semester totals |
| GET | `/api/schemes/{scheme}/branches/{branch}/semesters/{semester}` | The courses of one semester |

`{scheme}` is `2022` or `2025`. `{branch}` is the key from the branch list.
`{semester}` is the number from the branch response.

Full request and response shapes are in [DOCS.md](DOCS.md).

## The rules

The grade scale is the same in both schemes.

| Grade | Marks | Points |
| --- | --- | --- |
| O | 90 to 100 | 10 |
| A+ | 80 to 89 | 9 |
| A | 70 to 79 | 8 |
| B+ | 60 to 69 | 7 |
| B | 55 to 59 | 6 |
| C | 50 to 54 | 5 |
| P | 40 to 49 | 4 |
| F | below 40 | 0 |

**SGPA** is the sum of course credits times grade points, divided by the sum of
the course credits of the semester. Courses with zero credits are left out.

**CGPA** is the sum of semester credits times semester SGPA, divided by the
sum of the semester credits. Each semester SGPA is rounded to two decimals
first, the way the marks card prints it.

**Percentage** is CGPA times ten. Regulation 22OB clause 6.7 and regulation
25OB clause 26.0 define it that way.

The grade scale and all three formulas are also served as JSON from
[`/api/schemes`](DOCS.md#get-apischemes), so a client can read the rules from
the API instead of hardcoding them.

## Use it in your stack

Every response carries `Access-Control-Allow-Origin: *`, so a browser can call
it directly. Every response carries a one day `Cache-Control`, so you can put
it behind your own cache or a CDN.

### JavaScript

```js
const res = await fetch(
  "https://vtu.drshn.tech/api/schemes/2022/branches/cs/semesters/3",
);
const { courses } = await res.json();
```

### Python

```python
import requests

data = requests.get(
    "https://vtu.drshn.tech/api/schemes/2022/branches/cs/semesters/3"
).json()

for course in data["courses"]:
    print(course["code"], course["credits"], course["title"])
```

### Generate a client

[`openapi.json`](openapi.json) is an OpenAPI 3.1 description of every
endpoint. Point your favourite generator at it.

```bash
npx @openapitools/openapi-generator-cli generate \
  -i openapi.json \
  -g typescript-fetch \
  -o ./client
```

## Compute an SGPA in ten lines

```js
const GRADE_POINTS = [
  [90, 10], [80, 9], [70, 8], [60, 7],
  [55, 6], [50, 5], [40, 4], [0, 0],
];

const pointsFor = (marks) =>
  GRADE_POINTS.find(([min]) => marks >= min)[1];

const sgpa = (courses, marks) => {
  let weighted = 0;
  let credits = 0;

  for (const course of courses) {
    const mark = marks[course.code];
    if (mark === undefined || course.credits <= 0) continue;
    weighted += course.credits * pointsFor(mark);
    credits += course.credits;
  }

  return credits === 0 ? 0 : weighted / credits;
};
```

Run it against the live API and check that your number agrees with the
calculator at [vtu.drshn.tech](https://vtu.drshn.tech/calculator). If it does
not, the calculator is wrong and we want to know.

## Fair use

The API is free to use for any purpose, commercial or not. Attribution is
appreciated but never required.

A few requests to keep the service healthy:

- Cache responses. They are stable and already carry a one day cache header.
- Do not mirror the dataset as a bulk download. Fetch what your app needs
  through the API, the way it is meant to be used.
- Be reasonable with request volume. If you need the whole scheme in one
  request, use `/api/schemes/{scheme}` rather than looping over every branch
  and semester.

More detail is in [TERMS.md](TERMS.md).

## Accuracy

The credit totals in this API are checked against the totals printed in the
official VTU scheme PDFs, semester by semester, for every branch. A course
with a wrong credit count would change every SGPA computed from it, so the
check is not optional.

Course titles come from the same PDFs. Where the PDF itself contains a typo,
the typo is kept, because the API should agree with the document a student
is reading.

## Status

| | |
| --- | --- |
| 2022 scheme | Semesters 3 to 8, 43 branches |
| 2025 scheme | Semesters 3 to 8, 44 branches |
| Cache lifetime | 1 day |
| Authentication | None |
| Rate limit | None published, please be reasonable |

The 2025 regulation publishes semesters 3 to 8 only. Not every branch has
every semester, and the 2025 Computer Science semester 8 is an internship
track rather than a course list, so it carries fewer courses.

## License

The documentation and the examples in this repository are under the MIT
license, see [LICENSE](LICENSE).

The API itself is licensed for use by anyone, for any purpose, under the
[API Use Grant](TERMS.md). The scheme data is served only through the API.

## Links

- Calculator: <https://vtu.drshn.tech/calculator>
- Documentation site: <https://vtu.drshn.tech/docs>
- Endpoint reference: [DOCS.md](DOCS.md)
- OpenAPI spec: [openapi.json](openapi.json)
- Terms of use: [TERMS.md](TERMS.md)
- Examples: [examples/](examples/)
