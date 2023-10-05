//
//  FoodOrderHomeContract.swift
//  House
//
//  Created by Hanan Ahmed on 11/23/22.
//  Copyright © 2022 Ahmed samir ali. All rights reserved.
//

import Foundation
import SmilesStoriesManager
import SmilesSharedServices
import SmilesUtilities
import SmilesSharedModels
import SmilesOffers
import SmilesBanners
import SmilesReusableComponents

extension FoodOrderHomeViewModel {
    // MARK: - INPUT. View event methods
    enum Input {
        case getCuisines(categoryID: Int, menuItemType: String)
        case getOrderHistory(pageNo : Int = 0, filterKey : String = "filter", filterValue: String = "reorder", orderType: RestaurantMenuType)
        case getTopBrands(categoryID: Int, menuItemType: String?)
        case getCollections(categoryID: Int, menuItemType: String)
        case getSections(categoryID: Int)
        case getTopOffers(menuItemType: String?, bannerType: String?, categoryId: Int?, bannerSubType: String?)
        case getStories(categoryId:Int)
        case getRestaurantList(pageNo : Int = 0, filtersList: [RestaurantRequestFilter]?, selectedSortingTableViewCellModel: FilterDO?)
        case getPopularRestaurants(menuItemType: String?, popularRestaurantType: PopularRestaurantType, popularRestaurantRequest: PopularRestaurantRequest)
        case getPopupPopularRestaurants(menuItemType: String?, popularRestaurantType: PopularRestaurantType, popularRestaurantRequest: PopularRestaurantRequest)
        case getSubscriptionBanner(menuItemType: String)
        case getFiltersData(filtersSavedList: [RestaurantRequestWithNameFilter]?, isFilterAllowed: Int?, isSortAllowed: Int?)
        case removeAndSaveFilters(filter: FiltersCollectionViewCellRevampModel)
        case getSortingList(menuItemType: String)
        case generateActionContentForSortingItems(restaurantSortingResponseModel: GetSortingListResponseModel?)
        case updateRestaurantWishlistStatus(operation: Int, restaurantId: String)
        case didTapSearch
        case getVideoTutorial(sectionKey: String)
        case getAbandonedCart
        case routeToRestaurantDetail(restaurant: Restaurant, isViewCart: Bool?)
        case removeAbandonedCart(abandonedCart: Abandoned?)
        case viewCartDetail(restaurantId: String?)
        case setOrderStatus(orderId: String)
        case getLiveChatUrl(orderId: String?, orderNumber: String?)
        case getOrderRating(orderId: String, trackingStatus: Bool, restaurantId: String, ratingType: String, contentType: String
        )
        case emptyRestaurantList
        case getTopAds(menuItemType: RestaurantMenuType?)
        case reOrderFood(orderId : String?)
        case getReOrderAbandonedCart
    }
    
    
    enum Output {
        case fetchCuisinesDidSucceed(response: GetCuisinesResponseModel)
        case fetchCuisinesDidFail(error: Error)
        
        case fetchOrderHistoryDidSucceed(response: GetOrderHistoryDOResponse)
        case fetchOrderHistoryDidFail(error: Error)
        
        case fetchTopBrandsDidSucceed(response: GetTopBrandsResponseModel)
        case fetchTopBrandsDidFail(error: Error)
        
        case fetchCollectionsDidSucceed(response: GetCollectionsResponseModel)
        case fetchCollectionDidFail(error: Error)
        
        case fetchSectionsDidSucceed(response: GetSectionsResponseModel)
        case fetchSectionsDidFail(error: Error)
        
        case fetchTopOffersDidSucceed(response: GetTopOffersResponseModel)
        case fetchTopOffersDidFail(error: Error)
        
        case fetchStoriesDidSucceed(response: Stories)
        case fetchDidFail(error: Error)

        case fetchRestaurantListDidSucceed(response: GetRestaurantListingDOResponse)
        case fetchRestaurantListDidFail(error: Error)
        case emptyRestaurantListDidSucceed
        case showShimmer(identifier:SectionIdentifier)
        
        case fetchPopularRestaurantsDidSucceed(response: GetPopularRestaurantsResponseModel, menuItemType: String?, popularRestaurantType: PopularRestaurantType)
        case fetchPopularRestaurantsDidFail(error: Error)
        
        case fetchPopupPopularRestaurantsDidSucceed(response: GetPopularRestaurantsResponseModel, menuItemType: String?, popularRestaurantType: PopularRestaurantType)
        case fetchPopupPopularRestaurantsDidFail(error: Error)
        
        case fetchSubscriptionBannerDidSucceed(response: GetSubscriptionBannerResponseModel)
        case fetchSubscriptionBannerDidFail(error: Error)
        
        case fetchVideoTutorialDidSucceed(response: GetVideoTutorialResponseModel)
        case fetchVideoTutorialDidFail(error: Error)
        
        case fetchFiltersDataSuccess(filters: [FiltersCollectionViewCellRevampModel])
        case fetchAllSavedFiltersSuccess(filtersList: [RestaurantRequestFilter], filtersSavedList: [RestaurantRequestWithNameFilter])
        
        case fetchSortingListDidSucceed(response: GetSortingListResponseModel)
        case fetchSortingListDidFail(error: Error)
        
        case fetchContentForSortingItems(baseRowModels: [BaseRowModel])
        
        case updateWishlistStatusDidSucceed(response: WishListResponseModel)

        case fetchSavedFiltersAfterSuccess(filtersSavedList: [RestaurantRequestWithNameFilter])
        
        case didTapSearchSucceed
        

        case didUpdateAbandonedCartAndOrderTracking(cart: Abandoned?, trackingDetails: [TrackOrderOnMapResponseModelOrderTrackingDetail]?, timeout: Int?)
        case routeToRestaurantDetailDidSucceed(selectedRestaurant: Restaurant, isViewCart: Bool?)
        case removeAbandonedCartDidSucceed
        case viewCartDetailDidSucceed(restaurantId: String?)
        case setOrderStatusDidSucceed
        case getLiveChatUrlDidSucceed(chatbotUrl: String?)
        case getOrderRatingDidSucceed(response: OrderRatingResponse, restaurantId: String)
        
        case returnFromFoodCart
        
        case getTopAdsDidSucceed(response: GetTopAdsResponseModel)
        case getTopAdsDidFail(error: Error)
        
        case didSelectFilterOrSort
        case updateHeaderView
        
        case fetchReOrderDidSucceed(response: ReOrderResponseModel)
        case fetchReOrderDidFail(error: Error)
        
        case fetchAbandonedCartDidSucceed(response: AbandonedListResponseModel)
        case fetchAbandonedCartDidFail(error: Error)
        
        case navigateToRestaurantFromAbandonedCart(restaurantObject:Restaurant)
    }
}
