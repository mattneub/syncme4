import AppKit

/// Protocol describing the view controller's interaction with the datasource, so we can
/// mock it for testing.
protocol TableViewDatasourceType<Received, State>: ReceiverPresenter, NSTableViewDelegate {
    associatedtype State
    associatedtype Received
}
