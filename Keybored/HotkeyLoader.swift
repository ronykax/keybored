import CoreGraphics
import Foundation

enum HotkeyLoader {
    static func getUnresolvedHotkeys() -> [HotkeyUnresolved] {
        // load or create ~/keybored.json
        let path = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(
            "keybored.json")

        var result: [HotkeyUnresolved] = []

        if let data = try? Data(contentsOf: path) {
            result = (try? JSONDecoder().decode([HotkeyUnresolved].self, from: data)) ?? []
        } else {
            let empty = try! JSONEncoder().encode([HotkeyUnresolved]())
            try! empty.write(to: path)
        }

        return result
    }

    static func resolveHotkeys(_ unresolved: [HotkeyUnresolved]) -> [HotkeyID: String] {
        var result: [HotkeyID: String] = [:]

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
            result[HotkeyID(keyCode: keyCode, modifiers: flags)] = h.run
        }

        return result
    }
}
