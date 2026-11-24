# Dev stats for Aequalyn

Your GitHub and GitLab contributions: the last days as squares on the bar, and the year,
the totals and the streaks in the panel that opens from them.

It uses the logins the `gh` and `glab` commands already have (`gh auth login`,
`glab auth login`), and never reads, prints or forwards a token.

## On the bar

Installing puts it on the right of the bar; move it in the control center, under Bar.

| | |
| --- | --- |
| Left click | the panel |
| Right click | its settings |
| Middle click | fetch again |
| Esc | close |
| Page Up, Page Down | the pages |
| R | fetch again |

**Pop out** makes the panel a window, **Dock** puts it back. It looks as the
control center does, in your theme; the squares can have a colour of their own (Look). It
fetches every 30 minutes; Panel and data changes that.

From a key or a script: `qs ipc call dev-stats toggle` (or `open`, `close`, `settings`,
`refresh`).

More accounts: `~/.local/state/aequalyn-dev-stats/accounts.json`, a list of
`{"provider": "github", "host": "github.com", "user": "you"}`.

## What it runs

`bin/dev-stats.sh`, which calls `gh`, `glab` and `jq`.

Ported from [omarchy-dev-stats](https://github.com/qempexe/omarchy-dev-stats). MIT.
