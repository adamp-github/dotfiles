# Dotfiles for the two Omarchy machines.

Managed with [chezmoi](https://www.chezmoi.io/).

## Profiles

The desktop and the laptop share almost everything; the differences are data,
not structure. Each machine's profile is chosen from its hostname in
`.chezmoi.toml.tmpl` and recorded in `~/.config/chezmoi/chezmoi.toml` (machine
state, not tracked). Every per-machine fact lives in `.chezmoidata/profiles.yaml`:

| profile | hostname | notes |
| --- | --- | --- |
| `personal-desktop` | `5800x` | 24" screen, `GDK_SCALE=1`, Plex, no bar power widget |
| `personal-laptop` | `dl7390` | 14" screen, `GDK_SCALE=2`, no Plex, bar power/battery widget |

Unknown hosts fall back to `personal-laptop` (it installs the least). To
override, run `chezmoi edit-config` and change `profile`.

## Layout

- `.chezmoi.toml.tmpl` - picks the profile from `.chezmoi.hostname`, at `chezmoi init` time only.
- `.chezmoidata/profiles.yaml` - all per-machine values (git identity, scale, package flags, bar widgets).
- `.chezmoiignore` - keeps Linux-only files off non-Linux machines; keeps the README out of `$HOME`.
- `.chezmoiscripts/run_onchange_install-packages.sh.tmpl` - package list; profile-gated blocks.
- `dot_config/git/config.tmpl` - git identity and credential helper from the profile.
- `dot_config/git/hooks/` - global SAST hooks, wired up by `core.hooksPath`.
- `dot_config/hypr/monitors.lua.tmpl` - uses the profile's GDK scale.
- `dot_config/omarchy/shell.json.tmpl` - bar layout, power widget only on the laptop.

## Editing

Files ending in `.tmpl` are templates. Edit the source, not the target:

```sh
chezmoi edit ~/.config/git/config   # opens the template
chezmoi apply
```

`chezmoi re-add` deliberately skips templates, so runtime edits to these files
are lost on the next apply. Never `chezmoi add --force` a templated file - that
replaces the template with its rendered output.

## New machine

```sh
chezmoi init --apply adamp-github/dotfiles
```

then run the package script if needed (`chezmoi apply` runs it when its content
changes) and `sudo tailscale up`.
