import XCTest
@testable import Networking


/// ProductListMapper Unit Tests
///
class ProductListMapperTests: XCTestCase {
    /// Verifies that all of the Product Fields are parsed correctly.
    ///
    func testProductFieldsAreProperlyParsed() {
        let products = mapLoadAllProductsResponse()
        XCTAssertEqual(products.count, 10)

        let firstProduct = products[0]
        XCTAssertEqual(firstProduct.productID, 282)
        XCTAssertEqual(firstProduct.name, "Book the Green Room")
        XCTAssertEqual(firstProduct.slug, "book-the-green-room")
        XCTAssertEqual(firstProduct.permalink, "https://example.com/product/book-the-green-room/")

        XCTAssertEqual(firstProduct.productTypeKey, "booking")
        XCTAssertEqual(firstProduct.catalogVisibilityKey, "visible")

        XCTAssertEqual(firstProduct.description, "<p>This is the party room!</p>\n")
        XCTAssertEqual(firstProduct.shortDescription, "[contact-form]\n<p>The green room&#8217;s max capacity is 30 people. Reserving the date / time of your event is free. We can also accommodate large groups, with seating for 85 board game players at a time. If you have a large group, let us know and we&#8217;ll send you our large group rate.</p>\n<p>GROUP RATES</p>\n<p>Reserve your event for up to 30 guests for $100.</p>\n")
        XCTAssertEqual(firstProduct.sku, "")

        XCTAssertEqual(firstProduct.price, "0")
        XCTAssertEqual(firstProduct.regularPrice, "")
        XCTAssertEqual(firstProduct.salePrice, "")
        XCTAssertFalse(firstProduct.onSale)

        XCTAssertTrue(firstProduct.purchasable)
        XCTAssertEqual(firstProduct.totalSales, 0)
        XCTAssertTrue(firstProduct.virtual)

        XCTAssertFalse(firstProduct.downloadable)
        XCTAssertEqual(firstProduct.downloadLimit, -1)
        XCTAssertEqual(firstProduct.downloadExpiry, -1)

        XCTAssertEqual(firstProduct.externalURL, "")
        XCTAssertEqual(firstProduct.taxStatusKey, "taxable")
        XCTAssertEqual(firstProduct.taxClass, "")

        XCTAssertFalse(firstProduct.manageStock)
        XCTAssertNil(firstProduct.stockQuantity)
        XCTAssertEqual(firstProduct.stockStatusKey, "instock")

        XCTAssertEqual(firstProduct.backordersKey, "no")
        XCTAssertFalse(firstProduct.backordersAllowed)
        XCTAssertFalse(firstProduct.backordered)

        XCTAssertTrue(firstProduct.soldIndividually)
        XCTAssertEqual(firstProduct.weight, "")

        XCTAssertFalse(firstProduct.shippingRequired)
        XCTAssertFalse(firstProduct.shippingTaxable)
        XCTAssertEqual(firstProduct.shippingClass, "")
        XCTAssertEqual(firstProduct.shippingClassID, 0)

        XCTAssertTrue(firstProduct.reviewsAllowed)
        XCTAssertEqual(firstProduct.averageRating, "0.00")
        XCTAssertEqual(firstProduct.ratingCount, 0)

        XCTAssertEqual(firstProduct.relatedIDs, [])
        XCTAssertEqual(firstProduct.upsellIDs, [])
        XCTAssertEqual(firstProduct.crossSellIDs, [])
        XCTAssertEqual(firstProduct.parentID, 0)

        XCTAssertEqual(firstProduct.purchaseNote, "")
        XCTAssertEqual(firstProduct.images, [])

        XCTAssertEqual(firstProduct.attributes, [])
        XCTAssertEqual(firstProduct.defaultAttributes, [])
        XCTAssertEqual(firstProduct.variations, [])
        XCTAssertEqual(firstProduct.groupedProducts, [])

        XCTAssertEqual(firstProduct.menuOrder, 0)
        XCTAssertEqual(firstProduct.productType, ProductType(rawValue: "booking"))
    }

    /// Test that ProductTypeKey converts to
    /// a ProductType enum properly.
    func testThatProductTypeKeyConvertsToEnumProperly() {
        let products = mapLoadAllProductsResponse()

        let firstProduct = products[0]
        let customType = ProductType(rawValue: "booking")
        XCTAssertEqual(firstProduct.productTypeKey, "booking")
        XCTAssertEqual(firstProduct.productType, customType)

        let secondProduct = products[1]
        let simpleType = ProductType.simple
        XCTAssertEqual(secondProduct.productTypeKey, "simple")
        XCTAssertEqual(secondProduct.productType, simpleType)

        let thirdProduct = products[2]
        let groupedType = ProductType.grouped
        XCTAssertEqual(thirdProduct.productTypeKey, "grouped")
        XCTAssertEqual(thirdProduct.productType, groupedType)

        let fourthProduct = products[3]
        let externalType = ProductType.external
        XCTAssertEqual(fourthProduct.productTypeKey, "external")
        XCTAssertEqual(fourthProduct.productType, externalType)

        let fifthProduct = products[4]
        let variableType = ProductType.variable
        XCTAssertEqual(fifthProduct.productTypeKey, "variable")
        XCTAssertEqual(fifthProduct.productType, variableType)
    }

    /// Test that categories are properly mapped.
    ///
    func testThatProductCategoriesAreProperlyMapped() {
        let products = mapLoadAllProductsResponse()
        let firstProduct = products[0]
        let categories = firstProduct.categories
        XCTAssertEqual(categories.count, 1)

        guard let category = firstProduct.categories[0] else {
            XCTFail("Failed to parse product category")
            return
        }

        XCTAssertEqual(category.categoryID, 36)
        XCTAssertEqual(category.name, "Events")
        XCTAssertEqual(category.slug, "events")
        XCTAssertTrue(category.categoryID == 36)
    }

    /// Test that tags are properly mapped.
    ///
    func testThatProductTagsAreProperlyMapped() {
        let products = mapLoadAllProductsResponse()
        let firstProduct = products[0]
        let tags = firstProduct.tags
        XCTAssert(tags.count == 9)

        let tag = tags[2]
        XCTAssertEqual(tag?.tagID, 45)
        XCTAssertEqual(tag?.name, "birthday party")
        XCTAssertEqual(tag?.slug, "birthday-party")
    }

    /// Test that product images are properly mapped.
    ///
    func testThatProductImagesAreProperlyMapped() {
        let products = mapLoadAllProductsResponse()
        let product = products[1]
        let images = product.images
        XCTAssert(images.count == 1)

        let productImage = images[0]
        let dateCreated = DateFormatter.Defaults.dateTimeFormatter.date(from: "2018-05-07T21:02:45")
        let dateModified = DateFormatter.Defaults.dateTimeFormatter.date(from: "2018-05-07T21:03:04")
        XCTAssertEqual(productImage?.imageID, 209)
        XCTAssertEqual(productImage?.dateCreated, dateCreated)
        XCTAssertEqual(productImage?.dateModified, dateModified)
        XCTAssertEqual(productImage?.src, "https://i0.wp.com/thuy-nonjtpk.mystagingwebsite.com/wp-content/uploads/2018/05/71PEq6VvFjL._SL1500_.jpg?fit=1500%2C1500&ssl=1")
        XCTAssertEqual(productImage?.name, "Dymo LabelWriter 4XL")
        XCTAssert(productImage?.alt?.isEmpty == true)
    }
}


/// Private Methods.
///
private extension ProductListMapperTests {

    /// Returns the OrderListMapper output upon receiving `filename` (Data Encoded)
    ///
    func mapProducts(from filename: String) -> [Product] {
        guard let response = Loader.contentsOf(filename) else {
            return []
        }

        return try! ProductListMapper().map(response: response)
    }

    /// Returns the OrderListMapper output upon receiving `orders-load-all`
    ///
    func mapLoadAllProductsResponse() -> [Product] {
        return mapProducts(from: "products-load-all")
    }
}
