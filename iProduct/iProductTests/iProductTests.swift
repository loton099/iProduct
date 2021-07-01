//
//  iProductTests.swift
//  iProductTests
//
//  Created by Shakti Prakash Srichandan on 28/06/21.
//

import XCTest
@testable import iProduct

class iProductTests: XCTestCase {
    
    var productsut: ProductListViewModel!
    var cartSut: CartListViewModel!
    
    override func setUpWithError() throws {
        
        productsut = ProductListViewModel(apiService: MockNetworkFetcher(), dataSource: MockDataSource())
        cartSut = CartListViewModel(dataSource: MockDataSource())
        
    }
    
    override func tearDownWithError() throws {
        productsut = nil
        cartSut = nil
    }
    
    func testProductModelProductCount() throws {
        XCTAssertTrue(productsut.itemCount == 0)
    }
    
    func testProductBatchInsertion() throws {
        let expectation = self.expectation(description: "Products")
        productsut.fetchproductDetails()
        productsut.requestSucceeded = {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(productsut.itemCount, 2)
        productsut.fetchProductDetailFromDBWith()
        XCTAssertEqual(productsut.itemCount, 2)
    }
    
    func testProductFetchFromDB() throws {
        cartSut.fetchProductDetailFromDBWith()
        XCTAssertEqual(cartSut.itemCount, 0)
    }
    
}
