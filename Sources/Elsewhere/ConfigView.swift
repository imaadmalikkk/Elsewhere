import SwiftUI
import ServiceManagement
import ElsewhereCore

struct ConfigView: View {
    @ObservedObject var store: ElsewhereStore
    @State private var searchText = ""
    @State private var launchAtLogin = false

    private let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .none
        f.timeStyle = .short
        return f
    }()

    private var searchResults: [TimezoneEntry] {
        guard !searchText.isEmpty else { return [] }
        return TimezoneEntry.search(searchText)
    }

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Search
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.tertiary)
                TextField("Add a city...", text: $searchText)
                    .textFieldStyle(.plain)
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.tertiary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.primary.opacity(0.06), in: RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal, 20)
            .padding(.top, 12)

            // Search results dropdown
            if !searchResults.isEmpty {
                VStack(spacing: 0) {
                    ForEach(searchResults) { entry in
                        let isFav = store.isFavorite(entry.identifier)
                        Button {
                            if isFav {
                                store.removeCity(entry.identifier)
                            } else {
                                withAnimation {
                                    store.addCity(entry.identifier)
                                }
                                searchText = ""
                            }
                        } label: {
                            HStack(spacing: 10) {
                                Text(entry.flag)
                                    .font(.title3)
                                Text(entry.name)
                                    .foregroundStyle(.primary)
                                Spacer()
                                Image(systemName: isFav ? "checkmark.circle.fill" : "plus.circle")
                                    .foregroundStyle(isFav ? .blue : .secondary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }

            // MARK: - Scrollable Content
            ScrollView {
                VStack(spacing: 16) {
                    // MARK: Cities
                    SectionCard(title: "CITIES") {
                        ForEach(Array(store.allFavoriteEntries.enumerated()), id: \.element.id) { index, entry in
                            if index > 0 {
                                Divider()
                            }
                            let info = TimeFormatting.clockInfo(for: entry, at: Date(), formatter: formatter)
                            ClockRow(info: info, isPrimary: index == 0) {
                                withAnimation {
                                    store.removeCity(entry.identifier)
                                }
                            }
                        }
                    }

                    // MARK: Menu Bar
                    SectionCard(title: "MENU BAR") {
                        if let primary = store.primaryEntry {
                            HStack {
                                Spacer()
                                MenuBarPreview(entry: primary, format: store.displayFormat, formatter: formatter)
                                Spacer()
                            }
                            .padding(.vertical, 4)

                            Divider()
                        }

                        ForEach(Array(DisplayFormat.allCases.enumerated()), id: \.element) { index, format in
                            if index > 0 {
                                Divider()
                            }
                            FormatRow(format: format, isSelected: store.displayFormat == format) {
                                store.setDisplayFormat(format)
                            }
                        }
                    }

                    // MARK: General
                    SectionCard(title: "GENERAL") {
                        Toggle("Launch at Login", isOn: $launchAtLogin)
                            .onAppear {
                                launchAtLogin = SMAppService.mainApp.status == .enabled
                            }
                            .onChange(of: launchAtLogin) { _, newValue in
                                do {
                                    if newValue {
                                        try SMAppService.mainApp.register()
                                    } else {
                                        try SMAppService.mainApp.unregister()
                                    }
                                } catch {}
                            }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 8)
            }

            // MARK: - Footer
            Text("Elsewhere v2.0")
                .font(.caption2)
                .foregroundStyle(.quaternary)
                .padding(.bottom, 12)
        }
    }
}

// MARK: - Section Card

struct SectionCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.tertiary)
                .textCase(.uppercase)
                .padding(.leading, 4)

            VStack(spacing: 0) {
                content
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.primary.opacity(0.04))
            )
        }
    }
}

// MARK: - Format Row

struct FormatRow: View {
    let format: DisplayFormat
    let isSelected: Bool
    let onSelect: () -> Void
    @State private var isHovering = false

    var body: some View {
        Button(action: onSelect) {
            HStack {
                Text(format.label)
                    .foregroundStyle(.primary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.blue)
                        .fontWeight(.semibold)
                }
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 4)
            .contentShape(Rectangle())
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isHovering ? Color.primary.opacity(0.06) : Color.clear)
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovering = hovering
            }
        }
    }
}

// MARK: - Clock Row

struct ClockRow: View {
    let info: ClockInfo
    let isPrimary: Bool
    let onRemove: () -> Void
    @State private var isHovering = false

    var body: some View {
        HStack(spacing: 12) {
            Text(info.entry.flag)
                .font(.system(size: 24))

            VStack(alignment: .leading, spacing: 2) {
                Text(info.entry.name)
                    .font(.system(size: 13, weight: isPrimary ? .semibold : .regular))

                HStack(spacing: 4) {
                    Text(info.utcOffset)
                    if !info.relativeDiff.isEmpty && info.relativeDiff != "local" {
                        Text("(\(info.relativeDiff))")
                    } else if info.relativeDiff == "local" {
                        Text("local")
                    }
                    if !info.dayLabel.isEmpty {
                        Text("·")
                        Text(info.dayLabel)
                            .foregroundStyle(.orange)
                    }
                }
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
            }

            Spacer()

            Text(info.time)
                .font(.system(size: 20, weight: .light, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(isPrimary ? .primary : .secondary)

            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.tertiary)
            }
            .buttonStyle(.plain)
            .opacity(isHovering ? 1 : 0)
            .frame(width: 20)
        }
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovering = hovering
            }
        }
    }
}

// MARK: - Menu Bar Preview

struct MenuBarPreview: View {
    let entry: TimezoneEntry
    let format: DisplayFormat
    let formatter: DateFormatter

    var body: some View {
        HStack(spacing: 6) {
            if format.usesSFSymbol {
                Image(systemName: "globe")
                    .font(.system(size: 13))
            }
            Text(format.format(entry: entry, time: currentTime))
                .font(.system(size: 13, weight: .medium))
                .monospacedDigit()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(.quaternary.opacity(0.5), in: Capsule())
    }

    private var currentTime: String {
        formatter.timeZone = entry.timeZone
        return formatter.string(from: Date())
    }
}
