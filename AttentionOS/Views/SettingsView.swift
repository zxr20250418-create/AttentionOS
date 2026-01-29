import SwiftUI
import SwiftData
import UniformTypeIdentifiers
import CryptoKit

struct SettingsView: View {
    @AppStorage(NotificationSettings.globalEnabledKey) private var notificationsEnabled = true
    @Query private var inboxItems: [InboxItem]
    @Query private var cases: [Case]
    @Query private var attempts: [Attempt]
    @State private var isPickingExportDirectory = false
    @State private var showMissingExportAlert = false
    @State private var exportErrorMessage: String?
    @State private var exportDirectoryLabel: String = ObsidianExportManager.storedDisplayPath ?? "未选择"

    var body: some View {
        Form {
            Section("Notifications") {
                Toggle("Enable notifications", isOn: $notificationsEnabled)
                Text("Notifications are scheduled for items with a next review date.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Obsidian Export") {
                Button("Obsidian 导出目录") {
                    isPickingExportDirectory = true
                }

                Text(exportDirectoryLabel)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Button("导出全部") {
                    exportAllCases()
                }

                if let exportErrorMessage {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                        Text(exportErrorMessage)
                        Spacer()
                        Button("重新授权") {
                            isPickingExportDirectory = true
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("Settings")
        .onChange(of: notificationsEnabled) { _, isOn in
            handleNotificationsToggle(isOn: isOn)
        }
        .onAppear {
            if notificationsEnabled {
                Task {
                    _ = await NotificationManager.shared.requestAuthorizationIfNeeded()
                }
            }
            refreshExportDirectoryLabel()
        }
        .fileImporter(
            isPresented: $isPickingExportDirectory,
            allowedContentTypes: [.folder],
            allowsMultipleSelection: false
        ) { result in
            handleExportDirectorySelection(result: result)
        }
        .alert("请先选择导出目录", isPresented: $showMissingExportAlert) {
            Button("好", role: .cancel) { }
        }
    }

    private func handleNotificationsToggle(isOn: Bool) {
        if isOn {
            Task {
                _ = await NotificationManager.shared.requestAuthorizationIfNeeded()
                scheduleAll()
            }
        } else {
            NotificationManager.shared.cancelAll()
        }
    }

    private func scheduleAll() {
        for item in inboxItems {
            updateNotification(for: item, globalEnabled: true)
        }
        for caseItem in cases {
            updateNotification(for: caseItem, globalEnabled: true)
        }
        for attempt in attempts {
            updateNotification(for: attempt, globalEnabled: true)
        }
    }

    private func refreshExportDirectoryLabel() {
        exportDirectoryLabel = ObsidianExportManager.storedDisplayPath ?? "未选择"
    }

    private func handleExportDirectorySelection(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            do {
                try ObsidianExportManager.storeBookmark(for: url)
                exportDirectoryLabel = ObsidianExportManager.storedDisplayPath ?? url.path
                exportErrorMessage = nil
            } catch {
                exportErrorMessage = "目录授权保存失败，请重新授权。"
            }
        case .failure:
            break
        }
    }

    private func exportAllCases() {
        guard ObsidianExportManager.hasBookmark else {
            showMissingExportAlert = true
            return
        }
        do {
            try ObsidianExportManager.exportAll(cases: cases)
            exportErrorMessage = nil
        } catch {
            exportErrorMessage = "导出失败，请重新授权。"
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .modelContainer(PreviewContainer.shared)
}

private enum ObsidianExportSettings {
    static let bookmarkKey = "obsidianExportBookmark"
    static let displayPathKey = "obsidianExportDisplayPath"
}

private enum ObsidianExportError: Error {
    case missingBookmark
    case staleBookmark
    case accessDenied
}

private struct ObsidianExportManager {
    static var hasBookmark: Bool {
        UserDefaults.standard.data(forKey: ObsidianExportSettings.bookmarkKey) != nil
    }

    static var storedDisplayPath: String? {
        UserDefaults.standard.string(forKey: ObsidianExportSettings.displayPathKey)
    }

    static func storeBookmark(for url: URL) throws {
        let bookmarkData = try url.bookmarkData(
            options: .withSecurityScope,
            includingResourceValuesForKeys: nil,
            relativeTo: nil
        )
        UserDefaults.standard.set(bookmarkData, forKey: ObsidianExportSettings.bookmarkKey)
        UserDefaults.standard.set(url.path, forKey: ObsidianExportSettings.displayPathKey)
    }

    static func exportAll(cases: [Case]) throws {
        let exportURL = try resolveExportURL()
        guard exportURL.startAccessingSecurityScopedResource() else {
            throw ObsidianExportError.accessDenied
        }
        defer {
            exportURL.stopAccessingSecurityScopedResource()
        }

        let targetDirectory = exportURL.appendingPathComponent("AttentionOS", isDirectory: true)
        try FileManager.default.createDirectory(
            at: targetDirectory,
            withIntermediateDirectories: true,
            attributes: nil
        )

        for caseItem in cases {
            let markdown = MarkdownRenderer.render(caseItem: caseItem)
            let filename = MarkdownRenderer.fileName(for: caseItem)
            let fileURL = targetDirectory.appendingPathComponent(filename)
            try markdown.write(to: fileURL, atomically: true, encoding: .utf8)
        }
    }

    private static func resolveExportURL() throws -> URL {
        guard let data = UserDefaults.standard.data(forKey: ObsidianExportSettings.bookmarkKey) else {
            throw ObsidianExportError.missingBookmark
        }
        var isStale = false
        let url = try URL(
            resolvingBookmarkData: data,
            options: [.withSecurityScope],
            relativeTo: nil,
            bookmarkDataIsStale: &isStale
        )
        if isStale {
            throw ObsidianExportError.staleBookmark
        }
        return url
    }
}

private enum MarkdownRenderer {
    private static let frontmatterDateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    private static let listDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static func fileName(for caseItem: Case) -> String {
        let title = sanitizedTitle(from: caseItem.title)
        let identifier = shortIdentifier(for: caseItem)
        return "\(title)--\(identifier).md"
    }

    static func render(caseItem: Case) -> String {
        let identifier = shortIdentifier(for: caseItem)
        let title = caseItem.title.trimmingCharacters(in: .whitespacesAndNewlines)
        let displayTitle = title.isEmpty ? "Untitled" : title
        let escapedTitle = yamlEscaped(displayTitle)
        let updatedAt = frontmatterDateFormatter.string(from: caseItem.updatedAt)
        let nextReview = caseItem.nextReview.map { frontmatterDateFormatter.string(from: $0) } ?? ""

        var lines: [String] = []
        lines.append("---")
        lines.append("schema: 1")
        lines.append("id: \(identifier)")
        lines.append("title: \"\(escapedTitle)\"")
        lines.append("importance: \(caseItem.importance)")
        lines.append("urgency: \(caseItem.urgency)")
        lines.append("decision: \(caseItem.decision.rawValue)")
        lines.append("next_review: \(nextReview)")
        lines.append("updated_at: \(updatedAt)")
        lines.append("---")
        lines.append("")
        lines.append("## Brief")

        let briefContent = [caseItem.brief, caseItem.details]
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: "\n\n")
        if !briefContent.isEmpty {
            lines.append(briefContent)
        }
        lines.append("")
        lines.append("## Snapshot")

        let recentAttempts = caseItem.attempts.sorted { $0.createdAt > $1.createdAt }.prefix(3)
        if recentAttempts.isEmpty {
            lines.append("- No attempts yet")
        } else {
            for attempt in recentAttempts {
                let summary = attemptSummary(attempt)
                let date = listDateFormatter.string(from: attempt.createdAt)
                lines.append("- \(date) — \(summary)")
            }
        }
        lines.append("- Next step: \(nextStepText(for: caseItem))")
        lines.append("")
        lines.append("## Attempts")

        let timelineAttempts = caseItem.attempts.sorted { $0.createdAt < $1.createdAt }
        if timelineAttempts.isEmpty {
            lines.append("- No attempts yet")
        } else {
            for attempt in timelineAttempts {
                let summary = attemptSummary(attempt)
                let date = listDateFormatter.string(from: attempt.createdAt)
                lines.append("- \(date) — \(summary)")
            }
        }
        lines.append("")
        lines.append("## Playbook")
        lines.append("")

        return lines.joined(separator: "\n")
    }

    private static func attemptSummary(_ attempt: Attempt) -> String {
        let note = attempt.note.trimmingCharacters(in: .whitespacesAndNewlines)
        let outcome = attempt.outcome.trimmingCharacters(in: .whitespacesAndNewlines)
        let displayNote = note.isEmpty ? "Untitled Attempt" : note
        if outcome.isEmpty {
            return singleLine(displayNote)
        }
        return singleLine("\(displayNote) — \(outcome)")
    }

    private static func nextStepText(for caseItem: Case) -> String {
        if let nextReview = caseItem.nextReview {
            let date = listDateFormatter.string(from: nextReview)
            return "Review on \(date)"
        }
        if caseItem.decision != .undecided {
            return "Decision: \(caseItem.decision.rawValue)"
        }
        return "TBD"
    }

    private static func sanitizedTitle(from title: String) -> String {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let baseTitle = trimmed.isEmpty ? "Untitled" : trimmed
        let disallowed = CharacterSet(charactersIn: "/\\:?%*|\"<>")
        let sanitized = baseTitle.unicodeScalars.map { scalar -> Character in
            if disallowed.contains(scalar) {
                return "-"
            }
            return Character(scalar)
        }
        let result = String(sanitized).trimmingCharacters(in: .whitespacesAndNewlines)
        return result.isEmpty ? "Untitled" : result
    }

    private static func yamlEscaped(_ value: String) -> String {
        let withoutNewlines = value.replacingOccurrences(of: "\n", with: " ")
        return withoutNewlines.replacingOccurrences(of: "\"", with: "\\\"")
    }

    private static func singleLine(_ value: String) -> String {
        value.replacingOccurrences(of: "\n", with: " ")
    }

    private static func shortIdentifier(for caseItem: Case) -> String {
        let rawID = String(describing: caseItem.persistentModelID)
        let digest = SHA256.hash(data: Data(rawID.utf8))
        let hex = digest.map { String(format: "%02x", $0) }.joined()
        return String(hex.prefix(8))
    }
}
