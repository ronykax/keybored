import AppKit

struct Shortcut {
    let modifiers: NSEvent.ModifierFlags
    let key: String
    let command: String

    init?(string: String, command: String) {
        var mods: NSEvent.ModifierFlags = []
        let parts = string.lowercased().split(separator: "+").map(String.init)

        guard let lastKey = parts.last else { return nil }
        self.key = lastKey

        if parts.contains("command") { mods.insert(.command) }
        if parts.contains("control") { mods.insert(.control) }
        if parts.contains("option") { mods.insert(.option) }
        if parts.contains("shift") { mods.insert(.shift) }

        self.modifiers = mods
        self.command = command
    }

    func matches(event: NSEvent) -> Bool {
        // Strip out irrelevant system flags (like caps lock or num pad)
        let eventMods = event.modifierFlags.intersection([.command, .control, .option, .shift])
        let eventChar = event.charactersIgnoringModifiers?.lowercased() ?? ""

        return eventMods == modifiers && eventChar == key
    }
}
