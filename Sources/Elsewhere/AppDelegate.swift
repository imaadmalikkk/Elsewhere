import AppKit
import Combine
import ElsewhereCore

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var timer: Timer?

    let store = ElsewhereStore()
    private var cancellable: AnyCancellable?
    private lazy var configController = ConfigWindowController(store: store)

    private let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .none
        f.timeStyle = .short
        return f
    }()

    // MARK: - Lifecycle

    override init() {
        super.init()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.font = NSFont.monospacedDigitSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)

        // Observe store changes and refresh UI
        cancellable = store.objectWillChange.sink { [weak self] _ in
            Task { @MainActor in
                self?.updateTime()
                self?.buildMenu()
            }
        }

        buildMenu()
        updateTime()
        scheduleTimer()

        NotificationCenter.default.addObserver(self, selector: #selector(localeChanged), name: NSLocale.currentLocaleDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(localeChanged), name: .NSSystemTimeZoneDidChange, object: nil)
    }

    // MARK: - Timer

    private func scheduleTimer() {
        let now = Date()
        let seconds = Calendar.current.component(.second, from: now)
        let delay = TimeInterval(60 - seconds)

        timer = Timer(fire: now.addingTimeInterval(delay), interval: 60, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateTime()
            }
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    // MARK: - Display

    private func updateTime() {
        guard let primary = store.primaryEntry else { return }
        formatter.timeZone = primary.timeZone
        let time = formatter.string(from: Date())
        statusItem.button?.title = store.displayFormat.format(entry: primary, time: time)

        if store.displayFormat.usesSFSymbol, let symbolName = store.displayFormat.sfSymbolName {
            let config = NSImage.SymbolConfiguration(pointSize: 14, weight: .regular)
            statusItem.button?.image = NSImage(systemSymbolName: symbolName, accessibilityDescription: "Globe")?.withSymbolConfiguration(config)
            statusItem.button?.imagePosition = .imageLeading
        } else {
            statusItem.button?.image = nil
        }
    }

    // MARK: - Menu

    private func buildMenu() {
        let menu = NSMenu()
        let now = Date()

        // Top 3 favorites
        for entry in store.menuBarFavorites {
            let info = TimeFormatting.clockInfo(for: entry, at: now, formatter: formatter)
            let item = clockMenuItem(info: info)
            menu.addItem(item)
        }

        menu.addItem(.separator())

        let openItem = NSMenuItem(title: "Open Elsewhere...", action: #selector(openConfig(_:)), keyEquivalent: ",")
        openItem.target = self
        menu.addItem(openItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "Quit Elsewhere", action: #selector(quit(_:)), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    private func clockMenuItem(info: ClockInfo) -> NSMenuItem {
        let dayStr = info.dayLabel.isEmpty ? "" : " · \(info.dayLabel)"
        let title = "\(info.entry.flag)  \(info.entry.name)  \(info.time)"

        let item = NSMenuItem(title: title, action: #selector(clockItemClicked(_:)), keyEquivalent: "")
        item.target = self
        item.representedObject = info.entry.identifier

        let full = NSMutableAttributedString()
        let nameAttrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 13, weight: .medium)
        ]
        let timeAttrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedDigitSystemFont(ofSize: 13, weight: .regular)
        ]
        let metaAttrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 11, weight: .regular),
            .foregroundColor: NSColor.secondaryLabelColor
        ]

        full.append(NSAttributedString(string: "\(info.entry.flag)  \(info.entry.name)  ", attributes: nameAttrs))
        full.append(NSAttributedString(string: info.time, attributes: timeAttrs))
        full.append(NSAttributedString(string: "  \(info.utcOffset) (\(info.relativeDiff))\(dayStr)", attributes: metaAttrs))

        item.attributedTitle = full
        return item
    }

    // MARK: - Actions

    @objc private func clockItemClicked(_ sender: NSMenuItem) {
        guard let identifier = sender.representedObject as? String,
              let entry = TimezoneEntry.find(by: identifier) else { return }

        formatter.timeZone = entry.timeZone
        let time = formatter.string(from: Date())
        let text = "\(entry.flag) \(entry.name): \(time)"
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }

    @objc private func openConfig(_ sender: NSMenuItem) {
        configController.showWindow()
    }

    @objc private func quit(_ sender: NSMenuItem) {
        NSApp.terminate(nil)
    }

    @objc private func localeChanged() {
        updateTime()
        buildMenu()
    }
}
