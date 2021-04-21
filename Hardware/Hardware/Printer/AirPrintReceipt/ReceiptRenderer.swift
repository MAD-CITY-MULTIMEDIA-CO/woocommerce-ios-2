import UIKit

/// Renders a receipt in an AirPrint enabled printer.
/// To be properly implemented in https://github.com/woocommerce/woocommerce-ios/issues/3978
final class ReceiptRenderer: UIPrintPageRenderer {
    private let lines: [ReceiptLineItem]
    private let parameters: ReceiptParameters

    private let attributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: "HelveticaNeue", size: 48) as Any]

    init(content: ReceiptContent) {
        self.lines = content.lineItems
        self.parameters = content.parameters

        super.init()

        configureHeaderAndFooter()

        configureFormatter()
    }

    override func drawHeaderForPage(at pageIndex: Int, in headerRect: CGRect) {
        let pageNumberString = NSString(string: "Order receipt. Page \(pageIndex + 1)")
        pageNumberString.draw(in: headerRect, withAttributes: attributes)
    }

    override func drawContentForPage(at pageIndex: Int, in contentRect: CGRect) {
        let printOut = NSString(string: "Total charged: \(parameters.amount / 100) \(parameters.currency.uppercased())")

        printOut.draw(in: contentRect, withAttributes: attributes)
    }
}


private extension ReceiptRenderer {
    enum Constants {
        static let headerHeight: CGFloat = 80
        static let footerHeight: CGFloat = 80
        static let marging: CGFloat = 20
    }

    private func configureHeaderAndFooter() {
        headerHeight = Constants.headerHeight
        footerHeight = Constants.footerHeight
    }

    private func configureFormatter() {
        let formatter = UISimpleTextPrintFormatter(text: "\(parameters.amount / 100) \(parameters.currency.uppercased())")
        formatter.perPageContentInsets = .init(top: Constants.headerHeight, left: Constants.marging, bottom: Constants.footerHeight, right: Constants.marging)

        addPrintFormatter(formatter, startingAtPageAt: 0)
    }
}
