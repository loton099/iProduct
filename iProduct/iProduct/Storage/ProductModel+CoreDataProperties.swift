//
//  ProductModel+CoreDataProperties.swift
//  iProduct
//
//  Created by Shakti Prakash Srichandan on 29/06/21.
//
//

import Foundation
import CoreData


extension ProductModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProductModel> {
        return NSFetchRequest<ProductModel>(entityName: "ProductModel")
    }

    @NSManaged public var desc: String
    @NSManaged public var id: String
    @NSManaged public var image: String
    @NSManaged public var isaddedToCart: Bool
    @NSManaged public var name: String
    @NSManaged public var price: String

}

extension ProductModel : Identifiable, Displayable {
    var incart: Bool {
        get {
            self.isaddedToCart
        }
        set {
            self.isaddedToCart = newValue
        }
    }
    

}
