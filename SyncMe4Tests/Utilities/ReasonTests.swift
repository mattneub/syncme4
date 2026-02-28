@testable import SyncMe4
import Testing

struct ReasonTests {
    @Test("imageName is correct")
    func image() {
        var why = Reason.absentLeft
        #expect(why.imageName == "leftarrowgreen")
        why = Reason.absentRight
        #expect(why.imageName == "rightarrowgreen")
        why = Reason.olderLeft
        #expect(why.imageName == "leftarrowred")
        why = Reason.olderRight
        #expect(why.imageName == "rightarrowred")
    }

    @Test("direction is correct")
    func direction() {
        var why = Reason.absentLeft
        #expect(why.direction == .rightToLeft)
        why = Reason.absentRight
        #expect(why.direction == .leftToRight)
        why = Reason.olderLeft
        #expect(why.direction == .rightToLeft)
        why = Reason.olderRight
        #expect(why.direction == .leftToRight)
    }

    @Test("opposite is correct")
    func opposite() {
        var why = Reason.absentLeft
        #expect(why.opposite == .absentRight)
        why = Reason.absentRight
        #expect(why.opposite == .absentLeft)
        why = Reason.olderLeft
        #expect(why.opposite == .olderRight)
        why = Reason.olderRight
        #expect(why.opposite == .olderLeft)
    }

    @Test("destinationExists is correct")
    func destinationExists() {
        var why = Reason.absentLeft
        #expect(why.destinationExists == false)
        why = Reason.absentRight
        #expect(why.destinationExists == false)
        why = Reason.olderLeft
        #expect(why.destinationExists == true)
        why = Reason.olderRight
        #expect(why.destinationExists == true)
    }
}
