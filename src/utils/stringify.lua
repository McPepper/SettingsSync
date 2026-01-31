local function stringify(value, indent, visited)
	indent = indent or 0
	visited = visited or {}

	local t = type(value)
	if t == "string" then
		return string.format("%q", value)
	elseif t == "number" or t == "boolean" or t == "nil" then
		return tostring(value)
	elseif t ~= "table" then
		return "<" .. t .. ">"
	end

	if visited[value] then
		return "<cycle>"
	end
	visited[value] = true

	local padding = string.rep("  ", indent)
	local nextPadding = string.rep("  ", indent + 1)
	local parts = { "{" }

	for k, v in pairs(value) do
		local key = stringify(k, 0, visited)
		local val = stringify(v, indent + 1, visited)
		parts[#parts + 1] = nextPadding .. "[" .. key .. "] = " .. val .. ","
	end

	parts[#parts + 1] = padding .. "}"
	return table.concat(parts, "\n")
end

local function stringifyLines(value, indent, visited)
	local text = stringify(value, indent, visited)
	local lines = {}
	for line in string.gmatch(text, "([^\n]+)") do
		lines[#lines + 1] = line
	end
	return lines
end

local SettingsSync = _G.SettingsSync or {}
SettingsSync.Utils = SettingsSync.Utils or {}
SettingsSync.Utils.stringify = stringify
SettingsSync.Utils.stringifyLines = stringifyLines
_G.SettingsSync = SettingsSync

return stringify
