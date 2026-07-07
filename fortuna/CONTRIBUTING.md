# Contributing to fortuna

Thanks for considering it. The bar is low and the codebase is small on purpose.

## Ground rules

- **License.** All contributions are accepted under AGPL-3.0-or-later, the
  project's license. New source files should carry the
  `! SPDX-License-Identifier: AGPL-3.0-or-later` header.
- **No dependencies.** The whole point of fortuna is that it builds with
  `gfortran` and `make` and nothing else. PRs that add third-party libraries,
  frontend frameworks, or network calls to outside services will be declined.
- **Standard Fortran.** Code must compile warning-clean with
  `gfortran -std=f2018 -Wall -Wextra`. `make test` must pass.
- **The web UI source is `web/index.html`.** Never edit
  `src/fortuna_web_assets.f90` by hand; run `make webassets` after changing
  the HTML and commit both files.

## Workflow

1. Fork, branch, hack.
2. `make && make test` (add a test in `test/check.f90` if you changed behavior).
3. Open a PR that explains *why*, not just *what*.

## Good first issues

- BSD/macOS socket constants in `fortuna_http.f90` (they differ from Linux;
  a small platform detection would make `serve` portable).
- Historical bootstrap sampling as an alternative to the lognormal model
  (load a user-supplied CSV of annual real returns).
- Fat-tailed return distributions (Student's t).
- A glide path: shifting return/volatility as retirement approaches.
- Windows support notes.
