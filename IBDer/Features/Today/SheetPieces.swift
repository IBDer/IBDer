import SwiftUI

/// The title and cancel action every recording sheet starts with.
struct SheetHeader: View {
    let titleKey: LocalizedStringKey
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        HStack {
            Text(titleKey)
                .font(DesignTokens.Typography.title)
                .foregroundStyle(DesignTokens.Color.textPrimary)
            Spacer()
            Button("common.cancel") { dismiss() }
                .foregroundStyle(DesignTokens.Color.textSecondary)
        }
        .padding(DesignTokens.Spacing.regular)
    }
}

/// The time of day a record happened. Editable, so a forgotten event can be backfilled.
struct TimeRow: View {
    @Binding var happenedAt: Date

    var body: some View {
        HStack {
            Text("record.time")
                .font(DesignTokens.Typography.body)
                .foregroundStyle(DesignTokens.Color.textSecondary)
            Spacer()
            DatePicker("record.time", selection: $happenedAt, displayedComponents: .hourAndMinute)
                .labelsHidden()
        }
        .padding(.horizontal, DesignTokens.Spacing.medium)
        .padding(.vertical, DesignTokens.Spacing.small)
        .background(DesignTokens.Color.surface, in: RoundedRectangle(cornerRadius: DesignTokens.Radius.control))
    }
}

/// One line of free text.
struct FieldRow: View {
    let placeholder: LocalizedStringKey
    @Binding var text: String

    var body: some View {
        TextField(placeholder, text: $text)
            .font(DesignTokens.Typography.body)
            .padding(.horizontal, DesignTokens.Spacing.medium)
            .frame(height: DesignTokens.Layout.minimumTouchTarget)
            .background(DesignTokens.Color.surface, in: RoundedRectangle(cornerRadius: DesignTokens.Radius.control))
    }
}

/// A note field that grows to a couple of lines.
struct NoteField: View {
    @Binding var note: String
    let placeholder: LocalizedStringKey

    var body: some View {
        TextField(placeholder, text: $note, axis: .vertical)
            .font(DesignTokens.Typography.body)
            .lineLimit(2 ... 4)
            .padding(DesignTokens.Spacing.medium)
            .background(DesignTokens.Color.surface, in: RoundedRectangle(cornerRadius: DesignTokens.Radius.control))
    }
}

enum Pickers {
    /// A past day keeps the current clock time, so backfilling does not need a time picker first.
    static func defaultTime(for day: Date) -> Date {
        let calendar = Calendar.current
        if calendar.isDateInToday(day) {
            return .now
        }
        let parts = calendar.dateComponents([.hour, .minute], from: .now)
        return calendar.date(bySettingHour: parts.hour ?? 12, minute: parts.minute ?? 0, second: 0, of: day) ?? day
    }
}
