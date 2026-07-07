#!/usr/bin/env python3
# SPDX-License-Identifier: AGPL-3.0-or-later
"""Embed web/index.html into src/fortuna_web_assets.f90.

The web UI is compiled into the fortuna binary so that `fortuna serve`
is a single self-contained executable. Chunks are kept short and each
chunk is escaped independently, so generated source lines stay well
under Fortran's default free-form line limit.

Usage: python3 tools/embed_web.py [input.html] [output.f90]
"""
import pathlib
import sys

CHUNK = 50  # characters of raw HTML per Fortran string chunk


def fortran_literal(chunk: str) -> str:
    return '"' + chunk.replace('"', '""') + '"'


def main() -> None:
    src = pathlib.Path(sys.argv[1] if len(sys.argv) > 1 else "web/index.html")
    dst = pathlib.Path(sys.argv[2] if len(sys.argv) > 2 else "src/fortuna_web_assets.f90")

    lines = src.read_text(encoding="utf-8").splitlines()
    out = [
        "! SPDX-License-Identifier: AGPL-3.0-or-later",
        "! Generated from web/index.html by tools/embed_web.py -- DO NOT EDIT.",
        "! Regenerate with: make webassets",
        "module fortuna_web_assets",
        "   implicit none",
        "   private",
        "   public :: index_html",
        "contains",
        "",
        "   function index_html() result(s)",
        "      character(len=:), allocatable :: s",
        "",
        "      s = ''",
    ]
    for ln in lines:
        chunks = [ln[i:i + CHUNK] for i in range(0, len(ln), CHUNK)] or [""]
        lits = [fortran_literal(c) for c in chunks]
        if len(lits) == 1:
            out.append(f"      call ap(s, {lits[0]})")
        else:
            out.append(f"      call ap(s, {lits[0]}// &")
            for lit in lits[1:-1]:
                out.append(f"         {lit}// &")
            out.append(f"         {lits[-1]})")
    out += [
        "   end function index_html",
        "",
        "   subroutine ap(t, line)",
        "      character(len=:), allocatable, intent(inout) :: t",
        "      character(len=*), intent(in) :: line",
        "",
        "      t = t//line//char(10)",
        "   end subroutine ap",
        "",
        "end module fortuna_web_assets",
    ]
    dst.write_text("\n".join(out) + "\n", encoding="utf-8")
    print(f"embedded {src} -> {dst} ({len(lines)} html lines)")


if __name__ == "__main__":
    main()
