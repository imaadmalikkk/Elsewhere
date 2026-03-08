import Foundation

public struct TimezoneEntry: Equatable, Hashable, Identifiable, Sendable {
    public var id: String { identifier }
    public let name: String
    public let identifier: String
    public let flag: String
    public let region: String

    public var timeZone: TimeZone {
        TimeZone(identifier: identifier)!
    }

    public init(name: String, identifier: String, flag: String, region: String) {
        self.name = name
        self.identifier = identifier
        self.flag = flag
        self.region = region
    }

    public static func find(by identifier: String) -> TimezoneEntry? {
        all.first { $0.identifier == identifier }
    }

    public static func search(_ query: String) -> [TimezoneEntry] {
        guard !query.isEmpty else { return all }
        let q = query.lowercased()
        return all.filter {
            $0.name.lowercased().contains(q) ||
            $0.region.lowercased().contains(q) ||
            $0.identifier.lowercased().contains(q)
        }
    }

    // MARK: - Curated city list

    public static let all: [TimezoneEntry] = [
        // Americas
        TimezoneEntry(name: "New York", identifier: "America/New_York", flag: "🇺🇸", region: "Americas"),
        TimezoneEntry(name: "Los Angeles", identifier: "America/Los_Angeles", flag: "🇺🇸", region: "Americas"),
        TimezoneEntry(name: "Chicago", identifier: "America/Chicago", flag: "🇺🇸", region: "Americas"),
        TimezoneEntry(name: "Toronto", identifier: "America/Toronto", flag: "🇨🇦", region: "Americas"),
        TimezoneEntry(name: "São Paulo", identifier: "America/Sao_Paulo", flag: "🇧🇷", region: "Americas"),
        TimezoneEntry(name: "Mexico City", identifier: "America/Mexico_City", flag: "🇲🇽", region: "Americas"),
        TimezoneEntry(name: "Buenos Aires", identifier: "America/Argentina/Buenos_Aires", flag: "🇦🇷", region: "Americas"),

        // Europe
        TimezoneEntry(name: "London", identifier: "Europe/London", flag: "🇬🇧", region: "Europe"),
        TimezoneEntry(name: "Paris", identifier: "Europe/Paris", flag: "🇫🇷", region: "Europe"),
        TimezoneEntry(name: "Berlin", identifier: "Europe/Berlin", flag: "🇩🇪", region: "Europe"),
        TimezoneEntry(name: "Amsterdam", identifier: "Europe/Amsterdam", flag: "🇳🇱", region: "Europe"),
        TimezoneEntry(name: "Istanbul", identifier: "Europe/Istanbul", flag: "🇹🇷", region: "Europe"),
        TimezoneEntry(name: "Moscow", identifier: "Europe/Moscow", flag: "🇷🇺", region: "Europe"),

        // Middle East & Africa
        TimezoneEntry(name: "Dubai", identifier: "Asia/Dubai", flag: "🇦🇪", region: "Middle East & Africa"),
        TimezoneEntry(name: "Riyadh", identifier: "Asia/Riyadh", flag: "🇸🇦", region: "Middle East & Africa"),
        TimezoneEntry(name: "Cairo", identifier: "Africa/Cairo", flag: "🇪🇬", region: "Middle East & Africa"),
        TimezoneEntry(name: "Lagos", identifier: "Africa/Lagos", flag: "🇳🇬", region: "Middle East & Africa"),
        TimezoneEntry(name: "Nairobi", identifier: "Africa/Nairobi", flag: "🇰🇪", region: "Middle East & Africa"),

        // Asia & Oceania
        TimezoneEntry(name: "Mumbai", identifier: "Asia/Kolkata", flag: "🇮🇳", region: "Asia & Oceania"),
        TimezoneEntry(name: "Singapore", identifier: "Asia/Singapore", flag: "🇸🇬", region: "Asia & Oceania"),
        TimezoneEntry(name: "Hong Kong", identifier: "Asia/Hong_Kong", flag: "🇭🇰", region: "Asia & Oceania"),
        TimezoneEntry(name: "Shanghai", identifier: "Asia/Shanghai", flag: "🇨🇳", region: "Asia & Oceania"),
        TimezoneEntry(name: "Tokyo", identifier: "Asia/Tokyo", flag: "🇯🇵", region: "Asia & Oceania"),
        TimezoneEntry(name: "Seoul", identifier: "Asia/Seoul", flag: "🇰🇷", region: "Asia & Oceania"),
        TimezoneEntry(name: "Bangkok", identifier: "Asia/Bangkok", flag: "🇹🇭", region: "Asia & Oceania"),
        TimezoneEntry(name: "Jakarta", identifier: "Asia/Jakarta", flag: "🇮🇩", region: "Asia & Oceania"),
        TimezoneEntry(name: "Sydney", identifier: "Australia/Sydney", flag: "🇦🇺", region: "Asia & Oceania"),
        TimezoneEntry(name: "Auckland", identifier: "Pacific/Auckland", flag: "🇳🇿", region: "Asia & Oceania"),
    ]

    public static let regions: [String] = {
        var seen = Set<String>()
        return all.compactMap { entry in
            if seen.contains(entry.region) { return nil }
            seen.insert(entry.region)
            return entry.region
        }
    }()

    public static func entries(for region: String) -> [TimezoneEntry] {
        all.filter { $0.region == region }
    }
}
