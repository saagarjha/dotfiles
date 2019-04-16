k:bind({}, "F10", nil, function() 
	local current = hs.audiodevice.current()
	local devices = hs.battery.privateBluetoothBatteryInfo()
	local battery
	for _, device in pairs(devices) do
		if string.match(device.name, "AirPods") then
			battery = device
			break
		end
	end
	local volume = string.format("Volume: %.0f%%", current.volume)
	if battery then
		hs.notify.show(current.name, 
			"L: " .. battery.batteryPercentLeft .. "% " .. 
			"R: " .. battery.batteryPercentRight .. "%"
		, volume)
	else
		hs.notify.show("No AirPods connected", string.format("Battery: %.1f%%", hs.battery.percentage()), volume)
	end
end)

k:bind({}, "F11", nil, function() 
	hs.audiodevice.findOutputByName("Built-in"):setDefaultOutputDevice()
end)

k:bind({}, "F12", nil, function() 
	hs.audiodevice.findOutputByName("AirPods"):setDefaultOutputDevice()
end)
