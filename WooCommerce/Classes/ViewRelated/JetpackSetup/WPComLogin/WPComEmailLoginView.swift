import SwiftUI

/// Hosting controller for `WPComEmailLoginView`
final class WPComEmailLoginHostingController: UIHostingController<WPComEmailLoginView> {
    private lazy var noticePresenter: DefaultNoticePresenter = {
        let noticePresenter = DefaultNoticePresenter()
        noticePresenter.presentingViewController = self
        return noticePresenter
    }()

    init(onSubmit: @escaping (String) -> Void) {
        super.init(rootView: WPComEmailLoginView(viewModel: .init(onSubmit: onSubmit)))
    }

    @available(*, unavailable)
    required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTransparentNavigationBar()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: Localization.cancel, style: .plain, target: self, action: #selector(dismissView))
    }

    @objc
    private func dismissView() {
        dismiss(animated: true)
    }
}

private extension WPComEmailLoginHostingController {
    enum Localization {
        static let cancel = NSLocalizedString("Cancel", comment: "Button to dismiss the site credential login screen")
    }
}


/// Screen for logging in to a WPCom account during the Jetpack setup flow
/// This is presented for users authenticated with WPOrg credentials.
struct WPComEmailLoginView: View {
    @ObservedObject private var viewModel: WPComEmailLoginViewModel
    @FocusState private var isEmailFieldFocused: Bool

    init(viewModel: WPComEmailLoginViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Constants.blockVerticalPadding) {
                JetpackInstallHeaderView()

                // title and description
                VStack(alignment: .leading, spacing: Constants.contentVerticalSpacing) {
                    Text(Localization.installJetpack)
                        .largeTitleStyle()
                    Text(Localization.loginToInstall)
                        .subheadlineStyle()
                }

                // Email field
                AccountCreationFormFieldView(viewModel: .init(
                    header: Localization.emailLabel,
                    placeholder: Localization.enterEmail,
                    keyboardType: .emailAddress,
                    text: $viewModel.emailAddress,
                    isSecure: false,
                    errorMessage: nil,
                    isFocused: isEmailFieldFocused
                ))
                .focused($isEmailFieldFocused)

                Spacer()
            }
            .padding(Constants.contentHorizontalPadding)
        }
        .safeAreaInset(edge: .bottom) {
            VStack {
                // Primary CTA
                Button(Localization.installJetpack) {
                    viewModel.handleSubmission()
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(viewModel.emailAddress.isEmpty)
            }
            .background(Color(uiColor: .systemBackground))
        }
    }
}

private extension WPComEmailLoginView {
    enum Constants {
        static let blockVerticalPadding: CGFloat = 32
        static let contentVerticalSpacing: CGFloat = 8
        static let contentHorizontalPadding: CGFloat = 16
    }

    enum Localization {
        static let installJetpack = NSLocalizedString(
            "Install Jetpack",
            comment: "Title for the WPCom email login screen when Jetpack is not installed yet"
        )
        static let loginToInstall = NSLocalizedString(
            "Log in with your WordPress.com account to install Jetpack",
            comment: "Subtitle for the WPCom email login screen when Jetpack is not installed yet"
        )
        static let emailLabel = NSLocalizedString("Email address", comment: "Label for the email field on the WPCom email login screen of the Jetpack setup flow.")
        static let enterEmail = NSLocalizedString("Enter email", comment: "Placeholder text for the email field on the WPCom email login screen of the Jetpack setup flow.")
    }
}


struct WPComEmailLoginView_Previews: PreviewProvider {
    static var previews: some View {
        WPComEmailLoginView(viewModel: .init(onSubmit: { _ in }))
    }
}
