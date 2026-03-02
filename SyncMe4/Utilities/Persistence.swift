import Foundation

struct Defaults {
    static let stopList = "stopList"
}

protocol PersistenceType {
    func registerDefaults()
    func loadStopList() -> [String]
}

final class Persistence: PersistenceType {
    func registerDefaults() {
        let list = [
            ".DS_Store",
            "Icon\r",
            ".localized",
            ".file",
            ".fseventsd",
            ".Spotlight-V100",
            ".vol",
            ".Trashes"
        ]
        services.userDefaults.register(defaults: [Defaults.stopList: list])
    }

    func loadStopList() -> [String] {
        return (services.userDefaults.array(forKey: Defaults.stopList) as? [String]) ?? []
    }
}
