import SwiftUI
import ServiceManagement

struct ContentView: View {
    let configURL: URL
    let hotkeyCount: Int
    @State private var launchAtLogin = SMAppService.mainApp.status == .enabled
    @State private var quickPressAction: String = "capslock"
    @AppStorage("showMenuBarIcon") private var showMenuBarIcon = true

    var body: some View {
        VStack(spacing: 0) {
            Image("AppBanner")
                .resizable()
                .scaledToFit()
                .frame(height: 107)
                .padding(.horizontal, -16)

            VStack(alignment: .leading, spacing: 8) {
                Text("General")
                    .padding(.vertical, 4)
                    .foregroundStyle(.secondary)
                    .font(.headline)
                
                HStack {
                    Label("Loaded 6 hotkeys", systemImage: "keyboard.fill")
                        .foregroundStyle(.primary)
                        .monospacedDigit()
                    Spacer()
                    Button("Show in Finder") {
                        NSWorkspace.shared.activateFileViewerSelecting([configURL])
                    }
                    .controlSize(.small)
                }

                HStack {
                    Label("Launch at login", systemImage: "power").foregroundStyle(.primary)
                    Spacer()
                    Toggle("", isOn: $launchAtLogin)
                        .labelsHidden()
                        .toggleStyle(.switch)
                        .controlSize(.mini)
                        .onChange(of: launchAtLogin) {
                            setLaunchAtLogin(enabled: launchAtLogin)
                        }
                }
                
                HStack {
                    Label("Show icon in menu bar", systemImage: "pin.fill").foregroundStyle(.primary)
                    Spacer()
                    Toggle("", isOn: $showMenuBarIcon)
                        .labelsHidden()
                        .toggleStyle(.switch)
                        .controlSize(.mini)
                }
                
                Text("Hyper Key")
                    .padding(.vertical, 4)
                    .foregroundStyle(.secondary)
                    .font(.headline)
                    .padding(.top)
                
                HStack {
                    Label("Remap Caps Lock", systemImage: "capslock.fill").foregroundStyle(.primary)
                    Spacer()
                    Toggle("", isOn: $launchAtLogin)
                        .labelsHidden()
                        .toggleStyle(.switch)
                        .controlSize(.mini)
                }
                
                HStack {
                    Label("Quick press action", systemImage: "button.horizontal.top.press.fill").foregroundStyle(.primary)
                    Spacer()
                    Picker("", selection: $quickPressAction) {
                        Text("Caps Lock").tag("capslock")
                        Text("Escape").tag("escape")
                        Text("Nothing").tag("nothing")
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                    .controlSize(.small)
                }
            }
            .padding()
        }
        .labelStyle(FixedIconLabelStyle())
        .frame(width: 320)
    }

    func setLaunchAtLogin(enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("Failed to \(enabled ? "enable" : "disable") launch at login: \(error)")
            launchAtLogin = SMAppService.mainApp.status == .enabled
        }
    }
}

private struct FixedIconLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 8) {
            configuration.icon.frame(width: 20, height: 20)
            configuration.title
        }
    }
}

#Preview {
    ContentView(
        configURL: URL(string: "https://example.com/config.json")!,
        hotkeyCount: 5
    )
}
