import SwiftUI

/// Renders a row with a label on the left side, and a toggle switch on the right side
///
struct TitleAndToggleRow: View {
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(title, isOn: $isOn)
            .bodyStyle()
            .toggleStyle(SwitchToggleStyle.init(tint: Color(.primary)))
            .padding(Constants.padding)
    }
}

private extension TitleAndToggleRow {
    enum Constants {
        static let padding: CGFloat = 16
    }
}

struct TitleAndToggleRow_Previews: PreviewProvider {
    static var previews: some View {
        TitleAndToggleRow(title: "Toggle this setting", isOn: .constant(false))
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Single line, toggle off")

        TitleAndToggleRow(title: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas dictum ullamcorper enim.", isOn: .constant(true))
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Multi-line, toggle on")

        TitleAndToggleRow(title: "Toggle this setting", isOn: .constant(true))
            .previewLayout(.sizeThatFits)
            .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
            .previewDisplayName("Accessibility: Large Font Size")

        TitleAndToggleRow(title: "Toggle this setting", isOn: .constant(true))
            .previewLayout(.sizeThatFits)
            .environment(\.layoutDirection, .rightToLeft)
            .previewDisplayName("Localization: Right-to-Left Layout")
    }
}