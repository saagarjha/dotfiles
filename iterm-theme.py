#!/usr/bin/env python3

import iterm2


async def update_theme(connection):
	app = await iterm2.async_get_app(connection)
	# Themes have space-delimited attributes, one of which will be light or dark.
	theme = await app.async_get_variable("effectiveTheme")
	parts = theme.split(" ")
	preset_name = "Fixed Solarized"
	if "dark" in parts:
		preset_name += " Dark"
	else:
		preset_name += " Light"

	# Update the list of all profiles and iterate over them.
	profiles = await iterm2.PartialProfile.async_get(connection)
	for profile in profiles:
		preset = await iterm2.ColorPreset.async_get(connection, preset_name + (" (nano)" if "nano" in profile.name else ""))
		await profile.async_set_color_preset(preset)


async def main(connection):
	await update_theme(connection)
	async with iterm2.VariableMonitor(connection, iterm2.VariableScopes.APP, "effectiveTheme", None) as monitor:
		while True:
			# Block until theme changes
			_ = await monitor.async_get()
			await update_theme(connection)

iterm2.run_forever(main)
