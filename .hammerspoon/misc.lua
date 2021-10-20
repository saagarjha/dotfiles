-- Miscellanous functions

-- Paste character by character
hs.hotkey.bind({"cmd", "ctrl"}, 'v', function() hs.eventtap.keyStrokes(hs.pasteboard.getContents()) end)

-- Start LookThrough screensaver
k:bind({}, '\\', nil, function()
	screensaver = {}
	for s in table.pack(hs.execute("screensaver", true))[1]:gmatch("[^\n]+") do
		screensaver[#screensaver + 1] = s
	end
	hs.execute("screensaver LookThrough \'/Users/saagarjha/Library/Screen Savers/LookThrough.saver\'", true)
	hs.caffeinate.startScreensaver()
	hs.execute("screensaver " .. screensaver[1] .. " " .. screensaver[2])
end)

-- Combine windows
k:bind({}, '`', nil, function ()
	local app = hs.application.frontmostApplication()
	if app:title() ~= "Safari Technology Preview" then
		local menuItemTable = {"Window", "Merge All Windows"}
		if app:findMenuItem(menuItemTable) then
			app:selectMenuItem(menuItemTable)
		end
	end
end)

-- Paste version
local versions = {}

function vers(command)
	if not versions[command] then
		versions[command] = table.pack(hs.execute("vers " .. command, true):gsub("\n", ""))[1]
	end
	return versions[command]
end

k:bind({}, '[', nil, function()
	local topmostApplication = hs.application.frontmostApplication()
	local chooser = hs.chooser.new(function (choice)
		if choice then
			if choice["text"] ~= "Clear" then
				topmostApplication:activate()
				hs.eventtap.keyStrokes(choice["subText"])
			else
				versions = {}
			end
		end
	end)
	local choices = {
		{
			["text"] = "Mac", 
		["subText"] = vers("Mac")}, 
		{
			["text"] = "macOS", 
		["subText"] = vers("macOS")}, 
		{
			["text"] = "Mac + macOS", 
		["subText"] = vers("Mac") .. " running " .. vers("macOS")}, 
		-- {
		-- ["text"] = "Safari"
		-- },
		{
			["text"] = "Xcode", 
		["subText"] = vers("Xcode")}, 
		{
			["text"] = "Xcode + macOS", 
		["subText"] = vers("Xcode") .. "/" .. vers("macOS")}, 
		{
			["text"] = "Calendar", 
		["subText"] = vers("Calendar")}, 
		{
			["text"] = "Mail", 
		["subText"] = vers("Mail")}, 
		{
			["text"] = "Messages", 
		["subText"] = vers("Messages")}, 
		{
			["text"] = "Preview", 
		["subText"] = vers("Preview")}, 
		{
			["text"] = "Clear", 
			["subText"] = "Reset cached values"
		}, 
	}
	chooser:choices(choices)
	chooser:show()
end)
