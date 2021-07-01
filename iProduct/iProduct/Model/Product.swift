//
//  Product.swift
//  iProduct
//
//  Created by Shakti Prakash Srichandan on 29/06/21.
//

import Foundation


struct Product {
    let id, name: String
    let image: String
    let desc, price: String
    var isAddedtoCart: Bool = false
}

extension Product: Codable {
    enum CodingKeys: String, CodingKey {
        case id, name, image
        case desc = "description"
        case price
    }
}

extension Product: Displayable {
    var incart: Bool {
        get {
            self.isAddedtoCart
        }
        set {
            self.isAddedtoCart = newValue
        }
    }
    
}

extension Product {
    static let testProductOne = Product(id: "testid1", name: "testproduct1", image: "testproductimagelink1", desc: "testproductdesc1", price: "testprice1", isAddedtoCart: false)
    static let testProductTwo = Product(id: "testid2", name: "testproduct2", image: "testproductimagelink2", desc: "testproductdesc2", price: "testprice3", isAddedtoCart: false)
}
