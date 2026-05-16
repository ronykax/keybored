import SwiftUI

@main
struct KeyboredApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    let configPath: String
    let hotkeys: [Hotkey]
    private let tapManager: HotkeyManager
    
    init() {
        configPath = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("keybored.json").path
        
        hotkeys = Self.loadHotkeys(from: configPath)
        tapManager = HotkeyManager(hotkeys: hotkeys)
        
        let trusted = AXIsProcessTrusted()
        
        if trusted {
            do {
                try tapManager.start()
            } catch {
                print("failed to start event tap: \(error)")
            }
        } else {
            print("accessibility permission required - relaunch after granting")
        }
    }
    
    static func loadHotkeys(from path: String) -> [Hotkey] {
        let url = URL(fileURLWithPath: path)
        
        if !FileManager.default.fileExists(atPath: path) {
            try? "[]".write(to: url, atomically: true, encoding: .utf8)
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([Hotkey].self, from: data)
        } catch {
            print("Failed to load config:", error)
            return []
        }
    }
    
    var body: some Scene {
        Window("Keybored", id: "main") {
            ContentView(configPath: configPath, hotkeyCount: hotkeys.count)
                .windowResizeBehavior(.disabled)
                .windowMinimizeBehavior(.disabled)
                .onAppear { NSApp.setActivationPolicy(.regular) }
                .onDisappear { NSApp.setActivationPolicy(.accessory) }
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)
    }
}
