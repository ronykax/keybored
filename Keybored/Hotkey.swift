import CoreGraphics
import Foundation

struct Hotkey: Hashable, Identifiable {
    var id: Self { self }
    let keyCode: CGKeyCode
    let modifiers: UInt64

    init(keyCode: CGKeyCode, modifiers: CGEventFlags) {
        self.keyCode = keyCode
        self.modifiers = modifiers.rawValue
    }
}

struct Action: Hashable {
    let binary: String
    let arguments: [String]
}

struct HotkeyConfig: Codable {
    var modifiers: [String]
    var key: String
    var binary: String
    var arguments: [String]
}
