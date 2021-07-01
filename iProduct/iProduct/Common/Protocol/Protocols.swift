//
//  Protocols.swift
//  iProduct
//
//  Created by Shakti Prakash Srichandan on 28/06/21.
//

import Foundation

//MARK: - Protocol to handle common callbacks of view models
protocol BaseViewModel: class {
    // Used to update the request started/ended status. can be used to update the activity indicator.
    var requestStatusChanged: ((_ inProgress: Bool) -> Void)? { get set }
    // Used to inform about the error
    var requestEncounteredError: ((_ error: MEError?) -> Void)? { get set }
}

protocol Displayable {
    var id: String { get }
    var name: String { get }
    var image: String { get }
    var price: String { get }
    var desc: String { get }
    var incart: Bool { get set }
}

protocol CartHandler {
    func updateCartDetails(status: Bool, atIndex: Int?)
}

protocol Tappable: AnyObject {
    func performCartinteraction(product: Displayable, cell: CartHandler)
}

protocol Fetchable {
    func batchInsertProducts(_ products: [Displayable]) throws
    func fetchProductDetailsWith(_ offset: Int, predicate: Bool) -> [Displayable]
    func updateCartDetails(of product: Displayable) -> Displayable?
}
