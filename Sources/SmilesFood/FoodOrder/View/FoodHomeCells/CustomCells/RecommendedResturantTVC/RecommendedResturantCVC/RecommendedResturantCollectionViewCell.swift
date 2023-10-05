//
//  RecommendedResturantCollectionViewCell.swift
//  House
//
//  Created by Shahroze Zaheer on 10/26/22.
//  Copyright © 2022 Ahmed samir ali. All rights reserved.
//

import UIKit
import SmilesUtilities
import SmilesSharedModels

class RecommendedResturantCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var image: UIImageView!
    
    @IBOutlet weak var discountLbl: UILabel!
    @IBOutlet weak var discountView: UIView! {
        didSet {
            discountView.roundSpecifiCorners(corners: [.topRight, .bottomRight], radius: 12)
        }
    }
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var descriptionView: UIView!
    
    @IBOutlet weak var ratingLbl: UILabel!
    
    @IBOutlet weak var timeLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUI()
    }
    
    private func setupUI() {
        image.addMaskedCorner(withMaskedCorner: [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner], cornerRadius: 8.0)
    }

    func configureCellWithData(data : Restaurant) {
        title.text = data.restaurantName
        if let offer = data.offerDiscountText {
            discountView.isHidden = false
            discountLbl.text = offer
        } else {
            discountView.isHidden = true
            discountLbl.text = ""
        }
        
        if let cuisines = data.cuisines, !cuisines.isEmpty {
            descriptionView.isHidden = false
            descriptionLbl.text = cuisines.joined(separator: ", ")
            descriptionLbl.sizeToFit()
        } else {
            descriptionView.isHidden = true
        }
        
        if data.restaurantRating ?? 0 > 0 {
            ratingLbl.text = "\(data.restaurantRating ?? 0)"
        }
        
        if let time = data.deliveryTime{
            timeLbl.text = "\(time) \("MinTitle".localizedString)"
        }
      
        image.setImageWithUrlString(data.imageUrl.asStringOrEmpty()) { image in
            if let image = image {
                self.image.image = image
            }
        }
    }
}
