import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        if AXIsProcessTrusted() {
            let hyperKeyEnabled = UserDefaults.standard.bool(forKey: "hyperKeyEnabled")
            Monitor.setHyperKeyEnabled(hyperKeyEnabled)

            let quickPressAction = UserDefaults.standard.string(forKey: "quickPressAction")
            Monitor.quickPressAction = quickPressAction ?? "nothing"

            let unresolvedHotkeys = Parser.load()
            Monitor.hotkeys = Parser.resolve(unresolvedHotkeys)
            monitorState.hotkeyCount = Monitor.hotkeys.count  // notify the view

            Monitor.start()
        } else {
            requestPermissionAndQuit()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        Mapping.remapCapsLock(false)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        NSApp.setActivationPolicy(.accessory)
        return false
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows: Bool) -> Bool {
        NSApp.setActivationPolicy(.regular)
        NSApp.windows.first?.makeKeyAndOrderFront(nil)
        return true
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

        //        #if !DEBUG
        NSApp.terminate(nil)
        //        #endif
    }
}
