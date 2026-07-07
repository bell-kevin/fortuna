! SPDX-License-Identifier: AGPL-3.0-or-later
! Generated from web/index.html by tools/embed_web.py -- DO NOT EDIT.
! Regenerate with: make webassets
module fortuna_web_assets
   implicit none
   private
   public :: index_html
contains

   function index_html() result(s)
      character(len=:), allocatable :: s

      s = ''
      call ap(s, "<!DOCTYPE html>")
      call ap(s, "<html lang=""en"">")
      call ap(s, "<head>")
      call ap(s, "<meta charset=""utf-8"">")
      call ap(s, "<meta name=""viewport"" content=""width=device-width,"// &
         " initial-scale=1"">")
      call ap(s, "<title>fortuna — Monte Carlo wealth forecast</titl"// &
         "e>")
      call ap(s, "<style>")
      call ap(s, "  :root{")
      call ap(s, "    --paper:#edf2e9; --panel:#f7faf3; --ink:#1c2a2"// &
         "0; --ink-soft:#48584c;")
      call ap(s, "    --rule:#c2d1bd; --rule-soft:#dbe5d4; --green:#"// &
         "186b3f; --green-deep:#0e4d2c;")
      call ap(s, "    --red:#b23a26; --amber:#9a6a10;")
      call ap(s, "    --mono:ui-monospace,""SF Mono"",Menlo,Consolas,"""// &
         "Liberation Mono"",monospace;")
      call ap(s, "  }")
      call ap(s, "  *{box-sizing:border-box}")
      call ap(s, "  html,body{margin:0;padding:0}")
      call ap(s, "  body{")
      call ap(s, "    background:var(--paper); color:var(--ink); fon"// &
         "t-family:var(--mono);")
      call ap(s, "    font-size:14px; line-height:1.45;")
      call ap(s, "    background-image:repeating-linear-gradient(to "// &
         "bottom, transparent 0 27px, rgba(24,107,63,.05) 27"// &
         "px 28px);")
      call ap(s, "  }")
      call ap(s, "  a{color:var(--green-deep)}")
      call ap(s, "  .wrap{max-width:1180px;margin:0 auto;padding:20p"// &
         "x 16px 48px}")
      call ap(s, "")
      call ap(s, "  /* coding-form header strip */")
      call ap(s, "  header.form-strip{")
      call ap(s, "    border:2px solid var(--ink); background:var(--"// &
         "panel);")
      call ap(s, "    display:flex; flex-wrap:wrap; align-items:stre"// &
         "tch; margin-bottom:20px;")
      call ap(s, "  }")
      call ap(s, "  .strip-cell{padding:10px 14px; border-right:1px "// &
         "solid var(--ink)}")
      call ap(s, "  .strip-cell:last-child{border-right:none}")
      call ap(s, "  .strip-cell .lbl{font-size:10px; letter-spacing:"// &
         ".12em; color:var(--ink-soft); text-transform:upper"// &
         "case}")
      call ap(s, "  .strip-cell .val{font-size:13px; font-weight:700"// &
         "}")
      call ap(s, "  .brand{display:flex; align-items:center; gap:12p"// &
         "x; padding:10px 18px; border-right:2px solid var(-"// &
         "-ink)}")
      call ap(s, "  .brand h1{")
      call ap(s, "    margin:0; font-size:30px; font-weight:800; let"// &
         "ter-spacing:.28em;")
      call ap(s, "    color:var(--green-deep); text-transform:upperc"// &
         "ase;")
      call ap(s, "  }")
      call ap(s, "  .brand .f77{")
      call ap(s, "    border:1.5px solid var(--green-deep); color:va"// &
         "r(--green-deep); font-size:10px;")
      call ap(s, "    padding:3px 6px; letter-spacing:.1em; align-se"// &
         "lf:center;")
      call ap(s, "  }")
      call ap(s, "  .grow{flex:1 1 auto}")
      call ap(s, "")
      call ap(s, "  main{display:grid; grid-template-columns:340px 1"// &
         "fr; gap:20px}")
      call ap(s, "  @media (max-width:900px){ main{grid-template-col"// &
         "umns:1fr} }")
      call ap(s, "")
      call ap(s, "  /* input panel */")
      call ap(s, "  form.panel{")
      call ap(s, "    border:1.5px solid var(--ink); background:var("// &
         "--panel); padding:14px 14px 16px;")
      call ap(s, "    align-self:start;")
      call ap(s, "  }")
      call ap(s, "  fieldset{border:none; border-top:1px solid var(-"// &
         "-rule); margin:0 0 4px; padding:10px 0 6px}")
      call ap(s, "  fieldset:first-of-type{border-top:none; padding-"// &
         "top:2px}")
      call ap(s, "  legend{")
      call ap(s, "    padding:0 6px 0 0; font-size:10px; letter-spac"// &
         "ing:.14em; text-transform:uppercase;")
      call ap(s, "    color:var(--green-deep); font-weight:700;")
      call ap(s, "  }")
      call ap(s, "  .row{display:flex; align-items:center; justify-c"// &
         "ontent:space-between; gap:10px; margin:7px 0}")
      call ap(s, "  .row label{flex:1 1 auto; color:var(--ink-soft)}")
      call ap(s, "  .row input{")
      call ap(s, "    width:110px; padding:5px 7px; font:inherit; co"// &
         "lor:var(--ink); text-align:right;")
      call ap(s, "    background:#fff; border:1px solid var(--rule);"// &
         " border-radius:0;")
      call ap(s, "  }")
      call ap(s, "  .row input:focus{outline:2px solid var(--green);"// &
         " outline-offset:1px}")
      call ap(s, "  details{margin-top:6px}")
      call ap(s, "  details summary{")
      call ap(s, "    cursor:pointer; font-size:10px; letter-spacing"// &
         ":.14em; text-transform:uppercase;")
      call ap(s, "    color:var(--ink-soft);")
      call ap(s, "  }")
      call ap(s, "  .actions{display:flex; flex-direction:column; ga"// &
         "p:8px; margin-top:14px}")
      call ap(s, "  button{")
      call ap(s, "    font:inherit; font-weight:700; letter-spacing:"// &
         ".06em; padding:10px 12px;")
      call ap(s, "    border:1.5px solid var(--green-deep); cursor:p"// &
         "ointer; border-radius:0;")
      call ap(s, "  }")
      call ap(s, "  button.primary{background:var(--green-deep); col"// &
         "or:#fff}")
      call ap(s, "  button.primary:hover{background:var(--green)}")
      call ap(s, "  button.secondary{background:transparent; color:v"// &
         "ar(--green-deep)}")
      call ap(s, "  button.secondary:hover{background:rgba(24,107,63"// &
         ",.08)}")
      call ap(s, "  button:focus-visible{outline:2px solid var(--ink"// &
         "); outline-offset:2px}")
      call ap(s, "  button:disabled{opacity:.55; cursor:wait}")
      call ap(s, "  .solve-row{display:flex; align-items:center; gap"// &
         ":8px}")
      call ap(s, "  .solve-row input{width:64px; padding:5px 7px; fo"// &
         "nt:inherit; text-align:right;")
      call ap(s, "    border:1px solid var(--rule); background:#fff}")
      call ap(s, "  .hint{font-size:11px; color:var(--ink-soft); mar"// &
         "gin-top:10px}")
      call ap(s, "")
      call ap(s, "  /* results */")
      call ap(s, "  .results{display:flex; flex-direction:column; ga"// &
         "p:20px; min-width:0}")
      call ap(s, "  .card{border:1.5px solid var(--ink); background:"// &
         "var(--panel); padding:16px 18px}")
      call ap(s, "  .stat-top{display:flex; flex-wrap:wrap; align-it"// &
         "ems:baseline; gap:8px 18px}")
      call ap(s, "  .big{font-size:52px; font-weight:800; line-heigh"// &
         "t:1}")
      call ap(s, "  .big.good{color:var(--green-deep)} .big.mid{colo"// &
         "r:var(--amber)} .big.bad{color:var(--red)}")
      call ap(s, "  .verdict{font-size:14px; color:var(--ink-soft)}")
      call ap(s, "  .meter{height:10px; border:1px solid var(--ink);"// &
         " margin-top:12px; background:#fff}")
      call ap(s, "  .meter > div{height:100%; background:var(--green"// &
         "-deep); width:0%}")
      call ap(s, "  .stat-note{font-size:11px; color:var(--ink-soft)"// &
         "; margin-top:8px}")
      call ap(s, "  .solved{")
      call ap(s, "    margin-top:12px; padding:10px 12px; border:1.5"// &
         "px dashed var(--green-deep);")
      call ap(s, "    color:var(--green-deep); font-weight:700; disp"// &
         "lay:none;")
      call ap(s, "  }")
      call ap(s, "  #chartbox{position:relative}")
      call ap(s, "  canvas{display:block; width:100%; height:380px}")
      call ap(s, "  .legend{display:flex; flex-wrap:wrap; gap:14px; "// &
         "font-size:11px; color:var(--ink-soft); margin-top:"// &
         "8px}")
      call ap(s, "  .key{display:inline-block; width:14px; height:9p"// &
         "x; margin-right:5px; vertical-align:baseline}")
      call ap(s, "  .k-outer{background:rgba(24,107,63,.15)} .k-inne"// &
         "r{background:rgba(24,107,63,.34)}")
      call ap(s, "  .k-med{background:var(--green-deep); height:3px;"// &
         " vertical-align:middle}")
      call ap(s, "  .tip{")
      call ap(s, "    position:absolute; pointer-events:none; displa"// &
         "y:none; background:var(--ink); color:#f3f7ef;")
      call ap(s, "    font-size:11px; padding:7px 9px; white-space:p"// &
         "re; z-index:2;")
      call ap(s, "  }")
      call ap(s, "  .grid4{display:grid; grid-template-columns:repea"// &
         "t(auto-fit,minmax(170px,1fr)); gap:0}")
      call ap(s, "  .grid4 .cell{padding:12px 14px; border-right:1px"// &
         " solid var(--rule)}")
      call ap(s, "  .grid4 .cell:last-child{border-right:none}")
      call ap(s, "  .cell .lbl{font-size:10px; letter-spacing:.12em;"// &
         " text-transform:uppercase; color:var(--ink-soft)}")
      call ap(s, "  .cell .val{font-size:19px; font-weight:800; marg"// &
         "in-top:3px}")
      call ap(s, "  .error{")
      call ap(s, "    display:none; border:1.5px solid var(--red); c"// &
         "olor:var(--red); background:#fdf2ef;")
      call ap(s, "    padding:10px 14px; font-weight:700;")
      call ap(s, "  }")
      call ap(s, "  footer{margin-top:28px; font-size:11px; color:va"// &
         "r(--ink-soft); border-top:1px solid var(--rule); p"// &
         "adding-top:12px}")
      call ap(s, "  @media (prefers-reduced-motion:no-preference){")
      call ap(s, "    .card{transition:opacity .25s ease}")
      call ap(s, "  }")
      call ap(s, "</style>")
      call ap(s, "</head>")
      call ap(s, "<body>")
      call ap(s, "<div class=""wrap"">")
      call ap(s, "")
      call ap(s, "  <header class=""form-strip"" role=""banner"">")
      call ap(s, "    <div class=""brand"">")
      call ap(s, "      <h1>Fortuna</h1>")
      call ap(s, "      <span class=""f77"">FTN</span>")
      call ap(s, "    </div>")
      call ap(s, "    <div class=""strip-cell""><div class=""lbl"">Progr"// &
         "am</div><div class=""val"">Monte Carlo wealth foreca"// &
         "st</div></div>")
      call ap(s, "    <div class=""strip-cell""><div class=""lbl"">Units"// &
         "</div><div class=""val"">Today's dollars (real terms"// &
         ")</div></div>")
      call ap(s, "    <div class=""strip-cell grow""><div class=""lbl"">"// &
         "Backend</div><div class=""val"">100% Fortran, zero d"// &
         "ependencies</div></div>")
      call ap(s, "  </header>")
      call ap(s, "")
      call ap(s, "  <main>")
      call ap(s, "    <form class=""panel"" id=""f"" autocomplete=""off"">")
      call ap(s, "      <fieldset>")
      call ap(s, "        <legend>You</legend>")
      call ap(s, "        <div class=""row""><label for=""age"">Current "// &
         "age</label><input id=""age"" type=""number"" value=""30"// &
         """ min=""0"" max=""120"" step=""1""></div>")
      call ap(s, "        <div class=""row""><label for=""retire"">Retir"// &
         "ement age</label><input id=""retire"" type=""number"" "// &
         "value=""65"" min=""0"" max=""120"" step=""1""></div>")
      call ap(s, "        <div class=""row""><label for=""end"">Plan unt"// &
         "il age</label><input id=""end"" type=""number"" value="// &
         """95"" min=""1"" max=""130"" step=""1""></div>")
      call ap(s, "      </fieldset>")
      call ap(s, "      <fieldset>")
      call ap(s, "        <legend>Saving</legend>")
      call ap(s, "        <div class=""row""><label for=""balance"">Inve"// &
         "sted savings, $</label><input id=""balance"" type=""n"// &
         "umber"" value=""25000"" min=""0"" step=""1000""></div>")
      call ap(s, "        <div class=""row""><label for=""monthly"">Mont"// &
         "hly contribution, $</label><input id=""monthly"" typ"// &
         "e=""number"" value=""500"" min=""0"" step=""50""></div>")
      call ap(s, "        <div class=""row""><label for=""growth"">Contr"// &
         "ibution growth, %/yr</label><input id=""growth"" typ"// &
         "e=""number"" value=""1"" step=""0.1""></div>")
      call ap(s, "      </fieldset>")
      call ap(s, "      <fieldset>")
      call ap(s, "        <legend>Market (real, after inflation)</le"// &
         "gend>")
      call ap(s, "        <div class=""row""><label for=""return"">Expec"// &
         "ted return, %/yr</label><input id=""return"" type=""n"// &
         "umber"" value=""5"" step=""0.1""></div>")
      call ap(s, "        <div class=""row""><label for=""vol"">Volatili"// &
         "ty, %/yr</label><input id=""vol"" type=""number"" valu"// &
         "e=""15"" step=""0.5""></div>")
      call ap(s, "      </fieldset>")
      call ap(s, "      <fieldset>")
      call ap(s, "        <legend>Retirement</legend>")
      call ap(s, "        <div class=""row""><label for=""spend"">Spendi"// &
         "ng, $/yr</label><input id=""spend"" type=""number"" va"// &
         "lue=""40000"" min=""0"" step=""1000""></div>")
      call ap(s, "        <div class=""row""><label for=""pension"">Pens"// &
         "ion or Social Security, $/mo</label><input id=""pen"// &
         "sion"" type=""number"" value=""0"" min=""0"" step=""50""></"// &
         "div>")
      call ap(s, "        <div class=""row""><label for=""pension_age"">"// &
         "Pension starts at age</label><input id=""pension_ag"// &
         "e"" type=""number"" value=""67"" min=""0"" max=""130"" step"// &
         "=""1""></div>")
      call ap(s, "      </fieldset>")
      call ap(s, "      <details>")
      call ap(s, "        <summary>Engine</summary>")
      call ap(s, "        <div class=""row""><label for=""paths"">Simula"// &
         "ted futures</label><input id=""paths"" type=""number"""// &
         " value=""5000"" min=""100"" max=""200000"" step=""100""></"// &
         "div>")
      call ap(s, "        <div class=""row""><label for=""seed"">Seed (0"// &
         " = random)</label><input id=""seed"" type=""number"" v"// &
         "alue=""0"" min=""0"" step=""1""></div>")
      call ap(s, "      </details>")
      call ap(s, "      <div class=""actions"">")
      call ap(s, "        <button type=""button"" class=""primary"" id="""// &
         "run"">Run simulation</button>")
      call ap(s, "        <div class=""solve-row"">")
      call ap(s, "          <button type=""button"" class=""secondary"" "// &
         "id=""solve"">Find safe spending</button>")
      call ap(s, "          <label for=""target"">at</label>")
      call ap(s, "          <input id=""target"" type=""number"" value="""// &
         "90"" min=""50"" max=""99"" step=""1"" aria-label=""success"// &
         " target, percent"">")
      call ap(s, "          <span>%</span>")
      call ap(s, "        </div>")
      call ap(s, "      </div>")
      call ap(s, "      <p class=""hint"">A modelling toy, not financi"// &
         "al advice. Returns are drawn from a")
      call ap(s, "      lognormal model — real markets have fatter t"// &
         "ails.</p>")
      call ap(s, "    </form>")
      call ap(s, "")
      call ap(s, "    <section class=""results"">")
      call ap(s, "      <div class=""error"" id=""err"" role=""alert""></d"// &
         "iv>")
      call ap(s, "")
      call ap(s, "      <div class=""card"" id=""statcard"">")
      call ap(s, "        <div class=""stat-top"">")
      call ap(s, "          <div class=""big"" id=""rate"">—</div>")
      call ap(s, "          <div class=""verdict"" id=""verdict"">Set yo"// &
         "ur plan, then run the simulation.</div>")
      call ap(s, "        </div>")
      call ap(s, "        <div class=""meter"" aria-hidden=""true""><div"// &
         " id=""meterfill""></div></div>")
      call ap(s, "        <div class=""stat-note"" id=""statnote"">Succe"// &
         "ss = the portfolio is never depleted in retirement"// &
         ".</div>")
      call ap(s, "        <div class=""solved"" id=""solvedbox""></div>")
      call ap(s, "      </div>")
      call ap(s, "")
      call ap(s, "      <div class=""card"">")
      call ap(s, "        <div id=""chartbox"">")
      call ap(s, "          <canvas id=""chart"" aria-label=""fan chart"// &
         " of portfolio balance percentiles by age"" role=""im"// &
         "g""></canvas>")
      call ap(s, "          <div class=""tip"" id=""tip""></div>")
      call ap(s, "        </div>")
      call ap(s, "        <div class=""legend"">")
      call ap(s, "          <span><span class=""key k-outer""></span>5"// &
         "th–95th percentile</span>")
      call ap(s, "          <span><span class=""key k-inner""></span>2"// &
         "5th–75th percentile</span>")
      call ap(s, "          <span><span class=""key k-med""></span>Med"// &
         "ian</span>")
      call ap(s, "        </div>")
      call ap(s, "      </div>")
      call ap(s, "")
      call ap(s, "      <div class=""card grid4"">")
      call ap(s, "        <div class=""cell""><div class=""lbl"">Median "// &
         "at retirement</div><div class=""val"" id=""s_ret"">—</"// &
         "div></div>")
      call ap(s, "        <div class=""cell""><div class=""lbl"">Median "// &
         "at plan end</div><div class=""val"" id=""s_end"">—</di"// &
         "v></div>")
      call ap(s, "        <div class=""cell""><div class=""lbl"">5th per"// &
         "centile at end</div><div class=""val"" id=""s_p05"">—<"// &
         "/div></div>")
      call ap(s, "        <div class=""cell""><div class=""lbl"">Retirem"// &
         "ent spend used</div><div class=""val"" id=""s_spend"">"// &
         "—</div></div>")
      call ap(s, "      </div>")
      call ap(s, "    </section>")
      call ap(s, "  </main>")
      call ap(s, "")
      call ap(s, "  <footer>")
      call ap(s, "    fortuna is free software under the")
      call ap(s, "    <a href=""https://www.gnu.org/licenses/agpl-3.0"// &
         ".html"">GNU AGPL-3.0</a>.")
      call ap(s, "    The page you are reading was served by an HTTP"// &
         " server written in Fortran.")
      call ap(s, "  </footer>")
      call ap(s, "</div>")
      call ap(s, "")
      call ap(s, "<script>")
      call ap(s, "(function(){")
      call ap(s, "  ""use strict"";")
      call ap(s, "  var $ = function(id){ return document.getElement"// &
         "ById(id); };")
      call ap(s, "  var last = null;")
      call ap(s, "")
      call ap(s, "  function fmtMoney(x){")
      call ap(s, "    var a = Math.abs(x), s = x < 0 ? ""-$"" : ""$"";")
      call ap(s, "    if (a >= 1e9) return s + (a/1e9).toFixed(2) + "// &
         """B"";")
      call ap(s, "    if (a >= 1e6) return s + (a/1e6).toFixed(2) + "// &
         """M"";")
      call ap(s, "    if (a >= 1e4) return s + Math.round(a/1e3) + """// &
         "k"";")
      call ap(s, "    return s + Math.round(a).toLocaleString(""en-US"// &
         """);")
      call ap(s, "  }")
      call ap(s, "  function fmtAxis(x){")
      call ap(s, "    if (x >= 1e9) return ""$"" + (x/1e9).toFixed(1)."// &
         "replace(/\.0$/,"""") + ""B"";")
      call ap(s, "    if (x >= 1e6) return ""$"" + (x/1e6).toFixed(1)."// &
         "replace(/\.0$/,"""") + ""M"";")
      call ap(s, "    if (x >= 1e3) return ""$"" + Math.round(x/1e3) +"// &
         " ""k"";")
      call ap(s, "    return ""$"" + Math.round(x);")
      call ap(s, "  }")
      call ap(s, "")
      call ap(s, "  function params(solve){")
      call ap(s, "    var ids = [""age"",""retire"",""end"",""balance"",""mon"// &
         "thly"",""growth"",""return"",")
      call ap(s, "               ""vol"",""spend"",""pension"",""pension_ag"// &
         "e"",""paths"",""seed""];")
      call ap(s, "    var p = new URLSearchParams();")
      call ap(s, "    ids.forEach(function(id){ p.set(id, $(id).valu"// &
         "e || ""0""); });")
      call ap(s, "    if (solve){ p.set(""solve"",""1""); p.set(""target"""// &
         ", $(""target"").value || ""90""); }")
      call ap(s, "    return p;")
      call ap(s, "  }")
      call ap(s, "")
      call ap(s, "  function setBusy(b){")
      call ap(s, "    $(""run"").disabled = b; $(""solve"").disabled = b"// &
         ";")
      call ap(s, "    $(""run"").textContent = b ? ""Running…"" : ""Run s"// &
         "imulation"";")
      call ap(s, "  }")
      call ap(s, "")
      call ap(s, "  function run(solve){")
      call ap(s, "    setBusy(true);")
      call ap(s, "    $(""err"").style.display = ""none"";")
      call ap(s, "    fetch(""/api/simulate"", {")
      call ap(s, "      method:""POST"",")
      call ap(s, "      headers:{""Content-Type"":""application/x-www-f"// &
         "orm-urlencoded""},")
      call ap(s, "      body: params(solve).toString()")
      call ap(s, "    })")
      call ap(s, "    .then(function(r){ return r.json().then(functi"// &
         "on(j){ return {ok:r.ok, j:j}; }); })")
      call ap(s, "    .then(function(r){")
      call ap(s, "      if (!r.ok || r.j.error){ showError(r.j.error"// &
         " || ""The simulation failed.""); return; }")
      call ap(s, "      last = r.j;")
      call ap(s, "      render(r.j, solve);")
      call ap(s, "    })")
      call ap(s, "    .catch(function(){ showError(""Could not reach "// &
         "the fortuna server. Is it still running?""); })")
      call ap(s, "    .then(function(){ setBusy(false); });")
      call ap(s, "  }")
      call ap(s, "")
      call ap(s, "  function showError(msg){")
      call ap(s, "    var e = $(""err"");")
      call ap(s, "    e.textContent = msg;")
      call ap(s, "    e.style.display = ""block"";")
      call ap(s, "  }")
      call ap(s, "")
      call ap(s, "  function verdictFor(r){")
      call ap(s, "    if (r >= 0.95) return ""On track in nearly ever"// &
         "y simulated future."";")
      call ap(s, "    if (r >= 0.85) return ""Solid, with room for a "// &
         "run of bad markets."";")
      call ap(s, "    if (r >= 0.70) return ""Workable, but sensitive"// &
         " to rough decades."";")
      call ap(s, "    if (r >= 0.50) return ""Coin-flip territory. Ad"// &
         "just something."";")
      call ap(s, "    return ""This plan runs out of money in most fu"// &
         "tures."";")
      call ap(s, "  }")
      call ap(s, "")
      call ap(s, "  function render(d, solved){")
      call ap(s, "    var pctv = (100*d.success_rate);")
      call ap(s, "    var big = $(""rate"");")
      call ap(s, "    big.textContent = (pctv >= 99.95 ? ""100"" : pct"// &
         "v.toFixed(1)) + ""%"";")
      call ap(s, "    big.className = ""big "" + (d.success_rate >= 0."// &
         "85 ? ""good"" : d.success_rate >= 0.70 ? ""mid"" : ""ba"// &
         "d"");")
      call ap(s, "    $(""verdict"").textContent = verdictFor(d.succes"// &
         "s_rate);")
      call ap(s, "    $(""meterfill"").style.width = Math.max(0, Math."// &
         "min(100, pctv)) + ""%"";")
      call ap(s, "    $(""meterfill"").style.background = d.success_ra"// &
         "te >= 0.85 ? ""var(--green-deep)""")
      call ap(s, "      : d.success_rate >= 0.70 ? ""var(--amber)"" : "// &
         """var(--red)"";")
      call ap(s, "    $(""statnote"").textContent = ""Success = the por"// &
         "tfolio is never depleted in retirement. """)
      call ap(s, "      + d.paths.toLocaleString(""en-US"") + "" future"// &
         "s simulated."";")
      call ap(s, "")
      call ap(s, "    var sb = $(""solvedbox"");")
      call ap(s, "    if (solved && d.solved_spend !== undefined){")
      call ap(s, "      sb.style.display = ""block"";")
      call ap(s, "      sb.textContent = ""Highest sustainable spendi"// &
         "ng at a """)
      call ap(s, "        + Math.round(100*d.solved_target) + ""% tar"// &
         "get: """)
      call ap(s, "        + fmtMoney(d.solved_spend) + ""/yr  ("" + fm"// &
         "tMoney(d.solved_spend/12) + ""/mo)"";")
      call ap(s, "    } else {")
      call ap(s, "      sb.style.display = ""none"";")
      call ap(s, "    }")
      call ap(s, "")
      call ap(s, "    var n = d.ages.length - 1;")
      call ap(s, "    $(""s_ret"").textContent = fmtMoney(d.median_at_"// &
         "retirement);")
      call ap(s, "    $(""s_end"").textContent = fmtMoney(d.median_end"// &
         ");")
      call ap(s, "    $(""s_p05"").textContent = fmtMoney(d.p05[n]);")
      call ap(s, "    $(""s_spend"").textContent = fmtMoney(d.annual_s"// &
         "pend) + ""/yr"";")
      call ap(s, "")
      call ap(s, "    drawChart(d);")
      call ap(s, "  }")
      call ap(s, "")
      call ap(s, "  /* ---------------- fan chart ---------------- *"// &
         "/")
      call ap(s, "  var canvas = $(""chart""), tip = $(""tip"");")
      call ap(s, "  var geom = null;")
      call ap(s, "")
      call ap(s, "  function drawChart(d){")
      call ap(s, "    var dpr = window.devicePixelRatio || 1;")
      call ap(s, "    var W = canvas.clientWidth, H = canvas.clientH"// &
         "eight;")
      call ap(s, "    canvas.width = Math.round(W*dpr); canvas.heigh"// &
         "t = Math.round(H*dpr);")
      call ap(s, "    var ctx = canvas.getContext(""2d"");")
      call ap(s, "    ctx.setTransform(dpr,0,0,dpr,0,0);")
      call ap(s, "    ctx.clearRect(0,0,W,H);")
      call ap(s, "")
      call ap(s, "    var padL = 62, padR = 14, padT = 14, padB = 30"// &
         ";")
      call ap(s, "    var iw = W - padL - padR, ih = H - padT - padB"// &
         ";")
      call ap(s, "    var a0 = d.ages[0], a1 = d.ages[d.ages.length-"// &
         "1];")
      call ap(s, "    var ymax = 0;")
      call ap(s, "    for (var i=0;i<d.p95.length;i++) if (d.p95[i] "// &
         "> ymax) ymax = d.p95[i];")
      call ap(s, "    ymax = niceCeil(ymax || 1);")
      call ap(s, "")
      call ap(s, "    var X = function(age){ return padL + iw*(age-a"// &
         "0)/(a1-a0); };")
      call ap(s, "    var Y = function(v){ return padT + ih*(1 - v/y"// &
         "max); };")
      call ap(s, "    geom = {X:X, Y:Y, padL:padL, padT:padT, iw:iw,"// &
         " ih:ih, a0:a0, a1:a1, d:d};")
      call ap(s, "")
      call ap(s, "    var css = getComputedStyle(document.documentEl"// &
         "ement);")
      call ap(s, "    var ink = css.getPropertyValue(""--ink"").trim()"// &
         ";")
      call ap(s, "    var soft = css.getPropertyValue(""--ink-soft"")."// &
         "trim();")
      call ap(s, "    var rule = css.getPropertyValue(""--rule-soft"")"// &
         ".trim();")
      call ap(s, "    var green = css.getPropertyValue(""--green-deep"// &
         """).trim();")
      call ap(s, "    var red = css.getPropertyValue(""--red"").trim()"// &
         ";")
      call ap(s, "")
      call ap(s, "    /* coding-form column ruling: a light vertical"// &
         " line every year,")
      call ap(s, "       heavier every 5 years */")
      call ap(s, "    for (var age = Math.ceil(a0); age <= a1; age++"// &
         "){")
      call ap(s, "      ctx.beginPath();")
      call ap(s, "      ctx.strokeStyle = rule;")
      call ap(s, "      ctx.lineWidth = (age % 5 === 0) ? 1.2 : 0.5;")
      call ap(s, "      ctx.moveTo(X(age), padT); ctx.lineTo(X(age),"// &
         " padT+ih);")
      call ap(s, "      ctx.stroke();")
      call ap(s, "      if (age % 5 === 0){")
      call ap(s, "        ctx.fillStyle = soft; ctx.font = ""11px "" +"// &
         " css.getPropertyValue(""--mono"");")
      call ap(s, "        ctx.textAlign = ""center"";")
      call ap(s, "        ctx.fillText(String(age), X(age), H-10);")
      call ap(s, "      }")
      call ap(s, "    }")
      call ap(s, "    /* y ticks */")
      call ap(s, "    var ticks = 5;")
      call ap(s, "    for (var t=0;t<=ticks;t++){")
      call ap(s, "      var v = ymax*t/ticks, y = Y(v);")
      call ap(s, "      ctx.beginPath(); ctx.strokeStyle = rule; ctx"// &
         ".lineWidth = 0.8;")
      call ap(s, "      ctx.moveTo(padL, y); ctx.lineTo(padL+iw, y);"// &
         " ctx.stroke();")
      call ap(s, "      ctx.fillStyle = soft; ctx.font = ""11px "" + c"// &
         "ss.getPropertyValue(""--mono"");")
      call ap(s, "      ctx.textAlign = ""right"";")
      call ap(s, "      ctx.fillText(fmtAxis(v), padL-8, y+4);")
      call ap(s, "    }")
      call ap(s, "")
      call ap(s, "    band(ctx, d.ages, d.p05, d.p95, ""rgba(24,107,6"// &
         "3,0.15)"", X, Y);")
      call ap(s, "    band(ctx, d.ages, d.p25, d.p75, ""rgba(24,107,6"// &
         "3,0.30)"", X, Y);")
      call ap(s, "")
      call ap(s, "    ctx.beginPath();")
      call ap(s, "    ctx.strokeStyle = green; ctx.lineWidth = 2.2;")
      call ap(s, "    line(ctx, d.ages, d.p50, X, Y);")
      call ap(s, "    ctx.stroke();")
      call ap(s, "")
      call ap(s, "    /* retirement marker */")
      call ap(s, "    if (d.retire_age > a0 && d.retire_age < a1){")
      call ap(s, "      ctx.save();")
      call ap(s, "      ctx.setLineDash([5,4]);")
      call ap(s, "      ctx.strokeStyle = red; ctx.lineWidth = 1.4;")
      call ap(s, "      ctx.beginPath();")
      call ap(s, "      ctx.moveTo(X(d.retire_age), padT); ctx.lineT"// &
         "o(X(d.retire_age), padT+ih);")
      call ap(s, "      ctx.stroke();")
      call ap(s, "      ctx.setLineDash([]);")
      call ap(s, "      ctx.fillStyle = red; ctx.font = ""11px "" + cs"// &
         "s.getPropertyValue(""--mono"");")
      call ap(s, "      ctx.textAlign = ""left"";")
      call ap(s, "      ctx.fillText(""retire"", X(d.retire_age)+5, pa"// &
         "dT+12);")
      call ap(s, "      ctx.restore();")
      call ap(s, "    }")
      call ap(s, "")
      call ap(s, "    /* frame */")
      call ap(s, "    ctx.strokeStyle = ink; ctx.lineWidth = 1.4;")
      call ap(s, "    ctx.strokeRect(padL, padT, iw, ih);")
      call ap(s, "  }")
      call ap(s, "")
      call ap(s, "  function band(ctx, ages, lo, hi, fill, X, Y){")
      call ap(s, "    ctx.beginPath();")
      call ap(s, "    for (var i=0;i<ages.length;i++){")
      call ap(s, "      var x = X(ages[i]), y = Y(hi[i]);")
      call ap(s, "      if (i===0) ctx.moveTo(x,y); else ctx.lineTo("// &
         "x,y);")
      call ap(s, "    }")
      call ap(s, "    for (var j=ages.length-1;j>=0;j--) ctx.lineTo("// &
         "X(ages[j]), Y(lo[j]));")
      call ap(s, "    ctx.closePath();")
      call ap(s, "    ctx.fillStyle = fill;")
      call ap(s, "    ctx.fill();")
      call ap(s, "  }")
      call ap(s, "  function line(ctx, ages, v, X, Y){")
      call ap(s, "    for (var i=0;i<ages.length;i++){")
      call ap(s, "      var x = X(ages[i]), y = Y(v[i]);")
      call ap(s, "      if (i===0) ctx.moveTo(x,y); else ctx.lineTo("// &
         "x,y);")
      call ap(s, "    }")
      call ap(s, "  }")
      call ap(s, "  function niceCeil(v){")
      call ap(s, "    var m = Math.pow(10, Math.floor(Math.log10(v))"// &
         ");")
      call ap(s, "    var f = v/m;")
      call ap(s, "    var nf = f <= 1 ? 1 : f <= 2 ? 2 : f <= 2.5 ? "// &
         "2.5 : f <= 5 ? 5 : 10;")
      call ap(s, "    return nf*m;")
      call ap(s, "  }")
      call ap(s, "")
      call ap(s, "  canvas.addEventListener(""mousemove"", function(ev"// &
         "){")
      call ap(s, "    if (!geom || !last){ return; }")
      call ap(s, "    var r = canvas.getBoundingClientRect();")
      call ap(s, "    var mx = ev.clientX - r.left;")
      call ap(s, "    var age = geom.a0 + (mx - geom.padL)/geom.iw*("// &
         "geom.a1-geom.a0);")
      call ap(s, "    var i = Math.round(age - geom.a0);")
      call ap(s, "    if (i < 0 || i >= last.ages.length || mx < geo"// &
         "m.padL || mx > geom.padL+geom.iw){")
      call ap(s, "      tip.style.display = ""none""; drawChart(last);"// &
         " return;")
      call ap(s, "    }")
      call ap(s, "    drawChart(last);")
      call ap(s, "    var ctx = canvas.getContext(""2d"");")
      call ap(s, "    var x = geom.X(last.ages[i]);")
      call ap(s, "    ctx.beginPath();")
      call ap(s, "    ctx.strokeStyle = ""#1c2a20""; ctx.lineWidth = 1"// &
         ";")
      call ap(s, "    ctx.moveTo(x, geom.padT); ctx.lineTo(x, geom.p"// &
         "adT+geom.ih);")
      call ap(s, "    ctx.stroke();")
      call ap(s, "    tip.style.display = ""block"";")
      call ap(s, "    tip.textContent = ""age "" + Math.round(last.age"// &
         "s[i])")
      call ap(s, "      + ""\n95th  "" + fmtMoney(last.p95[i])")
      call ap(s, "      + ""\nmed   "" + fmtMoney(last.p50[i])")
      call ap(s, "      + ""\n5th   "" + fmtMoney(last.p05[i]);")
      call ap(s, "    var tx = x + 12;")
      call ap(s, "    if (tx > r.width - 130) tx = x - 132;")
      call ap(s, "    tip.style.left = tx + ""px"";")
      call ap(s, "    tip.style.top = (geom.padT + 8) + ""px"";")
      call ap(s, "  });")
      call ap(s, "  canvas.addEventListener(""mouseleave"", function()"// &
         "{")
      call ap(s, "    tip.style.display = ""none"";")
      call ap(s, "    if (last) drawChart(last);")
      call ap(s, "  });")
      call ap(s, "  window.addEventListener(""resize"", function(){ if"// &
         " (last) drawChart(last); });")
      call ap(s, "")
      call ap(s, "  $(""run"").addEventListener(""click"", function(){ r"// &
         "un(false); });")
      call ap(s, "  $(""solve"").addEventListener(""click"", function(){"// &
         " run(true); });")
      call ap(s, "  run(false);")
      call ap(s, "})();")
      call ap(s, "</script>")
      call ap(s, "</body>")
      call ap(s, "</html>")
   end function index_html

   subroutine ap(t, line)
      character(len=:), allocatable, intent(inout) :: t
      character(len=*), intent(in) :: line

      t = t//line//char(10)
   end subroutine ap

end module fortuna_web_assets
