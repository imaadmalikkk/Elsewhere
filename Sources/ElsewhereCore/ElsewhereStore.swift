import Foundation
import Combine

public class ElsewhereStore: ObservableObject {

    // MARK: - Keys

    private static let favoritesKey = "favoriteTimezones"
    private static let displayFormatKey = "displayFormat"

    // Legacy keys (for migration)
    private static let legacyPrimaryKey = "primaryTimezone"
    private static let legacySelectedKey = "selectedTimezones"

    // MARK: - Published State

    /// Ordered list of favorite timezone identifiers.
    /// Index 0 = primary (shown in menu bar). Indices 0–2 = shown in dropdown.
    @Published public var favorites: [String] = ["Asia/Dubai"]

    @Published public var displayFormat: DisplayFormat = .flagAndTime

    // MARK: - Computed

    public var primaryEntry: TimezoneEntry? {
        favorites.first.flatMap { TimezoneEntry.find(by: $0) }
    }

    /// Top 3 favorites for the menu bar dropdown
    public var menuBarFavorites: [TimezoneEntry] {
        favorites.prefix(3).compactMap { TimezoneEntry.find(by: $0) }
    }

    /// All favorites as TimezoneEntry objects
    public var allFavoriteEntries: [TimezoneEntry] {
        favorites.compactMap { TimezoneEntry.find(by: $0) }
    }

    // MARK: - Init

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        load()
    }

    // MARK: - Persistence

    private func load() {
        // Try new key first
        if let saved = defaults.stringArray(forKey: Self.favoritesKey) {
            let valid = saved.filter { TimezoneEntry.find(by: $0) != nil }
            if !valid.isEmpty {
                favorites = valid
                loadDisplayFormat()
                return
            }
        }

        // Migrate from legacy keys
        migrateFromLegacy()
        loadDisplayFormat()
    }

    private func loadDisplayFormat() {
        if let raw = defaults.string(forKey: Self.displayFormatKey),
           let format = DisplayFormat(rawValue: raw) {
            displayFormat = format
        }
    }

    private func migrateFromLegacy() {
        var migrated: [String] = []

        // Primary goes first
        if let primary = defaults.string(forKey: Self.legacyPrimaryKey),
           TimezoneEntry.find(by: primary) != nil {
            migrated.append(primary)
        }

        // Then the rest of the selected set
        if let selected = defaults.stringArray(forKey: Self.legacySelectedKey) {
            for id in selected where TimezoneEntry.find(by: id) != nil {
                if !migrated.contains(id) {
                    migrated.append(id)
                }
            }
        }

        if !migrated.isEmpty {
            favorites = migrated
        }

        // Save in new format and clean up
        save()
        defaults.removeObject(forKey: Self.legacyPrimaryKey)
        defaults.removeObject(forKey: Self.legacySelectedKey)
    }

    public func save() {
        defaults.set(favorites, forKey: Self.favoritesKey)
        defaults.set(displayFormat.rawValue, forKey: Self.displayFormatKey)
    }

    // MARK: - Mutations

    public func addCity(_ identifier: String) {
        guard TimezoneEntry.find(by: identifier) != nil,
              !favorites.contains(identifier) else { return }
        favorites.append(identifier)
        save()
    }

    public func removeCity(_ identifier: String) {
        guard favorites.count > 1 else { return }
        favorites.removeAll { $0 == identifier }
        save()
    }

    public func moveFavorite(from source: IndexSet, to destination: Int) {
        var items = favorites
        let moving = source.map { items[$0] }
        // Remove in reverse order to keep indices valid
        for index in source.sorted().reversed() {
            items.remove(at: index)
        }
        let insertAt = min(destination, items.count)
        items.insert(contentsOf: moving, at: insertAt)
        favorites = items
        save()
    }

    /// Makes the given identifier the primary (index 0) without losing order of others.
    public func setPrimary(_ identifier: String) {
        guard let idx = favorites.firstIndex(of: identifier), idx != 0 else { return }
        favorites.remove(at: idx)
        favorites.insert(identifier, at: 0)
        save()
    }

    public func setDisplayFormat(_ format: DisplayFormat) {
        displayFormat = format
        save()
    }

    public func isFavorite(_ identifier: String) -> Bool {
        favorites.contains(identifier)
    }
}
