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
	frame:SetSize(400, 250)
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

	local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
	closeButton:SetPoint("TOPRIGHT", -4, -4)
	closeButton:SetScript("OnClick", function()
		state.current.inputText = state.defaults.inputText
	end)

	local currentProfileLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	currentProfileLabel:SetPoint("TOPLEFT", 20, -40)
	currentProfileLabel:SetText("Current Profile: default")

	local input = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
	input:SetSize(220, 24)
	input:SetPoint("TOPLEFT", 20, -50)
	input:SetAutoFocus(false)
	input:SetText(state.current.inputText or "")

	local button = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	button:SetSize(80, 24)
	button:SetPoint("LEFT", input, "RIGHT", 10, 0)
	button:SetText("OK")
	button:SetScript("OnClick", function()
		local text = input:GetText()
		state.current.inputText = text
		print("You entered: " .. text) -- Placeholder action
	end)

	local cancelButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	cancelButton:SetSize(80, 24)
	cancelButton:SetPoint("BOTTOMRIGHT", -20, 20)
	cancelButton:SetText("Cancel")
	cancelButton:SetScript("OnClick", function()
		input:SetText(state.defaults.inputText)
		state.current.inputText = state.defaults.inputText
		frame:Hide()
	end)

	local saveButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	saveButton:SetSize(80, 24)
	saveButton:SetPoint("RIGHT", cancelButton, "LEFT", -10, 0)
	saveButton:SetText("Save")

	SettingsSync.Menu.Frame = frame
	return frame
end

local function ToggleMenu()
	local frame = CreateMenuFrame()
	if frame:IsShown() then
		frame:Hide()
	else
		frame:Show()
	end
end

SettingsSync.Menu.Show = ToggleMenu
