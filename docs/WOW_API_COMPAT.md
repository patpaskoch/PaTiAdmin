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
| `C_Item.GetWeaponEnchantInfo()` **without a slot**, read like the classic tuple | **observed wrong 2026-09-30** (owner: Main Hand "Unknown" with and without Rockbiter) | the function exists in this client but does not answer that way |
| `GetWeaponEnchantInfo()` classic tuple (hasMainHand, ms left, charges, enchantID, then the off hand) | **observed wrong 2026-10-02** (owner `/pa auras`, Rockbiter on): `hasMainHand=false`, the other main-hand values nil | unreliable in Forever: PaTiAuras uses it only where the modern API is missing or unreadable, and then only to confirm an imbue |
| `C_Item.GetWeaponEnchantInfo(Enum.WeaponSlot.MainHand)` | **observed 2026-10-02** (owner, Rockbiter on): several entries, one with `hasEnchant=true`, `timeLeft=3524825` (ms ≈ 58.7 min), `enchantType=3`, `enchantID=29`, `enchantIconID=136086` | the source PaTiAuras asks first. `hasEnchant=true` + positive `timeLeft` is the most reliable "temporary imbue" signal. `enchantID=29` is **not** a universal Rockbiter ID — see the mapping row below |
| `Enum.WeaponSlot` / `Enum.ItemEnchantType` | **observed 2026-10-02** (owner): WeaponSlot MainHand=0, OffHand=1, Ranged=2; ItemEnchantType None=0, Permanent=1, Temporary=2 | the active imbue comes with `enchantType=3`, a value not in the enum — so the type alone must not decide |
| Rockbiter Weapon ↔ temporary enchant ID 29 | **owner observed 2026-10-02** (Forever, one test, the rank the owner cast; enchantIconID 136086) | used by PaTiAuras as the Forever-only mapping for the concrete Rockbiter watch (`Profiles/Shaman.lua` `enchantIDs = { 29 }`). Not universal: other ranks/clients may differ — an unmapped ID reads Unknown, never Active or Missing |
| Rockbiter Weapon spell ID 8017 (rank 1, classic data) | **assumed** | used only if the client resolves it (`C_Spell.GetSpellInfo`) and the spell is known; cast by name = highest rank. Confirm: `/pa auras` → `weapon ROCKBITER_WEAPON id=8017` + "Learned spells with icon 136086" |
| Secure click on a weapon line (`SecureActionButtonTemplate`, `type1=spell`, `spell1=<name>`, `unit=player`) to cast a weapon imbue | **unknown** (PaTiAuras 2026-10-02) | attributes set out of combat only; PT-AURAS-150–155 |
| Secure `cancelaura` with `spell2=<buff name>` (own buff/proc) | **unknown** (PaTiAuras 2026-10-02) | PT-AURAS-163/164 |
| Secure `cancelaura` with `target-slot2=16` (weapon imbue) | **observed broken 2026-10-02** (owner): Blizzard error `SecureTemplates.lua:478: attempt to index global 'CANCELABLE_ITEMS' (a nil value)` | Forever client bug; PaTiAuras offers no imbue right-click. Defining the global from an addon would taint the secure handler — not done |
| Result in PaTiAuras | 2026-09-30 "Missing" with and without Rockbiter (the wrong tuple won; `enchantType=3` was also rejected) · **fix 2026-10-02 not yet tested in game** (PT-AURAS-052–057) | |
| Equipping / removing the main-hand weapon is seen (GetInventoryItemID + PLAYER_EQUIPMENT_CHANGED) | **observed 2026-09-30** (owner) | |
| `WEAPON_ENCHANT_CHANGED`, `WEAPON_SLOT_CHANGED` events | assumed, pcall-registered | 1 s fallback check |
| How the client identifies *which* imbue is on a weapon (enchant ID, name) | **unknown** | V1 only watches "imbue present"; needs `/pa auras` output with Flametongue/Windfury on |
| `UNIT_INVENTORY_CHANGED` / `PLAYER_EQUIPMENT_CHANGED` fire when an imbue is applied, expires or the weapon changes | assumed (PaTiAuras) | 2 s change check as fallback |
| `C_PaperDollInfo.GetTemporaryEnchantmentInfo` | **unknown**, not used | only reported by `/pa debug` |
| `GetInventoryItemID` + `GetItemInfoInstant` classID 2 = weapon (shield/held item → no imbue) | assumed (PaTiAuras) | unreadable → UNKNOWN instead of "missing" |
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

## Clickable targeting from the PaTiTank aggro panel (F17) — investigation 2026-09-29

Owner wish: click a "lost enemy" row → that enemy becomes the target. Investigated from the secure-system rules
(below); **nothing of this was tried in the Forever client** — each point is ASSUMPTION / NOT YET VERIFIED there.

| Question | Finding |
|---|---|
| `SecureActionButtonTemplate` with `type1=target`, `unit=nameplate3` | Targets on a hardware click, also in combat, if the attributes were set out of combat. The token is read at click time: the click hits whatever unit is `nameplate3` *then*. |
| Can nameplate tokens change their unit during combat? | Yes — a plate is released (NAME_PLATE_UNIT_REMOVED) and reused for another unit (…_ADDED). A button bound to a token follows the token, not the enemy. |
| Change `unit`/`type` of a secure button in combat | Not allowed from addon code (protected attributes; `ADDON_ACTION_BLOCKED`). |
| Move, show/hide, resize a secure button in combat | Not allowed from addon code (protected frame). |
| Tell secure code in combat which enemy is "lost" | No channel: threat is known only to addon (insecure) code; macro conditions and SecureHandler snippets have no threat or "target of" condition, and insecure code cannot write attributes of protected frames in combat. |
| Variant A — one fixed secure button per nameplate token | Possible, but its position is fixed at combat start while the aggro rows are sorted and change in combat → a row would sit over the button of a different token → **wrong enemy**. Showing all enemy plates as fixed rows avoids that, but is the "six bars" threat list the owner rejected, and still needs secure layout via state drivers (≈0.2 s lag). Rejected. |
| Variant B — stable tokens `target`, `party1target`…`party4target` | The same mapping problem: which row shows which token is decided in combat. Rejected. |
| Variant C — other official secure way | None found: every secure target path needs the unit decided out of combat or by the player (click on the unit itself). |
| `IsForbidden()` on nameplates | Blizzard can mark plates forbidden (e.g. friendly plates in instances on Retail). Addon code must not touch them; PaTiTank skips them. |

**Result: TECHNICALLY BLOCKED** for "click a row of the compact, sorted aggro list in combat". Implemented instead
(the safe fallback): the problem row's number above the nameplate of that enemy, coloured by state (`PaTiTank/Plates.lua`, our
own child frame of the plate). The player clicks that nameplate; Blizzard's own click targets exactly that enemy.

| API / behaviour | Status | Notes |
|---|---|---|
| `C_NamePlate.GetNamePlateForUnit(unit)` returns the plate frame | assumed (PaTiTank markers) | pcall-guarded; missing API → no markers |
| A child frame of a nameplate moves and hides with it and does not taint | assumed (PaTiTank markers) | taint log test required |

## Window opacity, snapping, PaTiSuite (2026-09-30)

| API / behaviour | Status | Notes |
|---|---|---|
| `SetBackdropColor` alpha on a frame with secure children, also in combat | assumed (all windows) | not a protected property; only changed from settings |
| Window snapping at drag end | **observed not working 2026-09-30** (owner) | removed instead of debugged (not needed) |
| PaTiSuite show/hide of single windows, Show all, Hide all | **observed working 2026-09-30** (owner) | the two buttons are now one dynamic button; compact entries, horizontal layout and collapse added 2026-10-02 (not yet tested) |
| `GameTooltip:SetOwner(frame, "ANCHOR_NONE")` + `SetPoint` beside the frame (PaTiShared `UI.SetTooltip`); GameTooltip stays on screen (clamped) | **assumed** (2026-10-02) | PT-SUITE-140–143, PT-AURAS-161/162 |
| PaTiSuite: show/hide at the first `PLAYER_ENTERING_WORLD` (after every addon's `PLAYER_LOGIN`) | **assumed** (2026-10-02) | restores the remembered visibility once per login; PT-SUITE-130–136 |
| A HIGHLIGHT-layer texture on a Button is drawn above its FontStrings | **observed 2026-09-30** (PaTiSuite hover unreadable) | use a BACKGROUND texture on OnEnter |
| `HookScript("OnShow"/"OnHide")` on another addon's window (also windows with secure children) | assumed (PaTiSuite) | post-hooks only, nothing secure is called |

## Rules that hold regardless of client

- Protected functions and secure attributes: never during `InCombatLockdown()`.
- Secret values: hand to widgets only; no arithmetic/comparison/string operations.
- No automation: one hardware click → one explicit action chosen earlier by the player.
- Aura APIs: `C_UnitAuras.GetAuraDataByIndex` if present, else `UnitAura` (PaTiAuras `AuraScan.lua`, PaTiHeal `Dispels.lua`).
  Which one this client offers is unconfirmed — `/pa auras` prints it.
- Addon communication (`C_ChatInfo.SendAddonMessage`, prefix registration): not used yet; verify limits in this client before designing a protocol.

## How to verify something

In game: `/run print(C_X and C_X.Fn and "yes" or "no")`, or `/dump C_X.Fn(...)`. Record result + date + build in the table.
