import AppKit

protocol OpenPanelFactoryType {
    func makeOpenPanel() -> any OpenPanelType
}

final class OpenPanelFactory: OpenPanelFactoryType {
    func makeOpenPanel() -> any OpenPanelType {
        return NSOpenPanel()
    }
}
