import CoreGraphics
import Foundation

struct Hotkey: Codable {
    let modifiers: [String]
    let key: String
    let run: String
}

class HotkeyManager {
    let hotkeys: [Hotkey]
    private var eventTap: CFMachPort?

    // Packed key: high 32 bits = modifier flags rawValue, low 32 bits = keyCode
    private let hotkeyLookup: [UInt64: Hotkey]

    init(hotkeys: [Hotkey]) {
        self.hotkeys = hotkeys
        var lookup = [UInt64: Hotkey](minimumCapacity: hotkeys.count)
        for hotkey in hotkeys {
            let flags = mapModifiers(hotkey.modifiers)
            let keyCode = mapKeyToKeyCode(hotkey.key)
            let packed = (UInt64(flags.rawValue) << 32) | UInt64(keyCode)
            lookup[packed] = hotkey
        }
        self.hotkeyLookup = lookup
    }

    func start() throws {
        // We only care about key down events
        let eventMask = (1 << CGEventType.keyDown.rawValue)

        guard
            let eventTap = CGEvent.tapCreate(
                tap: .cgSessionEventTap,
                place: .headInsertEventTap,
                options: .defaultTap,
                eventsOfInterest: CGEventMask(eventMask),
                callback: { proxy, type, event, refcon in
                    guard let refcon else {
                        return Unmanaged.passRetained(event)
                    }

                    let manager = Unmanaged<HotkeyManager>
                        .fromOpaque(refcon)
                        .takeUnretainedValue()

                    if type == .keyDown {
                        return manager.handleEvent(event)
                    }

                    return Unmanaged.passRetained(event)
                },
                userInfo: UnsafeMutableRawPointer(
                    Unmanaged.passUnretained(self).toOpaque()
                )
            )
        else {
            fatalError("failed to create event tap")
        }

        // Add the tap to the run loop
        let source = CFMachPortCreateRunLoopSource(nil, eventTap, 0)

        CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
    }

    func handleEvent(_ event: CGEvent) -> Unmanaged<CGEvent>? {
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)

        // Isolate just the modifier keys we care about
        let relevantFlags = event.flags.intersection([
            .maskCommand, .maskControl, .maskAlternate, .maskShift,
        ])

        let packed = (UInt64(relevantFlags.rawValue) << 32) | UInt64(keyCode)

        guard let hotkey = hotkeyLookup[packed] else {
            // Not our hotkey — pass it along to the system normally
            return Unmanaged.passRetained(event)
        }

        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/zsh")
        task.arguments = ["-c", hotkey.run]

        do {
            try task.run()
            task.waitUntilExit()
        } catch {
            print("failed to run hotkey: \(error)")
        }

        // Return nil to swallow the event (so other apps don't type "t")
        return nil
    }
}
