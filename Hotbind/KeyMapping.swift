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

// O(1) lookup into the map built below — no layout fetch, no scan
func mapKeyToKeyCode(_ key: String) -> Int64 {
    guard let firstChar = key.lowercased().first,
        let code = keyCodeMap[firstChar]
    else {
        return -1
    }

    return Int64(code)
}

// Scans all 128 virtual key codes exactly once at startup and maps the
// character each one produces (unmodified, lowercase) to its key code.
// Swift globals are lazily initialized, so this runs on first access.
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
