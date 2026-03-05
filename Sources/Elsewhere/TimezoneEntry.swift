import Foundation

struct TimezoneEntry {
    let name: String
    let identifier: String
    let flag: String

    var timeZone: TimeZone {
        TimeZone(identifier: identifier)!
    }

    static let dubai = TimezoneEntry(name: "Dubai", identifier: "Asia/Dubai", flag: "🇦🇪")
    static let london = TimezoneEntry(name: "London", identifier: "Europe/London", flag: "🇬🇧")

    static let all: [TimezoneEntry] = [.dubai, .london]

    static func find(by identifier: String) -> TimezoneEntry? {
        all.first { $0.identifier == identifier }
    }
}
