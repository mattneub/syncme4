@testable import SyncMe4
import Testing

struct PersistenceTests {
    let subject = Persistence()
    let userDefaults = MockUserDefaults()

    init() {
        services.userDefaults = userDefaults
    }

    @Test("registerDefaults: registers the default stop list")
    func registerDefaults() throws {
        subject.registerDefaults()
        #expect(userDefaults.methodsCalled == ["register(defaults:)"])
        let list = try #require(userDefaults.dictionary["stopList"] as? [String])
        #expect(list == [
            ".DS_Store",
            "Icon\r",
            ".localized",
            ".file",
            ".fseventsd",
            ".Spotlight-V100",
            ".vol",
            ".Trashes"
        ])
    }

    @Test("loadStopList: loads string array for stopList key, or empty array")
    func loadStopList() throws {
        do {
            userDefaults.thingsToReturn["stopList"] = ["Manny", "Moe", "Jack"]
            let result = subject.loadStopList()
            #expect(result == ["Manny", "Moe", "Jack"])
        }
        do {
            userDefaults.thingsToReturn["stopList"] = ["Manny", 1, "Jack"]
            let result = subject.loadStopList()
            #expect(result == [])
        }
        do {
            userDefaults.thingsToReturn["stopList"] = nil
            let result = subject.loadStopList()
            #expect(result == [])
        }
    }
}
