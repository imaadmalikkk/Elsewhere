import XCTest
@testable import ElsewhereCore

final class ElsewhereStoreTests: XCTestCase {

    private func freshDefaults() -> UserDefaults {
        let name = "com.elsewhere.test.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defaults.removePersistentDomain(forName: name)
        return defaults
    }

    // MARK: - Default State

    func testDefaultFavorites() {
        let store = ElsewhereStore(defaults: freshDefaults())
        XCTAssertEqual(store.favorites, ["Asia/Dubai"])
        XCTAssertEqual(store.primaryEntry?.name, "Dubai")
    }

    func testDefaultDisplayFormat() {
        let store = ElsewhereStore(defaults: freshDefaults())
        XCTAssertEqual(store.displayFormat, .flagAndTime)
    }

    // MARK: - Add / Remove

    func testAddCity() {
        let store = ElsewhereStore(defaults: freshDefaults())
        store.addCity("Europe/London")
        XCTAssertEqual(store.favorites, ["Asia/Dubai", "Europe/London"])
    }

    func testAddDuplicateCity() {
        let store = ElsewhereStore(defaults: freshDefaults())
        store.addCity("Asia/Dubai")
        XCTAssertEqual(store.favorites.count, 1)
    }

    func testAddInvalidCity() {
        let store = ElsewhereStore(defaults: freshDefaults())
        store.addCity("Mars/Olympus")
        XCTAssertEqual(store.favorites.count, 1)
    }

    func testRemoveCity() {
        let store = ElsewhereStore(defaults: freshDefaults())
        store.addCity("Europe/London")
        store.removeCity("Europe/London")
        XCTAssertEqual(store.favorites, ["Asia/Dubai"])
    }

    func testCannotRemoveLastCity() {
        let store = ElsewhereStore(defaults: freshDefaults())
        store.removeCity("Asia/Dubai")
        XCTAssertEqual(store.favorites.count, 1)
    }

    // MARK: - Primary

    func testSetPrimary() {
        let store = ElsewhereStore(defaults: freshDefaults())
        store.addCity("Europe/London")
        store.addCity("Asia/Tokyo")
        store.setPrimary("Asia/Tokyo")
        XCTAssertEqual(store.favorites.first, "Asia/Tokyo")
        XCTAssertEqual(store.primaryEntry?.name, "Tokyo")
        // Other favorites still present
        XCTAssertTrue(store.favorites.contains("Asia/Dubai"))
        XCTAssertTrue(store.favorites.contains("Europe/London"))
    }

    func testSetPrimaryAlreadyPrimary() {
        let store = ElsewhereStore(defaults: freshDefaults())
        store.setPrimary("Asia/Dubai")
        XCTAssertEqual(store.favorites, ["Asia/Dubai"])
    }

    // MARK: - Move

    func testMoveFavorite() {
        let store = ElsewhereStore(defaults: freshDefaults())
        store.addCity("Europe/London")
        store.addCity("Asia/Tokyo")
        // Move Tokyo (index 2) to position 0
        store.moveFavorite(from: IndexSet(integer: 2), to: 0)
        XCTAssertEqual(store.favorites.first, "Asia/Tokyo")
    }

    // MARK: - Display Format

    func testSetDisplayFormat() {
        let store = ElsewhereStore(defaults: freshDefaults())
        store.setDisplayFormat(.timeOnly)
        XCTAssertEqual(store.displayFormat, .timeOnly)
    }

    // MARK: - Computed Properties

    func testMenuBarFavorites() {
        let store = ElsewhereStore(defaults: freshDefaults())
        store.addCity("Europe/London")
        store.addCity("Asia/Tokyo")
        store.addCity("America/New_York")
        // Should return at most 3
        XCTAssertEqual(store.menuBarFavorites.count, 3)
        XCTAssertEqual(store.menuBarFavorites[0].name, "Dubai")
    }

    func testAllFavoriteEntries() {
        let store = ElsewhereStore(defaults: freshDefaults())
        store.addCity("Europe/London")
        XCTAssertEqual(store.allFavoriteEntries.count, 2)
    }

    func testIsFavorite() {
        let store = ElsewhereStore(defaults: freshDefaults())
        XCTAssertTrue(store.isFavorite("Asia/Dubai"))
        XCTAssertFalse(store.isFavorite("Europe/London"))
    }

    // MARK: - Persistence

    func testPersistence() {
        let defaults = freshDefaults()
        let store1 = ElsewhereStore(defaults: defaults)
        store1.addCity("Europe/London")
        store1.setDisplayFormat(.nameAndTime)

        let store2 = ElsewhereStore(defaults: defaults)
        XCTAssertEqual(store2.favorites, ["Asia/Dubai", "Europe/London"])
        XCTAssertEqual(store2.displayFormat, .nameAndTime)
    }

    // MARK: - Migration

    func testMigrationFromLegacyKeys() {
        let defaults = freshDefaults()
        // Simulate legacy data
        defaults.set("Europe/London", forKey: "primaryTimezone")
        defaults.set(["Europe/London", "Asia/Tokyo", "Asia/Dubai"], forKey: "selectedTimezones")

        let store = ElsewhereStore(defaults: defaults)
        // Primary should be first
        XCTAssertEqual(store.favorites.first, "Europe/London")
        // All selected should be present
        XCTAssertTrue(store.favorites.contains("Asia/Tokyo"))
        XCTAssertTrue(store.favorites.contains("Asia/Dubai"))
        // Legacy keys should be cleaned up
        XCTAssertNil(defaults.string(forKey: "primaryTimezone"))
        XCTAssertNil(defaults.stringArray(forKey: "selectedTimezones"))
    }
}
