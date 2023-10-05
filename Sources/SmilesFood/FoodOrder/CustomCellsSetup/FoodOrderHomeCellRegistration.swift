//
//  FoodOrderHomeCellRegistration.swift
//  House
//
//  Created by Hanan Ahmed on 11/17/22.
//  Copyright © 2022 Ahmed samir ali. All rights reserved.
//

import Foundation
import SmilesUtilities
import SmilesSharedModels
import SmilesOffers
import SmilesBanners
import SmilesReusableComponents
import SmilesStoriesManager

struct FoodOrderHomeCellRegistration: CellRegisterable {
    
    func register(for tableView: UITableView) {
        
        tableView.registerCellFromNib(CollectionsTableViewCell.self, bundle: CollectionsTableViewCell.module)
        
        tableView.registerCellFromNib(RestaurantsRevampTableViewCell.self, bundle: RestaurantsRevampTableViewCell.module)
        
        tableView.registerCellFromNib(StoriesTableViewCell.self, bundle: StoriesTableViewCell.module)
        
        tableView.registerCellFromNib(RecommendedResturantsTableViewCell.self, withIdentifier: String(describing: RecommendedResturantsTableViewCell.self))
        
        tableView.registerCellFromNib(TopOffersTableViewCell.self, bundle: TopOffersTableViewCell.module)
        
        tableView.registerCellFromNib(CuisinesTableViewCell.self, withIdentifier: String(describing: CuisinesTableViewCell.self))
        
        tableView.registerCellFromNib(TopBrandsTableViewCell.self, bundle: TopBrandsTableViewCell.module)
        
        tableView.registerCellFromNib(DeliveryAndPickupTableViewCell.self, withIdentifier: String(describing: DeliveryAndPickupTableViewCell.self))
        
        tableView.registerCellFromNib(OrderAgainTableViewCellRevamp.self, withIdentifier: String(describing: OrderAgainTableViewCellRevamp.self))
        
        tableView.registerCellFromNib(FiltersTableViewCell.self, withIdentifier: String(describing: FiltersTableViewCell.self), bundle: FiltersTableViewCell.module)
        
        tableView.registerCellFromNib(SubscriptionTableViewCell.self, withIdentifier: String(describing: SubscriptionTableViewCell.self))
    }
}
