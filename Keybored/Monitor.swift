import Cocoa

enum Monitor {
    static private var hyperEnabled = false
    static private var hyperActive = false

    static var hotkeys: [Hotkey: String] = [:]

    static func setHyperEnabled(_ enabled: Bool) {
        Monitor.hyperEnabled = enabled

        let task = Process()
        task.launchPath = "/usr/bin/hidutil"

        if enabled {
            task.arguments = [
                "property", "--set",
                "{\"UserKeyMapping\":[{\"HIDKeyboardModifierMappingSrc\":0x700000039,\"HIDKeyboardModifierMappingDst\":0x70000006D}]}",
            ]
        } else {
            task.arguments = ["property", "--set", "{\"UserKeyMapping\":[]}"]
        }

        task.launch()
    }

    static func start() {
        let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(
                (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.keyUp.rawValue)
            ),
            callback: { _, _, event, _ in
                let keyCode = CGKeyCode(event.getIntegerValueField(.keyboardEventKeycode))

                // f18 = 79
                if keyCode == 79 && Monitor.hyperEnabled {
                    Monitor.hyperActive = event.type == .keyDown
                    return nil  // swallow f18
                }

                // inject all four modifier keys if hyper is active
                if Monitor.hyperActive {
                    event.flags = event.flags.union([
                        .maskCommand, .maskShift, .maskAlternate, .maskControl,
                    ])
                }

                let modifiers = event.flags.intersection([
                    .maskCommand, .maskShift, .maskAlternate, .maskControl,
                ])
                let id = Hotkey(keyCode: keyCode, modifiers: modifiers)

                if let action = Monitor.hotkeys[id] {
                    if event.type == .keyDown {
                        print("Hotkey matched: \(action)")
                        Monitor.runScript(action)
                    }

                    return nil  // swallow both
                }

                return Unmanaged.passRetained(event)  // pass through
            },
            userInfo: nil
        )!

        // add it to the run loop so it keeps running
        let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
    }

    static private func runScript(_ script: String) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        process.arguments = ["-c", script]
        try? process.run()
    }
}
