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
| `SecureUnitButtonTemplate` with `[mod-]type<n>=spell`, `[mod-]spell<n>` | **verified 2026-09-28** (owner: Left and Shift+Right cast the chosen spell) | other combinations still to test |
| `SecureActionButtonTemplate` `type=raidtarget`, `action=set` | in use (PaTiGroup <= 0.4) | |
| `type=raidtarget` with `marker=0` clears the target's marker | assumed (PaTiGroup Clear) | test Clear button + binding |
| `type=macro` with `macrotext` running `/tm` lines | assumed (PaTiGroup Reset All, replaces the character macro) | test Reset All |
| Bindings.xml `CLICK <Button>:LeftButton` + `BINDING_NAME_CLICK ...` names | assumed (PaTiGroup) | check the key binding menu |
| `RAID_TARGET_1..8` global marker names | assumed (PaTiGroup) | fallback: own L.MARKER_n |
| `DoReadyCheck`, `C_PartyInfo.DoCountdown` | in use (PaTiGroup) | leader/assistant only, `pcall` |
| `C_SpellBook.IsSpellKnown`, `C_Spell.GetSpellInfo` | in use (PaTiHeal) | `pcall`/existence-guarded; fallback `GetSpellInfo` |
| Spellbook scan: `C_SpellBook.GetSpellBookItemInfo` (modern) or `GetSpellBookItemName/Info` (classic) | assumed (PaTiHeal ranks) | pcall-guarded; no ranks shown if neither works |
| Casting a rank via spell attribute "Name(Rank n)" with the client's localized rank text | assumed (PaTiHeal ranks) | classic behaviour; test by choosing a low rank |
| `C_UnitAuras.GetAuraDataByIndex` / `UnitAura` with filter `HARMFUL|RAID` (= dispellable by you) | assumed (PaTiHeal dispel icons) | secret values skipped |
| `RAID_CLASS_COLORS[classFile]` for name colours | assumed (PaTiHeal) | falls back to the normal text colour |
| Greater Heal spell ID (rank 1) | **unknown** — not in PaTiHeal's list until confirmed | `/run print(C_Spell.GetSpellInfo(2060).name, C_Spell.GetSpellInfo(2061).name)` and look up Greater Heal |
| `C_Spell.GetSpellTexture` | assumed (PaTiHeal dropdown icons) | fallback `GetSpellTexture`; missing icon only hides the icon |
| `RegisterUnitWatch` / `UnregisterUnitWatch` on `SecureUnitButtonTemplate` rows | assumed (PaTiHeal) | fallback: Show/Hide out of combat only |
| Unassigned modifier click (e.g. Shift+Left with only Left bound) falls back to the plain `type1` binding or does nothing | **unknown** (PaTiHeal, same in 0.6.0) | test: bind only Left, Shift+Left-click a row |
| `C_AddOns.GetAddOnMetadata` | assumed (PaTiHeal debug) | fallback `GetAddOnMetadata` |
| Priest spell IDs 588, 1243, 21562, 14752, 27681, 976, 27683 (`C_Spell.GetSpellInfo`) | **verified 2026-09-28** (owner, deDE client) | PaTiAuras Priest profile |
| `C_UnitAuras.GetAuraDataByIndex` present, `issecretvalue` present | **verified 2026-09-28** (owner: `/pa debug`) | aura data values themselves not yet observed |
| Shaman spell IDs 24398, 974, 61295, 53390 | assumed | `/pa auras` as Shaman |
| `SecureActionButtonTemplate` `type1=spell` + `unit` casts on that unit without changing the target | assumed (PaTiAuras click-to-buff) | same mechanism as PaTiHeal's verified unit clicks |
| `UnitIsVisible(unit)` | assumed (PaTiAuras: members out of sight are no click target) | missing API → everyone counts as reachable |
| Secure attributes cannot change in combat, so a buff button cannot move to the next member mid-combat | rule of the secure system | PaTiAuras keeps the pre-combat target |
| Heal profile IDs: Shaman 974 Earth Shield, 61295 Riptide, dispels 526, 2870, 51886; Priest 139 Renew, 17 Power Word: Shield, 33076 Prayer of Mending, dispels 527, 528, 552 | assumed (PaTiHeal, PaTiAuras healing) | unknown IDs only hide their entry; confirm with `/ph auras` and `/pa auras` |
| Aura filter `HELPFUL|PLAYER` returns only auras you cast | assumed (PaTiHeal HoTs) | readable foreign `sourceUnit` is skipped as a second guard |
| Dispel spells cast via the `spell` click attribute on the clicked unit (click dispel) | assumed (PaTiHeal) | same mechanism as the verified click heals |
| Key binding menu path "ESC > Key Bindings (Tastaturbelegung) > PaTiGroup" | **unknown** (PaTiGroup settings note) | settings also name "ESC > Options > Key Bindings"; owner: report the real path |
| `## Notes-deDE` in the TOC shown on a German client | assumed (all addons) | fallback is the English `## Notes` |
| `UnitDetailedThreatSituation` | in use (PaTiTank) | 3rd return = threat percent; secret values only reach the bar |
| `UNIT_MAXHEALTH` event | assumed (PaTiTank) | added to keep the health bar maximum current |
| `UnitThreatSituation(unit, enemy)` returns 0-3/nil per enemy | assumed (PaTiTank aggro) | pcall + secret check; missing/secret → UNKNOWN; `/pt debug` shows presence |
| Nameplate unit tokens `nameplateN` + `NAME_PLATE_UNIT_ADDED/REMOVED` | assumed (PaTiTank aggro) | pcall-registered; without them only target and party targets count |
| `partyNtarget` tokens and `UNIT_TARGET` | assumed (PaTiTank aggro) | enemies nobody targets and without a nameplate stay invisible |
| `UnitCanAttack`, `UnitIsDead`, `UnitGUID` | assumed (PaTiTank aggro) | GUID used only for de-duplication, secret → skipped; missing APIs → no enemies |
| Which of these threat/unit values are secret in combat | **unknown** | PaTiTank shows "unclear" rows then |
| Yes/no API flags (`IsInInstance`, `UnitAffectingCombat`, `UnitIsGroupLeader` …) return true/false or 1/nil | **unknown which** | PaTiDungeon/PaTiGroup accept both |
| `C_QuestLog.GetSelectedQuest`, `GetTitleForQuestID`, `GetQuestObjectives` | in use (PaTiQuest) | all `pcall`-guarded |
| `GetInstanceInfo`, `IsInInstance`, `GetNumGroupMembers`, `UnitIsGroupLeader` | in use (PaTiDungeon) | |
| `UnitGroupRolesAssigned` | in use (PaTiHeal, PaTiGroup) | may return NONE without LFG roles; checked for secret values first |
| `issecretvalue` | assumed present only in clients with restricted values | code treats a missing function as "nothing is secret" |
| `BackdropTemplate` | in use (all) | |
| `GLOBAL_MOUSE_DOWN` event | assumed (PaTiShared popup, `pcall`-registered) | popup still closes by click/ESC without it |
| `Texture:SetRotation` | assumed (PaTiShared line icons) | verify × and ▾ render |
| `FontString:GetUnboundedStringWidth` | assumed, fallback `GetStringWidth` | |
| XML `<Script file>` inside an addon passes `(addonName, ns)` | **verified 2026-09-28** (PaTiHeal with embedded PaTiShared loaded without Lua errors) | |
| CJK glyphs via Blizzard font objects on a deDE client | assumed | manual font test |

## Rules that hold regardless of client

- Protected functions and secure attributes: never during `InCombatLockdown()`.
- Secret values: hand to widgets only; no arithmetic/comparison/string operations.
- No automation: one hardware click → one explicit action chosen earlier by the player.
- Aura APIs: `C_UnitAuras.GetAuraDataByIndex` if present, else `UnitAura` (PaTiAuras `AuraScan.lua`, PaTiHeal `Dispels.lua`).
  Which one this client offers is unconfirmed — `/pa auras` prints it.
- Addon communication (`C_ChatInfo.SendAddonMessage`, prefix registration): not used yet; verify limits in this client before designing a protocol.

## How to verify something

In game: `/run print(C_X and C_X.Fn and "yes" or "no")`, or `/dump C_X.Fn(...)`. Record result + date + build in the table.
