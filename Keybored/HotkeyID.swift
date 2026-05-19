import CoreGraphics
import Foundation

struct HotkeyID: Hashable {
    let keyCode: CGKeyCode
    let modifiers: UInt64

    init(keyCode: CGKeyCode, modifiers: CGEventFlags) {
        self.keyCode = keyCode
        self.modifiers = modifiers.rawValue
    }
}

struct HotkeyUnresolved: Codable {
    var modifiers: [String]
    var key: String
    var run: String
}
