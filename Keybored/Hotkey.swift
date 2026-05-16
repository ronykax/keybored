import Foundation

struct Hotkey: Codable {
    let modifiers: [String]
    let key: String
    let run: String

    static let configFileName = "keybored.json"

    static func configURL(
        in homeDirectory: URL = FileManager.default.homeDirectoryForCurrentUser
    ) -> URL {
        homeDirectory.appendingPathComponent(configFileName)
    }

    static func load(from configURL: URL) -> [Hotkey] {
        if !FileManager.default.fileExists(atPath: configURL.path) {
            createEmptyConfigIfNeeded(at: configURL)
            return []
        }

        do {
            let data = try Data(contentsOf: configURL)
            return try JSONDecoder().decode([Hotkey].self, from: data)
        } catch {
            print("Failed to load config:", error)
            return []
        }
    }

    static func createEmptyConfigIfNeeded(at configURL: URL) {
        guard !FileManager.default.fileExists(atPath: configURL.path) else { return }
        try? "[]".write(to: configURL, atomically: true, encoding: .utf8)
    }
}
