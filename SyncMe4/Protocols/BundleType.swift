import Foundation

protocol BundleType {
    func url(
        forResource name: String?,
        withExtension ext: String?,
        subdirectory subpath: String?
    ) -> URL?
}

extension Bundle: BundleType {}
