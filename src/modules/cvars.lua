local SettingsSync = _G.SettingsSync
SettingsSync.CVars = SettingsSync.CVars or {}

local function Print(msg)
	DEFAULT_CHAT_FRAME:AddMessage("|cff00d1b2SettingsSync|r: " .. msg)
end

local function Debug(msg)
	if SettingsSync and SettingsSync.Debug then
		SettingsSync.Debug(msg)
	end
end

local CVARS_TO_SYNC = {
	"autoLootDefault",
}

local function SaveCVars()
	local data = {}
	for _, name in ipairs(CVARS_TO_SYNC) do
		if GetCVar then
			data[name] = GetCVar(name)
		end
	end
	return data
end

local function ApplyCVars(cvars)
	if not cvars then
		--Print("No CVAR data to apply.")
		return
	end

	for name, value in pairs(cvars) do
		if SetCVar and value ~= nil then
			SetCVar(name, value)
		end
	end

	--Print("Applied " .. tostring(#CVARS_TO_SYNC) .. " CVARs.")
end

SettingsSync.CVars.Save = SaveCVars
SettingsSync.CVars.Apply = ApplyCVars
SettingsSync.CVars.List = CVARS_TO_SYNC
