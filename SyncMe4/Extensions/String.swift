import Foundation

extension String {
    // Insert zero-width spaces into file paths, so that they wrap nicely.
    var urlWrap: String {
        replacingOccurrences(of: "/", with: "/\u{200B}")
    }

    // Display line-end characters as escaped
    var escapedString: String {
        replacingOccurrences(of: "\r", with: "\\r")
            .replacingOccurrences(of: "\n", with: "\\n")
    }

    // Convert escaped line-end characters to actual line-ends
    var unescapedString: String {
        replacingOccurrences(of: "\\r", with: "\r")
            .replacingOccurrences(of: "\\n", with: "\n")
    }
}
