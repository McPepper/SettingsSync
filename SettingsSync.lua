local addonName = ...
local SettingsSync = _G.SettingsSync or {}
_G.SettingsSync = SettingsSync

-- Account-wide and per-character saved variables
SettingsSyncDB = SettingsSyncDB or {
	profiles = {},
	debug = true,
	latestVersion = 0,
}

SettingsSyncCharDB = SettingsSyncCharDB or {
	latestVersion = nil,
}

local function Print(msg)
	DEFAULT_CHAT_FRAME:AddMessage("|cff00d1b2SettingsSync|r: " .. msg)
end

local function Debug(msg)
	if not SettingsSyncDB.debug then
		return
	end
	Print("Debug: " .. msg)
end

SettingsSync.Print = Print
SettingsSync.Debug = Debug

local function GetProfile()
	local name = "default"
	SettingsSyncDB.profiles[name] = SettingsSyncDB.profiles[name] or {}
	return SettingsSyncDB.profiles[name], name
end

local function GetAccountLatestVersion()
	return SettingsSyncDB.latestVersion
end

local function GetCharacterLatestVersion()
	return SettingsSyncCharDB.latestVersion
end

local function Menu()
	if SettingsSync.Menu and SettingsSync.Menu.Show then
		SettingsSync.Menu.Show()
	end
end

local function SaveProfile()
	local profile, resolvedName = GetProfile()
	Print("Saving profile '" .. resolvedName .. "' ...")

	if SettingsSync.Chat and SettingsSync.Chat.Save then
		profile.chat = SettingsSync.Chat.Save()
	end

	if SettingsSync.ActionBars and SettingsSync.ActionBars.Save then
		profile.actionBars = SettingsSync.ActionBars.Save()
	end

	if SettingsSync.CVars and SettingsSync.CVars.Save then
		profile.cvars = SettingsSync.CVars.Save()
	end

	if SettingsSync.EditMode and SettingsSync.EditMode.Save then
		profile.editMode = SettingsSync.EditMode.Save()
	end

	SettingsSyncDB.latestVersion = (SettingsSyncDB.latestVersion or 0) + 1

	Print("Saved settings to profile '" .. resolvedName .. "'.")
end

local function ShowReloadPrompt()
	if not StaticPopupDialogs["SETTINGSSYNC_RELOAD_UI"] then
		StaticPopupDialogs["SETTINGSSYNC_RELOAD_UI"] = {
			text = "SettingsSync: Reload UI to apply changes?",
			button1 = YES,
			button2 = NO,
			OnAccept = function()
				ReloadUI()
			end,
			timeout = 0,
			whileDead = 1,
			hideOnEscape = 1,
			preferredIndex = 3,
		}
	end
	StaticPopup_Show("SETTINGSSYNC_RELOAD_UI")
end

local function ApplyProfile(showReloadPrompt)
	local profile, resolvedName = GetProfile()
	Print("Applying profile '" .. resolvedName .. "' ...")
	if SettingsSync.Chat and SettingsSync.Chat.Apply then
		SettingsSync.Chat.Apply(profile.chat)
	end
	if SettingsSync.ActionBars and SettingsSync.ActionBars.Apply then
		SettingsSync.ActionBars.Apply(profile.actionBars)
	end
	if SettingsSync.CVars and SettingsSync.CVars.Apply then
		SettingsSync.CVars.Apply(profile.cvars)
	end
	if SettingsSync.EditMode and SettingsSync.EditMode.Apply then
		SettingsSync.EditMode.Apply(profile.editMode)
	end

	Print("Applied settings from profile '" .. resolvedName .. "'.")

	if showReloadPrompt then
		ShowReloadPrompt()
	end
end

local function ResetProfile()
	SettingsSyncDB.profiles["default"] = nil
	Print("Reset 'default'.")
end

local function ShowHelp()
	Print("Commands:")
	Print("/ss - Open the SettingsSync menu")
	Print("/settingssync - Open the SettingsSync menu")
	Print("/ss help - Show this help")
end

SLASH_SETTINGSSYNC1 = "/settingssync"
SLASH_SETTINGSSYNC2 = "/ss"

SlashCmdList["SETTINGSSYNC"] = function(msg)
	local cmd = msg:match("^(%S*)") or ""
	cmd = cmd:lower()

	if cmd == "save" then
		SaveProfile()
	elseif cmd == "apply" then
		ApplyProfile()
	elseif cmd == "menu" then
		Menu()
	elseif cmd == "reset" then
		ResetProfile()
	elseif cmd == "" then
		Menu()
	elseif cmd == "help" then
		ShowHelp()
	else
		ShowHelp()
	end
end

local function ApplyDefaultOnLoad()
	local profile = SettingsSyncDB.profiles and SettingsSyncDB.profiles["default"]
	if profile then
		ApplyProfile(false)
	end
end

local loadFrame = CreateFrame("Frame")
loadFrame:RegisterEvent("PLAYER_LOGIN")
loadFrame:SetScript("OnEvent", function()
	ApplyDefaultOnLoad()
end)
