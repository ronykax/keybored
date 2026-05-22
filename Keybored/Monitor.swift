import Cocoa
import Combine
import IOKit

class MonitorState: ObservableObject {
    @Published var hotkeyCount = 0
}

let monitorState = MonitorState()

enum Monitor {
    static private var hyperKeyEnabled = false
    static private var hyperKeyActive = false
    static private var hyperKeyDownTime: Date? = nil
    static private var hyperKeyUsedAsModifier = false

    static var quickPressAction = "nothing"
    static var hotkeys: [Hotkey: Action] = [:]

    static func setHyperKeyEnabled(_ enabled: Bool) {
        Monitor.hyperKeyEnabled = enabled
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
                if keyCode == 79 && Monitor.hyperKeyEnabled {
                    if event.type == .keyDown {
                        // only record the first keydown, ignore repeats
                        if Monitor.hyperKeyDownTime == nil {
                            Monitor.hyperKeyDownTime = Date()
                        }

                        Monitor.hyperKeyActive = true
                    } else {
                        // only quick press if hyper wasn't used as a modifier
                        if let downTime = Monitor.hyperKeyDownTime,
                            Date().timeIntervalSince(downTime) < NSEvent.keyRepeatDelay,
                            !Monitor.hyperKeyUsedAsModifier
                        {
                            DispatchQueue.global(qos: .userInitiated).async {
                                Monitor.quickPress()
                            }
                        }

                        Monitor.hyperKeyDownTime = nil
                        Monitor.hyperKeyActive = false
                        Monitor.hyperKeyUsedAsModifier = false
                    }

                    return nil
                }

                // inject all four modifier keys if hyper is active
                if Monitor.hyperKeyActive {
                    Monitor.hyperKeyUsedAsModifier = true
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

    static private func runScript(_ action: Action) {
        DispatchQueue.global(qos: .userInitiated).async {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: action.binary)
            process.arguments = action.arguments
            try? process.run()
        }
    }

    static private func quickPress() {
        if quickPressAction == "escape" {

        } else if quickPressAction == "capslock" {
            Monitor.toggleCapsLock()
        } else {

        }
    }

    static private func toggleCapsLock() {
        let ioService = IOServiceGetMatchingService(
            kIOMainPortDefault, IOServiceMatching("IOHIDSystem"))
        var connect: io_connect_t = 0
        IOServiceOpen(ioService, mach_task_self_, UInt32(kIOHIDParamConnectType), &connect)

        var state = false
        IOHIDGetModifierLockState(connect, Int32(kIOHIDCapsLockState), &state)
        IOHIDSetModifierLockState(connect, Int32(kIOHIDCapsLockState), !state)

        IOServiceClose(connect)
        IOObjectRelease(ioService)
    }
}
