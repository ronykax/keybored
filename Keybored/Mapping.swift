import Carbon.HIToolbox
import CoreGraphics

enum ModifierToken {
    static let command = "cmd"
    static let control = "ctrl"
    static let option = "opt"
    static let shift = "shift"
}

struct Mapping {
    static let trackedModifierFlags: CGEventFlags = [
        .maskCommand, .maskControl, .maskAlternate, .maskShift,
    ]

    static func modifierFlags(from modifiers: [String]) -> CGEventFlags {
        var flags: CGEventFlags = []

        if modifiers.contains(ModifierToken.command) { flags.insert(.maskCommand) }
        if modifiers.contains(ModifierToken.control) { flags.insert(.maskControl) }
        if modifiers.contains(ModifierToken.option) { flags.insert(.maskAlternate) }
        if modifiers.contains(ModifierToken.shift) { flags.insert(.maskShift) }

        return flags
    }

    static func keyCode(for key: String) -> Int64 {
        guard let firstChar = key.lowercased().first,
              let code = keyCodeMap[firstChar]
        else {
            return -1
        }

        return Int64(code)
    }
}

// Built once at first use from the current keyboard layout.
private let keyCodeMap: [Character: CGKeyCode] = {
    guard
        let inputSource = TISCopyCurrentKeyboardLayoutInputSource()?.takeRetainedValue(),
        let layoutData = TISGetInputSourceProperty(inputSource, kTISPropertyUnicodeKeyLayoutData)
    else {
        return [:]
    }

    let data = unsafeBitCast(layoutData, to: CFData.self)
    let keyboardLayout = unsafeBitCast(
        CFDataGetBytePtr(data),
        to: UnsafePointer<UCKeyboardLayout>.self
    )

    var map = [Character: CGKeyCode](minimumCapacity: 128)

    for keyCode in 0..<128 {
        var deadKeyState: UInt32 = 0
        var chars: [UniChar] = Array(repeating: 0, count: 4)
        var length = 0

        let result = UCKeyTranslate(
            keyboardLayout,
            UInt16(keyCode),
            UInt16(kUCKeyActionDisplay),
            0,
            UInt32(LMGetKbdType()),
            OptionBits(kUCKeyTranslateNoDeadKeysBit),
            &deadKeyState,
            chars.count,
            &length,
            &chars
        )

        guard result == noErr, length > 0 else { continue }

        let produced = String(utf16CodeUnits: chars, count: length).lowercased()

        if let char = produced.first {
            map[char] = CGKeyCode(keyCode)
        }
    }

    return map
}()
