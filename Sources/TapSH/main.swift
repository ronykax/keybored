import CoreGraphics
import Foundation

let configPath: String = {
    if CommandLine.arguments.count == 2 {
        return CommandLine.arguments[1]
    }

    let fallbackPath = FileManager.default.currentDirectoryPath + "/config.json"
    return fallbackPath
}()

let hotkeys = loadHotkeys(from: configPath)
let tapManager = HotkeyManager(hotkeys: hotkeys)

do {
    try tapManager.start()
    CFRunLoopRun()
} catch {
    print("Failed to start event tap: \(error)")
}
