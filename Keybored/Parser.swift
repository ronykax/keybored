import CoreGraphics
import Foundation

enum Parser {
    static func load() -> [HotkeyConfig] {
        // load or create ~/keybored.json
        let path = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(
            "keybored.json")

        var result: [HotkeyConfig] = []

        if let data = try? Data(contentsOf: path) {
            result = (try? JSONDecoder().decode([HotkeyConfig].self, from: data)) ?? []
        } else {
            let empty = try! JSONEncoder().encode([HotkeyConfig]())
            try! empty.write(to: path)
        }

        return result
    }

    static func resolve(_ unresolved: [HotkeyConfig]) -> [Hotkey: String] {
        var result: [Hotkey: String] = [:]

        for h in unresolved {
            // convert string modifiers to CGEventFlags
            let flags = h.modifiers.reduce(CGEventFlags()) { acc, mod in
                switch mod {
                case "cmd":
                    return CGEventFlags(rawValue: acc.rawValue | CGEventFlags.maskCommand.rawValue)
                case "shift":
                    return CGEventFlags(rawValue: acc.rawValue | CGEventFlags.maskShift.rawValue)
                case "opt":
                    return CGEventFlags(
                        rawValue: acc.rawValue | CGEventFlags.maskAlternate.rawValue)
                case "ctrl":
                    return CGEventFlags(rawValue: acc.rawValue | CGEventFlags.maskControl.rawValue)
                default:
                    return acc
                }
            }

            // resolve key string to key code
            guard let keyCode = keyCodeFor(h.key) else { continue }
            result[Hotkey(keyCode: keyCode, modifiers: flags)] = h.run
        }

        return result
    }
}
