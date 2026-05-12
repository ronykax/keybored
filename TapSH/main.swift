import CoreGraphics
import Foundation

let hotkeys = loadHotkeys(from: "/Users/rony/Projects/tapsh/config.json")
print("Loaded hotkeys: \(hotkeys)")

// Initialize our tap manager
let tapManager = HotkeyManager(hotkeys: hotkeys)

do {
    try tapManager.start()
    print("Listening for hotkeys... (Press Ctrl+C to quit)")

    // This keeps the CLI running forever, listening to events
    CFRunLoopRun()
} catch {
    print("Failed to start event tap: \(error)")
}
