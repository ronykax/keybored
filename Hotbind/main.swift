import CoreGraphics
import Foundation

let configPath = FileManager.default.homeDirectoryForCurrentUser
    .appendingPathComponent("hotbind.json").path

let hotkeys = loadHotkeys(from: configPath)
let tapManager = HotkeyManager(hotkeys: hotkeys)

do {
    try tapManager.start()
    CFRunLoopRun()
} catch {
    print("Failed to start event tap: \(error)")
}
