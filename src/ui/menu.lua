local SettingsSync = _G.SettingsSync
SettingsSync.Menu = SettingsSync.Menu or {}
SettingsSync.Menu.State = SettingsSync.Menu.State or {
	defaults = {
		inputText = "",
	},
}

local function CreateMenuFrame()
	if SettingsSync.Menu.Frame then
		return SettingsSync.Menu.Frame
	end

	local frame = CreateFrame("Frame", "SettingsSyncMenuFrame", UIParent, "BackdropTemplate")
	frame:SetSize(500, 250)
	frame:SetPoint("CENTER")
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", frame.StartMoving)
	frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
	frame:SetClampedToScreen(true)
	frame:Hide()

	frame:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 },
	})
	frame:SetBackdropColor(0, 0, 0, 0.8)

	local state = SettingsSync.Menu.State
	state.current = state.current or { inputText = state.defaults.inputText }

	local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	title:SetPoint("TOP", 0, -12)
	title:SetText("SettingsSync")
	title:SetTextColor(1, 1, 1)

	local currentProfileLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	currentProfileLabel:SetPoint("TOPLEFT", 20, -40)
	currentProfileLabel:SetText("Current Profile:")
	currentProfileLabel:SetTextColor(1, 1, 1)

	local currentProfileValue = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	currentProfileValue:SetPoint("LEFT", currentProfileLabel, "RIGHT", 6, 0)
	local function ResolveCurrentProfileName()
		if SettingsSync.GetCurrentProfileName then
			return SettingsSync.GetCurrentProfileName()
		end
		if SettingsSyncDB and SettingsSyncDB.currentProfile and SettingsSyncDB.currentProfile ~= "" then
			return SettingsSyncDB.currentProfile
		end
		return "default"
	end
	currentProfileValue:SetText(ResolveCurrentProfileName())
	currentProfileValue:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
	frame.CurrentProfileValue = currentProfileValue
	frame.ResolveCurrentProfileName = ResolveCurrentProfileName

	local createNewProfileLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	createNewProfileLabel:SetPoint("TOPLEFT", 20, -60)
	createNewProfileLabel:SetText("Create New Profile:")
	createNewProfileLabel:SetTextColor(1, 1, 1)

	local input = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
	input:SetSize(365, 24)
	input:SetPoint("TOPLEFT", createNewProfileLabel, "BOTTOMLEFT", 5, -5)
	input:SetAutoFocus(false)
	input:SetText(state.current.inputText or "")

	local function GetProfileNames()
		local names = {}
		if SettingsSyncDB and SettingsSyncDB.profiles then
			for name in pairs(SettingsSyncDB.profiles) do
				table.insert(names, name)
			end
		end
		if #names == 0 then
			table.insert(names, "default")
		end
		table.sort(names, function(a, b)
			return tostring(a):lower() < tostring(b):lower()
		end)
		return names
	end

	local selectProfileLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	selectProfileLabel:SetPoint("TOPLEFT", 20, -110)
	selectProfileLabel:SetText("Select Profile:")
	selectProfileLabel:SetTextColor(1, 1, 1)

	local profileDropdown = CreateFrame("Frame", "SettingsSyncProfileDropdown", frame, "UIDropDownMenuTemplate")
	profileDropdown:SetPoint("TOPLEFT", selectProfileLabel, "BOTTOMLEFT", -18, -5)
	UIDropDownMenu_SetWidth(profileDropdown, 354)
	UIDropDownMenu_JustifyText(profileDropdown, "LEFT")

	local deleteProfileButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	deleteProfileButton:SetSize(80, 24)
	deleteProfileButton:SetPoint("LEFT", profileDropdown, "RIGHT", -5, 2)
	deleteProfileButton:SetText("Delete")

	local function RefreshProfileDropdown()
		UIDropDownMenu_Initialize(profileDropdown, function(self, level)
			local info = UIDropDownMenu_CreateInfo()
			for _, name in ipairs(GetProfileNames()) do
				info.text = name
				info.checked = (frame.ResolveCurrentProfileName and name == frame.ResolveCurrentProfileName())
				info.func = function()
					if SettingsSync.SetCurrentProfileName then
						local resolved = SettingsSync.SetCurrentProfileName(name)
						if resolved then
							if frame.CurrentProfileValue then
								frame.CurrentProfileValue:SetText(resolved)
							end
							UIDropDownMenu_SetText(profileDropdown, resolved)
						end
					end
				end
				UIDropDownMenu_AddButton(info, level)
			end
		end)

		if frame.ResolveCurrentProfileName then
			UIDropDownMenu_SetText(profileDropdown, frame.ResolveCurrentProfileName())
		end
	end
	frame.RefreshProfileDropdown = RefreshProfileDropdown
	deleteProfileButton:SetScript("OnClick", function()
		local selectedName = frame.ResolveCurrentProfileName and frame.ResolveCurrentProfileName() or "default"
		if SettingsSync.DeleteProfile then
			local deleted, newName = SettingsSync.DeleteProfile(selectedName)
			if deleted then
				if frame.CurrentProfileValue then
					frame.CurrentProfileValue:SetText(newName)
				end
				RefreshProfileDropdown()
			end
		end
	end)

	local button = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	button:SetSize(80, 24)
	button:SetPoint("LEFT", input, "RIGHT", 10, 0)
	button:SetText("Create")
	button:SetScript("OnClick", function()
		local text = input:GetText()
		state.current.inputText = text
		if SettingsSync.SetCurrentProfileName then
			local resolved = SettingsSync.SetCurrentProfileName(text)
			if resolved then
				frame.CurrentProfileValue:SetText(resolved)
				input:SetText("")
				state.current.inputText = ""
				RefreshProfileDropdown()

				if SettingsSync.Print then
					SettingsSync.Print("Created and switched to profile: " .. resolved)
				end

				if SettingsSync.SaveProfile then
					SettingsSync.SaveProfile()
				end
			end
		end
	end)

	local saveButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	saveButton:SetSize(110, 24)
	saveButton:SetPoint("BOTTOMLEFT", 20, 20)
	saveButton:SetText("Save settings")
	saveButton:SetScript("OnClick", function()
		if SettingsSync.SaveProfile then
			SettingsSync.SaveProfile()
		end
	end)

	local applyButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	applyButton:SetSize(110, 24)
	applyButton:SetPoint("LEFT", saveButton, "RIGHT", 8, 0)
	applyButton:SetText("Apply Settings")
	applyButton:SetScript("OnClick", function()
		if SettingsSync.ApplyProfile then
			SettingsSync.ApplyProfile()
		end
		input:SetText(state.defaults.inputText)
		state.current.inputText = state.defaults.inputText
		frame:Hide()
	end)

	local discardButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	discardButton:SetSize(140, 24)
	discardButton:SetPoint("BOTTOMRIGHT", -20, 20)
	discardButton:SetText("Discard changes")
	discardButton:SetScript("OnClick", function()
		input:SetText(state.defaults.inputText)
		state.current.inputText = state.defaults.inputText
		frame:Hide()
	end)

	SettingsSync.Menu.Frame = frame
	return frame
end

local function ToggleMenu()
	local frame = CreateMenuFrame()
	if frame:IsShown() then
		frame:Hide()
	else
		if frame.CurrentProfileValue and frame.ResolveCurrentProfileName then
			frame.CurrentProfileValue:SetText(frame.ResolveCurrentProfileName())
		end
		if frame.RefreshProfileDropdown then
			frame.RefreshProfileDropdown()
		end
		frame:Show()
	end
end

SettingsSync.Menu.Show = ToggleMenu
