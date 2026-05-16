import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    // Don't quit when the last window closes
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }
}
