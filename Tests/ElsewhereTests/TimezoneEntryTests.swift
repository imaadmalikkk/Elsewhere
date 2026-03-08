import XCTest
@testable import ElsewhereCore

final class TimezoneEntryTests: XCTestCase {

    // MARK: - Data Integrity

    func testAllEntriesHaveValidTimezones() {
        for entry in TimezoneEntry.all {
            XCTAssertNotNil(
                TimeZone(identifier: entry.identifier),
                "\(entry.name) has invalid IANA identifier: \(entry.identifier)"
            )
        }
    }

    func testAllEntriesHaveNonEmptyFields() {
        for entry in TimezoneEntry.all {
            XCTAssertFalse(entry.name.isEmpty, "Entry has empty name")
            XCTAssertFalse(entry.flag.isEmpty, "Entry \(entry.name) has empty flag")
            XCTAssertFalse(entry.region.isEmpty, "Entry \(entry.name) has empty region")
        }
    }

    func testNoDuplicateIdentifiers() {
        let identifiers = TimezoneEntry.all.map(\.identifier)
        let unique = Set(identifiers)
        XCTAssertEqual(identifiers.count, unique.count, "Duplicate timezone identifiers found")
    }

    func testCityCount() {
        XCTAssertGreaterThanOrEqual(TimezoneEntry.all.count, 20, "Should have at least 20 cities")
    }

    // MARK: - Lookup

    func testFindByValidIdentifier() {
        let entry = TimezoneEntry.find(by: "Asia/Dubai")
        XCTAssertNotNil(entry)
        XCTAssertEqual(entry?.name, "Dubai")
        XCTAssertEqual(entry?.flag, "🇦🇪")
    }

    func testFindByInvalidIdentifier() {
        XCTAssertNil(TimezoneEntry.find(by: "Mars/Olympus_Mons"))
    }

    func testFindLondon() {
        let entry = TimezoneEntry.find(by: "Europe/London")
        XCTAssertNotNil(entry)
        XCTAssertEqual(entry?.flag, "🇬🇧")
    }

    // MARK: - Search

    func testSearchByName() {
        let results = TimezoneEntry.search("Tokyo")
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.identifier, "Asia/Tokyo")
    }

    func testSearchByRegion() {
        let results = TimezoneEntry.search("Europe")
        XCTAssertTrue(results.count >= 5, "Should find multiple European cities")
    }

    func testSearchCaseInsensitive() {
        let results = TimezoneEntry.search("dubai")
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Dubai")
    }

    func testSearchEmpty() {
        let results = TimezoneEntry.search("")
        XCTAssertEqual(results.count, TimezoneEntry.all.count, "Empty search returns all")
    }

    func testSearchNoMatch() {
        let results = TimezoneEntry.search("Atlantis")
        XCTAssertTrue(results.isEmpty)
    }

    // MARK: - Regions

    func testRegionsExist() {
        XCTAssertTrue(TimezoneEntry.regions.contains("Americas"))
        XCTAssertTrue(TimezoneEntry.regions.contains("Europe"))
        XCTAssertTrue(TimezoneEntry.regions.contains("Middle East & Africa"))
        XCTAssertTrue(TimezoneEntry.regions.contains("Asia & Oceania"))
    }

    func testRegionEntriesNonEmpty() {
        for region in TimezoneEntry.regions {
            XCTAssertFalse(TimezoneEntry.entries(for: region).isEmpty, "Region \(region) is empty")
        }
    }

    func testAllEntriesBelongToARegion() {
        let regionEntries = TimezoneEntry.regions.flatMap { TimezoneEntry.entries(for: $0) }
        XCTAssertEqual(regionEntries.count, TimezoneEntry.all.count)
    }

    // MARK: - Equatable

    func testEquality() {
        let a = TimezoneEntry(name: "Dubai", identifier: "Asia/Dubai", flag: "🇦🇪", region: "Middle East & Africa")
        let b = TimezoneEntry(name: "Dubai", identifier: "Asia/Dubai", flag: "🇦🇪", region: "Middle East & Africa")
        XCTAssertEqual(a, b)
    }

    // MARK: - TimeZone property

    func testTimeZoneProperty() {
        let entry = TimezoneEntry.find(by: "America/New_York")!
        XCTAssertEqual(entry.timeZone.identifier, "America/New_York")
    }
}
