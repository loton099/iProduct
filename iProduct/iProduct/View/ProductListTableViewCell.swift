//
//  ProductListTableViewCell.swift
//  iProduct
//
//  Created by Shakti Prakash Srichandan on 29/06/21.
//

import UIKit

class ProductListTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var productImageView: NetworkImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var cartButton: UIButton!
    var data: Displayable?
    weak var delegate: Tappable?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupUIWith(_ data: Displayable, hideCart: Bool = false) {
        self.data = data
        self.nameLabel.text = data.name
        self.priceLabel.text = "Rs:- \(data.price)"
        self.descLabel.text = data.desc
        self.productImageView.loadImageWithURL(url: data.image, placeHolderImage: UIImage(systemName: "photo.on.rectangle.angled"))
        self.cartButton.isSelected = data.incart
        self.cartButton.isHidden = hideCart
    }
    
    @IBAction func cartButtonTapped(_ sender: UIButton) {
        guard let currentProduct = data else { return }
        self.delegate?.performCartinteraction(product: currentProduct, cell: self)
    }
    
}

extension ProductListTableViewCell: CartHandler {
    func updateCartDetails(status: Bool, atIndex: Int?) {
        self.cartButton.isSelected = status
    }
    
}
