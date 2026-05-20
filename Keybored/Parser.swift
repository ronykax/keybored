import CoreGraphics
import Foundation

enum Parser {
    static func filePath() -> URL {
        FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("keybored.json")
    }

    static func load() -> [ConfigItem] {
        let path = filePath()
        var result: [ConfigItem] = []

        if let data = try? Data(contentsOf: path) {
            result = (try? JSONDecoder().decode([ConfigItem].self, from: data)) ?? []
        } else {
            let empty = try! JSONEncoder().encode([ConfigItem]())
            try! empty.write(to: path)
        }

        return result
    }

    static func resolve(_ unresolved: [ConfigItem]) -> [Hotkey: Action] {
        var result: [Hotkey: Action] = [:]

        for x in unresolved {
            // convert string modifiers to CGEventFlags
            let flags = x.modifiers.reduce(CGEventFlags()) { acc, mod in
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
            guard let keyCode = Mapping.keyCodeFor(x.key) else { continue }
            result[Hotkey(keyCode: keyCode, modifiers: flags)] = Action(binary: x.binary, arguments: x.arguments)
        }

        return result
    }
}
