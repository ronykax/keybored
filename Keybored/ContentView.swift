import SwiftUI
import ServiceManagement
import ServiceManagement

struct ContentView: View {
    let configPath: String
    let hotkeyCount: Int
    @State private var launchAtLogin = SMAppService.mainApp.status == .enabled

    var body: some View {
        VStack(spacing: 0) {
            Image("AppBanner")
                .resizable()
                .scaledToFit()
                .frame(height: 93)
                .padding(.horizontal, -16)
                .overlay {
                    Color.clear.contentShape(Rectangle())
                        .gesture(DragGesture().onChanged { _ in
                            NSApp.keyWindow?.performDrag(with: NSApp.currentEvent!)
                        })
                }

            VStack(alignment: .leading, spacing: 12) {
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
                        .toggleStyle(.checkbox)
                        .onChange(of: launchAtLogin) {
                            setLaunchAtLogin(launchAtLogin)
                        }
                }

                Button {
                    NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: configPath)])
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
    
    func setLaunchAtLogin(_ enable: Bool) {
        do {
            if enable {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("Failed to \(enable ? "enable" : "disable") launch at login: \(error)")
            launchAtLogin = SMAppService.mainApp.status == .enabled // revert on failure
        }
    }
}

private struct FixedIconLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 8) {
            configuration.icon.frame(width: 16, height: 16)
            configuration.title
        }
    }
}
