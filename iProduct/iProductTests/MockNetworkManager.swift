//
//  MockNetworkManager.swift
//  iProductTests
//
//  Created by Shakti Prakash Srichandan on 01/07/21.
//

import Foundation
import Combine
@testable import iProduct

class MockNetworkFetcher: NetworkFetchable  {
    func getProductDetails() -> AnyPublisher<[Product], MEError> {
        return Just([Product.testProductOne,Product.testProductTwo])
            .setFailureType(to: MEError.self)
            .eraseToAnyPublisher()
       
    }
}

class MockDataSource: Fetchable {
   
    
    private var localProducts: [Displayable] = []
   
    func batchInsertProducts(_ products: [Displayable], completion: @escaping (Result<Bool, MEError>) -> Void) {
        localProducts = products
        completion(.success(true))
    }
    
    func fetchProductDetailsWith(_ offset: Int, predicate: Bool) -> [Displayable] {
        return localProducts
    }
    
    func updateCartDetails(of product: Displayable) -> Displayable? {
        return nil
    }
    
    
}
