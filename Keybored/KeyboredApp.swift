import SwiftUI

@main
struct KeyboredApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @AppStorage("showMenuBar") var showMenuBar = true

    var body: some Scene {
        Window("Keybored", id: "main") {
            SettingsView()
                .frame(width: 400)
                .windowResizeBehavior(.disabled)
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)
        
        MenuBarExtra("hi", systemImage: "keyboard.fill", isInserted: $showMenuBar) {
            MenuBarView()
        }
    }
}
