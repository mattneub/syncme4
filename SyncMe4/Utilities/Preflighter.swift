import AppKit

final class Preflighter {
//    let f1 : String
//    let f2 : String
//
//    dynamic var currentFolder : NSString? // observable
//    dynamic var result : NSArray? // observable, this is how to know we're finished
//    // work around bug where isFinished does not trigger KVO notification properly
//
//    init(f1:String, f2:String) {
//        self.f1 = f1
//        self.f2 = f2
//        super.init()
//    }
//
    func compareFolders(f1: String, f2: String) -> [Entry] {
        var list = [Entry]()
        // let stopList = UserDefaults.standard.value(forKey:"stopList") as! [String]
        let stopList = [String]()
        self.listInto(&list, withFolder: f1, withFolder: f2, doingDates: true, stopList: stopList)
        self.listInto(&list, withFolder: f2, withFolder: f1, doingDates: false, stopList: stopList)
        // done! remove current folder info, this will also ultimately re-enable Preflight button
        // self.currentFolder = nil
        // self.result = list as NSArray // signal that we're done, observer must pick up result
        return list
    }

    // TODO: another naming thing: "doingDates", while true in effect, doesn't really describe the circumstances
    // the fact is that we simply call this twice, once going one way, the other going the other way
    // and the second time we don't bother with items that appear in both original and clone...
    // because we dealt with them the first time
    // workhorse info-gathering routine, designed to be run on background thread
    func listInto(_ theList: inout [Entry], withFolder ff1: String, withFolder ff2: String, doingDates: Bool, stopList: [String]) {
        let fm = FileManager.default
        let f1contents = try! fm.contentsOfDirectory(atPath: ff1)
        // self.currentFolder = ff1 as NSString // signal so interface can be updated

        // loop thru items of original folder
        for origname in f1contents {
//            if self.isCancelled {
//                return
//            }
            let clonepath = (ff2 as NSString).appendingPathComponent(origname)
            let origpath = (ff1 as NSString).appendingPathComponent(origname)
            let origurl = URL(fileURLWithPath: origpath)
            let cloneurl = URL(fileURLWithPath: clonepath)
            // if this item is an alias or symlink, don't even process it
            // (also pick up mod date because might need it later)
            let vals = try! origurl.resourceValues(forKeys: [.isAliasFileKey, .isSymbolicLinkKey, .contentModificationDateKey])
            if let b = vals.isAliasFile, b { continue }
            if let b = vals.isSymbolicLink, b { continue }
            // if the name of this item is in the stop list, don't even process it
            if stopList.contains(origname) { continue }
            // okay, ready to do some actual work!
            var isDir: ObjCBool = false
            // if item doesn't exist in clone, add an entry for it
            if !(fm.fileExists(atPath: clonepath, isDirectory: &isDir)) {
                let why : Reason = doingDates ? .absentRight : .absentLeft
                theList.append(Entry(copyFrom: origpath, copyTo: clonepath, why: why))
                continue
            }
            // okay, item exists in both places
            if isDir.boolValue { // if clone is a folder...
                let vals = try! cloneurl.resourceValues(forKeys: [.isPackageKey])
                if let b = vals.isPackage, !b { // ...and is not a package ...
                    // then dive dive dive
                    // TODO: shouldn't I be doing a sanity check to make sure orig is a folder too?
                    self.listInto(&theList, withFolder: origpath, withFolder: clonepath,
                                  doingDates:doingDates, stopList:stopList)
                    // return from dive
                    // if we returned because we canceled, propagate cancellation
//                    if self.isCancelled {
//                        return
//                    }
                    // update interface info to where we were
//                    self.currentFolder = ff1 as NSString
                    continue
                }
            }
            // okay, item exists in both places and is a file
            // if we're not comparing dates, don't bother with it
            if !doingDates { continue }
            // okay, item exists in both places and is a file and we're comparing dates
            // so compare them!
            let vals2 = try! cloneurl.resourceValues(forKeys: [.contentModificationDateKey])
            if let dorig = vals.contentModificationDate, let dclone = vals2.contentModificationDate {
                if dorig == dclone {
                    continue // they are the same date; nothing to do
                }
                // okay, they have different dates; we need an entry for this
                if dorig > dclone {
                    let why : Reason = doingDates ? .olderRight : .olderLeft
                    theList.append(Entry(copyFrom: origpath, copyTo: clonepath, why: why))
                } else {
                    let why : Reason = doingDates ? .olderLeft : .olderRight
                    theList.append(Entry(copyFrom: clonepath, copyTo: origpath, why: why))
                }
            }

        }
    }
}
