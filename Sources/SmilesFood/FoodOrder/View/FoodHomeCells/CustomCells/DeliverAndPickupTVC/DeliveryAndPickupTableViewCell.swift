//
//  DeliveryAndPickupTableViewCell.swift
//  House
//
//  Created by Shahroze Zaheer on 11/1/22.
//  Copyright © 2022 Ahmed samir ali. All rights reserved.
//

import UIKit

class DeliveryAndPickupTableViewCell: UITableViewCell {

    @IBOutlet weak var bottomCurveView: UIView! {
        didSet {
            bottomCurveView.roundCorners(with: [.topLeft, .topRight], radius: 22)
        }
    }
    
    @IBOutlet weak var foodDeliverTitle: UILabel!
    @IBOutlet weak var foodDeliveryIcon: UIImageView!
    @IBOutlet weak var foodDeliveryBottomBar: RoundUIView!
    
    @IBOutlet weak var foodPickupTitle: UILabel!
    @IBOutlet weak var foodPickupIcon: UIImageView!
    @IBOutlet weak var foodPickupBottomBar: RoundUIView!
    
    var menuTypeCallback: ((_ menuItem: RestaurantMenuType) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        buttonStatus(isDeliverySelected: true)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func foodPickupTapped(_ sender: Any) {
        buttonStatus(isDeliverySelected: false)
        menuTypeCallback?(.PICK_UP)
    }
    
    @IBAction func foodDeliveryTapped(_ sender: Any) {
        buttonStatus(isDeliverySelected: true)
        menuTypeCallback?(.DELIVERY)
    }
    
    func buttonStatus(isDeliverySelected: Bool) {
        if isDeliverySelected {
            foodDeliveryIcon.tintColor = .foodEnableColor
            foodDeliverTitle.textColor = .foodEnableColor
            foodDeliveryBottomBar.backgroundColor = .foodEnableColor
            foodDeliveryBottomBar.isHidden = false
            
            foodPickupIcon.tintColor = .foodDisableColor
            foodPickupTitle.textColor = .foodDisableColor
            foodPickupBottomBar.isHidden = true
        } else {
            foodDeliveryIcon.tintColor = .foodDisableColor
            foodDeliverTitle.textColor = .foodDisableColor
            foodDeliveryBottomBar.isHidden = true
            
            foodPickupIcon.tintColor = .foodEnableColor
            foodPickupTitle.textColor = .foodEnableColor
            foodPickupBottomBar.backgroundColor = .foodEnableColor
            foodPickupBottomBar.isHidden = false
        }
    }
}
