import SwiftUI

@main
struct KeyboredApp: App {
    init() {
        if AXIsProcessTrusted() {
            let hyperKeyEnabled = UserDefaults.standard.bool(forKey: "hyperKeyEnabled")
            Monitor.setHyperEnabled(hyperKeyEnabled)

            let unresolvedHotkeys = HotkeyLoader.getUnresolvedHotkeys()
            Monitor.hotkeys = HotkeyLoader.resolveHotkeys(unresolvedHotkeys)

            Monitor.start()
        } else {
            requestPermissionAndQuit()
        }
    }

    var body: some Scene {
        Window("Keybored", id: "main") {
            ContentView()
        }
    }

    func requestPermissionAndQuit() {
        let alert = NSAlert()
        alert.messageText = "Accessibility permission required"
        alert.informativeText = "Enable Accessibility access in System Settings."
        alert.addButton(withTitle: "Continue")
        alert.runModal()

        if let url = URL(
            string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")
        {
            NSWorkspace.shared.open(url)
        }

        #if !DEBUG
            NSApp.terminate(nil)
        #endif
    }
}
