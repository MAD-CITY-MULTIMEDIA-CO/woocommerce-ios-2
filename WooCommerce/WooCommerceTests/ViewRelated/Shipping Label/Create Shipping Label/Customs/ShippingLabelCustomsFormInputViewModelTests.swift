import XCTest
import Yosemite
@testable import WooCommerce

final class ShippingLabelCustomsFormInputViewModelTests: XCTestCase {

    func test_missingContentExplanation_returns_false_when_contentType_is_not_other() {
        // Given
        let viewModel = ShippingLabelCustomsFormInputViewModel(customsForm: ShippingLabelCustomsForm.fake(),
                                                               destinationCountry: Country.fake(),
                                                               countries: [],
                                                               currency: "$")

        // When
        viewModel.contentsType = .documents
        viewModel.contentExplanation = ""

        // Then
        XCTAssertFalse(viewModel.missingContentExplanation)
    }

    func test_missingContentExplanation_returns_false_when_contentType_is_other_and_explanation_is_not_empty() {
        // Given
        let viewModel = ShippingLabelCustomsFormInputViewModel(customsForm: ShippingLabelCustomsForm.fake(),
                                                               destinationCountry: Country.fake(),
                                                               countries: [],
                                                               currency: "$")

        // When
        viewModel.contentsType = .other
        viewModel.contentExplanation = "Test contents"

        // Then
        XCTAssertFalse(viewModel.missingContentExplanation)
    }

    func test_missingContentExplanation_returns_true_when_contentType_is_other_and_explanation_is_empty() {
        // Given
        let viewModel = ShippingLabelCustomsFormInputViewModel(customsForm: ShippingLabelCustomsForm.fake(),
                                                               destinationCountry: Country.fake(),
                                                               countries: [],
                                                               currency: "$")

        // When
        viewModel.contentsType = .other
        viewModel.contentExplanation = ""

        // Then
        XCTAssertTrue(viewModel.missingContentExplanation)
    }

    func test_missingRestrictionComments_returns_false_when_restrictionType_is_not_other() {
        // Given
        let viewModel = ShippingLabelCustomsFormInputViewModel(customsForm: ShippingLabelCustomsForm.fake(),
                                                               destinationCountry: Country.fake(),
                                                               countries: [],
                                                               currency: "$")

        // When
        viewModel.restrictionType = .quarantine
        viewModel.restrictionComments = ""

        // Then
        XCTAssertFalse(viewModel.missingRestrictionComments)
    }

    func test_missingRestrictionComments_returns_false_when_restrictionType_is_other_and_comment_is_not_empty() {
        // Given
        let viewModel = ShippingLabelCustomsFormInputViewModel(customsForm: ShippingLabelCustomsForm.fake(),
                                                               destinationCountry: Country.fake(),
                                                               countries: [],
                                                               currency: "$")

        // When
        viewModel.restrictionType = .other
        viewModel.restrictionComments = "Test restriction"

        // Then
        XCTAssertFalse(viewModel.missingRestrictionComments)
    }

    func test_missingRestrictionComments_returns_true_when_restrictionType_is_other_and_comment_is_empty() {
        // Given
        let viewModel = ShippingLabelCustomsFormInputViewModel(customsForm: ShippingLabelCustomsForm.fake(),
                                                               destinationCountry: Country.fake(),
                                                               countries: [],
                                                               currency: "$")

        // When
        viewModel.restrictionType = .other
        viewModel.restrictionComments = ""

        // Then
        XCTAssertTrue(viewModel.missingRestrictionComments)
    }

    func test_missingITNForDestination_returns_false_when_ITN_validation_is_not_required() {
        // Given
        let viewModel = ShippingLabelCustomsFormInputViewModel(customsForm: ShippingLabelCustomsForm.fake(),
                                                               destinationCountry: Country.fake(),
                                                               countries: [],
                                                               currency: "$")

        // When
        viewModel.itn = ""

        // Then
        XCTAssertFalse(viewModel.missingITNForDestination)
    }

    func test_missingITNForDestination_returns_true_when_ITN_validation_is_required_for_destination_and_itn_is_empty() {
        // Given
        let viewModel = ShippingLabelCustomsFormInputViewModel(customsForm: ShippingLabelCustomsForm.fake(),
                                                               destinationCountry: Country(code: "IR", name: "Iran", states: []),
                                                               countries: [],
                                                               currency: "$")

        // When
        viewModel.itn = ""

        // Then
        XCTAssertTrue(viewModel.missingITNForDestination)
    }

    func test_invalidITN_returns_false_when_itn_format_is_correct() {
        // Given
        let viewModel = ShippingLabelCustomsFormInputViewModel(customsForm: ShippingLabelCustomsForm.fake(),
                                                               destinationCountry: Country.fake(),
                                                               countries: [],
                                                               currency: "$")

        // When
        viewModel.itn = "AES X20080930987654"

        // Then
        XCTAssertFalse(viewModel.invalidITN)
    }

    func test_invalidITN_returns_true_when_itn_format_is_incorrect() {
        // Given
        let viewModel = ShippingLabelCustomsFormInputViewModel(customsForm: ShippingLabelCustomsForm.fake(),
                                                               destinationCountry: Country.fake(),
                                                               countries: [],
                                                               currency: "$")

        // When
        viewModel.itn = "X2014@"

        // Then
        XCTAssertTrue(viewModel.invalidITN)
    }

    func test_contentExplanation_is_reset_when_contentType_is_not_other() {
        // Given
        let viewModel = ShippingLabelCustomsFormInputViewModel(customsForm: ShippingLabelCustomsForm.fake(),
                                                               destinationCountry: Country.fake(),
                                                               countries: [],
                                                               currency: "$")

        // When
        viewModel.contentsType = .other
        viewModel.contentExplanation = "Test"
        viewModel.contentsType = .documents

        // Then
        XCTAssertTrue(viewModel.contentExplanation.isEmpty)
    }

    func test_restrictionComment_is_reset_when_restrictionType_is_not_other() {
        // Given
        let viewModel = ShippingLabelCustomsFormInputViewModel(customsForm: ShippingLabelCustomsForm.fake(),
                                                               destinationCountry: Country.fake(),
                                                               countries: [],
                                                               currency: "$")

        // When
        viewModel.restrictionType = .other
        viewModel.restrictionComments = "Test"
        viewModel.restrictionType = .sanitaryOrPhytosanitaryInspection

        // Then
        XCTAssertTrue(viewModel.restrictionComments.isEmpty)
    }
}