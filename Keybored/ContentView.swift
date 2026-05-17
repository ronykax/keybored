import SwiftUI
import ServiceManagement

struct ContentView: View {
    let configURL: URL
    let hotkeyCount: Int
    @State private var launchAtLogin = SMAppService.mainApp.status == .enabled

    var body: some View {
        VStack(spacing: 0) {
            Image("AppBanner")
                .resizable()
                .scaledToFit()
                .frame(height: 93)
                .padding(.horizontal, -16)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("Loaded hotkeys", systemImage: "keyboard.fill").foregroundStyle(.primary)
                    Spacer()
                    Text("\(hotkeyCount)").foregroundStyle(.secondary).monospacedDigit()
                }

                HStack {
                    Label("Launch at login", systemImage: "power").foregroundStyle(.primary)
                    Spacer()
                    Toggle("", isOn: $launchAtLogin)
                        .labelsHidden()
                        .toggleStyle(.switch)
                        .controlSize(.small)
                        .onChange(of: launchAtLogin) {
                            setLaunchAtLogin(enabled: launchAtLogin)
                        }
                }

                Button {
                    NSWorkspace.shared.activateFileViewerSelecting([configURL])
                } label: {
                    Label("Reveal configuration in Finder", systemImage: "folder.fill")
                }
                .buttonStyle(.plain)
                .foregroundStyle(.blue)

                Button {
                    if let url = URL(string: "https://x.com/ronykax") { NSWorkspace.shared.open(url) }
                } label: {
                    Label("Rony Kati on X", systemImage: "at")
                }
                .buttonStyle(.plain)
                .foregroundStyle(.blue)
            }
            .padding()
        }
        .labelStyle(FixedIconLabelStyle())
        .frame(width: 280)
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
