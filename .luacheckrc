-- Luacheck for all PaTi repositories. Run through tools/check.sh (from the code root, so the
-- per-addon patterns below match "PaTiAddons/<Addon>/...").
-- WoW runs Lua 5.1. Do not silence warnings globally; allow names deliberately.
std = "lua51"

-- Existing files use long one-line statements; wrapping them is a follow-up, not a lint failure.
-- New code should stay below ~120 characters (docs/ARCHITECTURE.md).
max_line_length = false

-- Unused `self` in WoW script handlers (e.g. OnEvent(self, event)) is the normal signature.
ignore = { "212/self" }

exclude_files = { "**/.git/**", "**/dist/**" }

-- WoW API used by the suite. Before adding a name, confirm it exists in the Interface 16001
-- client (docs/WOW_API_COMPAT.md). Keep alphabetical.
read_globals = {
    "C_AddOns", "C_Item", "C_NamePlate", "C_PaperDollInfo", "C_PartyInfo", "C_QuestLog", "C_Spell", "C_SpellBook", "C_UnitAuras",
    "CreateFrame", "CreateMacro", "DoReadyCheck", "EditMacro",
    "GameTooltip", "GetAddOnMetadata", "GetBindingAction", "GetBuildInfo", "GetCurrentBindingSet", "GetInstanceInfo",
    "GetLocale", "GetMacroIndexByName", "GetMacroInfo", "GetNumGroupMembers", "GetSpellInfo", "GetSpellTexture",
    "InCombatLockdown", "IsAltKeyDown", "IsControlKeyDown", "IsInGroup", "IsInInstance", "IsShiftKeyDown",
    "LOCALIZED_CLASS_NAMES_MALE", "RegisterUnitWatch", "UnregisterUnitWatch",
    "DebuffTypeColor", "Enum", "GetNumSpellTabs", "GetSpellBookItemInfo", "GetSpellBookItemName", "GetSpellTabInfo",
    "GetInventoryItemID", "GetInventoryItemTexture", "GetItemInfoInstant", "GetWeaponEnchantInfo",
    "GetTime", "UnitAura", "issecretvalue", "IsInRaid", "GetSpecialization", "GetSpecializationInfo", "GetRaidTargetIndex", "GetBindingKey", "RAID_CLASS_COLORS", "UnitIsVisible",
    "SaveBindings", "SetBinding", "SetBindingClick",
    "UIParent", "UISpecialFrames",
    "UnitAffectingCombat", "UnitClass", "UnitDetailedThreatSituation", "UnitExists", "UnitGroupRolesAssigned",
    "UnitCanAttack", "UnitGUID", "UnitIsDead", "UnitThreatSituation",
    "UnitHealth", "UnitHealthMax", "UnitIsConnected", "UnitIsDeadOrGhost", "UnitIsGroupAssistant",
    "UnitIsGroupLeader", "UnitName", "UnitPower", "UnitPowerMax", "UnitPowerType",
    "tinsert", "unpack",
}

-- Slash command registration writes into this Blizzard table.
globals = { "SlashCmdList" }

-- Globals an addon may create: its SavedVariables, SLASH_* names and binding functions — nothing else.
-- PaTiAlertsAPI: the one cross-addon global (AGENTS.md §3) — created by PaTiAlerts, only read (optionally) by producers.
files["**/PaTiHeal/**/*.lua"] = { globals = { "PaTiHealDB", "SLASH_PATIHEAL1", "SLASH_PATIHEAL2" }, read_globals = { "PaTiAlertsAPI" } }
files["**/PaTiTank/**/*.lua"] = { globals = { "PaTiTankDB", "SLASH_PATITANK1", "SLASH_PATITANK2" }, read_globals = { "PaTiAlertsAPI" } }
files["**/PaTiQuest/**/*.lua"] = { globals = { "PaTiQuestDB", "SLASH_PATIQUEST1", "SLASH_PATIQUEST2" } }
files["**/PaTiDungeon/**/*.lua"] = { globals = { "PaTiDungeonDB", "SLASH_PATIDUNGEON1", "SLASH_PATIDUNGEON2" } }
files["**/PaTiAuras/**/*.lua"] = { globals = { "PaTiAurasDB", "SLASH_PATIAURAS1", "SLASH_PATIAURAS2" }, read_globals = { "PaTiAlertsAPI" } }
files["**/PaTiAlerts/**/*.lua"] = { globals = { "PaTiAlertsDB", "SLASH_PATIALERTS1", "SLASH_PATIALERTS2", "PaTiAlertsAPI" } }
files["**/PaTiGroup/**/*.lua"] = { globals = { "PaTiGroupDB", "SLASH_PATIGROUP1", "SLASH_PATIGROUP2", "SLASH_PATIGROUP3", "PaTiGroup_Toggle" } }

-- Specs run under tools/lua/test.lua (busted-compatible); mocks install WoW functions as globals.
files["**/tests/**/*.lua"] = { std = "+busted", globals = { "GetLocale", "InCombatLockdown" } }

-- Tooling runs outside WoW (plain Lua 5.1 / LuaJIT).
files["**/tools/**/*.lua"] = { std = "+luajit" }
