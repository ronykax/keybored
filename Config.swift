import Foundation

struct Config {
    static func load(from path: String) -> [String: String]? {
        let url = URL(fileURLWithPath: path)

        guard let data = try? Data(contentsOf: url),
            let array = try? JSONSerialization.jsonObject(with: data) as? [[String: String]]
        else {
            return nil
        }

        var mappings = [String: String]()
        for item in array {
            if let key = item.keys.first, let val = item.values.first {
                mappings[key] = val
            }
        }
        return mappings
    }
}
