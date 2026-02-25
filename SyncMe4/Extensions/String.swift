import Foundation

// Insert zero-width spaces into file paths, so that they wrap nicely.
extension String {
    var urlWrap: String {
        replacingOccurrences(of: "/", with: "/\u{200B}")
    }
}
