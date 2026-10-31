# Launch plan — bringing the PaTiSuite to players

Owner decision 2026-10-19: "you decide" — the agent chose the first wave, the channels and the support model below.
Binding together with [`RELEASE.md`](RELEASE.md) (beta gate, beta freeze, distribution checklist). Nothing here
overrides the beta gate: an addon goes public only when its main paths are `✅ VERIFIED` in game.
Current status, the to-do list and the income rules: [`BUSINESS_PLAN.md`](BUSINESS_PLAN.md).

## 1. Positioning

**PaTiSuite — small World of Warcraft addons that fit together.** One look (four themes), German and English, each
addon installable on its own, display-first, no automation, open source (MIT). The message is not "twelve addons" but
"one calm, consistent UI family"; every addon page links the others.

Target players: WoW Forever players in small groups (dungeons), German- and English-speaking, who want a clean UI
without big addon packs.

## 2. Waves (by in-game verification, INGAME_TEST_STATUS.md 2026-10-19)

| Wave | Addons | Why |
|---|---|---|
| **1** | **PaTiHeal, PaTiAuras, PaTiDungeon, PaTiSuite** | most main paths verified (Heal 22, Auras 22, Dungeon 20 tests, Dungeon without any FAIL); Heal + Auras are the most useful for groups; Dungeon's hand-drawn map is unique; PaTiSuite ties the family together and shows the themes |
| **2** | PaTiChronicle, PaTiRota, PaTiSocial, PaTiGroup | Chronicle is the showcase ("Every run tells a story") but has no verified test yet; Rota has two open FAILs; Social and Group need more main-path tests |
| **3** | PaTiAggro, PaTiLead, PaTiQuest, PaTiAlerts | few verified tests so far; Aggro and Lead have open FAILs |

A wave starts when every addon in it meets the beta gate. Wave 2 follows about four weeks after wave 1 at the earliest,
so that bug reports of wave 1 are handled first.

### Wave 1 — what is still missing (per addon)

- [ ] Main paths `✅ VERIFIED`: installation/loading (`…-001`–`…-005`), the main feature sections, Combat / Sicherheit
- [ ] Open FAIL assessed: PT-HEAL-057 (solo window height), PT-AURAS-201 (Lightning Shield) — retest or accept in Known Issues
- [ ] Fresh install from the release zip, the independence test and the combined test (TESTING.md)
- [ ] Screenshots from the list in RELEASE.md (at least 3 per addon, one with the WoForever theme)
- [ ] Version: stable 1.0.0 only after the beta; the beta is tagged `-beta.N` (RELEASE.md)

### Launch day (WoW Forever live, 2026-11-04)

The beta realms closed on 2026-10-23; nothing can be tested in game until the live launch on 2026-11-04. Beta results
are not automatically valid on the live client. Order for the first sessions — stop and report at the first Lua error:

1. **Client facts** (agent updates `AGENTS.md` §1 and `WOW_API_COMPAT.md` with the answers):
   - live AddOns folder (the beta used `…\_classic_beta_\Interface\AddOns\`) — the deploy target changes with it
   - `/dump select(4, GetBuildInfo())` → the Interface number. If it is not `16001`, the agent bumps every TOC first;
     otherwise the addons show as "out of date"
2. **Deploy and smoke test, all twelve addons together:** login and `/reload` without Lua errors (`…-004`, `…-005`),
   then `/ph debug`, `/pa debug`, `/prota debug`, `/pg debug` and report the output.
3. **Wave 1 retests** (fix exists, retest open): PT-HEAL-057 (solo window height), PT-HEAL-172 (offline member: clicks
   cast nothing), PT-AURAS-201 (Lightning Shield click, shaman).
4. **Wave 1 main paths** per addon in `INGAME_TESTING.md`: Installation / Laden, the main feature sections
   (Heal: Party Frames, Click Healing, Combat · Auras: Personal, Group Buffs, Beobachten, Combat · Dungeon: Instanz,
   Karte, Combat · Suite: Show / Hide, Themes, Combat), then Combined.
5. **Screenshots** during step 4 (list in RELEASE.md, at least 3 per addon, one with the WoForever theme).
6. Then the agent tags `-beta.1` per addon; the owner runs the fresh install test from the release zip
   (`…-001`, `…-002`) and the independence test.

Waiting for owner details (not wave 1): PT-AGGRO-030 and PT-GROUP-243 failed on 2026-10-18 without a note — what went
wrong? PT-ROTA-033 needs `/prota debug` output out of combat (cooldown code freeze until then).

## 3. Channels

| Channel | Role | Decision |
|---|---|---|
| **GitHub Releases** | the source of every download; zip, changelog, issues | **yes, first** — the release workflow is ready |
| **CurseForge** | the biggest audience; author rewards by downloads | **yes, if** "WoW Forever / Interface 16001" can be chosen as game version. Never list the addons under another client: players would install them into a game they do not fit |
| **WoWInterface** | smaller, flexible version field | **yes** (manual upload; version "WoW Forever 1.60.1") |
| **Wago Addons** | growing, popular with experienced players | **yes, if** the client is supported (same rule as CurseForge) |
| **WoW Forever community** (Discord, forums) | the most exact audience | **yes, the main announcement** — one post per wave, screenshots, link to GitHub |
| **Reddit** (r/wowaddons) | reach beyond the community | **yes**, once per wave, with pictures, no spam |
| **Short video** (YouTube / Shorts) | showcase | **wave 2**: 60 seconds of PaTiChronicle after a dungeon |

Rules: one announcement per wave per channel, answers to every question within a few days, a changelog for every
update. No paid advertising.

## 4. Support (donations)

- **Ko-fi** as the "buy me a coffee" page (no platform fee on one-off donations as far as known; check the current
  terms). Optional later: GitHub Sponsors.
- Where the link appears: `.github/FUNDING.yml` (the "Sponsor" button on every repo), a short "Support" section in every
  README, the platform descriptions. **Never in the game**: no donation text, link or reminder in any addon window —
  addons stay free and open (Blizzard UI Add-On Development Policy; check its current text).
- Expectation: a few euros up to low double digits per month if the addons are liked. Keep a simple income list from
  the first donation on (tax: ask a tax advisor or the tax office when income starts).

## 5. Texts (wave 1)

Short descriptions come from the TOC `## Notes` (+ `Notes-deDE`), long descriptions from the README (features,
installation, commands, known limitations). Announcement (German / English):

> **PaTiSuite – kleine Addons für WoW Forever, die zusammenpassen.** Heilen mit Klick-Zaubern (PaTiHeal), die
> eigenen und die Gruppen-Buffs im Blick (PaTiAuras), eine selbst gezeichnete Dungeon-Karte (PaTiDungeon) und ein
> Steuerfenster für alle (PaTiSuite). Ein ruhiges Design in vier Farbschemata, Deutsch und Englisch, jedes Addon
> einzeln installierbar, quelloffen. Feedback und Fehler gern über GitHub.

> **PaTiSuite – small WoW Forever addons that fit together.** Click-cast healing (PaTiHeal), your own and your
> group's buffs at a glance (PaTiAuras), a hand-drawn dungeon map (PaTiDungeon) and one control panel for all
> (PaTiSuite). One calm design in four themes, English and German, every addon on its own, open source. Feedback and
> bug reports welcome on GitHub.

## 6. Who does what

| Task | Who |
|---|---|
| Finish the wave-1 in-game tests, take the screenshots | owner (in game) |
| Create the Ko-fi account, the CurseForge / Wago / WoWInterface accounts; check whether the platforms list WoW Forever | owner (accounts are personal) |
| `FUNDING.yml`, the README "Support" sections, platform texts, the release tags and notes, this plan | agent, after the owner names the Ko-fi user name |
| Upload to the platforms, post the announcements | owner (own accounts), with the agent's texts |
| Bug reports → fixes during the beta (beta freeze: no new features) | agent |
