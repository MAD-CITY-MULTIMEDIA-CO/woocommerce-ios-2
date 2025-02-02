import UIKit

/// A toolbar design that contains subviews at the left and right horizontally.
///
final class ToolbarView: UIView {
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [])
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        pinSubviewToSafeArea(stackView)
    }

    func addDividerOnTop() {
        let divider = UIView()
        divider.backgroundColor = .divider
        divider.translatesAutoresizingMaskIntoConstraints = false
        addSubview(divider)

        NSLayoutConstraint.activate([
            divider.heightAnchor.constraint(equalToConstant: 1/UIScreen.main.scale),
            divider.topAnchor.constraint(equalTo: topAnchor),
            divider.leadingAnchor.constraint(equalTo: leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    func setSubviews(leftViews: [UIView], rightViews: [UIView]) {
        stackView.removeAllArrangedSubviews()

        let flexView = UIView(frame: .zero)
        flexView.translatesAutoresizingMaskIntoConstraints = false
        flexView.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let subviews = leftViews + [flexView] + rightViews
        stackView.addArrangedSubviews(subviews)
    }
}
