import Carbon.HIToolbox

// Maps your string array to actual macOS bitmask flags
func mapModifiers(_ modifiers: [String]) -> CGEventFlags {
    var flags: CGEventFlags = []

    if modifiers.contains("cmd") { flags.insert(.maskCommand) }
    if modifiers.contains("ctrl") { flags.insert(.maskControl) }
    if modifiers.contains("opt") { flags.insert(.maskAlternate) }
    if modifiers.contains("shift") { flags.insert(.maskShift) }

    return flags
}

// Maps your string key to a macOS Virtual KeyCode
func mapKeyToKeyCode(_ key: String) -> Int64 {
    guard let firstChar = key.first,
        let code = keyCode(for: firstChar)
    else {
        return -1
    }

    return Int64(code)
}

func keyCode(for character: Character) -> CGKeyCode? {
    guard let inputSource = TISCopyCurrentKeyboardLayoutInputSource()?.takeRetainedValue(),
        let layoutData = TISGetInputSourceProperty(
            inputSource,
            kTISPropertyUnicodeKeyLayoutData
        )
    else {
        return nil
    }

    let data = unsafeBitCast(layoutData, to: CFData.self)
    let keyboardLayout = unsafeBitCast(
        CFDataGetBytePtr(data),
        to: UnsafePointer<UCKeyboardLayout>.self
    )

    let target = String(character).lowercased()

    for keyCode in 0..<128 {
        var deadKeyState: UInt32 = 0
        var chars: [UniChar] = Array(repeating: 0, count: 4)
        var length: Int = 0

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

        if result == noErr {
            let produced = String(utf16CodeUnits: chars, count: length).lowercased()

            if produced == target {
                return CGKeyCode(keyCode)
            }
        }
    }

    return nil
}
