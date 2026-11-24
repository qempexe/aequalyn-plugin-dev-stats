# Dev stats for Aequalyn

Your GitHub and GitLab contributions over the desktop: the year as a grid, the total, the
current and the longest streak.

It uses the logins the `gh` and `glab` commands already have (`gh auth login`,
`glab auth login`), and never reads, prints or forwards a token. Nothing runs while it is
closed.

## Open it

`qs ipc call dev-stats toggle`, or a key in `~/.config/hypr/keybinds.lua`:

```lua
hl.bind(M .. " + ALT + G", hl.dsp.exec_cmd("qs ipc call dev-stats toggle"))
```

| Key | |
| --- | --- |
| Arrows | move over the days |
| Page Up, Page Down | earlier and later year |
| Tab | next account |
| R | fetch again |
| Esc | close |

More accounts: `~/.local/state/aequalyn-dev-stats/accounts.json`, a list of
`{"provider": "github", "host": "github.com", "user": "you"}`.

## What it runs

`bin/dev-stats.sh`, which calls `gh`, `glab` and `jq`.

Ported from [omarchy-dev-stats](https://github.com/qempexe/omarchy-dev-stats). MIT.
