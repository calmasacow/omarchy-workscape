# Personal WorkScape fork

Based on [calebhat/omarchy-workscape](https://github.com/calebhat/omarchy-workscape), version 1.12.0. The original plugin ID and author attribution are preserved.

## Changes

- Selecting a profile saves it, then applies its displays and workspace assignments. Pending selections wait for ongoing saves and applies to finish.
- Normal profile selection and the panel's **Apply selected** button use `--switch-profile [id]`, which moves existing workspaces without launching saved apps. **Fresh** remains an explicit app relaunch operation. The original `--apply-profile` and `--apply-matching` CLI commands retain their launch behavior.
- The panel and background service no longer automatically change the selected profile when displays change. Stale live-status responses cannot overwrite a newer selection. Optional apply at login remains controlled by the existing setting.
- A selected compatible profile takes priority over other matching profiles, including duplicates with newer claim timestamps.
- Disabled monitors may be disconnected without making a profile invalid. Connected disabled monitors still belong to the profile, and workspace pins to disabled monitors are skipped.
- Monitor enable/disable operations use Hyprland's Lua `hl.monitor` API.

## Install

```sh
omarchy plugin add https://github.com/calmasacow/omarchy-workscape.git --enable
```

This retains the upstream plugin ID, so it replaces the source of the existing WorkScape installation rather than adding a second WorkScape instance. Back up saved profiles before replacing an existing installation. Profiles remain in `~/.local/state/omarchy/workscape/config.json`.

## Optional workspace-number widget

`companions/workspaces/` contains the local `calmasacow.workspaces` clone of Omarchy's workspace bar widget, with its original author attribution and `clonedFrom` metadata.

It reads the selected WorkScape profile and shows only workspace numbers assigned to the bar's display, including empty workspaces. It skips assignments to disabled monitors. Without a saved profile mapping, it uses Hyprland's live workspace assignments. The widget covers workspaces 1–10 and uses the stock display of `0` for workspace 10.

For a new installation, copy this directory into `~/.config/omarchy/plugins/calmasacow.workspaces`, then enable it with `omarchy plugin enable calmasacow.workspaces`. Disable the stock `omarchy.workspaces` widget if it is also enabled. An existing local clone can be backed up and replaced with these files.

The companion is stored here for backup; updating WorkScape does not automatically update a separately installed companion widget.

## Local configuration

Personal profiles, monitor identities, saved app assignments, and Hyprland monitor configuration are not committed. Mirror resolution and refresh-rate settings remain in the machine's Hyprland monitor configuration.

## Validation

```sh
PYTHONDONTWRITEBYTECODE=1 bash test/run
omarchy plugin validate .
omarchy plugin validate companions/workspaces
```

The default test suite uses isolated fixtures and does not launch windows or modify saved user profiles.
