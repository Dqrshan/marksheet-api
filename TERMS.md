# Terms of use for the marksheet API

Last updated 10 November 2026.

These terms cover the HTTP API at `https://vtu.drshn.tech/api` and the
calculator at `https://vtu.drshn.tech`. Using the API means accepting them.

## The grant

The API is free to use for any purpose, commercial or not. You may:

- call it from a browser, a server, a mobile app, a script, a bot, a
  spreadsheet, a class project or a commercial product;
- use, store, copy, analyse, transform and display the data it returns;
- redistribute data you obtained through the API, including inside your own
  product or service;
- use it without credit, though saying where the data came from is a kind
  thing to do.

There is no key, no signup and no fee.

## The data is served through the API

The scheme tables are the point of this service. They are meant to be consumed
through the API, the way the calculator consumes them.

Please do not:

- scrape the API to build a bulk mirror of the dataset;
- crawl every branch and every semester on every request when one call to
  `/api/schemes/{scheme}` would do;
- republish the dataset as a downloadable file or a standalone product.

If you want the whole dataset, ask for it and we will work something out.

## Be reasonable with traffic

No published rate limit today. In practice:

- responses are stable and carry a one day cache lifetime, so cache them;
- send a `User-Agent` that identifies your client;
- if you are building something large, get in touch before you launch it.

We will not cut off a well-behaved client. We will cut off a client that is
trying to take the service down.

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

The API does not require authentication, does not set cookies and does not
collect personal data. Server logs may record the requested path and the
client address, as any web server does, and are used only to keep the service
running and to find abuse.

## Changes

These terms may change. The version in this repository is the version that
applies. Material changes will be announced at `https://vtu.drshn.tech/api`.

## Questions

Open an issue in this repository, or reach the maintainer through the contact
address published at `https://vtu.drshn.tech`.
