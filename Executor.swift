import Foundation

struct Executor {
    static func run(_ shellCommand: String) {
        let task = Process()
        task.launchPath = "/bin/sh"
        task.arguments = ["-c", shellCommand]

        do {
            try task.run()
        } catch {
            print("Failed to run command: \(shellCommand)")
        }
    }
}
