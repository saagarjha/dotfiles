import Foundation

// Annoyingly, IOKIt's HID headers are not exposed directly
func hidutil(properties: some Codable) throws {
	let value = String(data: try JSONEncoder().encode(properties), encoding: .utf8)!
	let process = Process()
	process.executableURL = URL(fileURLWithPath: "/usr/bin/hidutil")
	process.arguments = ["property", "--set", value]
	process.launch()
	process.waitUntilExit()
}

func setup() throws {
	try hidutil(properties: [
		"UserKeyMapping": [
			[
				"HIDKeyboardModifierMappingSrc": 0x7_0000_0039, // Caps lock
				"HIDKeyboardModifierMappingDst": 0x7_0000_006D, // F18
			]
		]
	])
}

func teardown() throws {
	try hidutil(properties: [
		"UserKeyMapping": [
			[String: Int](),
		]
	])
}

try setup()

let signals = [SIGINT, SIGTERM]

let sources = signals.map {
	signal($0, SIG_IGN)
	let source = DispatchSource.makeSignalSource(signal: $0)
	source.setEventHandler {
		try? teardown()
		exit(0)
	}
	source.resume()
	return source
}

dispatchMain()
