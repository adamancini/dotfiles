# Shell Commands (Bash tool runs zsh)

The Bash tool runs zsh 5.9. `~/.zshenv` loads `~/.zshrc.d/conf.d/*.zsh` for non-interactive shells, so the full environment (paths, `gwt`, kubecm, pass, direnv) is present. Do not switch the tool to bash. Write idiomatic zsh, not bash-in-zsh. Full references: `devops-toolkit:knowledge-base` -> `shell-scripting/idiomatic-zsh.md` and `shell-scripting/sed-gnu-vs-bsd.md`.

## The tool shell is NOT plain `zsh -c` (verified)

- **`BARE_GLOB_QUAL` is off** in the tool (on in plain zsh): `*(N)`, `*(.)`, `*(om[1])` fail with "no matches found". In the tool, write qualifiers as `(#q...)` after `setopt extended_glob`: `setopt extended_glob; rm -- *.tmp(#qN)`. Or `setopt null_glob` for the whole call.
- Options reset every call (a `setopt` does not carry to the next Bash call), so set them at the top of each command that needs them.
- `grep` is a Claude Code wrapper around **ugrep** with `--ignore-files -I`, not BSD or GNU grep. `sed` is **GNU sed 4.10** (gnubin first on PATH); `/usr/bin/sed` is BSD. See the search and sed sections below.

## Searching: rg (ripgrep 15, /opt/homebrew/bin/rg, no config file)

Prefer `rg` for shell searches (the dedicated Grep tool is also ripgrep-based). Its defaults SKIP files, and so does the tool's `grep` wrapper (verified):

| Skips by default | `rg` | tool `grep -r` | `/usr/bin/grep -r` |
|---|---|---|---|
| gitignored files (`.env`, build output) | yes | yes | no |
| hidden files/dirs | yes | no | no |
| binary files | yes | yes | no |

- **Exhaustive searches** (secrets, credentials, leftover references before a rename or delete, "is X used anywhere"): use `rg -uuu` (or `--no-ignore --hidden --binary`) or `/usr/bin/grep -r`. A default `rg`/`grep` saying "no matches" does NOT prove absence.
- Never feed a default `rg -l` list into a bulk edit/delete and assume it is complete; ignored and hidden files are silently left out.
- Regex is Rust syntax: no backreferences or lookaround unless `-P`. `-F` for literal strings. Case-sensitive by default (`-i`, `-S` smart case).
- `rg -r/--replace` only rewrites OUTPUT; it never edits files.
- Patterns starting with `-`: `rg -e '-x'` or `rg -- '-x'`. Exit 1 = no match, 2 = error.
- File lists for other tools: `rg -l0 pat | xargs -0 cmd`, or into a zsh array: `files=(${(0)"$(rg -l0 pat)"})` (verified: handles spaces; the `"${(@0)...}"` form adds a bogus empty element from the trailing NUL).
- Script files run with `zsh file` / a zsh shebang get plain zsh defaults (`BARE_GLOB_QUAL` on), so `(N)` works there; prefer `(#qN)` + `extended_glob` anyway so code works in both.

## zsh failure modes (verified on 5.9)

- **Unmatched glob.** With a builtin (`print`, `cd`, `for`, `[[`), "no matches found" aborts EVERYTHING after it in the call (exit 1). With an external command (`rm`, `ls`, `kubectl`), only that command and its `&&` chain die; later `;` commands still run and overall status can be 0. Every glob that may match nothing gets a null-glob qualifier (see above).
- **No word splitting.** Unquoted `$var` is one argument. Lists live in arrays: `args=(-n "$ns" get pods); kubectl "${args[@]}"`. `${=var}` only for deliberately splitting a trusted string.
- **Command substitution DOES split** when unquoted. Lines into an array: `lines=("${(@f)$(cmd)}")` (keeps empty lines) or `${(f)"$(cmd)"}` (drops them).
- **Unquoted empty values vanish** as arguments; quote when an empty argument must be passed.
- Arrays are 1-based: `$arr[1]`, `$arr[-1]`, `$arr[2,-1]`, `$#arr`. `read -A`, not `read -a`.
- `echo` interprets backslashes and `print "-x..."` parses options: always `print -r -- "$x"`; `print -rl --` for one per line; `print -u2` for stderr.
- A word starting with `=` expands to a command path; quote it.
- `local x` at script top level, re-run in a loop, prints `x=value` (no `typeset_silent`); declare once outside the loop.

## Prefer zsh-native over external tools

| Instead of | Write |
|---|---|
| `basename`/`dirname`/`realpath` | `${f:t}` `${f:h}` `${f:a}` (`:A` resolves symlinks), `${f:r}` `${f:e}`; work on whole arrays |
| `find . -name '*.yaml' -type f` | `**/*.yaml(#qN.)` (results are already safe single args; no `-print0`) |
| `find -mmin -60` / `-size +1M` / newest | `**/*(#qN.mh-1)` / `**/*(#qN.Lm+1)` / `*(#qN.om[1])` |
| `tr : '\n'`, `IFS=, ... "${a[*]}"` | `${(s.:.)PATH}`, `${(j:,:)arr}` |
| `sort`, `sort -u`, `tr` case | `${(o)arr}`, `${(u)arr}`, `${(L)s}` |
| `grep` over an array | `${(M)arr:#pat}` (keep) / `${arr:#pat}` (drop) |
| `cat file`, `wc -l`, `seq 1 10` | `"$(<file)"`, `$#lines`, `{1..10}` |
| bash `${!name}`, `PIPESTATUS`, `mapfile` | `${(P)name}`, `$pipestatus`, `"${(@f)$(cmd)}"` |
| `sed 's/x/y/g'` on a variable | `${v//x/y}`, `${v:s/x/y/}` |

`extended_glob` also enables `^pat`, `pat~excl` and `(#i)`: `**/*.go~*/vendor/*(#qN.)`.

## sed (GNU vs BSD, verified GNU 4.10 vs macOS /usr/bin/sed)

Bare `sed` here is GNU. Hooks, launchd jobs, `/usr/bin/sed`, CI and other machines may get BSD. The dangerous differences are the SILENT ones (both exit 0, different result):

- **In-place flag is incompatible.** GNU: `-i` / `-i.bak`. BSD: `-i ''` / `-i .bak`. `sed -i '' ...` on GNU fails; `sed -i 's/...' f` on BSD fails; `sed -i -e ...` on BSD silently creates `file-e` backups. Only `-i.bak` (attached suffix) works on both; then remove the `.bak`.
- **BRE GNU extensions silently no-op on BSD:** `\+ \? \|`, `\w \s \b \< \>`. Use `-E` (ERE, both) with `+ ? | {n}` and POSIX classes `[[:alnum:]_]`, `[[:space:]]`.
- **`\U \L \u \l` case conversion**: BSD inserts a literal `U`. GNU only.
- **GNU-only, BSD errors:** one-liner `a text`/`i text`/`c text` (portable: `a\` + newline + text), `{cmd}` without `;` before `}`, `first~step`, `0,/re/` (BSD silently ignores), `Q`, `F`, `e`, `-z`, `-s`, `--long-options`, `l N`.
- **BSD aborts on invalid UTF-8** ("illegal byte sequence"); prefix `LC_ALL=C` when editing arbitrary bytes.
- **In-place hazards on BOTH:** `-n -i` without `p` truncates the file to empty; `-i` breaks hardlinks. **GNU `-i` replaces a symlink with a regular file** (target untouched, link destroyed) unless `--follow-symlinks`; BSD refuses symlinks. `perl -pi` also clobbers symlinks.

Rules for sed edits:
- Editing files: prefer the Edit tool. For shell edits, run without `-i` first and diff (`sed 'expr' f | diff f -`), then apply.
- In-place: `[[ -L $f ]]` check first, use `-E`, `-i.bak` only when the target sed is unknown, otherwise GNU syntax with `--follow-symlinks`. Never `-n` with `-i`.
- Scripts that must run on any Mac/Linux: call `gsed` explicitly or avoid in-place sed (write to temp file, then `mv`).
- For transforming a variable's value, use zsh expansion, not sed.

## Snippets, functions, scripts

- Multi-line logic: wrap in a function opening with `emulate -L zsh` (plus `setopt err_return pipe_fail no_unset` when it should stop on failure). Declare variables with `local`/`typeset` (`-a` array, `-A` assoc, `-i` int, `-r` read-only); do not create globals implicitly.
- `[[ ]]` for tests, `(( ))` for arithmetic (`(( n > 3 ))`). Key exists: `(( ${+h[k]} ))`.
- `exit` inside a function kills the whole shell; use `return`.
- `cmd | while read -r l; do ...; done` keeps variables (last pipeline stage runs in the current shell).
- Script files with a `#!/usr/bin/env bash` shebang are bash: write those as bash and run them with `bash file`.

## Destructive commands (rm, mv, cp, sed -i, kubectl delete, apply)

- Null-glob every pattern, guard path variables with `${dir:?}`, put `--` before paths, and quote expansions anyway so the line stays correct if pasted into bash.
- Dry-run first: `print -rl -- **/*.tmp(#qN)` before `rm`; `zmv -n` before `zmv`; sed without `-i` before with.
- Huge match lists can exceed ARG_MAX: `autoload -U zargs; zargs -- **/*.tmp(#qN) -- rm --`.
