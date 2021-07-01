//
//  CartDetailsViewController.swift
//  iProduct
//
//  Created by Shakti Prakash Srichandan on 30/06/21.
//

import UIKit

class CartDetailsViewController: BaseViewController {
    
    @IBOutlet weak var cartListTableView: UITableView!
    lazy var viewModel = CartListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchInCartdetails()
        
    }
    
    fileprivate func setupUI() {
        self.cartListTableView.register(NibFiles.ProductListTableViewCell.instance, forCellReuseIdentifier: ProductListTableViewCell.identifier)
    }
    
    fileprivate func fetchInCartdetails() {
        viewModel.fetchProductDetailFromDBWith()
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
    
}

//MARK: TableView Delegate / Datasource methods
extension CartDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.itemCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: ProductListTableViewCell.identifier, for: indexPath) as? ProductListTableViewCell {
            cell.setupUIWith(self.viewModel.itemAt(indexPath.row),hideCart: true)
            return cell
        }
        return UITableViewCell()
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}
