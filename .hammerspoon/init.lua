-- A global variable for Hyper Mode
k = hs.hotkey.modal.new({}, "F17")

-- Enter Hyper Mode when F18 (Hyper/Caps lock) is pressed
pressedF18 = function()
	k.triggered = false
	k:enter()
end

-- Leave Hyper Mode when F18 (Hyper/Caps lock) is pressed
releasedF18 = function()
	k:exit()
end

-- Bind the Hyper key
local f18 = hs.hotkey.bind({}, 'F18', pressedF18, releasedF18)

-- Automatically load all the other lua scripts
for file in hs.fs.dir(os.getenv("HOME") .. "/.hammerspoon/") do
	if file:sub(-4) == ".lua" and file ~= "init.lua" then
		require(file:sub(0, -5))
	end
end
