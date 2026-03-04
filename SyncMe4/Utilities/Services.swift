import AppKit

final class Services {
    var beeper: any BeeperType = Beeper()
    var bundle: any BundleType = Bundle.main
    var finderScripter: any FinderScripterType = FinderScripter()
    var openPanelOpener: any OpenPanelOpenerType = OpenPanelOpener()
    var openPanelFactory: any OpenPanelFactoryType = OpenPanelFactory()
    var persistence: any PersistenceType = Persistence()
    var preflighter: any PreflighterType = Preflighter()
    var sorter: any SorterType = Sorter()
    var userDefaults: any UserDefaultsType = UserDefaults.standard
    var workspace: any WorkspaceType = NSWorkspace.shared
}
