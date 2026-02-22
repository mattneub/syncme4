import AppKit

func start() async {
    // instantiate app, see https://stackoverflow.com/a/44604299/341994
    guard let classString = Bundle.main.infoDictionary?["NSPrincipalClass"] as? String,
          let app = (NSClassFromString(classString) as? NSApplication.Type)?.shared else {
        return
    }
    // make strong reference to delegate, assign to app
    let delegate = AppDelegate()
    app.delegate = delegate
    // start running
    _ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
}
await start()
