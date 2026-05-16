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
                print(error)
            }
        } else {
            let alert = NSAlert()
            alert.messageText = "Permission Required"
            alert.informativeText = "Enable accessibility access for Keybored to detect shortcuts.\n\nRelaunch the app when you're done."

            alert.addButton(withTitle: "Continue")

            alert.runModal()

            NSWorkspace.shared.open(
                URL(string:
                "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
            )

            #if !DEBUG
            NSApplication.shared.terminate(nil)
            #endif
        }
    }
    
    // decode and return list of hotkeys from config file (create config file if it doesn't exist)
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
