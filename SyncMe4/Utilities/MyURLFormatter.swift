import AppKit

/// Formatter that mediates between a file URL object value and a path string.
nonisolated
class MyURLFormatter: Formatter {
    /// "return the NSString that textually represents the cell's object for display":
    override func string(for object: Any?) -> String? {
        guard let url = object as? URL else {
            return ""
        }
        guard url.isFileURL else {
            return ""
        }
        return url.path(percentEncoded: false)
    }

    /// "return by reference the object anObject after creating it from the string passed in.
    /// Return YES if the conversion from string to cell-content object was successful"
    override func getObjectValue(
        _ object: AutoreleasingUnsafeMutablePointer<AnyObject?>?,
        for string: String,
        errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?
    ) -> Bool {
        if string == "" {
            object?.pointee = nil
        } else {
            let result = URL(filePath: string, directoryHint: .isDirectory, relativeTo: nil)
            object?.pointee = result as NSURL
        }
        return true
    }
}

