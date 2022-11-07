import enum Yosemite.CreateAccountError

extension WooAnalyticsEvent {
    enum StoreCreation {
        /// Event property keys.
        private enum Key {
            static let source = "source"
            static let url = "url"
            static let errorType = "error_type"
        }

        /// Tracked when the user taps on the CTA in store picker (logged in to WPCOM) to create a store.
        static func sitePickerCreateSiteTapped(source: StorePickerSource) -> WooAnalyticsEvent {
            WooAnalyticsEvent(statName: .sitePickerCreateSiteTapped,
                              properties: [Key.source: source.rawValue])
        }

        /// Tracked when a site is created from the store creation flow.
        static func siteCreated(source: Source, siteURL: String) -> WooAnalyticsEvent {
            WooAnalyticsEvent(statName: .siteCreated,
                              properties: [Key.source: source.rawValue, Key.url: siteURL])
        }

        /// Tracked when site creation fails.
        static func siteCreationFailed(source: Source, error: Error) -> WooAnalyticsEvent {
            WooAnalyticsEvent(statName: .siteCreationFailed,
                              properties: [Key.source: source.rawValue],
                              error: error)
        }

        /// Tracked when the user dismisses the store creation flow before the flow is complete.
        static func siteCreationDismissed(source: Source) -> WooAnalyticsEvent {
            WooAnalyticsEvent(statName: .siteCreationDismissed,
                              properties: [Key.source: source.rawValue])
        }

        /// Tracked when the user taps on the CTA in login prologue (logged out) to create a store.
        static func loginPrologueCreateSiteTapped() -> WooAnalyticsEvent {
            WooAnalyticsEvent(statName: .loginPrologueCreateSiteTapped,
                              properties: [:])
        }

        /// Tracked when the user taps on the CTA in the account creation form to log in instead.
        static func signupFormLoginTapped() -> WooAnalyticsEvent {
            WooAnalyticsEvent(statName: .signupFormLoginTapped,
                              properties: [:])
        }

        /// Tracked when the user taps to submit the WPCOM signup form.
        static func signupSubmitted() -> WooAnalyticsEvent {
            WooAnalyticsEvent(statName: .signupSubmitted,
                              properties: [:])
        }

        /// Tracked when WPCOM signup succeeds.
        static func signupSuccess() -> WooAnalyticsEvent {
            WooAnalyticsEvent(statName: .signupSuccess,
                              properties: [:])
        }

        /// Tracked when WPCOM signup fails.
        static func signupFailed(error: CreateAccountError) -> WooAnalyticsEvent {
            WooAnalyticsEvent(statName: .signupFailed,
                              properties: [Key.errorType: error.analyticsValue])
        }
    }
}

extension WooAnalyticsEvent.StoreCreation {
    enum StorePickerSource: String {
        /// From switching stores.
        case switchStores = "switching_stores"
        /// From the login flow.
        case login
        /// The store creation flow is originally initiated from login prologue and dismissed,
        /// which lands on the store picker.
        case loginPrologue = "prologue"
        /// Other sources like from any error screens during the login flow.
        case other
    }

    enum Source: String {
        case loginPrologue = "prologue"
        case storePicker = "store_picker"
        case loginEmailError = "login_email_error"
    }
}

private extension CreateAccountError {
    var analyticsValue: String {
        switch self {
        case .emailExists:
            return "EMAIL_EXIST"
        case .invalidEmail:
            return "EMAIL_INVALID"
        case .invalidPassword:
            return "PASSWORD_INVALID"
        default:
            return "\(self)"
        }
    }
}