@testable import SyncMe4
import Foundation

final class MockBundle: BundleType {
    var name: String?
    var ext: String?
    var subpath: String?
    var methodsCalled = [String]()
    var urlToReturn: URL?

    func url(
        forResource name: String?,
        withExtension ext: String?,
        subdirectory subpath: String?
    ) -> URL? {
        methodsCalled.append(#function)
        self.name = name
        self.ext = ext
        self.subpath = subpath
        return urlToReturn
    }

}
