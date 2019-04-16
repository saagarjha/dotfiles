-- Bring up a GUI window switcher with Hyper+space

local chooser = nil
local windows = nil
local choices = nil

-- Delete chooser and reset variables
function deleteChooser(...)
	chooser:delete()
	chooser = nil
	windows = nil
	choices = nil
end

-- Filter the results
function queryChangedCallback(query)
	local filteredChoices = {}
	if query == "" then
		filteredChoices = choices
	else
		for i = 1, #choices do
			local choice = choices[i]
			if fuzzyMatch(choice.text, query) or fuzzyMatch(choice.subText, query) then
				filteredChoices[#filteredChoices + 1] = choice
			end
		end
	end
	chooser:choices(filteredChoices)
	chooser:rows(#filteredChoices)
end

-- Find a window by id in windows
function findWindow(id)
	for i = 1, #windows do
		if windows[i]:id() == id then
			return windows[i]
		end
	end
	return nil
end

function windowSwitcher()
	if chooser then
		deleteChooser()
	else
		windows = windowFilter:getWindows()
		-- windows = hs.window.allWindows()
		choices = {}
		for i, w in pairs(windows) do
			choices[i] = {
				text = w:title(), 
				subText = w:application():title(), 
				image = w:snapshot(), 
				id = w:id(), 
			}
		end
		chooser = hs.chooser.new(function(choice)
			if choice then
				findWindow(choice.id):focus()
			end
			deleteChooser()
		end)
		chooser:choices(choices)
		chooser:queryChangedCallback(queryChangedCallback)
		chooser:show()
	end
end

-- k:bind({}, "space", nil, function() windowSwitcher() end)


local autoHideDelay = 5
local autoHideFadeOut = 1
local rows = 3
local columns = 3
local spacing = 30
local searchHeight = 0 -- 50
local searchInset = 0 -- 10
local font = hs.styledtext.defaultFonts.system
local searchFont = {name = hs.styledtext.defaultFonts.system.name, size = 25}
local textColor = {red = 255, green = 255, blue = 255, alpha = 1}
local backgroundColor = {red = 0, green = 0, blue = 0, alpha = 0.75}
local alignment = "center"

local drawingObjects = {}
local hideTimer = nil
local windows = {}
local filter = ""

-- eventTap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
-- local code = event:getKeyCode()
-- if code == hs.keycodes.map.delete then
-- filter = filter:sub(1, -2)
-- elseif code == hs.keycodes.map.escape then
-- hideWindows(0)
-- return
-- else
-- local character = hs.keycodes.map[code]
-- if #character == 1 then
-- filter = filter .. character
-- end
-- end
-- hs.alert(filter)
-- print(filter)
-- hideWindows(0)
-- searchWindows()
-- return true
-- end)

function searchWindows()
	windows = windowFilter:getWindows()
	-- local i = 1
	-- local filteredWindows = {}
	-- for j=1,#windows do
	-- local window = windows[i]
	-- if fuzzyMatch(window:title(), filter) then
	-- filteredWindows[i] = window
	-- i = i + 1
	-- end
	-- end
	-- windows = filteredWindows
	if hideTimer then
		hideTimer:stop()
		hideTimer = nil
	end
	hideWindows(0)
	showWindows(windows)
end

-- Draw a grid of the windows, for use with focusWindow.
function showWindows(windows)
	-- local windows = windowFilter:getWindows()
	local frame = hs.screen.mainScreen():fullFrame()
	drawingObjects[#drawingObjects + 1] = hs.drawing.rectangle(frame)
	:setFillColor(backgroundColor)
	:setStrokeColor(backgroundColor)
	local searchText = hs.styledtext.new(filter, {
		font = searchFont, 
		color = textColor, 
		paragraphStyle = {alignment = alignment}, 
	})
	local textSize = hs.drawing.getTextDrawingSize(searchText)
	-- Bug with getTextDrawingSize
	textSize.w = textSize.w + 8
	drawingObjects[#drawingObjects + 1] = hs.drawing.text(hs.geometry(
		frame.w / 2 - textSize.w / 2, 
		frame.y + searchInset, 
		textSize.w, 
	textSize.h), 
	searchText
)
frame.y = frame.y + searchHeight
frame.h = frame.h - searchHeight
local height = (frame.h - spacing * (rows + 1)) / rows
local width = (frame.w - spacing * (columns + 1)) / columns
for i = 1, #windows do
	if i <= rows * columns then
		local row = math.floor((i - 1) / rows)
		local column = (i - 1) % rows
		drawingObjects[#drawingObjects + 1] = hs.drawing.image(hs.geometry(
			spacing * (column + 1) + width * column, 
			searchHeight + spacing * (row + 1) + height * row, 
			width, 
		height), 
	windows[i]:snapshot())
	local styledText = hs.styledtext.new(i .. ": " .. windows[i]:title(), {
		font = font, 
		color = textColor, 
		paragraphStyle = {alignment = alignment}, 
	})
	local textSize = hs.drawing.getTextDrawingSize(styledText)
	-- Bug with getTextDrawingSize
	textSize.w = textSize.w + 8
	local title = hs.drawing.text(hs.geometry(
		spacing * (column + 1) + width * column + width / 2 - math.min(textSize.w, frame.w / columns) / 2, 
		searchHeight + spacing * (row + 1) + height * (row + 1) + spacing / 2 - textSize.h / 2, 
		math.min(textSize.w, frame.w / columns), 
	textSize.h), 
	styledText
)
drawingObjects[#drawingObjects + 1] = hs.drawing.rectangle(title:frame())
:setRoundedRectRadii(5, 5)
:setFillColor(backgroundColor)
:setStrokeColor(backgroundColor)
drawingObjects[#drawingObjects + 1] = title
end
end
for i = 1, #drawingObjects do
	drawingObjects[i]:show(0)
end
-- eventTap:start()
hideTimer = hs.timer.doAfter(autoHideDelay, function()
	hideWindows(autoHideFadeOut)
end)
end

-- Hide the windows shown with showWindows, with a fade out of time
function hideWindows(time)
	for i = 1, #drawingObjects do
		hideObject(drawingObjects[i], time)
	end
	drawingObjects = {}
	-- eventTap:stop()
	-- filter = ""
	return
end

-- Hide the specified object with the delay, then delete it
function hideObject(object, time)
	object:hide(time)
	hs.timer.doAfter(time, function() object:delete() end)
end

-- Focus the window referred to by i
function focusWindow(i)
	-- windowFilter:getWindows()[i]:focus()
	windows[i]:focus()
	hideWindows(0)
end

-- Bind Hyper+1-9 to window switching
for i = 1, 9 do
	k:bind({}, tostring(i), nil, function() focusWindow(i) end)
end


-- Bind Hyper+0 for window switcher
k:bind({}, '0', nil, function() searchWindows() end)

