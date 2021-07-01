//
//  ProductListViewModel.swift
//  iProduct
//
//  Created by Shakti Prakash Srichandan on 29/06/21.
//

import Foundation
import Combine

class ProductListViewModel: BaseViewModel {
    var requestStatusChanged: ((_ inProgress: Bool) -> Void)?
    var requestSucceeded: (() -> Void)?
    var requestEncounteredError: ((_ error: MEError?) -> Void)?
    private var disposables = Set<AnyCancellable>()
    var networkfecher: NetworkFetchable
    var dataSource: Fetchable
    private lazy var products : [Displayable] = []
    var itemCount: Int  {
        return self.products.count
    }
    private var offset = 0
    private var totalItemCount = 0
    func itemAt(_ index: Int) -> Displayable {
        return self.products[index]
    }
    init(apiService: NetworkFetchable = NetworkFetcher(),dataSource: Fetchable = ProductDataSource()) {
        self.networkfecher = apiService
        self.dataSource = dataSource
    }
    
    //MARK: Methods
    func fetchproductDetails() {
        self.requestStatusChanged?(true)
        self.networkfecher.getProductDetails()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.requestStatusChanged?(false)
                switch completion {
                    case .finished:
                        debugPrint("Completed")
                  
                case .failure(let error ): debugPrint(" Error Occured \(error)")
                    self.requestEncounteredError?(error)
                }
            } receiveValue: { [weak self] products in
                guard let self = self else { return }
                if products.count > 0 {
                 self.performBatchInsertionWth(products)
                } else {
                    self.requestEncounteredError?(MEError.unknownError())
                }
               
            }
            .store(in: &disposables)
    }
    
    private func performBatchInsertionWth(_ products: [Displayable]) {
        do  {
            try  self.dataSource.batchInsertProducts(products)
            debugPrint("Insertions Success")
            totalItemCount = products.count
            self.fetchProductDetailFromDBWith()
        }
        catch let error {
            debugPrint("failed to store",error.localizedDescription)
        }
    }
    
    func fetchProductDetailFromDBWith() {
        if products.count <= totalItemCount {
            self.requestStatusChanged?(true)
            let savedProducts = self.dataSource.fetchProductDetailsWith(offset, predicate: false)
           
            DispatchQueue.main.async { [weak self] in
                self?.requestStatusChanged?(false)
                if savedProducts.count > 0 {
                    self?.offset += 10
                    self?.products += savedProducts
                    self?.requestSucceeded?()
                    debugPrint(savedProducts.count)
                }
                
            }
           
        }
    }
    
    func performAddtoCart(_ product: Displayable , completionHandler: @escaping ((Result<Displayable , MEError>) -> Void)) {
        if let updatedProduct =  self.dataSource.updateCartDetails(of: product) {
            completionHandler(.success(updatedProduct))
        }
        else {
            completionHandler(.failure(MEError.unknownError()))
        }
    }
}
