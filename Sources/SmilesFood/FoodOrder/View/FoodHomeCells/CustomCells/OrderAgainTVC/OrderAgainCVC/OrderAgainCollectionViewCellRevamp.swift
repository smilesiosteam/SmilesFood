//
//  OrderAgainCollectionViewCellRevamp.swift
//  House
//
//  Created by Shahroze Zaheer on 11/4/22.
//  Copyright © 2022 Ahmed samir ali. All rights reserved.
//

import UIKit

class OrderAgainCollectionViewCellRevamp: UICollectionViewCell {

    @IBOutlet weak var image: UIImageView! {
        didSet {
            image.layer.borderColor = UIColor.appRevampLayerBorderColor.cgColor
            image.layer.borderWidth = 1.0
        }
    }
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var cusiensLbl: UILabel!
    @IBOutlet weak var ratingLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUI()
    }
    
    private func setupUI() {
        image.addMaskedCorner(withMaskedCorner: [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner], cornerRadius: 16.0)
    }
    
    func configureCellWithData(data : OrderListDO) {
        title.text = data.restaurentName
       
        if let cusines = data.cuisines, cusines.count > 0 {
            let joined = cusines.joined(separator: ",")
            cusiensLbl.text = joined
        }
        
        if let restaurantRating = data.restaurantRating, restaurantRating > 0 {
            ratingLbl.text = "\(restaurantRating)"
        }
        
        if let time = data.deliveryTime {
            timeLbl.text = "\(time) \("MinTitle".localizedString)"
        }
      
        if let largeImageUrl = data.imageUrlLarge, !largeImageUrl.isEmpty {
            image.setImageWithUrlString(largeImageUrl)
        } else if let imageUrl = data.imageUrl, !imageUrl.isEmpty {
            image.setImageWithUrlString(imageUrl)
        } else {
            image.image = UIColor.appRevampImageBackgroundColor.as1ptImage()
        }
    }

}
