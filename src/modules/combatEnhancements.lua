local SettingsSync = _G.SettingsSync
SettingsSync.CombatEnhancements = SettingsSync.CombatEnhancements or {}

local function Print(msg)
	if SettingsSync and SettingsSync.Print then
		SettingsSync.Print(msg)
	end
end

local function Debug(msg)
	if SettingsSync and SettingsSync.Debug then
		SettingsSync.Debug(msg)
	end
end

local function SaveCombatEnhancements()
	return {}
end

local function ApplyCombatEnhancements(combatEnhancements)
	return combatEnhancements
end

SettingsSync.CombatEnhancements.Save = SaveCombatEnhancements
SettingsSync.CombatEnhancements.Apply = ApplyCombatEnhancements
