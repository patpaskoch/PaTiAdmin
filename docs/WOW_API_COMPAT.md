# WoW API compatibility — WoW Forever, Interface 16001

The suite targets **one** client: WoW Forever build 1.60.1.70009, Interface 16001. It has a modern engine
(C_* namespaces, BackdropTemplate) with classic-era game rules — so neither Retail nor Classic Era
documentation is automatically right. Record every verified fact here; unverified assumptions must say so.

Status legend: **verified** (observed in this client, with date) · **in use** (shipped code relies on it, no
explicit test recorded) · **assumed** (not yet used/tested).

## Facts

| API / behaviour | Status | Notes |
|---|---|---|
| `SetRaidTarget` from addon Lua | verified protected (before 2026-09-28) | PaTiGroup uses `SecureActionButtonTemplate` `type=raidtarget` and a `/tm` macro instead |
| `SecureUnitButtonTemplate` with `[mod-]type<n>=spell`, `[mod-]spell<n>` | in use (PaTiHeal) | set only out of combat |
| `SecureActionButtonTemplate` `type=raidtarget`, `type=macro` | in use (PaTiGroup) | |
| `CreateMacro`, `EditMacro`, `GetMacroIndexByName`, `GetMacroInfo` | in use (PaTiGroup) | needs a free character macro slot |
| `SetBindingClick`, `GetBindingAction`, `SaveBindings(GetCurrentBindingSet())` | in use (PaTiGroup) | only sets Ctrl+Left click if it is unbound |
| `DoReadyCheck`, `C_PartyInfo.DoCountdown` | in use (PaTiGroup) | leader/assistant only, `pcall` |
| `C_SpellBook.IsSpellKnown`, `C_Spell.GetSpellInfo` | in use (PaTiHeal) | `pcall`/existence-guarded; fallback `GetSpellInfo` |
| `C_Spell.GetSpellTexture` | assumed (PaTiHeal dropdown icons) | fallback `GetSpellTexture`; missing icon only hides the icon |
| `RegisterUnitWatch` / `UnregisterUnitWatch` on `SecureUnitButtonTemplate` rows | assumed (PaTiHeal) | fallback: Show/Hide out of combat only |
| Unassigned modifier click (e.g. Shift+Left with only Left bound) falls back to the plain `type1` binding or does nothing | **unknown** (PaTiHeal, same in 0.6.0) | test: bind only Left, Shift+Left-click a row |
| `C_AddOns.GetAddOnMetadata` | assumed (PaTiHeal debug) | fallback `GetAddOnMetadata` |
| `UnitDetailedThreatSituation` | in use (PaTiTank) | 3rd return = threat percent |
| `C_QuestLog.GetSelectedQuest`, `GetTitleForQuestID`, `GetQuestObjectives` | in use (PaTiQuest) | all `pcall`-guarded |
| `GetInstanceInfo`, `IsInInstance`, `GetNumGroupMembers`, `UnitIsGroupLeader` | in use (PaTiDungeon) | |
| `UnitGroupRolesAssigned` | in use (PaTiHeal) | may return NONE without LFG roles |
| `BackdropTemplate` | in use (all) | |
| `GLOBAL_MOUSE_DOWN` event | assumed (PaTiShared popup, `pcall`-registered) | popup still closes by click/ESC without it |
| `Texture:SetRotation` | assumed (PaTiShared line icons) | verify × and ▾ render |
| `FontString:GetUnboundedStringWidth` | assumed, fallback `GetStringWidth` | |
| XML `<Script file>` inside an addon passes `(addonName, ns)` | assumed (PaTiShared `Shared.xml`) | verify when the first addon embeds PaTiShared |
| CJK glyphs via Blizzard font objects on a deDE client | assumed | manual font test |

## Rules that hold regardless of client

- Protected functions and secure attributes: never during `InCombatLockdown()`.
- Secret values: hand to widgets only; no arithmetic/comparison/string operations.
- No automation: one hardware click → one explicit action chosen earlier by the player.
- Aura APIs: use `C_UnitAuras` only if present, else `UnitAura`; check availability first (not used yet).
- Addon communication (`C_ChatInfo.SendAddonMessage`, prefix registration): not used yet; verify limits in this client before designing a protocol.

## How to verify something

In game: `/run print(C_X and C_X.Fn and "yes" or "no")`, or `/dump C_X.Fn(...)`. Record result + date + build in the table.
