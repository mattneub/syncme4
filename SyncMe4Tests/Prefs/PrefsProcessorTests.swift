@testable import SyncMe4
import Testing
import AppKit

final class PrefsProcessorTests {
    let subject = PrefsProcessor()
    let presenter = MockReceiverPresenter<PrefsEffect, PrefsState>()
    let persistence = MockPersistence()
    let coordinator = MockRootCoordinator()

    init() {
        subject.presenter = presenter
        subject.coordinator = coordinator
        services.persistence = persistence
    }

    @Test("receive add: appends empty item to state, presents, sends editLastRow")
    func add() async {
        let item = StopListItem(name: "Groucho")
        subject.state.stopListItems = [item]
        await subject.receive(.add)
        #expect(subject.state.stopListItems.map(\.name) == ["Groucho", ""])
        #expect(presenter.statesPresented == [subject.state])
        #expect(presenter.thingsReceived == [.editLastRow])
    }

    @Test("receive cancel: calls coordinator closePrefs")
    func cancel() async {
        await subject.receive(.cancel)
        #expect(coordinator.methodsCalled == ["closePrefs()"])
    }

    @Test("receive changed: changes name of given row, sends changed")
    func changed() async {
        let item = StopListItem(name: "Groucho")
        subject.state.stopListItems = [item]
        await subject.receive(.changed(row: 0, text: "Harpo"))
        #expect(subject.state.stopListItems[0].name == "Harpo")
        #expect(subject.state.stopListItems[0].id == item.id)
        #expect(presenter.thingsReceived == [.changed(row: 0, text: "Harpo")])
    }

    @Test("receive delete: removes the given row, presents")
    func delete() async {
        let item1 = StopListItem(name: "Groucho")
        let item2 = StopListItem(name: "Harpo")
        subject.state.stopListItems = [item1, item2]
        await subject.receive(.delete(row: 0))
        #expect(subject.state.stopListItems == [item2])
        #expect(presenter.statesPresented == [subject.state])
    }

    @Test("receive initialData: calls persistence loadStopList, escapes, sets state, presents")
    func initialData() async {
        persistence.stopList = ["Grou\ncho"]
        await subject.receive(.initialData)
        #expect(persistence.methodsCalled == ["loadStopList()"])
        #expect(subject.state.stopListItems[0].name == "Grou\\ncho")
        #expect(presenter.statesPresented == [subject.state])
    }

    @Test("receive save: unescapes list, calls persistence saveStopList, calls coordinator closePrefs")
    func save() async {
        let item = StopListItem(name: "Grou\\ncho")
        subject.state.stopListItems = [item]
        await subject.receive(.save)
        #expect(persistence.methodsCalled == ["saveStopList(_:)"])
        #expect(persistence.stopList == ["Grou\ncho"])
        #expect(coordinator.methodsCalled == ["closePrefs()"])
    }
}
