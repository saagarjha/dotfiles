-- Switch between windows with Hyper+number keys

-- The set of saved windows
local windows = {}

-- Set a window to show later
function setWindow(windowNumber)
	windows[windowNumber] = hs.window.frontmostWindow()
	k.triggered = true
end

-- Show window
function focusWindow(windowNumber)
	windows[windowNumber]:focus()
	k.triggered = true
end

-- List currently set windows
function listWindows()
	local t = {}
	for i = 1, 9 do
		if windows[i] and windows[i]:application() and windows[i]:title() and windows[i]:application():title() then
			t[#t + 1] = (tostring(i) .. ": " .. windows[i]:application():title() .. " - " .. windows[i]:title()):sub(0, 75)
		end
	end
	hs.alert.show(table.concat(t, "\n"))
end

-- Clear set windows
function clearWindows()
	windows = {}
end

-- Bind Hyper+1-9 to window switching
for i = 1, 9 do
	k:bind({"cmd"}, tostring(i), nil, function() setWindow(i) end)
	k:bind({"alt"}, tostring(i), nil, function() focusWindow(i) end)
end

-- Bind Hyper+0 to window switcher/clearing
k:bind({"cmd"}, '0', nil, function() clearWindows(0) end)
k:bind({"alt"}, '0', nil, function() listWindows(0) end)
