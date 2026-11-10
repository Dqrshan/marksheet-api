# Terms of use for the marksheet API

Last updated 10 November 2026.

These terms cover the HTTP API at `https://dev.vtu.drshn.tech/api`, the
dashboard at `https://dev.vtu.drshn.tech` and the calculator at
`https://vtu.drshn.tech`. Using the API means accepting them.

## The grant

The API is free to use for any purpose, commercial or not. You may:

- call it from a browser, a server, a mobile app, a script, a bot, a
  spreadsheet, a class project or a commercial product;
- use, store, copy, analyse, transform and display the data it returns;
- redistribute data you obtained through the API, including inside your own
  product or service;
- use it without credit, though saying where the data came from is a kind
  thing to do.

There is no fee. The course level data needs a key, and a key is free.

## Access levels

| Level | What it opens |
| --- | --- |
| Open | The scheme list, the grade scale, the branch list, the credit totals of each semester |
| Key | The courses of one semester |
| Key | The whole scheme in one answer, five times a day |

A key is sent in the `X-API-Key` header. It is a line of text, it never
belongs in code that runs in somebody else's browser, and it can be replaced
at any time. Keys are made in the dashboard at `https://dev.vtu.drshn.tech`,
where you sign in with Google. The plain key is shown once and only its hash
is kept, so a lost key cannot be looked up and has to be replaced.

The calculator uses a session instead of a key. A session is short lived, has
a request budget and a data budget, and every answer for it comes back
encrypted. That is a control on how fast and how often the data can be taken.
It is not a claim that taking it is impossible, and anyone who reads the
calculator's source can see exactly how it works.

## The data is served through the API

The scheme tables are the point of this service. They are meant to be consumed
through the API, the way the calculator consumes them.

Please do not:

- scrape the API to build a bulk mirror of the dataset;
- crawl every branch and every semester on every request when one call to
  `/api/schemes/{scheme}/export` would do;
- republish the dataset as a downloadable file or a standalone product.

If you want the whole dataset, ask for a key and take the export route. It is
one call with a budget, and that is the supported way to get everything.

## Be reasonable with traffic

There is a limit on every caller and the answer carries the numbers, so you
always know where you stand.

| Caller | Calls |
| --- | --- |
| An address, no key | 120 a minute, 10000 a day |
| A calculator session | 150 calls and 96 KB of data, for 30 minutes |
| A developer key | 600 a minute, 100000 a day, and five bulk exports a day |

In practice:

- metadata answers are stable and carry a one day cache lifetime, so cache
  them;
- send a `User-Agent` that identifies your client;
- if you are building something large, get in touch before you launch it.

We will not cut off a well-behaved client. We will slow down and log a client
that is trying to take the service down.

## Accuracy

The data comes from the official VTU scheme PDFs, and the credit totals are
checked against the totals printed in those PDFs for every branch and every
semester.

It is still a transcription, so it is not infallible. Check any figure against
your own marks card before you rely on it. If you find a mistake, tell us and
we will fix it.

## No warranty

The API and the data are provided on an as-is and best-effort basis, without
warranty of any kind. We do not guarantee that it will be available,
uninterrupted or free of errors, and we do not guarantee that it will stay at
the same address.

## Limits of liability

To the maximum extent permitted by law, the maintainers of this API are not
liable for any loss arising out of its use, including lost profits, lost data
and lost goodwill, however that loss arises.

## Privacy

The API does not set cookies and does not collect personal data. The
dashboard signs you in with Google and keeps a session cookie of its own,
which holds your address and nothing else. Server logs record the requested
path, the client address, the status and the size of the answer, as any web
server does. They are used to keep the service running and to find abuse. A
key is never written to a log. The key of a session is never written to a
log.

A support message is kept until it has been read. It holds the name, the
address and the text you wrote.

## Changes

These terms may change. The version in this repository is the version that
applies. Material changes will be announced at
`https://dev.vtu.drshn.tech`.

## Questions

Open an issue in this repository, or reach the maintainer through the contact
address published at `https://dev.vtu.drshn.tech`.
