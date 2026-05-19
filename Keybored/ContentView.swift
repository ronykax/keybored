import SwiftUI

struct ContentView: View {
    @AppStorage("hyperKeyEnabled") var hyperKeyEnabled = false

    var body: some View {
        VStack {
            Toggle("Hyper Key", isOn: $hyperKeyEnabled)
                .onChange(of: hyperKeyEnabled) { _, newValue in
                    Monitor.setHyperEnabled(newValue)
                }
                .controlSize(.mini)
                .toggleStyle(.switch)
            Button("Reload Hotkeys") {
                let unresolvedHotkeys = Parser.load()
                Monitor.hotkeys = Parser.resolve(unresolvedHotkeys)
            }
        }
        .padding()
        .frame(width: 400)
    }
}

#Preview {
    ContentView()
}
