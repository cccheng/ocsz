# ocsz

A light-weight terminal browser for [opencode](https://opencode.ai) sessions, built with [`fzf`](https://github.com/junegunn/fzf).

Browse your past opencode sessions in an interactive picker, fuzzy-search them, and resume the one you want — without leaving the terminal.

```
just now   Add dark mode toggle                              ~/projects/webapp
3m ago     ◦ Locate theme provider (@explorer subagent)      ~/projects/webapp
14m ago    ◦ Compare cache libraries (@librarian subagent)   ~/projects/webapp
52m ago    Write API migration plan                          ~/projects/api
1h ago     ◦ Review auth refactor risk (@oracle subagent)    ~/projects/api
2h ago     Refactor login flow                               ~/projects/api
2h ago     ◦ Rename getUser across repo (@fixer subagent)    ~/projects/api
6h ago     Set up CI pipeline                                ~/projects/infra
6h ago     ◦ Polish settings page (@designer subagent)       ~/projects/infra
1d ago     Draft release notes v2.1                          ~/notes
4d ago     Investigate memory leak                           ~/projects/daemon
4d ago     ◦ Research backpressure (@librarian subagent)     ~/projects/daemon
```

## Features

- **Browse & search** — sessions listed newest-first, fuzzy-filtered as you type.
- **Resume in place** — `Enter` reopens the session in opencode, in its own project directory.
- **More actions** — fork-and-resume, start a new session, continue the last session, delete, and copy the resume command to the clipboard.
- **Live preview** — title, id, directory, and created/updated times for the highlighted session.
- **Subagent sessions hidden by default** — child/subagent sessions are filtered out; toggle them with a hotkey and they show up clearly marked.
- **Aligned, colored list** — columns line up even with full-width CJK titles; colors follow the terminal/fzf palette and honor `NO_COLOR`.
- **Format-agnostic** — reads everything through the `opencode` CLI, so it keeps working regardless of how opencode stores sessions internally (SQLite, etc.).

## Requirements

- [`opencode`](https://opencode.ai) (developed against 1.17.9)
- [`fzf`](https://github.com/junegunn/fzf) 0.38+ (uses `become`/`reload`; tested on 0.73)
- GNU coreutils (`date`, `wc`, `base64`) — standard on Linux

Optional:

- A clipboard tool (`wl-copy`, `xclip`, `xsel`, or `pbcopy`). Without one, the copy action falls back to an [OSC 52](https://en.wikipedia.org/wiki/ANSI_escape_code#OSC_(Operating_System_Command)_sequences) escape and also prints the command to stdout.

`jq` and `glow` are **not** required.

## Installation

```sh
make install      # copies ocsz to ~/.local/bin/ocsz
```

Make sure `~/.local/bin` is on your `PATH`. To remove it:

```sh
make uninstall
```

You can also just run the script directly:

```sh
./ocsz
```

## Usage

Run `ocsz` with no arguments to open the picker. Type to fuzzy-search, then use the keys below.

Pass extra opencode args after `--`, for example `ocsz -- --port 4096`; they apply to resume, fork-and-resume, new, and continue-last launches.

| Key            | Action                                            |
| -------------- | ------------------------------------------------- |
| `Enter`        | Resume the selected session                       |
| `Ctrl-F`       | Fork the selected session, then resume            |
| `Alt-N`        | Start a new session (in the current directory)    |
| `Alt-L`        | Continue the last session                         |
| `Alt-S`        | Show / hide subagent (child) sessions             |
| `Ctrl-X`       | Delete the selected session (with confirm), then refresh |
| `Ctrl-Y`       | Copy the session id + resume command to clipboard |
| `?`            | Toggle the preview pane                           |
| `Esc` / `Ctrl-C` | Quit                                            |

### Subagent sessions

Sessions spawned by subagents (the opencode task tool) have a parent session, and are **hidden by default** so the list stays focused on the sessions you actually started. Press `Alt-S` to toggle them on/off. When shown, each subagent row is prefixed with `◦` and dimmed, so it is easy to tell apart at a glance (the marker remains visible even with `NO_COLOR`).

## Colors

The list uses the terminal's 16-color palette so it blends with your theme:

- relative time — dimmed (bright-black)
- title — default foreground (so fzf's match highlighting stands out)
- directory — cyan

Disable all color with either environment variable:

```sh
NO_COLOR=1 ocsz
OCSZ_NO_COLOR=1 ocsz
```

## How it works

`ocsz` does not parse opencode's storage files directly. Instead it drives the `opencode` CLI:

- list sessions: `opencode db --format tsv "SELECT ... FROM session ..."`
- resume: `opencode [extra...] <dir> -s <id>`
- fork and resume: `opencode [extra...] <dir> --fork -s <id>`
- continue last: `opencode [extra...] -c`
- delete: `opencode session delete <id>`

This keeps the tool independent of opencode's on-disk format.

## Customization

A few knobs live at the top of the `ocsz` script:

- `TIME_WIDTH`, `TITLE_WIDTH` — column widths.
- `SUB_MARKER` — the subagent marker glyph (default `◦ `). If you change it to a non-ASCII glyph, update the width-1 exception in `char_width()` to match its codepoint.
- `C_TIME`, `C_DIM`, `C_DIR` — ANSI color codes for the columns.

## Environment variables

| Variable            | Effect                                                          |
| ------------------- | -------------------------------------------------------------- |
| `NO_COLOR`          | Disable all color (standard convention).                       |
| `OCSZ_NO_COLOR`     | Disable all color (tool-specific opt-out).                     |
| `OCSZ_DRY_RUN=1`    | Make actions print the `opencode` command instead of running it (useful for testing). |
| `OCSZ_OPENCODE_ARGS` | Extra args passed to every `opencode` launch (resume/fork/new/last), e.g. `--port 4096`. A CLI `--` passthrough overrides this. Args are whitespace-split, so values containing spaces are not supported. |

## Prior art

`ocsz` was inspired by these similar opencode session tools:

- [bashtools/oc_session](https://github.com/bashtools/oc_session) - lists opencode sessions as a Markdown table.
- [Shane0xM/oc-session](https://github.com/Shane0xM/oc-session) - a session browser with fuzzy search and resume.
- [mclarkson/ocs](https://github.com/mclarkson/ocs) - an interactive TUI session browser.

## License

[MIT](LICENSE)
