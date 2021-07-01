//
//  ViewController.swift
//  iProduct
//
//  Created by Shakti Prakash Srichandan on 28/06/21.
//

import UIKit

class ViewController: BaseViewController {
    @IBOutlet weak var cartListTableView: UITableView!
    lazy var viewModel = ProductListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchDetails()
    }
    
    fileprivate func setupUI() {
        self.cartListTableView.register(NibFiles.ProductListTableViewCell.instance, forCellReuseIdentifier: ProductListTableViewCell.identifier)
    }
    
    fileprivate func fetchDetails() {
        viewModel.fetchproductDetails()
    }
    //MARK:- BaseViewController  methods
    override func viewModelObject() -> BaseViewModel? {
        return viewModel
    }
    
    override func setUpViewModelCallbacks() {
        super.setUpViewModelCallbacks()
        
        guard let viewModel = viewModelObject() as? ProductListViewModel else { return }
        
        viewModel.requestSucceeded = {  [weak self] in
            guard let self = self else {return}
            self.cartListTableView.reloadData()
        }
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if shouldLoadMore() {
            viewModel.fetchProductDetailFromDB()
        }
    }
    
    private func shouldLoadMore() -> Bool {
        return (cartListTableView.contentOffset.y + cartListTableView.frame.size.height) >= cartListTableView.contentSize.height
    }
}

//MARK: TableView Delegate / Datasource methods
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.itemCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: ProductListTableViewCell.identifier, for: indexPath) as? ProductListTableViewCell {
            cell.setupUIWith(self.viewModel.itemAt(indexPath.row))
            cell.delegate = self
            return cell
        }
        return UITableViewCell()
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

extension ViewController: Tappable {
    func performCartinteraction(product: Displayable, cell: CartHandler) {
        
        self.viewModel.performAddtoCart(product) { result  in
            
            DispatchQueue.main.async {
                switch result {
                
                case .success( let updatedProduct):
                    cell.updateCartDetails(status: updatedProduct.incart, atIndex: nil)
                    if updatedProduct.incart == true {
                        AlertManager.showAlert(on: self, withTitle: "added_to_cart".localized, message: "")
                    }
                    
                case .failure(let error):
                    debugPrint("Error ",error.localizedDescription)
                    
                }
            }
        }
    }
    
    
}
