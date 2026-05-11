import AppKit

let configPath = "config.json"
guard let configData = Config.load(from: configPath) else {
    print("Error: Could not load or parse \(configPath)")
    exit(1)
}

let shortcuts = configData.compactMap { Shortcut(string: $0.key, command: $0.value) }
print("Loaded \(shortcuts.count) shortcuts.")

// macOS requires Accessibility permissions for background keystroke monitoring
let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
let isTrusted = AXIsProcessTrustedWithOptions(options as CFDictionary)

if !isTrusted {
    print(
        "⚠️ Please grant Accessibility permissions in System Settings -> Privacy & Security, then restart the app."
    )
} else {
    print("Listening for shortcuts in the background...")
}

// Listen to all keystrokes globally
NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
    for shortcut in shortcuts {
        if shortcut.matches(event: event) {
            Executor.run(shortcut.command)
        }
    }
}

// Required to keep the CLI alive and capable of receiving NSEvents
let app = NSApplication.shared
app.setActivationPolicy(.accessory)  // Keeps it out of the dock
app.run()
