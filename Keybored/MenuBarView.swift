import SwiftUI

struct MenuBarView: View {
    var body: some View {
        Text("Keybored")
        
        Divider()
        
        Button {
            NSApp.setActivationPolicy(.regular)
            NSApp.windows.first?.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        } label: {
            Label("Show Window", systemImage: "macwindow")
        }
        
        Button {
            let unresolvedHotkeys = Parser.load()
            Monitor.hotkeys = Parser.resolve(unresolvedHotkeys)
            monitorState.hotkeyCount = Monitor.hotkeys.count  // notify the view
        } label: {
            Label("Relaod", systemImage: "arrow.clockwise")
        }
        
        Divider()
        
        Button {
            NSApp.terminate(nil)
        } label: {
            Label("Quit", systemImage: "power")
        }
    }
}
