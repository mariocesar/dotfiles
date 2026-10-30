# Python

How Python is written anywhere in this repo: `install.py`, the `postinstall/` hooks, `uses/`, and the scripts in `*/.local/bin/`. What makes a command (name, header, shebang) is in `docs/scripts.md`.

## Language

- Stdlib first: a dependency has to earn its place. Code that bootstraps a machine, like `install.py` and the `postinstall/` hooks, stays stdlib.
- Code passes `ruff check` and `ruff format` (repo `ruff.toml`) when written or edited. A deliberate pattern gets a one-line `# noqa: CODE` on its line; a rule that flags a smell, like `global`, gets the established fix instead. Older code is fixed when touched for another reason.

## Code shape

- Code reads top to bottom in the order a reader meets it: output order in a printer, a request's path in a server. Don't group by type, with every constant first and every function after.
- A constant sits beside its one user. Only policy goes first, such as what `share` never serves.
- Helpers are vocabulary: one-line words used many times that make the body read like its output (`h2`, `tr`, `code`, `>> stdout` in `uses.py`). A function with one caller is inlined, unless it is a stage of `main()` or a boundary worth naming, such as a security check.
- `main()` is an orchestrator: it parses flags and calls one function per stage, named for what the stage does, like `link_active_buckets`, `skip_foreign_bucket` and `run_hooks` in `install.py`. Every stage, not only the long ones. A long stage takes `# noqa: C901, PLR0912` on its `def` rather than being split into smaller single-use functions.
- A printer, which reads files and writes text for a pipe, can be plain top-level code like `uses.py`.
- Flags reach a stage as keyword-only arguments (`fake=options.fake`), so its signature shows what it depends on. No `global`, and no Context or Config object unless several stages share several values; then pass argparse's `options` itself.
- A framework calls a server's handlers, so their settings go where the framework hands them over: `request.app.state` in Starlette, `functools.partial(Handler, …)` for `http.server`.
- No class that only holds state or wraps one function; functions and arguments do that.
- Delete what nobody uses: a flag, prompt or parameter goes once nothing relies on it.
- Let the tool that owns a job do it: `install.py` asks `git ls-files` what is in a bucket, and `.gitignore` declares the junk, rather than the script keeping its own list.
- Trust the repo's own files: a traceback is the error message. Never trust what arrives over the network: there every check stays.
