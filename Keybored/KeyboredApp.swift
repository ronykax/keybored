import SwiftUI

@main
struct KeyboredApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    let configURL: URL
    let hotkeyCount: Int
    private let hotkeyManager: HotkeyManager

    init() {
        let configURL = Hotkey.configURL()
        let loadedHotkeys = Hotkey.load(from: configURL)
        let manager = HotkeyManager(hotkeys: loadedHotkeys)

        self.configURL = configURL
        self.hotkeyCount = manager.hotkeyCount
        self.hotkeyManager = manager

        Self.requestAccessibilityAndStartHotkeys(
            manager: manager,
            isAccessibilityGranted: AXIsProcessTrusted()
        )
    }

    var body: some Scene {
        settingsWindow
    }

    private var settingsWindow: some Scene {
        Window("Keybored", id: "main") {
            ContentView(configURL: configURL, hotkeyCount: hotkeyCount)
                .windowResizeBehavior(.disabled)
                .windowMinimizeBehavior(.disabled)
                .onAppear { NSApp.setActivationPolicy(.regular) }
                .onDisappear { NSApp.setActivationPolicy(.accessory) }
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)
    }

    private static func requestAccessibilityAndStartHotkeys(
        manager: HotkeyManager,
        isAccessibilityGranted: Bool
    ) {
        if isAccessibilityGranted {
            startHotkeyListener(manager: manager)
        } else {
            promptForAccessibilityPermission()
        }
    }

    private static func startHotkeyListener(manager: HotkeyManager) {
        do {
            try manager.start()
        } catch {
            print(error)
        }
    }

    private static func promptForAccessibilityPermission() {
        let alert = NSAlert()
        alert.messageText = "Permission Required"
        alert.informativeText = """
            Enable accessibility access for Keybored to detect shortcuts.

            Relaunch the app when you're done.
            """
        alert.addButton(withTitle: "Continue")
        alert.runModal()

        NSWorkspace.shared.open(
            URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        )

        #if !DEBUG
        NSApplication.shared.terminate(nil)
        #endif
    }
}
