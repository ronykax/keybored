import CoreGraphics
import Foundation

class HotkeyManager {
    let hotkeyCount: Int
    private var eventTap: CFMachPort?

    private let commandsByPackedKey: [UInt64: String]

    private static let shell = URL(fileURLWithPath: "/bin/zsh")

    init(hotkeys: [Hotkey]) {
        hotkeyCount = hotkeys.count

        var lookup = [UInt64: String](minimumCapacity: hotkeys.count)
        for hotkey in hotkeys {
            let flags = Mapping.modifierFlags(from: hotkey.modifiers)
            let keyCode = Mapping.keyCode(for: hotkey.key)
            let packed = Self.packedKey(modifiers: flags, keyCode: keyCode)
            lookup[packed] = hotkey.run
        }
        commandsByPackedKey = lookup
    }

    func start() throws {
        try installKeyboardTap()
    }

    private func installKeyboardTap() throws {
        let eventMask = (1 << CGEventType.keyDown.rawValue)

        // C API requires a static closure; refcon points back to this manager.
        guard let eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: { _, type, event, refcon in
                guard let refcon else {
                    return Unmanaged.passRetained(event)
                }

                let manager = Unmanaged<HotkeyManager>
                    .fromOpaque(refcon)
                    .takeUnretainedValue()

                return type == .keyDown
                    ? manager.handleEvent(event)
                    : Unmanaged.passRetained(event)
            },
            userInfo: UnsafeMutableRawPointer(
                Unmanaged.passUnretained(self).toOpaque()
            )
        ) else {
            throw NSError(domain: "Hotkey", code: 1)
        }

        let source = CFMachPortCreateRunLoopSource(
            kCFAllocatorDefault,
            eventTap,
            0
        )

        CFRunLoopAddSource(
            CFRunLoopGetMain(),
            source,
            .commonModes
        )

        CGEvent.tapEnable(tap: eventTap, enable: true)
        self.eventTap = eventTap
    }

    func handleEvent(_ event: CGEvent) -> Unmanaged<CGEvent>? {
        let packed = Self.packedKey(for: event)

        guard let command = commandsByPackedKey[packed] else {
            return Unmanaged.passRetained(event)
        }

        runShellCommand(command)
        return nil
    }

    private static func packedKey(modifiers: CGEventFlags, keyCode: Int64) -> UInt64 {
        (UInt64(modifiers.rawValue) << 32) | UInt64(keyCode)
    }

    private static func packedKey(for event: CGEvent) -> UInt64 {
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        let modifiers = event.flags.intersection(Mapping.trackedModifierFlags)
        return packedKey(modifiers: modifiers, keyCode: keyCode)
    }

    private func runShellCommand(_ command: String) {
        let task = Process()
        task.executableURL = Self.shell
        task.arguments = ["-c", command]

        do {
            try task.run()
        } catch {
            print("failed to run hotkey: \(error)")
        }
    }
}
