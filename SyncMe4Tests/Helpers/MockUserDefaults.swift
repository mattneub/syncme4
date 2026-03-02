@testable import SyncMe4
import AppKit

final class MockUserDefaults: UserDefaultsType {
    var methodsCalled = [String]()
    var dictionary = [String: Any]()
    var thingsSet = [String: Any]()
    var thingsToReturn = [String: Any]()

    func register(defaults registrationDictionary: [String: Any]) {
        methodsCalled.append(#function)
        dictionary = registrationDictionary
    }

    func array(forKey defaultName: String) -> [Any]? {
        methodsCalled.append(#function)
        return thingsToReturn[defaultName] as? [Any]
    }
}
