# fortuna

https://montecarlo.you/

**A Monte Carlo personal-finance forecaster. Full-stack Fortran.**

`fortuna` answers the questions people actually lose sleep over — *will my money last?*, *when can I retire?*, *how much can I safely spend?* — by simulating tens of thousands of possible market futures in a few hundred milliseconds. It is one self-contained binary with three faces:

- a **CLI** that prints percentile tables, solves for safe spending, and emits JSON/CSV for scripting,
- a **Monte Carlo engine** written in modern Fortran (the language was built for exactly this kind of number crunching),
- a **local web UI** — served by an HTTP server *written in Fortran*, binding straight to libc sockets through `iso_c_binding`. No frameworks, no runtime, no JavaScript build step, no third-party code anywhere in the stack. The frontend is a single dependency-free HTML page compiled into the binary itself.

![fortuna web UI](https://github.com/bell-kevin/fortuna/blob/main/fortuna/docs/screenshot.png)

Everything is free software under the **GNU AGPL-3.0**.

## Why this exists

Most retirement calculators online are ad-funded lead generators that hide their assumptions and phone home with your finances. `fortuna` is the opposite: your numbers never leave your machine, every line of the model is readable, and the whole thing builds from source in about two seconds with nothing but `gfortran` and `make`.

And yes — the web page you interact with is delivered by Fortran. The same language that put probes on other planets can serve `Content-Type: text/html`.

## Quick start

```sh
sudo apt install gfortran make     # or dnf/pacman/brew equivalent
git clone https://github.com/bell-kevin/fortuna
cd fortuna
make
make test
```

Run a forecast:

```sh
./bin/fortuna --age 35 --balance 80000 --monthly 900 --spend 45000
```

```
  success rate: 56.6%  [##############..........]
  (share of futures where the portfolio was never depleted in retirement)

   age        5th pct       25th pct         median       75th pct       95th pct
  ------------------------------------------------------------------------------
    35         $80,000        $80,000        $80,000        $80,000        $80,000
    45        $147,238       $202,509       $251,805       $320,845       $469,311
    55        $249,604       $383,519       $524,001       $737,343     $1,242,400
    65*       $374,317       $632,028       $956,880     $1,418,068     $2,631,603
    75              $0       $310,395       $819,323     $1,758,379     $4,305,365
    ...
```

Ask the harder question — the most you can spend without wrecking the plan:

```sh
./bin/fortuna spend --age 40 --balance 300000 --monthly 1000 --retire-age 60 --target 90
```

```
  highest sustainable retirement spending at a 90.0% success target:

    $21,016 per year  ($1,751 per month, today's dollars)
```

Or open the web UI:

```sh
./bin/fortuna serve            # then open http://127.0.0.1:8080/
```

Building with the [Fortran Package Manager](https://fpm.fortran-lang.org/) also works: `fpm build`, `fpm test`, `fpm run -- serve`.

## Commands and options

| Command | Does |
|---|---|
| `fortuna simulate` (default) | run a forecast, print percentile bands |
| `fortuna spend` | bisect for the highest spending that still meets a success target |
| `fortuna serve` | start the local web UI |
| `fortuna help` / `version` | what you'd expect |

Plan options (dollars are **today's dollars**, rates are **percent**): `--age`, `--retire-age`, `--end-age`, `--balance`, `--monthly`, `--contrib-growth`, `--return`, `--vol`, `--spend`, `--pension`, `--pension-age`.

Engine and output: `--paths` (default 10,000), `--seed` (>0 for reproducible runs), `--target` (for `spend`), `--json`, `--csv FILE`.

Server: `--port`, `--host` (default `127.0.0.1`), `--webroot DIR` (serve `DIR/index.html` from disk instead of the embedded page — handy when hacking on the UI).

`fortuna help` prints the full reference.

## HTTP API

The web UI talks to two endpoints you can also script against:

```
GET  /api/health                     -> {"ok":true}
POST /api/simulate                   -> forecast as JSON
GET  /api/simulate?age=40&spend=...  -> same, via query string
```

`POST /api/simulate` takes `application/x-www-form-urlencoded` keys: `age`, `retire`, `end`, `balance`, `monthly`, `growth`, `return`, `vol`, `spend`, `pension`, `pension_age`, `paths`, `seed`, plus `solve=1&target=90` to run the safe-spending solver. The response contains `success_rate`, yearly `ages`/`p05`/`p25`/`p50`/`p75`/`p95` arrays, and summary fields.

```sh
curl -s -X POST -d "age=40&balance=300000&solve=1&target=90" \
  http://127.0.0.1:8080/api/simulate | jq .solved_spend
```

## The model (read this part)

- Everything is computed in **real (inflation-adjusted) terms**, so supply a *real* expected return. Historically, broad global equity portfolios have earned real returns in the rough neighborhood of 4–6%/yr with ~15–20% volatility, but the right inputs are your call — that's why they're inputs.
- Monthly log-returns are i.i.d. normal with `mu_m = ln(1+R)/12 − sigma_m²/2` and `sigma_m = sigma/√12`, so the expected annual growth factor is exactly `1+R`.
- Accumulation: monthly contributions, growing by `--contrib-growth` per year. Retirement (from `--retire-age`): withdraw `--spend`/12 monthly; pension income starts at `--pension-age`.
- A path **fails** if the balance is ever depleted during retirement. The success rate is the fraction of paths that never fail.

Known simplifications, on purpose: returns are lognormal (real markets have fatter tails and momentum/mean-reversion), there are no taxes or fees, and spending is constant in real terms. Treat the output as a way to *reason about ranges and trade-offs*, not as a prophecy. **This is a modelling toy, not financial advice.**

## Project layout

```
app/main.f90              entry point
src/fortuna_sim.f90       Monte Carlo engine, percentile math, spending solver
src/fortuna_rng.f90       Box-Muller Gaussian sampling
src/fortuna_http.f90      HTTP/1.1 server over libc sockets via iso_c_binding
src/fortuna_forms.f90     urlencoded form/query parsing
src/fortuna_json.f90      minimal JSON writer
src/fortuna_report.f90    terminal tables, money formatting, CSV export
src/fortuna_web_assets.f90  the web UI, embedded (generated — do not edit)
src/fortuna_cli.f90       argument parsing and dispatch
web/index.html            the actual frontend source (vanilla HTML/CSS/JS)
tools/embed_web.py        regenerates fortuna_web_assets.f90 (make webassets)
test/check.f90            test suite (make test)
```

The code is standard-conforming Fortran 2018 and compiles warning-clean with `gfortran -Wall -Wextra`. Linux is the tested platform (the socket constants in `fortuna_http.f90` are Linux values); the CLI portions are portable anywhere gfortran runs.

## Hacking on the web UI

Edit `web/index.html`, then either regenerate the embedded module:

```sh
make webassets && make
```

or skip the embed loop entirely during development:

```sh
./bin/fortuna serve --webroot web    # serves web/index.html from disk
```

The frontend is deliberately plain: one HTML file, no build tools, no external requests, canvas-based charts. If you can read HTML, you can hack on it.

## Contributing

Bug reports, portability patches (BSD/macOS socket constants would be a nice one), and model improvements (historical bootstrap sampling, fat-tailed distributions, glide paths, taxes) are all welcome — see `CONTRIBUTING.md`.

## License

AGPL-3.0-or-later. If you run a modified `fortuna` as a network service for others, the AGPL's whole point is that they get the source too. See [LICENSE](LICENSE).
