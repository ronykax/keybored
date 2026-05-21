import Cocoa
import Combine

class MonitorState: ObservableObject {
    @Published var hotkeyCount = 0
}

let monitorState = MonitorState()

enum Monitor {
    static private var hyperEnabled = false
    static private var hyperActive = false

    static var hotkeys: [Hotkey: Action] = [:]

    static func setHyperEnabled(_ enabled: Bool) {
        Monitor.hyperEnabled = enabled
        Mapping.remapCapsLock(enabled)
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
                // get key code from event
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

                // get modifiers from event
                let modifiers = event.flags.intersection([
                    .maskCommand, .maskShift, .maskAlternate, .maskControl,
                ])

                // build ID from key code and modifiers
                let id = Hotkey(keyCode: keyCode, modifiers: modifiers)

                // run the ID's script if it exists
                if let action = Monitor.hotkeys[id] {
                    if event.type == .keyDown {
                        Monitor.runScript(action)
                    }
                    
                    return nil // swallow both
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

    static private func runScript(_ action: Action) {
        DispatchQueue.global(qos: .userInitiated).async {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: action.binary)
            process.arguments = action.arguments
            try? process.run()
        }
    }
}
