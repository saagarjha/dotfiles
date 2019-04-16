-- Dark mode related functions

-- Set dark mode (0 for light, 1 for dark, and -1 to swap)
function setDarkMode(value)
	local mode
	if value == -1 then 
		mode = "!preferences.darkMode()"
	elseif value == 0 then
		mode = "false"
	elseif value == 1 then
		mode = "true"
	end
	hs.osascript.javascript(
		"var preferences = Application(\"System Events\").appearancePreferences(); preferences.darkMode = " .. mode
	)
end

-- Toggle dark mode
k:bind({}, "F6", nil, function() setDarkMode(-1) end)

-- Toggle dark mode at sunrise and sunset
-- local sunrise = "06:00"
-- local sunset = "18:00"

-- hs.timer.doAt(sunrise, hs.timer.days(1), function () setDarkMode(0) end)
-- hs.timer.doAt(sunset, hs.timer.days(1), function () setDarkMode(1) end)
