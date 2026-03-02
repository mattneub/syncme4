import Foundation

protocol UserDefaultsType {
    func register(defaults registrationDictionary: [String : Any])
    func array(forKey defaultName: String) -> [Any]?
}

extension UserDefaults: UserDefaultsType {}
