local Lighting = game:GetService("Lighting")

local TARGET = getgenv().FB_CONFIG

local Fullbright = {}
local enabled = false
local orig = {}
local stashed = {}
local conns = {}

local function stash(atm)
	if stashed[atm] then return end
	stashed[atm] = true
	pcall(function() atm.Parent = nil end)
end

function Fullbright.Enable()
	if enabled then return end
	enabled = true

	for prop, val in pairs(TARGET) do
		orig[prop] = Lighting[prop]
		Lighting[prop] = val
		table.insert(conns, Lighting:GetPropertyChangedSignal(prop):Connect(function()
			local cur = Lighting[prop]
			if cur ~= val then
				orig[prop] = cur -- game's new intended value
				Lighting[prop] = val
			end
		end))
	end

	for _, c in ipairs(Lighting:GetChildren()) do
		if c:IsA("Atmosphere") then stash(c) end
	end
	table.insert(conns, Lighting.ChildAdded:Connect(function(c)
		if c:IsA("Atmosphere") then stash(c) end
	end))
end

function Fullbright.Disable()
	if not enabled then return end
	enabled = false

	for _, c in ipairs(conns) do c:Disconnect() end
	table.clear(conns)

	for prop, val in pairs(orig) do
		Lighting[prop] = val
	end
	table.clear(orig)

	for atm in pairs(stashed) do
		pcall(function() atm.Parent = Lighting end)
	end
	table.clear(stashed)
end

function Fullbright.Toggle()
	if enabled then Fullbright.Disable() else Fullbright.Enable() end
	return enabled
end

function Fullbright.IsEnabled()
	return enabled
end

return Fullbright
