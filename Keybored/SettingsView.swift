import ServiceManagement
import SwiftUI

struct SettingsView: View {
    @AppStorage("hyperKeyEnabled") var hyperKeyEnabled = true
    @AppStorage("showMenuBar") var showMenuBar = true
    @AppStorage("quickPressAction") var quickPressAction = "nothing"
    @ObservedObject var state = monitorState

    var body: some View {
        VStack {
            Form {
                Section("General") {
                    HStack {
                        Text("Loaded \(state.hotkeyCount) hotkeys")
                        Spacer()

                        Button {
                            let filePath = Parser.filePath()
                            NSWorkspace.shared.activateFileViewerSelecting([filePath])
                        } label: {
                            Image(systemName: "folder")
                        }
                        .buttonStyle(.plain)

                        Button("Reload") {
                            let unresolvedHotkeys = Parser.load()
                            Monitor.hotkeys = Parser.resolve(unresolvedHotkeys)
                            monitorState.hotkeyCount = Monitor.hotkeys.count  // notify the view
                        }
                    }

                    Toggle(
                        "Launch at login",
                        isOn: Binding(
                            get: { SMAppService.mainApp.status == .enabled },
                            set: { enable in
                                if enable {
                                    try? SMAppService.mainApp.register()
                                } else {
                                    try? SMAppService.mainApp.unregister()
                                }
                            }
                        ))

                    VStack(alignment: .leading) {
                        Toggle("Show menu bar icon", isOn: $showMenuBar)
                        Text("If disabled, open the app from Finder or Spotlight.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Hyper Key") {
                    VStack(alignment: .leading) {
                        Toggle("Remap Caps Lock", isOn: $hyperKeyEnabled)
                            .onChange(of: hyperKeyEnabled) { _, newValue in
                                Monitor.setHyperKeyEnabled(newValue)
                            }
                        Text("Remap Caps Lock to  **􀆍􀆕􀆝􀆔**  for conflict-free shortcuts.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Picker("Quick press action", selection: $quickPressAction) {
                        Text("Nothing").tag("nothing")
                        Text("Caps Lock").tag("capslock")
                        Text("Escape").tag("escape")
                    }
                    .onChange(of: quickPressAction) { _, newValue in
                        Monitor.quickPressAction = newValue
                    }
                }
            }
            .formStyle(.grouped)
        }
    }
}

//#Preview {
//    ContentView()
//}
