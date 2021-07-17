-- Switch between apps with Hyper+Letter

-- Show app
function showApp(app)
	if hs.application.find(app):isRunning() then
		hs.application.launchOrFocus(app)
	end
end

-- Launch app (or show it, if it's already running)
function launchApp(app)
	if app == "Finder" or (app == "Ghidra" and hs.application.find("Ghidra")) then
		hs.application.get(app):activate(true)
	else
		hs.application.launchOrFocus(app)
	end
	k.triggered = true
end

-- Binds an app to showApp and launchApp
function bindApp(key, app)
	k:bind({}, key, nil, function() launchApp(app) end)
	-- k:bind({"cmd"}, key, nil, function() launchApp(app) end)
end

bindApp('a', "Activity Monitor")
bindApp('c', "Google Chrome Canary")
bindApp('d', "Fork")
bindApp('e', "Sublime Text")
bindApp('f', "Finder")
bindApp('g', "Messages")
bindApp('h', "Hopper Disassembler v4")
bindApp('i', "Simulator")
bindApp('j', "Eclipse")
bindApp('k', "Keynote")
bindApp('l', "Calendar")
bindApp('m', "Mail")
bindApp('n', "Numbers")
bindApp('o', "Notes")
bindApp('p', "Pages")
bindApp('q', "Ghidra")
bindApp('r', "Preview")
bindApp('s', hs.application.nameForBundleID("com.apple.SafariTechnologyPreview") and "Safari Technology Preview" or "Safari")
bindApp('t', hs.application.nameForBundleID("com.googlecode.iterm2") and "iTerm" or "Terminal")
bindApp('u', "iTunes")
bindApp('v', "Telegram")
bindApp('w', "Microsoft Word")
bindApp('x', table.pack(hs.execute("readlink /var/db/xcode_select_link", true):gsub("/Applications/", ""):gsub("/Contents/Developer\n", ""))[1])
bindApp('y', "Skype")
bindApp('/', "Dictionary")
