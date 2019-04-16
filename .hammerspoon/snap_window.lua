-- Window snapping using Hyper+arrow keys

-- Keys currently pressed
local pressed = {
	up = false, 
	down = false, 
	left = false, 
	right = false
}

-- React to an arrow key press
function arrowPressed()
	local win = hs.window.focusedWindow()
	local f = win:frame()
	local screen = win:screen()
	local max = screen:frame()
	f.x = max.x
	f.y = max.y
	f.w = max.w
	f.h = max.h
	if pressed.left or pressed.right then
		if pressed.up then
			f.h = max.h / 2
		elseif pressed.down then
			f.h = max.h / 2
			f.y = max.y + max.h / 2
		end
	else
		if pressed.down then
			local window = hs.window.focusedWindow()
			-- window:centerOnScreen()
			-- local frame = window:frame()
			local frame = window:_frame()
			-- print("frame: " .. frame.x .. " " .. frame.y .. " " .. frame.w .. " " .. frame.h)
			local screen = window:screen():frame()
			-- print("screen: " .. screen.x .. " " .. screen.y .. " " .. screen.w .. " " .. screen.h)
			frame.x = screen.w / 2 - frame.w / 2
			frame.y = screen.h / 2 - frame.h / 2
			-- print("newFrame: " .. frame.x .. " " .. frame.y .. " " .. frame.w .. " " .. frame.h)
			-- print(hs.inspect(frame))
			window:setFrame(frame)
			return
		end
	end
	if pressed.left then
		f.w = max.w / 2
	elseif pressed.right then
		f.w = max.w / 2
		f.x = max.x + max.w / 2
	end
	win:setFrame(f)
end

-- Bind the Hyper+arrow keys
local directions = {"up", "down", "left", "right"}
for i = 1, #directions do
	k:bind({}, directions[i], function()
		pressed[directions[i]] = true
		arrowPressed()
	end, function()
		pressed[directions[i]] = false
	end)
end
