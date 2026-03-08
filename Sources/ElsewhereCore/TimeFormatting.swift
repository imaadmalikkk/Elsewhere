import Foundation

public enum DisplayFormat: String, CaseIterable {
    case flagAndTime = "flagAndTime"       // 🇦🇪 7:42 PM
    case flagOnly = "flagOnly"             // 🇦🇪
    case nameAndTime = "nameAndTime"       // Dubai 7:42 PM
    case timeOnly = "timeOnly"             // 7:42 PM
    case globeAndTime = "globeAndTime"     // 🌐 7:42 PM (SF Symbol in actual app)

    public var label: String {
        switch self {
        case .flagAndTime: return "Flag + Time"
        case .flagOnly: return "Flag Only"
        case .nameAndTime: return "City + Time"
        case .timeOnly: return "Time Only"
        case .globeAndTime: return "Globe + Time"
        }
    }

    /// Whether this format uses an SF Symbol icon instead of text
    public var usesSFSymbol: Bool {
        self == .globeAndTime
    }

    /// SF Symbol name for icon-based formats
    public var sfSymbolName: String? {
        switch self {
        case .globeAndTime: return "globe"
        default: return nil
        }
    }

    public func format(entry: TimezoneEntry, time: String) -> String {
        switch self {
        case .flagAndTime: return "\(entry.flag) \(time)"
        case .flagOnly: return entry.flag
        case .nameAndTime: return "\(entry.name) \(time)"
        case .timeOnly: return time
        case .globeAndTime: return time // title text only; icon set separately via NSImage
        }
    }
}

public struct ClockInfo {
    public let entry: TimezoneEntry
    public let time: String
    public let utcOffset: String
    public let relativeDiff: String
    public let dayLabel: String

    public var copyText: String {
        "\(entry.flag) \(entry.name): \(time)"
    }
}

public struct TimeFormatting {

    public static func utcOffsetString(for timeZone: TimeZone, at date: Date) -> String {
        let offset = timeZone.secondsFromGMT(for: date)
        let h = offset / 3600
        let m = abs(offset % 3600) / 60
        return m == 0 ? String(format: "UTC%+d", h) : String(format: "UTC%+d:%02d", h, m)
    }

    public static func relativeDiffString(from local: TimeZone, to remote: TimeZone, at date: Date) -> String {
        let localOffset = local.secondsFromGMT(for: date)
        let remoteOffset = remote.secondsFromGMT(for: date)
        let diff = remoteOffset - localOffset

        if diff == 0 { return "local" }

        let hours = diff / 3600
        let mins = abs(diff % 3600) / 60
        if mins == 0 {
            return String(format: "%+dh", hours)
        }
        return String(format: "%+dh%02dm", hours, mins)
    }

    public static func dayLabel(local: TimeZone, remote: TimeZone, at date: Date) -> String {
        var localCal = Calendar.current
        localCal.timeZone = local
        var remoteCal = Calendar.current
        remoteCal.timeZone = remote

        let localDay = localCal.ordinality(of: .day, in: .year, for: date) ?? 0
        let remoteDay = remoteCal.ordinality(of: .day, in: .year, for: date) ?? 0

        if remoteDay > localDay { return "Tomorrow" }
        if remoteDay < localDay { return "Yesterday" }
        return ""
    }

    public static func clockInfo(
        for entry: TimezoneEntry,
        at date: Date,
        localTimeZone: TimeZone = .current,
        formatter: DateFormatter
    ) -> ClockInfo {
        formatter.timeZone = entry.timeZone
        let time = formatter.string(from: date)
        let utc = utcOffsetString(for: entry.timeZone, at: date)
        let rel = relativeDiffString(from: localTimeZone, to: entry.timeZone, at: date)
        let day = dayLabel(local: localTimeZone, remote: entry.timeZone, at: date)
        return ClockInfo(entry: entry, time: time, utcOffset: utc, relativeDiff: rel, dayLabel: day)
    }

    // MARK: - Meeting Planner

    public struct OverlapResult {
        public let city1: TimezoneEntry
        public let city2: TimezoneEntry
        public let overlapStart: Int  // hour in city1's local time
        public let overlapEnd: Int    // hour in city1's local time
        public let overlapHours: Int
    }

    /// Find overlapping working hours (9-17) between two cities
    public static func workingHoursOverlap(
        city1: TimezoneEntry,
        city2: TimezoneEntry,
        at date: Date,
        workStart: Int = 9,
        workEnd: Int = 17
    ) -> OverlapResult {
        let offset1 = city1.timeZone.secondsFromGMT(for: date)
        let offset2 = city2.timeZone.secondsFromGMT(for: date)
        let diffHours = (offset2 - offset1) / 3600

        // city2's work hours in city1's local time
        let city2StartInCity1 = workStart - diffHours
        let city2EndInCity1 = workEnd - diffHours

        let overlapStart = max(workStart, city2StartInCity1)
        let overlapEnd = min(workEnd, city2EndInCity1)
        let overlap = max(0, overlapEnd - overlapStart)

        return OverlapResult(
            city1: city1,
            city2: city2,
            overlapStart: overlapStart,
            overlapEnd: overlapEnd,
            overlapHours: overlap
        )
    }
}
