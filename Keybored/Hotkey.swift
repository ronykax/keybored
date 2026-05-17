import Foundation

enum HotkeyKey: Codable, Equatable {
    case string(String)
    case int(Int)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intValue = try? container.decode(Int.self) {
            self = .int(intValue)
        } else {
            self = .string(try container.decode(String.self))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value):
            try container.encode(value)
        case .int(let value):
            try container.encode(value)
        }
    }
}

struct Hotkey: Codable {
    let modifiers: [String]
    let key: HotkeyKey
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
