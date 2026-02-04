local SettingsSync = _G.SettingsSync
SettingsSync.Chat = SettingsSync.Chat or {}

local function Print(msg)
	DEFAULT_CHAT_FRAME:AddMessage("|cff00d1b2SettingsSync|r: " .. msg)
end

local function Debug(msg)
	if SettingsSync and SettingsSync.Debug then
		SettingsSync.Debug(msg)
	end
end

local function SaveChat()
	--Print("Saving chat settings.")
	local chat = { windows = {}, maxWindows = NUM_CHAT_WINDOWS }

	for i = 1, NUM_CHAT_WINDOWS do
		local name, size, r, g, b, a, isShown, isLocked, isDocked, isUninteractable = FCF_GetChatWindowInfo(i)

		if i == 1 and name == "" then
			-- ChatFrame 1 is always "General" if not renamed
			name = "General"
		end

		if name ~= nil then
			local groups = { GetChatWindowMessages(i) }
			local rawChannels = { GetChatWindowChannels(i) }
			local channels = {}

			for index = 1, #rawChannels, 2 do
				local channelName = rawChannels[index]
				local zoneChannel = rawChannels[index + 1]
				if channelName then
					channels[#channels + 1] = {
						name = channelName,
						zone = zoneChannel,
					}
				end
			end

			chat.windows[i] = {
				name = name or "",
				fontSize = size,
				r = r,
				g = g,
				b = b,
				a = a,
				isShown = isShown,
				isLocked = isLocked,
				isDocked = isDocked,
				isUninteractable = isUninteractable,
				groups = groups,
				channels = channels,
			}
		end
	end

	return chat
end

local function ApplyChat(chat)
	if FCF_ResetChatWindows then
		FCF_ResetChatWindows()
	end

	if not chat or not chat.windows then
		--Print("No chat data to apply.")
		return
	end

	--Print("Applying chat settings.")
	for i = 1, NUM_CHAT_WINDOWS do
		local window = chat.windows[i]
		if window then
			local frame = _G["ChatFrame" .. i]

			-- Name
			if window.name and window.name ~= "" then
				if SetChatWindowName and FCF_SetWindowName then
					FCF_SetWindowName(frame, window.name)
					SetChatWindowName(i, window.name)
				end
			end

			-- Docked state
			if window.isDocked ~= nil then
				if window.isDocked then
					FCF_DockFrame(frame)
				else
					FCF_UnDockFrame(frame)
				end
			end

			-- Lock state
			if window.isLocked ~= nil then
				FCF_SetLocked(frame, window.isLocked)
			end

			-- Interactable
			if window.isUninteractable ~= nil then
				FCF_SetUninteractable(frame, window.isUninteractable)
			end

			-- Color
			if frame and window.r and window.g and window.b and window.a then
				FCF_SetWindowColor(frame, window.r, window.g, window.b)
				FCF_SetWindowAlpha(frame, window.a)
			end

			-- Font size and flags
			if frame and window.fontSize and FCF_SetChatWindowFontSize then
				FCF_SetChatWindowFontSize(nil, frame, window.fontSize)
				if window.fontFlags then
					local fontPath = frame:GetFont()
					frame:SetFont(fontPath, window.fontSize, window.fontFlags)
				end
			end

			-- Groups
			if frame and window.groups and ChatFrame_RemoveAllMessageGroups and ChatFrame_AddMessageGroup then
				ChatFrame_RemoveAllMessageGroups(frame)
				for _, group in ipairs(window.groups) do
					ChatFrame_AddMessageGroup(frame, group)
				end
			end

			-- Channels
			if frame and window.channels and ChatFrame_RemoveAllChannels then
				ChatFrame_RemoveAllChannels(frame)
				local useRegister = not frame.AddChannel
				local registerArgs = useRegister and {} or nil

				for _, channel in ipairs(window.channels) do
					local channelName = nil
					local zoneChannel = nil
					if type(channel) == "table" then
						channelName = channel.name or channel[1]
						zoneChannel = channel.zone or channel[2]
					else
						channelName = channel
						zoneChannel = 0
					end

					if channelName and channelName ~= "" then
						if frame.AddChannel then
							frame:AddChannel(channelName)
						elseif registerArgs then
							registerArgs[#registerArgs + 1] = channelName
							registerArgs[#registerArgs + 1] = zoneChannel or 0
						end
					end
				end

				if registerArgs and #registerArgs > 0 then
					if frame.RegisterForChannels then
						frame:RegisterForChannels(unpack(registerArgs))
					elseif ChatFrame_RegisterForChannels then
						ChatFrame_RegisterForChannels(frame, unpack(registerArgs))
					end
				end
			end
		end
	end
end

SettingsSync.Chat.Save = SaveChat
SettingsSync.Chat.Apply = ApplyChat
