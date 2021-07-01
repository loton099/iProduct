//
//  ProductDataSource.swift
//  iProduct
//
//  Created by Shakti Prakash Srichandan on 29/06/21.
//

import Foundation
import CoreData


class ProductDataSource: Fetchable {
    
    var persistentContainer: NSPersistentContainer
    
    init(persistentContainer: NSPersistentContainer = PersistenceManager.shared.persistentContainer) {
        self.persistentContainer = persistentContainer
    }
    
    
    
    func batchInsertProducts(_ products: [Displayable], completion: @escaping (Result<Bool, MEError>) -> Void) {
        persistentContainer.performBackgroundTask { context  in
            let batchInsert = self.performbatchInsertRequest(with: products)
            do {
                try context.execute(batchInsert)
                debugPrint("Record inserted SucessFully")
                completion(.success(true))
            } catch let error {
                debugPrint("BatchInsertion Failuer",error.localizedDescription)
                completion(.failure(MEError.unknownError()))
            }
        }
    }
    
    func fetchProductDetailsWith(_ offset: Int, predicate: Bool) -> [Displayable] {
        let fetchRequest: NSFetchRequest<ProductModel> =
            ProductModel.fetchRequest()
        //fetchRequest.fetchLimit = 10
        fetchRequest.fetchOffset = offset
        if predicate {
            fetchRequest.predicate = NSPredicate(format: "isaddedToCart  = %d ", true)
        }
        do {
            let results = try persistentContainer.viewContext.fetch(fetchRequest)
            return results
        } catch let error {
            print(error)
            return []
        }
    }
    
    func updateCartDetails(of product: Displayable) -> Displayable? {
        
        guard let managedobject = product as? ProductModel else { return nil }
        managedobject.incart = !product.incart
        do {
            try  managedobject.managedObjectContext?.save()
            return managedobject
        } catch let error {
            debugPrint("Unable to update",error.localizedDescription)
            return nil
        }
        
    }
    
    
    private func performbatchInsertRequest(with products: [Displayable]) ->  NSBatchInsertRequest {
        var index = 0
        let total = products.count
        let batchInsert = NSBatchInsertRequest(entity: ProductModel.entity()) { (managedObject: NSManagedObject) -> Bool in
            guard index < total else { return true }
            if let product = managedObject as? ProductModel {
                let data = products[index]
                product.id = data.id
                product.name = data.name
                product.desc = data.desc
                product.price = data.price
                product.image = data.image
            }
            
            index += 1
            return false
        }
        return batchInsert
    }
    
}
