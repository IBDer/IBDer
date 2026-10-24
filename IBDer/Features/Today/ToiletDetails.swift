import SwiftUI

/// The details only a stool record needs. Kept out of the sheet so each piece stays readable.
struct ToiletDetails: View {
    @Binding var bristol: BristolType?
    @Binding var blood: BloodAmount?
    @Binding var perianal: PerianalSensation?

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.large) {
            bristolSection
            bloodSection
            perianalSection
        }
    }

    private var bristolSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.small) {
            SectionTitle(titleKey: "toilet.bristol.title")
            VStack(spacing: DesignTokens.Spacing.xSmall) {
                ForEach(BristolType.allCases, id: \.self) { type in
                    bristolRow(type)
                }
            }
        }
    }

    /// One row per form: a shape wide enough to read, the number, and the sentence that actually
    /// tells someone which one they are looking at.
    private func bristolRow(_ type: BristolType) -> some View {
        let isSelected = bristol == type
        let tint = Self.bristolTint(type)
        return Button {
            bristol = isSelected ? nil : type
        } label: {
            HStack(spacing: DesignTokens.Spacing.medium) {
                BristolGlyph(type: type, tint: tint)
                    .frame(width: 56, height: 36)
                VStack(alignment: .leading, spacing: 2) {
                    Text("toilet.bristol.number \(type.rawValue)")
                        .font(DesignTokens.Typography.headline)
                        .foregroundStyle(DesignTokens.Color.textPrimary)
                    Text(Self.bristolTitle(type))
                        .font(DesignTokens.Typography.caption)
                        .foregroundStyle(DesignTokens.Color.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: DesignTokens.Spacing.small)
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(DesignTokens.Typography.body)
                    .foregroundStyle(isSelected ? tint : DesignTokens.Color.border)
            }
            .padding(.horizontal, DesignTokens.Spacing.medium)
            .padding(.vertical, DesignTokens.Spacing.small)
            .background(
                isSelected ? tint.opacity(0.16) : DesignTokens.Color.surface,
                in: RoundedRectangle(cornerRadius: DesignTokens.Radius.control)
            )
            .overlay {
                RoundedRectangle(cornerRadius: DesignTokens.Radius.control)
                    .stroke(isSelected ? tint : DesignTokens.Color.border, lineWidth: 1)
            }
            .contentShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.control))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(Self.bristolTitle(type)))
        .accessibilityIdentifier("toilet.bristol.\(type.rawValue)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    static func bristolTint(_ type: BristolType) -> Color {
        DesignTokens.Color.series[(type.rawValue - 1) % DesignTokens.Color.series.count]
    }

    private var bloodSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.small) {
            SectionTitle(titleKey: "toilet.blood.title")
            ChoiceGrid {
                ForEach(BloodAmount.allCases, id: \.self) { amount in
                    ChoiceChip(
                        titleKey: Self.bloodTitle(amount),
                        isSelected: blood == amount,
                        identifier: "toilet.blood.\(amount.rawValue)"
                    ) {
                        blood = amount
                    }
                }
            }
        }
    }

    private var perianalSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.small) {
            SectionTitle(titleKey: "toilet.perianal.title")
            ChoiceGrid {
                ForEach(PerianalSensation.allCases, id: \.self) { sensation in
                    ChoiceChip(
                        titleKey: Self.perianalTitle(sensation),
                        isSelected: perianal == sensation,
                        identifier: "toilet.perianal.\(sensation.rawValue)"
                    ) {
                        perianal = perianal == sensation ? nil : sensation
                    }
                }
            }
        }
    }

    static func bristolTitle(_ type: BristolType) -> LocalizedStringKey {
        switch type {
        case .type1: "toilet.bristol.1"
        case .type2: "toilet.bristol.2"
        case .type3: "toilet.bristol.3"
        case .type4: "toilet.bristol.4"
        case .type5: "toilet.bristol.5"
        case .type6: "toilet.bristol.6"
        case .type7: "toilet.bristol.7"
        }
    }

    static func bloodTitle(_ amount: BloodAmount) -> LocalizedStringKey {
        switch amount {
        case .none: "toilet.blood.none"
        case .onPaper: "toilet.blood.onPaper"
        case .mixed: "toilet.blood.mixed"
        case .mostlyBlood: "toilet.blood.mostlyBlood"
        }
    }

    static func perianalTitle(_ sensation: PerianalSensation) -> LocalizedStringKey {
        switch sensation {
        case .normal: "toilet.perianal.normal"
        case .pain: "toilet.perianal.pain"
        case .burning: "toilet.perianal.burning"
        case .urge: "toilet.perianal.urge"
        case .itch: "toilet.perianal.itch"
        }
    }
}

/// A two-column grid of choices, the shape every short list in a sheet uses.
struct ChoiceGrid<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: DesignTokens.Spacing.small),
                GridItem(.flexible(), spacing: DesignTokens.Spacing.small),
            ],
            spacing: DesignTokens.Spacing.small
        ) {
            content
        }
    }
}
