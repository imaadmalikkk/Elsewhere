import AppKit
import SwiftUI
import ElsewhereCore

@MainActor
class ConfigWindowController {
    private var window: NSWindow?
    private let store: ElsewhereStore

    init(store: ElsewhereStore) {
        self.store = store
    }

    func showWindow() {
        if let window = window {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let configView = ConfigView(store: store)
        let hostingController = NSHostingController(rootView: configView)

        let window = NSWindow(contentViewController: hostingController)
        window.title = "Elsewhere"
        window.setFrameAutosaveName("ElsewhereConfig")
        window.isReleasedWhenClosed = false
        window.setContentSize(NSSize(width: 400, height: 640))
        window.minSize = NSSize(width: 360, height: 440)
        window.styleMask = [.titled, .closable, .resizable, .miniaturizable, .fullSizeContentView]
        window.titlebarAppearsTransparent = true
        window.center()

        self.window = window
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
