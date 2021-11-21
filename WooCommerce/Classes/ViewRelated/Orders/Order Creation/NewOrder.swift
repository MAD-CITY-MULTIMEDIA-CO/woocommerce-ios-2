import SwiftUI

/// Hosting controller that wraps an `NewOrder` view.
///
final class NewOrderHostingController: UIHostingController<NewOrder> {

    init() {
        super.init(rootView: NewOrder())
    }

    required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// View to create a new manual order
///
struct NewOrder: View {
    let viewModel = NewOrderViewModel()

    var body: some View {
        ScrollView {
            EmptyView()
        }
        .background(Color(.listBackground))
            .ignoresSafeArea(.container, edges: [.horizontal, .bottom])
        .navigationTitle(Localization.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(action: {
                    // TODO-5405 - Add create order action
                }, label: {
                    Text(Localization.createButton)
                })
                    .renderedIf(viewModel.isCreateButtonEnabled)
            }
        }
        .wooNavigationBarStyle()
    }
}

// MARK: Constants
private extension NewOrder {
    enum Localization {
        static let title = NSLocalizedString("New Order", comment: "Title for the order creation screen")
        static let createButton = NSLocalizedString("Create", comment: "Button to create an order on the New Order screen")
    }
}

struct NewOrder_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NewOrder()
        }
    }
}
