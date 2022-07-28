import Foundation
import UIKit

enum NotificationBadgeType {
    case primary
    case secondary

    var color: UIColor {
        switch self {
        case .primary:
            return .primary
        case .secondary:
            return .accent
        }
    }
}

struct NotificationsBadgeInput {
    let hide: Bool
    let type: NotificationBadgeType
    let tab: WooTab
    let tabBar: UITabBar
    let tabIndex: Int
}

final class NotificationsBadgeController {
    /// Displays or Hides the Dot, depending on the new Badge Value
    ///
    func updateBadge(with input: NotificationsBadgeInput) {
        input.hide ? hideDotOn(with: input) : showDotOn(with: input)
    }

    /// Shows the dot in the specified WooTab
    ///
    private func showDotOn(with input: NotificationsBadgeInput) {
        hideDotOn(with: input)
        let dot = DotView(frame: CGRect(x: DotConstants.xOffset,
                                        y: DotConstants.yOffset,
                                        width: DotConstants.diameter,
                                        height: DotConstants.diameter),
                          color: UIColor.primary,
                          borderWidth: DotConstants.borderWidth)
        dot.tag = dotTag(for: input.tab)
        dot.isHidden = true
        input.tabBar.orderedTabBarActionableViews[input.tabIndex].subviews.first?.insertSubview(dot, at: 1)
        dot.fadeIn()
    }

    /// Hides the Dot in the specified WooTab
    ///
    private func hideDotOn(with input: NotificationsBadgeInput) {
        let tag = dotTag(for: input.tab)
        if let subviews = input.tabBar.orderedTabBarActionableViews[input.tabIndex].subviews.first?.subviews {
            for subview in subviews where subview.tag == tag {
                subview.fadeOut() { _ in
                    subview.removeFromSuperview()
                }
            }
        }
    }

    /// Returns the DotView's Tag for the specified WooTab
    ///
    private func dotTag(for tab: WooTab) -> Int {
        return tab.identifierNumber + DotConstants.tagOffset
    }
}


// MARK: - Constants!
//
private extension NotificationsBadgeController {

    enum DotConstants {
        static let diameter    = CGFloat(9)
        static let borderWidth = CGFloat(1)
        static let xOffset     = CGFloat(16)
        static let yOffset     = CGFloat(0)
        static let tagOffset   = 999
    }
}


// MARK: - DotView UIView
//
private class DotView: UIView {

    private var borderWidth = CGFloat(1) // Border line width defaults to 1

    private let color: UIColor

    /// Designated Initializer
    ///
    init(frame: CGRect, color: UIColor, borderWidth: CGFloat) {
        self.color = color
        super.init(frame: frame)
        self.borderWidth = borderWidth
        setupSubviews()
    }

    /// Required Initializer
    ///
    required init?(coder aDecoder: NSCoder) {
        color = UIColor.primary

        super.init(coder: aDecoder)
        setupSubviews()
    }

    private func setupSubviews() {
        backgroundColor = .clear
    }

    override func draw(_ rect: CGRect) {
        let path = UIBezierPath(ovalIn: CGRect(x: rect.origin.x + borderWidth,
                                               y: rect.origin.y + borderWidth,
                                               width: rect.size.width - borderWidth * 2,
                                               height: rect.size.height - borderWidth * 2))
        color.setFill()
        path.fill()

        path.lineWidth = borderWidth
        UIColor.basicBackground.setStroke()
        path.stroke()
    }
}
