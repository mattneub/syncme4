import AppKit

protocol BeeperType {
    func beep()
}

final class Beeper: BeeperType {
    func beep() {
        NSSound.beep()
    }
}
