# Localization

## Rules

- **Source language: English (enUS)** — every key exists there. It is also the fallback.
- Locales: `enUS`, `deDE`, `zhCN`, `zhTW`, `koKR`. `enGB` and every other client locale use enUS.
- Players can override the client language per addon in Settings → Language (`DB.language`, default `"auto"`).
- No visible UI text in feature code. Chat output, tooltips, menu entries, labels — all through keys.
  Not translated: addon names, slash commands, debug dumps meant for bug reports.
- An unsure translation is **left out**, not guessed: the English fallback is better than a wrong word.
- Missing keys never break the addon: lookup order current language → enUS → the key itself.

## File format

```
<Addon>/Locales/enUS.lua   (source)     <Addon>/Locales/deDE.lua   zhCN.lua   zhTW.lua   koKR.lua
```
```lua
-- <Addon> strings, Deutsch. One key per line.
local _, ns = ...
ns.Locales = ns.Locales or {}
local L = ns.Locales.deDE or {}
ns.Locales.deDE = L

L.CLICK_CASTING = "Klickzauber"
L.LEFT_CLICK = "Linksklick"
```
- Keys: `UPPER_SNAKE_CASE`, describe meaning not wording (`OPEN_SETTINGS_TIP`, not `CLICK_HERE_TEXT`).
- One `L.KEY = "..."` per line (the validator reads lines). Format strings use `%s`/`%d` with the same order in all locales.
- List the locale files in the TOC **after** `Shared\Shared.xml` and **before** the addon code.
- PaTiShared ships its own keys (`SETTINGS`, `CLOSE`, …) in the same tables. Addon keys must not reuse them (the validator reports duplicates).
- Lookup: with PaTiShared embedded use `ns.UI.L.KEY` / `UI.BindText(fontString, "KEY")` (relabels on language change).
  An addon without PaTiShared needs the same 5-line lookup (`ns.Locales[lang][key] or ns.Locales.enUS[key] or key`) — do not invent another.

## Validation (`tools/check.sh` → locales)

Errors: missing enUS, unknown locale file name, duplicate key (also across `Shared/Locales` and `Locales`),
key not present in enUS, file does not load, non-string value. Warning: untranslated keys per locale.

## Status (2026-09-28)

| Scope | enUS | deDE | zhCN | zhTW | koKR |
|---|---|---|---|---|---|
| PaTiShared (15 keys) | ✓ | ✓ | ✓ unreviewed | – (fallback) | ✓ unreviewed |
| Addons | hard-coded German text, no Locales/ yet — migrate per addon when its UI is touched (FOLLOW_UPS.md) |

zhCN/koKR shared strings were written by an AI agent and need a native-speaker check. Rendering of
Chinese/Korean on the deDE client is unverified (manual test).
