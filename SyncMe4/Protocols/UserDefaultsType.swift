import Foundation

protocol UserDefaultsType {
    func register(defaults: [String: Any])
    func array(forKey: String) -> [Any]?
    func set(_: Any?, forKey: String)
}

extension UserDefaults: UserDefaultsType {}
