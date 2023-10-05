//
//  FoodOrderTableViewDelegate.swift
//  House
//
//  Created by Hanan Ahmed on 11/22/22.
//  Copyright © 2022 Ahmed samir ali. All rights reserved.
//

import Foundation
import AnalyticsSmiles
import SmilesStoriesManager
import SmilesUtilities
import SmilesSharedModels
import SmilesBanners
import SmilesReusableComponents

// MARK: - UITableViewDelegate
extension FoodOrderHomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let secID = SectionIdentifier(rawValue: self.foodSections?.sectionDetails?[safe: indexPath.section]?.sectionIdentifier ?? "") {
            switch secID {
            case .TOPPLACEHOLDER:
                break
            case .TOPBANNERS:
                break
            case .TOPCUISINE:
                break
            case .RECOMMENDEDLISTING:
                break
            case .TOPCOLLECTIONS:
                break
            case .STORIES:
                break
            case .TOPBRANDS:
                break
            case .SUBSCRIPTIONBANNERS:
                if let subscription = ((self.dataSource?.dataSources?[safe: indexPath.section] as? TableViewDataSource<GetSubscriptionBannerResponseModel>)?.models?[safe: indexPath.row] as? GetSubscriptionBannerResponseModel)?.subscriptionBanner {
                    
                    if let eventName = self.foodSections?.getEventName(for: SectionIdentifier.SUBSCRIPTIONBANNERS.rawValue), !eventName.isEmpty {
                        SmilesCommonMethods.registerPersonalizationEvent(for: eventName, urlScheme: subscription.redirectionUrl.asStringOrEmpty(), source: self.personalizationEventSource)
                    }
                    handleBannerDeepLinkRedirections(url: subscription.redirectionUrl.asStringOrEmpty())
                }
            case .RESTAURANTLISTING:
                if let restaurant = (self.dataSource?.dataSources?[safe: indexPath.section] as? TableViewDataSource<Restaurant>)?.models?[safe: indexPath.row] {
                    
                    if let eventName = self.foodSections?.getEventName(for: SectionIdentifier.RESTAURANTLISTING.rawValue), !eventName.isEmpty {
                        SmilesCommonMethods.registerPersonalizationEvent(for: eventName, restaurantId: restaurant.restaurantId.asStringOrEmpty(), menuItemType: self.orderTypeLocalVariable.rawValue, recommendationModelEvent: restaurant.recommendationModelEvent.asStringOrEmpty(), source: self.personalizationEventSource)
                    }
                    selectedFavoriteRestaurantIndexPath = indexPath
                    redirectToRestaurantDetailController(restaurant: restaurant, sourceClick: restaurant.sourceClick)
                }
            case .ORDERHISTORY:
                break
            default:
                break
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if indexPath.section == 0 {
//            return 70
//        }
        
        switch self.foodSections?.sectionDetails?[safe: indexPath.section]?.sectionIdentifier {
//        case SectionIdentifier.TOPPLACEHOLDER.rawValue:
//            return 70
        case SectionIdentifier.TOPCOLLECTIONS.rawValue:
            return 190
        case SectionIdentifier.STORIES.rawValue:
            return 260
        case SectionIdentifier.ORDERHISTORY.rawValue:
            return 190
        case SectionIdentifier.TOPBRANDS.rawValue:
            return 108
        case SectionIdentifier.RECOMMENDEDLISTING.rawValue:
            return 190
        case SectionIdentifier.SUBSCRIPTIONBANNERS.rawValue:
            return 160
        default:
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        if !(self.sections.isEmpty){
            if let restaurantListingIndex = getSectionIndex(for: .RESTAURANTLISTING), section != restaurantListingIndex {
                if self.dataSource?.tableView(tableView, numberOfRowsInSection: section) == 0 {
                    return CGFloat.leastNormalMagnitude
                }
            }
        }else {
            if self.dataSource?.tableView(tableView, numberOfRowsInSection: section) == 0 && !self.didSelectFilterOrSort {
                return CGFloat.leastNormalMagnitude
            }
        }
        if let section = self.foodSections?.sectionDetails?[safe: section] {
            if section.sectionIdentifier == SectionIdentifier.OFFERLISTING.rawValue {
                return 125
            } else {
                return UITableView.automaticDimension
            }
        }
        
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if !(self.sections.isEmpty){
            if let restaurantListingIndex = getSectionIndex(for: .RESTAURANTLISTING), section != restaurantListingIndex {
                if self.dataSource?.tableView(tableView, numberOfRowsInSection: section) == 0 {
                    return nil
                }
            }
        } else {
            if self.dataSource?.tableView(tableView, numberOfRowsInSection: section) == 0 && !self.didSelectFilterOrSort {
                return nil
            }
        }
        if let sectionData = self.foodSections?.sectionDetails?[safe: section] {
            if sectionData.sectionIdentifier == SectionIdentifier.RESTAURANTLISTING.rawValue && (sectionData.isSortAllowed != 0 || sectionData.isFilterAllowed != 0) {
                self.input.send(.getFiltersData(filtersSavedList: self.filtersSavedList, isFilterAllowed: sectionData.isFilterAllowed, isSortAllowed: sectionData.isSortAllowed)) // Get Filters Data
                let filtersCell = tableView.dequeueReusableCell(withIdentifier: "FiltersTableViewCell") as! FiltersTableViewCell
                filtersCell.title.text = sectionData.title
                filtersCell.title.setTextSpacingBy(value: -0.2)
                filtersCell.subTitle.text = sectionData.subTitle
                filtersCell.filtersData = self.filtersData
                filtersCell.backgroundColor = UIColor(hexString: sectionData.backgroundColor ?? "")
                
                filtersCell.callBack = { [weak self] filterData in
                    if filterData.tag == RestaurantFiltersType.filters.rawValue {
                        let analyticsSmiles = AnalyticsSmiles(service: FirebaseAnalyticsService())
                        analyticsSmiles.sendAnalyticTracker(trackerData: Tracker(eventType: AnalyticsEvent.firebaseEvent(.ClickOnFilter).name, parameters: [:]))
                        self?.redirectToRestaurantFilters()
                    } else if filterData.tag == RestaurantFiltersType.deliveryTime.rawValue {
                        // Delivery time
                        if let sortingListRowModels = self?.sortingListRowModels {
                            self?.redirectToSortingPopUp(rowModels: sortingListRowModels)
                        }
                    } else {
                        // Remove and saved filters
                        self?.input.send(.removeAndSaveFilters(filter: filterData))
                    }
                }
                
                if let section = self.foodSections?.sectionDetails?[safe: section] {
                    if section.sectionIdentifier == SectionIdentifier.RESTAURANTLISTING.rawValue {
                        filtersCell.stackViewTopConstraint.constant = 20
                    }
                }
                
                self.configureHeaderForShimmer(section: section, headerView: filtersCell)
                return filtersCell
            } else {
                let headerView = FoodHeaderNib()
                headerView.title.text = sectionData.title
                headerView.title.setTextSpacingBy(value: -0.2)
                headerView.subTitle.text = sectionData.subTitle
                
                if section == 0 {
                    headerView.stackViewTopConstraint.constant = 0
                } else {
                    if let section = self.foodSections?.sectionDetails?[safe: section] {
                        if section.sectionIdentifier != SectionIdentifier.OFFERLISTING.rawValue && section.sectionIdentifier != SectionIdentifier.TOPBANNERS.rawValue && section.sectionIdentifier != SectionIdentifier.ORDERHISTORY.rawValue {
                            headerView.stackViewTopConstraint.constant = 20
                        }
                        
                        if section.sectionIdentifier == SectionIdentifier.TOPBANNERS.rawValue && hasOrderHistory {
                            headerView.stackViewTopConstraint.constant = 34
                        }
                    }
                }
                
                headerView.setBackgroundColor(color: UIColor(hexString: sectionData.backgroundColor ?? ""))
                if sectionData.sectionIdentifier == SectionIdentifier.ORDERHISTORY.rawValue {
                    headerView.viewAllView.isHidden = false
                }
                headerView.callBack = { [weak self] in
                    debugPrint(section)
                    let orderHistoryIndex = self?.getSectionIndex(for: .ORDERHISTORY)
                    if orderHistoryIndex == section{
                        self?.orderHistorViewAll()
                    }
                }
                self.configureHeaderForShimmer(section: section, headerView: headerView)
                return headerView
            }
            
        }
        return nil
    }
    
    func configureHeaderForShimmer(section:Int, headerView:UIView){
        func showHide(isDummy:Bool){
            if isDummy {
                headerView.enableSkeleton()
                headerView.showAnimatedGradientSkeleton()
            } else {
                headerView.hideSkeleton()
            }
        }
        if let sectionData = self.foodSections?.sectionDetails?[safe: section], let secID = SectionIdentifier(rawValue: sectionData.sectionIdentifier ?? ""){
            switch  secID {
            case .ORDERHISTORY:
                if let dataSource = self.dataSource?.dataSources?[safe: section] as? TableViewDataSource<GetOrderHistoryDOResponse>{
                    showHide(isDummy: dataSource.isDummy)
                }
            case .TOPBANNERS:
                if let dataSource = (self.dataSource?.dataSources?[safe: section] as? TableViewDataSource<GetTopAdsResponseModel>){
                    showHide(isDummy: dataSource.isDummy)
                }
            case .TOPCUISINE:
                if let dataSource = (self.dataSource?.dataSources?[safe: section] as? TableViewDataSource<GetCuisinesResponseModel>){
                    showHide(isDummy: dataSource.isDummy)
                }
            case .RECOMMENDEDLISTING:
                if let dataSource = (self.dataSource?.dataSources?[safe: section] as? TableViewDataSource<GetPopularRestaurantsResponseModel>){
                    showHide(isDummy: dataSource.isDummy)
                }
            case .TOPCOLLECTIONS:
                if let dataSource = (self.dataSource?.dataSources?[safe: section] as? TableViewDataSource<GetCollectionsResponseModel>){
                    showHide(isDummy: dataSource.isDummy)
                }
            case .STORIES:
                if let dataSource = (self.dataSource?.dataSources?[safe: section] as? TableViewDataSource<Stories>){
                    showHide(isDummy: dataSource.isDummy)
                }
            case .TOPBRANDS:
                if let dataSource = (self.dataSource?.dataSources?[safe: section] as? TableViewDataSource<GetTopBrandsResponseModel>){
                    showHide(isDummy: dataSource.isDummy)
                }
            case .SUBSCRIPTIONBANNERS:
                if let dataSource = (self.dataSource?.dataSources?[safe: section] as? TableViewDataSource<GetSubscriptionBannerResponseModel>){
                    showHide(isDummy: dataSource.isDummy)
                }
            case .RESTAURANTLISTING:
                if let dataSource = (self.dataSource?.dataSources?[safe: section] as? TableViewDataSource<Restaurant>){
                    showHide(isDummy: dataSource.isDummy)
                }
            default:
                break
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if !(self.sections.isEmpty){
            if let restaurantIndex = getSectionIndex(for: .RESTAURANTLISTING) {
                if indexPath.section == restaurantIndex {
                    let lastItem = self.restaurants.endIndex - 1
                    if indexPath.row == lastItem {
                        if let isLastPageReached = restaurantListing?.isLastPageReached, !isLastPageReached {
                            restaurantPage += 1
                            var restaurantFiltersObjects = [RestaurantRequestFilter]()
                            if let savedFilters = self.filtersSavedList, !savedFilters.isEmpty {
                                for item in savedFilters {
                                    let restaurantRequestFilter = RestaurantRequestFilter()
                                    restaurantRequestFilter.filterKey = item.filterKey
                                    restaurantRequestFilter.filterValue = item.filterValue
                                    restaurantFiltersObjects.append(restaurantRequestFilter)
                                }
                            }
//                            if let savedFilters = self.savedFilters {
//                                restaurantFiltersObjects = savedFilters
//                            }
                            if let sort = self.viewModel.selectedSortingTableViewCellModel {
                                let restaurantRequestFilter = RestaurantRequestFilter()
                                restaurantRequestFilter.filterKey = sort.filterKey
                                restaurantRequestFilter.filterValue = sort.filterValue
                                restaurantFiltersObjects.append(restaurantRequestFilter)
                            }
                            input.send(.getRestaurantList(pageNo: restaurantPage, filtersList: restaurantFiltersObjects, selectedSortingTableViewCellModel: self.viewModel.selectedSortingTableViewCellModel))
                        }
                    }
                }
            }
        }
    }
}
