//
//  CartListViewModel.swift
//  iProduct
//
//  Created by Shakti Prakash Srichandan on 29/06/21.
//

import Foundation

import Combine

class CartListViewModel: BaseViewModel {
    var requestStatusChanged: ((_ inProgress: Bool) -> Void)?
    var requestSucceeded: (() -> Void)?
    var requestEncounteredError: ((_ error: MEError?) -> Void)?
    
    var dataSource: Fetchable
    private lazy var products : [Displayable] = []
    var itemCount: Int  {
        return self.products.count
    }
    private var offset = 0
    private var canRequestMore = true
    func itemAt(_ index: Int) -> Displayable {
        return self.products[index]
    }
    init(dataSource: Fetchable = ProductDataSource()) {
        self.dataSource = dataSource
    }
    
    
    func fetchProductDetailFromDBWith() {
        if canRequestMore {
            let savedProducts = self.dataSource.fetchProductDetailsWith(offset, predicate: true)
            if savedProducts.count > 0 {
                canRequestMore = true
                self.products += savedProducts
                self.requestSucceeded?()
            }
            else {
                canRequestMore = false
                self.requestEncounteredError?(MEError.alert(title: "empty_cart", message: "add_to_cart", code: 400))
            }
            
            debugPrint(savedProducts.count)
        }
    }
}
