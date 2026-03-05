import AppKit
import ServiceManagement

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var timer: Timer?
    private var selected: TimezoneEntry = .dubai

    private let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .none
        f.timeStyle = .short
        return f
    }()

    private let defaultsKey = "selectedTimezone"

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Load saved timezone
        if let saved = UserDefaults.standard.string(forKey: defaultsKey),
           let entry = TimezoneEntry.find(by: saved) {
            selected = entry
        }

        // Create status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.font = NSFont.monospacedDigitSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)

        buildMenu()
        updateTime()
        scheduleTimer()
    }

    // MARK: - Timer

    private func scheduleTimer() {
        // Align to next minute boundary
        let now = Date()
        let calendar = Calendar.current
        let seconds = calendar.component(.second, from: now)
        let delay = TimeInterval(60 - seconds)

        timer = Timer(fire: now.addingTimeInterval(delay), interval: 60, repeats: true) { [weak self] _ in
            self?.updateTime()
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    // MARK: - Display

    private func updateTime() {
        formatter.timeZone = selected.timeZone
        let time = formatter.string(from: Date())
        statusItem.button?.title = "\(selected.flag) \(time)"
    }

    // MARK: - Menu

    private func buildMenu() {
        let menu = NSMenu()

        for entry in TimezoneEntry.all {
            let item = NSMenuItem(title: "\(entry.flag) \(entry.name)", action: #selector(selectTimezone(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = entry.identifier
            item.state = entry.identifier == selected.identifier ? .on : .off
            menu.addItem(item)
        }

        menu.addItem(.separator())

        let loginItem = NSMenuItem(title: "Launch at Login", action: #selector(toggleLaunchAtLogin(_:)), keyEquivalent: "")
        loginItem.target = self
        loginItem.state = (SMAppService.mainApp.status == .enabled) ? .on : .off
        menu.addItem(loginItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "Quit Elsewhere", action: #selector(quit(_:)), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    // MARK: - Actions

    @objc private func selectTimezone(_ sender: NSMenuItem) {
        guard let identifier = sender.representedObject as? String,
              let entry = TimezoneEntry.find(by: identifier) else { return }

        selected = entry
        UserDefaults.standard.set(identifier, forKey: defaultsKey)
        buildMenu()
        updateTime()
    }

    @objc private func toggleLaunchAtLogin(_ sender: NSMenuItem) {
        do {
            if SMAppService.mainApp.status == .enabled {
                try SMAppService.mainApp.unregister()
            } else {
                try SMAppService.mainApp.register()
            }
        } catch {
            // Silently handle — user can retry
        }
        buildMenu()
    }

    @objc private func quit(_ sender: NSMenuItem) {
        NSApp.terminate(nil)
    }
}
