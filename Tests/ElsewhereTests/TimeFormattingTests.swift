import XCTest
@testable import ElsewhereCore

final class TimeFormattingTests: XCTestCase {

    // MARK: - UTC Offset

    func testUTCOffsetDubai() {
        let tz = TimeZone(identifier: "Asia/Dubai")!
        let date = Date()
        let result = TimeFormatting.utcOffsetString(for: tz, at: date)
        XCTAssertEqual(result, "UTC+4") // Dubai is always UTC+4, no DST
    }

    func testUTCOffsetMumbai() {
        let tz = TimeZone(identifier: "Asia/Kolkata")!
        let date = Date()
        let result = TimeFormatting.utcOffsetString(for: tz, at: date)
        XCTAssertEqual(result, "UTC+5:30") // India is UTC+5:30
    }

    func testUTCOffsetGMT() {
        // Use a fixed date in winter to avoid DST
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        let date = cal.date(from: DateComponents(year: 2025, month: 1, day: 15, hour: 12))!
        let tz = TimeZone(identifier: "Europe/London")!
        let result = TimeFormatting.utcOffsetString(for: tz, at: date)
        XCTAssertEqual(result, "UTC+0")
    }

    func testUTCOffsetNegative() {
        let tz = TimeZone(identifier: "America/New_York")!
        // Use winter date to get EST (UTC-5)
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        let date = cal.date(from: DateComponents(year: 2025, month: 1, day: 15, hour: 12))!
        let result = TimeFormatting.utcOffsetString(for: tz, at: date)
        XCTAssertEqual(result, "UTC-5")
    }

    // MARK: - Relative Diff

    func testRelativeDiffSameZone() {
        let tz = TimeZone(identifier: "Asia/Dubai")!
        let result = TimeFormatting.relativeDiffString(from: tz, to: tz, at: Date())
        XCTAssertEqual(result, "local")
    }

    func testRelativeDiffDubaiToLondon() {
        // In winter, London is UTC+0, Dubai is UTC+4
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        let date = cal.date(from: DateComponents(year: 2025, month: 1, day: 15, hour: 12))!
        let dubai = TimeZone(identifier: "Asia/Dubai")!
        let london = TimeZone(identifier: "Europe/London")!
        let result = TimeFormatting.relativeDiffString(from: dubai, to: london, at: date)
        XCTAssertEqual(result, "-4h")
    }

    func testRelativeDiffWithHalfHour() {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        let date = cal.date(from: DateComponents(year: 2025, month: 1, day: 15, hour: 12))!
        let london = TimeZone(identifier: "Europe/London")!
        let mumbai = TimeZone(identifier: "Asia/Kolkata")!
        let result = TimeFormatting.relativeDiffString(from: london, to: mumbai, at: date)
        XCTAssertEqual(result, "+5h30m")
    }

    // MARK: - Day Label

    func testDayLabelSameDay() {
        // Noon UTC — most zones are the same calendar day
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        let date = cal.date(from: DateComponents(year: 2025, month: 6, day: 15, hour: 12))!
        let london = TimeZone(identifier: "Europe/London")!
        let paris = TimeZone(identifier: "Europe/Paris")!
        let result = TimeFormatting.dayLabel(local: london, remote: paris, at: date)
        XCTAssertEqual(result, "")
    }

    func testDayLabelTomorrow() {
        // 11:30 PM in London = next day in Auckland (UTC+12/+13)
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "Europe/London")!
        let date = cal.date(from: DateComponents(year: 2025, month: 1, day: 15, hour: 23, minute: 30))!
        let london = TimeZone(identifier: "Europe/London")!
        let auckland = TimeZone(identifier: "Pacific/Auckland")!
        let result = TimeFormatting.dayLabel(local: london, remote: auckland, at: date)
        XCTAssertEqual(result, "Tomorrow")
    }

    func testDayLabelYesterday() {
        // Early morning in Auckland = previous day in New York
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "Pacific/Auckland")!
        let date = cal.date(from: DateComponents(year: 2025, month: 1, day: 16, hour: 2, minute: 0))!
        let auckland = TimeZone(identifier: "Pacific/Auckland")!
        let newYork = TimeZone(identifier: "America/New_York")!
        let result = TimeFormatting.dayLabel(local: auckland, remote: newYork, at: date)
        XCTAssertEqual(result, "Yesterday")
    }

    // MARK: - ClockInfo

    func testClockInfoHasAllFields() {
        let entry = TimezoneEntry.find(by: "Asia/Dubai")!
        let f = DateFormatter()
        f.dateStyle = .none
        f.timeStyle = .short
        let info = TimeFormatting.clockInfo(for: entry, at: Date(), formatter: f)
        XCTAssertEqual(info.entry, entry)
        XCTAssertFalse(info.time.isEmpty)
        XCTAssertFalse(info.utcOffset.isEmpty)
        XCTAssertFalse(info.relativeDiff.isEmpty)
        XCTAssertFalse(info.copyText.isEmpty)
        XCTAssertTrue(info.copyText.contains("Dubai"))
    }

    // MARK: - Meeting Planner

    func testOverlapSameCity() {
        let dubai = TimezoneEntry.find(by: "Asia/Dubai")!
        let result = TimeFormatting.workingHoursOverlap(city1: dubai, city2: dubai, at: Date())
        XCTAssertEqual(result.overlapHours, 8) // 9-17 = 8h full overlap
    }

    func testOverlapDubaiLondonWinter() {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        let date = cal.date(from: DateComponents(year: 2025, month: 1, day: 15, hour: 12))!
        let dubai = TimezoneEntry.find(by: "Asia/Dubai")!
        let london = TimezoneEntry.find(by: "Europe/London")!
        let result = TimeFormatting.workingHoursOverlap(city1: dubai, city2: london, at: date)
        // Dubai 9-17 = London 5-13. Overlap = London 9-13 = Dubai 13-17 = 4 hours
        XCTAssertEqual(result.overlapHours, 4)
    }

    func testOverlapNoOverlap() {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        let date = cal.date(from: DateComponents(year: 2025, month: 1, day: 15, hour: 12))!
        let auckland = TimezoneEntry.find(by: "Pacific/Auckland")!
        let la = TimezoneEntry.find(by: "America/Los_Angeles")!
        let result = TimeFormatting.workingHoursOverlap(city1: auckland, city2: la, at: date)
        // Auckland UTC+13, LA UTC-8 in winter = 21h diff. No overlap expected
        XCTAssertEqual(result.overlapHours, 0)
    }

    // MARK: - Display Format

    func testDisplayFormatFlagAndTime() {
        let entry = TimezoneEntry.find(by: "Asia/Dubai")!
        let result = DisplayFormat.flagAndTime.format(entry: entry, time: "7:42 PM")
        XCTAssertEqual(result, "🇦🇪 7:42 PM")
    }

    func testDisplayFormatFlagOnly() {
        let entry = TimezoneEntry.find(by: "Europe/London")!
        let result = DisplayFormat.flagOnly.format(entry: entry, time: "3:42 PM")
        XCTAssertEqual(result, "🇬🇧")
    }

    func testDisplayFormatNameAndTime() {
        let entry = TimezoneEntry.find(by: "Asia/Tokyo")!
        let result = DisplayFormat.nameAndTime.format(entry: entry, time: "11:42 PM")
        XCTAssertEqual(result, "Tokyo 11:42 PM")
    }

    func testDisplayFormatTimeOnly() {
        let entry = TimezoneEntry.find(by: "Asia/Dubai")!
        let result = DisplayFormat.timeOnly.format(entry: entry, time: "7:42 PM")
        XCTAssertEqual(result, "7:42 PM")
    }

    func testDisplayFormatGlobeAndTime() {
        let entry = TimezoneEntry.find(by: "Asia/Dubai")!
        let result = DisplayFormat.globeAndTime.format(entry: entry, time: "7:42 PM")
        XCTAssertEqual(result, "7:42 PM") // Globe icon set via NSImage, text is time only
    }

    func testDisplayFormatGlobeUsesSFSymbol() {
        XCTAssertTrue(DisplayFormat.globeAndTime.usesSFSymbol)
        XCTAssertEqual(DisplayFormat.globeAndTime.sfSymbolName, "globe")
    }

    func testNonGlobeFormatsNoSFSymbol() {
        XCTAssertFalse(DisplayFormat.flagAndTime.usesSFSymbol)
        XCTAssertNil(DisplayFormat.flagAndTime.sfSymbolName)
    }

    func testAllDisplayFormatsHaveLabels() {
        for format in DisplayFormat.allCases {
            XCTAssertFalse(format.label.isEmpty)
        }
    }

    func testDisplayFormatRoundTrip() {
        for format in DisplayFormat.allCases {
            let restored = DisplayFormat(rawValue: format.rawValue)
            XCTAssertEqual(restored, format)
        }
    }
}
