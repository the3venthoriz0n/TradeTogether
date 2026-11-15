# TradeTogether v0.12.0-strpm

STR Plugin Messaging edition of TradeTogether for Skyrim Together Reborn.

## Requirements

- Skyrim Special Edition / Anniversary Edition, including **1.7.104.0**
- SKSE 2.3.x for Skyrim 1.7.x, with Address Library for SKSE Plugins (format 5)
- Skyrim Together Reborn
- STR Plugin Messaging API with Proxy Resolver support
- The same TradeTogether build on every player
- SkyUI for the optional MCM

TradeTogether itself opens no UDP socket and requires no TradeTogether-specific port forwarding.

## Trade flow

1. Both players connect through Skyrim Together Reborn.
2. Target the other player's character and press the configured **Trade / Validate** key (default: T).
3. The target receives an **Accept / Decline** MessageBox.
4. Both players compose their offer in their personal inventory.
5. Add or remove items and gold using the configured controls.
6. Press **Trade / Validate** to review the offers.
7. Both players receive the Ready / Modify and final Confirm / Modify prompts.
8. After both confirmations, TradeTogether performs the automatic native transfer.

Quest items are rejected. Item-only, gold-only, mixed item/gold trades and one-way gifts are supported.

## v0.12.0 — Skyrim 1.7.104 support

v0.12.0 rebuilds the plugin against alandtse's maintained CommonLibSSE-NG (v15.7.3, vendored as a submodule in `lib/commonlibsse-ng`). It declares Address Library format 5 and version independence, which SKSE 2.3.x requires on Skyrim 1.7.99 and later. Gameplay and controls are unchanged from v0.11.0.

Skyrim Together Reborn and the STR Plugin Messaging API must also support your game version.

CommonLibSSE-NG is GPL-3.0-or-later, so this plugin is distributed under the GPL as well.

## v0.11.0 — configurable controls and SkyUI MCM

v0.11.0 moves all TradeTogether controls out of hard-coded input constants.

The following actions are configurable:

- Trade / Validate
- Add selected item
- Remove selected item
- Add gold
- Remove gold
- Cancel trade

Defaults remain:

```text
Trade / Validate     T
Add selected item    Insert
Remove selected item Delete
Add gold             Numpad +
Remove gold          Numpad -
Cancel trade         Tab
```

Users without a numpad can map **Add Gold** and **Remove Gold** to normal keyboard keys.

The current Shift/Ctrl amount modifiers are preserved:

```text
Shift + Gold key = x10
Ctrl + Gold key  = x100
```

### INI storage

Bindings are persisted in:

```text
Data\SKSE\Plugins\TradeTogether.ini
```

```ini
[Controls]
TradeKey=20
AddItemKey=210
RemoveItemKey=211
GoldAddKey=78
GoldRemoveKey=74
CancelKey=15
```

The values are DirectInput / SkyUI keymap scan codes.

### Runtime MCM bridge

The SKSE plugin exports a small Papyrus API through `TradeTogetherNative`.

When a key is changed in the MCM:

1. the new scan code is written to `TradeTogether.ini`;
2. `InputEventSink` reloads the bindings immediately;
3. no Skyrim restart or save reload is required.

A **Reset all key bindings** MCM action restores the original defaults.

MCM Helper is not required. The menu uses SkyUI's normal `SKI_ConfigBase` API.

Papyrus sources:

```text
Source\Scripts\TradeTogetherNative.psc
Source\Scripts\TradeTogetherMCM.psc
```

Build/setup documentation:

```text
docs\MCM_SETUP.md
```

## Numpad compatibility

The historical numpad + / - bindings need a special Win32 input path because SkyUI's InventoryMenu does not consistently expose those keys as normal `ButtonEvent`s.

v0.11.0 keeps that proven fallback only when the gold actions are still mapped to their default numpad keys.

If the user selects any other key in the MCM, TradeTogether uses the normal Skyrim/SKSE keyboard event stream instead.

## Connected-player target validation

TradeTogether uses STRPM's Proxy Resolver to map connected STR `ConnectionID`s to local Skyrim proxy FormIDs. Normal NPCs are rejected, while real STR proxies are sent through `TargetKind::kPlayer`.

## Deferred STRPM receive path

Incoming STRPM callbacks only copy messages into a preallocated queue. Parsing, logging and gameplay work happen afterwards outside the transport callback.

## Skyrim Souls RE compatible MessageBoxes

TradeTogether preserves native `MessageBoxData` defaults and does not force `MessageBoxMenu` pause flags.

With Skyrim Souls RE, this configuration remains supported:

```ini
[UNPAUSED_MENUS]
bMessageBoxMenu = true
```

TradeTogether hotkeys are suspended while `MessageBoxMenu` is open so an input intended for an unpaused MessageBox cannot also trigger a trade action in the background.

The complete v0.10.0 trade flow was validated with Skyrim Souls RE and unpaused MessageBoxes.

## Native instance-aware transfer

TradeTogether uses Skyrim's native inventory transfer path and supplies the selected stack's `ExtraDataList` when available. This is intended to preserve tempering, enchantments, charge, custom names and other per-instance data. Gold uses Skyrim's native Gold form.

## STR Plugin Messaging transport

Channel:

```text
tradetogether.offer.v1
```

Messages use reliable + ordered delivery.

## Diagnostics

Log:

```text
Documents/My Games/Skyrim Special Edition/SKSE/TradeTogether.log
```

Expected v0.12.0 startup entries include:

```text
TradeTogether v0.12.0-strpm loading
TradeTogether Papyrus MCM bridge registered
TradeTogether controls loaded: trade=... add=... remove=... goldAdd=... goldRemove=... cancel=...
TradeTogether STRPM deferred receive dispatcher started
TradeTogether v0.12.0-strpm ready ... network=ready
```

Changing a key through the MCM should log:

```text
MCM key mapping updated: action=GoldAdd key=0x...
TradeTogether controls loaded: ...
```

## Current status

`v0.11.0-strpm` includes the configurable-control system, native Papyrus bridge and SkyUI MCM. The C++ plugin and both Papyrus scripts compile successfully, the lightweight `TradeTogetherMCM.esp` is packaged, and the v0.11.0 archive is generated successfully.

The existing v0.10.0 STR trade flow and Skyrim Souls RE compatibility remain the validated gameplay baseline carried forward by this release.

## License

TradeTogether is free software under the **GNU General Public License, version 3 or (at your option) any later version (GPL-3.0-or-later)**. It statically links [CommonLibSSE-NG](https://github.com/alandtse/CommonLibSSE-NG), which is GPL-3.0-or-later (with a Modding Exception for Skyrim and SKSE), so the whole plugin is distributed under the GPL. The complete, unmodified licence text is in [`COPYING`](COPYING). Copyright the3venthoriz0n and the contributors named in [CREDITS.md](CREDITS.md). There is NO WARRANTY, to the extent permitted by law.

The licences of the libraries built in are reproduced in [`THIRD_PARTY_NOTICES.txt`](THIRD_PARTY_NOTICES.txt) (generated by `python -I tools/make_notices.py`).

TradeTogether was started by Caelvanost (https://github.com/Caelvanost/TradeTogether); see CREDITS.md. The upstream repository does not publish a licence file.

## Credits

Everybody whose work this mod uses, links or requires (CommonLibSSE-NG and its authors, SKSE, Address Library, SkyUI, MCM Helper, the libraries, Bethesda Game Studios, and the AI assistance) is listed in [CREDITS.md](CREDITS.md). It is also in the download as `Data/Docs/TradeTogether/CREDITS.txt`.

## Source code

- GitHub: https://github.com/the3venthoriz0n/TradeTogether (clone with `git clone --recurse-submodules`).
- Every GitHub release has a source archive attached next to the mod zip: `TradeTogether_<version>_source.zip`. It holds the repository at the release commit plus the pinned sources of the submodules (CommonLibSSE-NG). To make one yourself: `powershell -File tools\make_source_archive.ps1`.
- The mod download itself contains `Data/Docs/TradeTogether/` with `COPYING.txt` (the GPL), `CREDITS.txt`, `THIRD_PARTY_NOTICES.txt` and `SOURCE.txt` (where the source is).
- The build also downloads the vcpkg libraries listed in `vcpkg.json` (pinned by `vcpkg-configuration.json`) and the MinHook v1.3.4 decoder (CMake FetchContent).

## Build

Clone with submodules (`git clone --recurse-submodules`), install vcpkg to `C:\dev\vcpkg` (or set `VCPKG_ROOT`), then build the C++ plugin:

```powershell
.\build_release.bat
```

MCM scripts:

```powershell
set "SKYUI_SOURCE=C:\path\to\SkyUI\scripts\source"
.\build_mcm.bat
```

Expected archive name:

```text
dist/TradeTogether-0.12.0.zip
```

Packaging never overwrites or deletes an earlier build: if the zip name is already in `dist`, the new one gets a `_yyyyMMdd-HHmmss` suffix (for example `TradeTogether-0.12.0_20261114-160500.zip`), so versions sit side by side for rollback; the script prints the final path.

## Releasing

**To release, tag `main`.** The tag is the version, you never edit version numbers by hand for a release.

1. **Make sure `main` is what you want to ship** (the tag may only be pushed on a commit that is already on `main`, or the run stops before building anything).
2. **Pick the next version** (`vMAJOR.MINOR.PATCH`): patch for fixes, minor for new features.
3. **Tag and push:**

        git checkout main && git pull
        git tag v0.12.1
        git push origin v0.12.1

4. **Watch it:** `gh run watch` (or the Actions tab). The first run on a fresh cache takes a while; later runs reuse the cached build dependencies.
5. **Check the result:** the run is green and the GitHub release has:

- `TradeTogether_<version>.zip`

**What the workflow does** (`.github/workflows/release.yml`, run on a Windows runner): checks the tag looks like `v1.2.3` and its commit is on `main`; stamps the version into `CMakeLists.txt`, `vcpkg.json`, `src/main.cpp` (two strings), `tools/make_vortex_archive.ps1`, `make_vortex_archive.bat`, `build_release.bat` and `package/Data/SKSE/Plugins/TradeTogether.ini` (the internal marker is `<version>-strpm`, checked in the DLL by `tools/verify_release_dll.ps1`) (it stops if any of them does not match exactly once); builds; packages with the repo's script; uploads the zip(s) as a build artifact and creates the GitHub release. No Nexus upload and no version-bump commit are done: this repo has no Nexus page, so the numbers in the repo files stay as they are and only the tagged build carries the new version. The archive contains the committed `TradeTogetherMCM.esp` and compiled scripts from `package/Data`; the workflow does not rebuild the MCM (`build_mcm.bat` needs SkyUI sources), so rebuild and commit them first when the MCM changed.

**Test builds, one tag per change.** A tag with a suffix, such as `v0.12.1-test1`, builds the same way and creates a GitHub *pre-release* with the zip named `TradeTogether_0.12.1-test1.zip`. Use one for every change you want kept as a build, and a plain `vX.Y.Z` tag for what you publish. The numeric part of the tag is what gets stamped into the build.

**Dry run, no release:** Actions tab, "Release", "Run workflow" on `main`. It builds and packages and uploads the zip as a build artifact; it does not create a release.

**If something goes wrong.** *"Tag ... is not on main" or "must look like v1.2.3":* delete the tag (`git push origin :refs/tags/vX.Y.Z` and `git tag -d vX.Y.Z`), fix, tag again. *The build fails on the runner:* use the dry run after each fix instead of pushing more tags. *A zip you package locally has the old version:* normal; only the workflow stamps the tag version.

