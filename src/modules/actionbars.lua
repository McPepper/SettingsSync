local SettingsSync = _G.SettingsSync
SettingsSync.ActionBars = SettingsSync.ActionBars or {}

local function Print(msg)
	DEFAULT_CHAT_FRAME:AddMessage("|cff00d1b2SettingsSync|r: " .. msg)
end

local function Debug(msg)
	if SettingsSync and SettingsSync.Debug then
		SettingsSync.Debug(msg)
	end
end

local function SaveActionBars()
	local show2, show3, show4, show5, show6, show7, show8
	if GetActionBarToggles then
		show2, show3, show4, show5, show6, show7, show8 = GetActionBarToggles()
	end

	return {
		show2 = show2,
		show3 = show3,
		show4 = show4,
		show5 = show5,
		show6 = show6,
		show7 = show7,
		show8 = show8,
	}
end

local function ApplyActionBars(actionBars)
	if not actionBars then
		--Print("No action bar data to apply.")
		return
	end

	--Print("Applying action bar settings.")

	if SetActionBarToggles and actionBars.show2 ~= nil then
		SetActionBarToggles(
			actionBars.show2,
			actionBars.show3,
			actionBars.show4,
			actionBars.show5,
			actionBars.show6,
			actionBars.show7,
			actionBars.show8,
			"true"
		)
	end

	-- Apply immediately for the current session.
	if _G.SHOW_MULTI_ACTIONBAR_1 ~= nil then _G.SHOW_MULTI_ACTIONBAR_1 = actionBars.show2 end
	if _G.SHOW_MULTI_ACTIONBAR_2 ~= nil then _G.SHOW_MULTI_ACTIONBAR_2 = actionBars.show3 end
	if _G.SHOW_MULTI_ACTIONBAR_3 ~= nil then _G.SHOW_MULTI_ACTIONBAR_3 = actionBars.show4 end
	if _G.SHOW_MULTI_ACTIONBAR_4 ~= nil then _G.SHOW_MULTI_ACTIONBAR_4 = actionBars.show5 end
	if _G.SHOW_MULTI_ACTIONBAR_5 ~= nil then _G.SHOW_MULTI_ACTIONBAR_5 = actionBars.show6 end
	if _G.SHOW_MULTI_ACTIONBAR_6 ~= nil then _G.SHOW_MULTI_ACTIONBAR_6 = actionBars.show7 end
	if _G.SHOW_MULTI_ACTIONBAR_7 ~= nil then _G.SHOW_MULTI_ACTIONBAR_7 = actionBars.show8 end

	if MultiActionBar_Update then
		MultiActionBar_Update()
	end
end

SettingsSync.ActionBars.Save = SaveActionBars
SettingsSync.ActionBars.Apply = ApplyActionBars
