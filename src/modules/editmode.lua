local SettingsSync = _G.SettingsSync
SettingsSync.EditMode = SettingsSync.EditMode or {}

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

local Modern = 1
local Classic = 2

local function SaveEditModeLayout()
	local layoutInfo = C_EditMode.GetLayouts()
	if not layoutInfo then
		return nil
	end
	local layouts = layoutInfo.layouts
	local activeLayout = layoutInfo.activeLayout

	local presets = 2

	local layoutName
	local isPreset = false
	local customIndex

	if activeLayout and activeLayout <= presets then
		isPreset = true
		layoutName = (activeLayout == Modern and "Modern") or (activeLayout == Classic and "Classic") or "Preset"
	else
		customIndex = activeLayout and (activeLayout - presets) or nil
		layoutName = customIndex and layouts and layouts[customIndex] and layouts[customIndex].layoutName or nil
	end

	local editMode = {
		layoutName = layoutName,
		activeLayout = activeLayout,
		isPreset = isPreset,
		customIndex = customIndex,
	}

	return editMode
end

local function ApplyEditModeLayout(editMode)
	if not editMode then
		return
	end

	-- Check if we have a valid layout to apply
	local layoutInfo = C_EditMode.GetLayouts()
	local layouts = layoutInfo.layouts
	local presets = 2

	local targetLayout
	if editMode.isPreset then
		targetLayout = editMode.activeLayout
	else
		if editMode.layoutName then
			for index, layout in ipairs(layouts) do
				if layout and layout.layoutName == editMode.layoutName then
					targetLayout = index + presets
					break
				end
			end
		end
	end

	if not targetLayout then
		Print("No valid edit mode layout found for '" .. tostring(editMode.layoutName) .. "'.")
		Print("Defaulting to 'Modern' layout.")
		C_EditMode.SetActiveLayout(Modern)
		return
	end

	-- If we already on the desired layout, do nothing
	if layoutInfo.activeLayout == targetLayout then
		return
	end

	C_EditMode.SetActiveLayout(targetLayout)
end

SettingsSync.EditMode.Save = SaveEditModeLayout
SettingsSync.EditMode.Apply = ApplyEditModeLayout
