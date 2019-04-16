-- Switch between resolutions with Hyper+F1, F2, and F3

-- The set of resolutions to allow
local resolutions = {
	{w = 1280, h = 800, scale = 1}, 
	{w = 1024, h = 640, scale = 2}, 
	{w = 1280, h = 800, scale = 2}, 
	{w = 1440, h = 900, scale = 2}, 
	{w = 1680, h = 1050, scale = 2}, 
	{w = 2560, h = 1600, scale = 1}, 
}

-- The default resolution
local DEFAULT_RESOLUTION = {w = 1280, h = 800, scale = 2}

-- Get the index of the current resolution
function getResolution()
	local currentResolution = hs.screen.mainScreen():currentMode()
	for i = 1, #resolutions do
		local resolution = resolutions[i]
		if currentResolution.w == resolution.w and
			currentResolution.h == resolution.h and
			currentResolution.scale == resolution.scale then
			return i
		end
	end
	return 0
end

-- Change the resolution in the specified direction (0 to reset to default)
function changeResolution(direction)
	local resolution = direction == 0 and DEFAULT_RESOLUTION or resolutions[clamp(getResolution() + direction, 1, #resolutions)]
	if hs.screen.mainScreen():setMode(resolution.w, resolution.h, resolution.scale) then
		hs.alert.show("Resolution set to: " .. resolution.w .. "x" .. resolution.h .. "@" .. resolution.scale .. "x")
	end
end

k:bind({}, "F1", nil, function() changeResolution(-1) end)
k:bind({}, "F2", nil, function() changeResolution(1) end)
k:bind({}, "F3", nil, function() changeResolution(0) end)
