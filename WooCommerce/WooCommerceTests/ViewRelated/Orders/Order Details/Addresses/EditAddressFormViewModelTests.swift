import XCTest
import Yosemite
import TestKit
import Combine
@testable import WooCommerce

final class EditAddressFormViewModelTests: XCTestCase {

    let sampleSiteID: Int64 = 123

    let testingStorage = MockStorageManager()

    let testingStores = MockStoresManager(sessionManager: .testingInstance)

    var subscriptions = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()

        testingStorage.reset()
        testingStores.reset()
        subscriptions.removeAll()
    }

    func test_creating_with_address_prefills_fields_with_correct_data() {
        // Given
        let address = sampleAddress()
        let viewModel = EditAddressFormViewModel(siteID: sampleSiteID, address: address)

        // Then
        XCTAssertEqual(viewModel.fields.firstName, address.firstName)
        XCTAssertEqual(viewModel.fields.lastName, address.lastName)
        XCTAssertEqual(viewModel.fields.email, address.email ?? "")
        XCTAssertEqual(viewModel.fields.phone, address.phone ?? "")

        XCTAssertEqual(viewModel.fields.company, address.company ?? "")
        XCTAssertEqual(viewModel.fields.address1, address.address1)
        XCTAssertEqual(viewModel.fields.address2, address.address2 ?? "")
        XCTAssertEqual(viewModel.fields.city, address.city)
        XCTAssertEqual(viewModel.fields.postcode, address.postcode)

        XCTAssertEqual(viewModel.navigationTrailingItem, .done(enabled: false))
    }

    func test_updating_fields_enables_done_button() {
        // Given
        let address = sampleAddress()
        let viewModel = EditAddressFormViewModel(siteID: sampleSiteID, address: address)
        XCTAssertEqual(viewModel.navigationTrailingItem, .done(enabled: false))

        // When
        viewModel.fields.firstName = "John"

        // Then
        XCTAssertEqual(viewModel.navigationTrailingItem, .done(enabled: true))
    }

    func test_updating_fields_back_to_original_values_disables_done_button() {
        // Given
        let address = sampleAddress()
        let viewModel = EditAddressFormViewModel(siteID: sampleSiteID, address: address)
        XCTAssertEqual(viewModel.navigationTrailingItem, .done(enabled: false))

        // When
        viewModel.fields.firstName = "John"
        viewModel.fields.lastName = "Ipsum"
        viewModel.fields.firstName = "Johnny"
        viewModel.fields.lastName = "Appleseed"

        // Then
        XCTAssertEqual(viewModel.navigationTrailingItem, .done(enabled: false))
    }

    func test_creating_without_address_disables_done_button() {
        // Given
        let viewModel = EditAddressFormViewModel(siteID: sampleSiteID, address: nil)

        // Then
        XCTAssertEqual(viewModel.navigationTrailingItem, .done(enabled: false))
    }

    func test_creating_with_address_with_empty_nullable_fields_disables_done_button() {
        // Given
        let address = sampleAddressWithEmptyNullableFields()
        let viewModel = EditAddressFormViewModel(siteID: sampleSiteID, address: address)

        // Then
        XCTAssertEqual(viewModel.navigationTrailingItem, .done(enabled: false))
    }

    func test_loading_indicator_gets_enabled_during_network_request() {
        // Given
        let address = sampleAddress()
        let viewModel = EditAddressFormViewModel(siteID: sampleSiteID, address: address)

        // When
        viewModel.updateRemoteAddress { _ in }

        // Then
        assertEqual(viewModel.navigationTrailingItem, .loading)
    }

    func test_loading_indicator_gets_disabled_after_the_network_operation_completes() {
        // Given
        let address = sampleAddress()
        let viewModel = EditAddressFormViewModel(siteID: sampleSiteID, address: address)

        // When
        let navigationItem = waitFor { promise in
            viewModel.updateRemoteAddress { _ in
                promise(viewModel.navigationTrailingItem)
            }
        }

        // Then
        assertEqual(navigationItem, .done(enabled: false))
    }

    func test_starting_view_model_without_stored_countries_fetches_them_remotely() {
        // Given
        let viewModel = EditAddressFormViewModel(siteID: sampleSiteID, address: sampleAddress(), storageManager: testingStorage, stores: testingStores)

        // When
        let countriesFetched: Bool = waitFor { promise in
            self.testingStores.whenReceivingAction(ofType: DataAction.self) { action in
                switch action {
                case .synchronizeCountries:
                    promise(true)
                }
            }

            viewModel.onLoadTrigger.send()
        }

        // Then
        XCTAssertTrue(countriesFetched)
    }

    func test_syncing_countries_correctly_sets_showPlaceholders_properties() {
        // Given
        let viewModel = EditAddressFormViewModel(siteID: sampleSiteID, address: sampleAddress(), storageManager: testingStorage, stores: testingStores)
        testingStores.whenReceivingAction(ofType: DataAction.self) { action in
            switch action {
            case .synchronizeCountries(_, let completion):
                completion(.success([])) // Sending an empty because we don't really care about countries on this test.
            }
        }

        // When
        let showPlaceholdersStates: [Bool] = waitFor { promise in
            viewModel.$showPlaceholders
                .dropFirst() // Drop initial value
                .collect(2)  // Expect two state changes
                .sink { emittedValues in
                    promise(emittedValues)
                }
                .store(in: &self.subscriptions)

            viewModel.onLoadTrigger.send()
        }

        // Then
        assertEqual(showPlaceholdersStates, [true, false]) // true: showPlaceholders, false: hide placeholders
    }
}

private extension EditAddressFormViewModelTests {
    func sampleAddress() -> Address {
        return Address(firstName: "Johnny",
                       lastName: "Appleseed",
                       company: nil,
                       address1: "234 70th Street",
                       address2: nil,
                       city: "Niagara Falls",
                       state: "NY",
                       postcode: "14304",
                       country: "US",
                       phone: "333-333-3333",
                       email: "scrambled@scrambled.com")
    }

    func sampleAddressWithEmptyNullableFields() -> Address {
        return Address(firstName: "Johnny",
                       lastName: "Appleseed",
                       company: "",
                       address1: "234 70th Street",
                       address2: "",
                       city: "Niagara Falls",
                       state: "NY",
                       postcode: "14304",
                       country: "US",
                       phone: "",
                       email: "")
    }
}