//
//  CuisinesCollectionViewCell.swift
//  CustomCollectionViews
//
//  Created by Shahroze Zaheer on 10/24/22.
//

import UIKit

class CuisinesCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var image: UIImageView! 
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        image.addBorder(withBorderWidth: 1, borderColor: .black)
        image.addMaskedCorner(withMaskedCorner: [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner], cornerRadius: image.frame.height / 2)
        
        title.font = .circularXXTTBookFont(size: 14.0)
        title.textColor = .appRevampItemTitleColor
    }

    func configureCell(with cuisine: GetCuisinesResponseModel.CuisineDO) {
        image.setImageWithUrlString(cuisine.imageUrl.asStringOrEmpty()) { image in
            if let image = image {
                self.image.image = image
            }
        }
        
        title.text = cuisine.title
    }
}
