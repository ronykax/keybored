import Foundation

func loadHotkeys(from path: String) -> [Hotkey] {
    do {
        let url = URL(fileURLWithPath: path)
        let data = try Data(contentsOf: url)

        return try JSONDecoder().decode(
            [Hotkey].self,
            from: data
        )
    } catch {
        print("Failed to load config:")
        print(error)

        return []
    }
}
