//
//  FoodOrderHomeViewModel.swift
//  House
//
//  Created by Shahroze Zaheer on 10/26/22.
//  Copyright (c) 2022 All rights reserved.
//

import Foundation
import Combine
import SmilesStoriesManager
import SmilesSharedServices
import SmilesUtilities
import SmilesSharedModels
import SmilesOffers
import SmilesBanners
import SmilesReusableComponents

class FoodOrderHomeViewModel: NSObject {
    
    enum PopularRestaurantType {
        case foodOrder
        case popularRestaurantPopup
    }
    
    // MARK: -- Variables
    private var output: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()

    private let cuisinesViewModel = CuisinesViewModel()
    private let topBrandsViewModel = TopBrandsViewModel()
    private let collectionsViewModel = CollectionsViewModel()
    private let sectionsViewModel = SectionsViewModel()
    private let orderHistoryViewModel = OrderHistroyViewModel()
    private let topOffersViewModel = TopOffersViewModel()
    private let wishListViewModel = WishListViewModel()
    private let restaurantListModel = RestaurantListViewModel()

    private let popularRestaurantsViewModel = PopularRestaurantsViewModel()
    private let subscriptionBannerViewModel = SubscriptionBannerViewModel()
    private let sortingListViewModel = SortingListViewModel()
    private let videoTutorialViewModel = VideoTutorialViewModel()
    private let abandonedCartViewModel = AbandonedCartViewModel()
    private let topAdsViewModel = TopAdsViewModel()
    private let foodReorderViewModel = FoodReorderViewModel()

    private var filtersSavedList: [RestaurantRequestWithNameFilter]?
    private var filtersList: [RestaurantRequestFilter]?
    var selectedSortingTableViewCellModel: FilterDO?

    private var cuisinesUseCaseinput: PassthroughSubject<CuisinesViewModel.Input, Never> = .init()
    private var topBrandsUseCaseInput: PassthroughSubject<TopBrandsViewModel.Input, Never> = .init()
    private var collectionsUseCaseInput: PassthroughSubject<CollectionsViewModel.Input, Never> = .init()
    private var inputOrderHistory: PassthroughSubject<OrderHistroyViewModel.Input, Never> = .init()
    private var sectionsUseCaseInput: PassthroughSubject<SectionsViewModel.Input, Never> = .init()
    private var topOffersUseCaseInput: PassthroughSubject<TopOffersViewModel.Input, Never> = .init()
    private var wishListUseCaseInput: PassthroughSubject<WishListViewModel.Input, Never> = .init()
    private var restaurantListUseCaseInput: PassthroughSubject<RestaurantListViewModel.Input, Never> = .init()
    private var popularRestaurantsUseCaseInput: PassthroughSubject<PopularRestaurantsViewModel.Input, Never> = .init()
    private var subscriptionBannerUseCaseInput: PassthroughSubject<SubscriptionBannerViewModel.Input, Never> = .init()
    private var sortingsUseCaseInput: PassthroughSubject<SortingListViewModel.Input, Never> = .init()
    private var videoTutorialUseCaseInput: PassthroughSubject<VideoTutorialViewModel.Input, Never> = .init()
    private var abandonedCartUseCaseInput :PassthroughSubject<AbandonedCartViewModel.Input, Never> = .init()
    private var topAdsUseCaseInput :PassthroughSubject<TopAdsViewModel.Input, Never> = .init()
    private var reOrderFoodUseCaseInput :PassthroughSubject<FoodReorderViewModel.Input, Never> = .init()

    private var popularRestaurantType: PopularRestaurantType = .foodOrder
}

// MARK: - INPUT. View event methods
extension FoodOrderHomeViewModel {
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        output = PassthroughSubject<Output, Never>()
        input.sink { [weak self] event in
            switch event {
            case .getCuisines(let categoryID, let menuItemType):
                self?.bind(to: self?.cuisinesViewModel ?? CuisinesViewModel())
                self?.cuisinesUseCaseinput.send(.getCuisines(categoryID: categoryID, menuItemType: menuItemType))
                
            case .getOrderHistory(pageNo: let pageNo, filterKey: let filterKey, filterValue: let filterValue, orderType: let orderType):
                self?.bind(to: self?.orderHistoryViewModel ?? OrderHistroyViewModel())
                self?.inputOrderHistory.send(.getOrderHistory(pageNo: pageNo, filterKey: filterKey, filterValue: filterValue, orderType: orderType))
                
            case .getTopBrands(let categoryID, let menuItemType):
                self?.bind(to: self?.topBrandsViewModel ?? TopBrandsViewModel())
                self?.topBrandsUseCaseInput.send(.getTopBrands(categoryID: categoryID, menuItemType: menuItemType))
                
            case .getCollections(categoryID: let categoryID, menuItemType: let menuItemType):
                self?.bind(to: self?.collectionsViewModel ?? CollectionsViewModel())
                self?.collectionsUseCaseInput.send(.getCollections(categoryID: categoryID, menuItemType: menuItemType))
                
            case .getSections(categoryID: let categoryID):
                self?.bind(to: self?.sectionsViewModel ?? SectionsViewModel())
                self?.sectionsUseCaseInput.send(.getSections(categoryID: categoryID, baseUrl: Environment.UAT.serviceBaseUrl, isGuestUser: isGuestUser))
                
            case .getTopOffers(let menuItemType, let bannerType, let categoryId, let bannerSubType):
                self?.bind(to: self?.topOffersViewModel ?? TopOffersViewModel())
                self?.topOffersUseCaseInput.send(.getTopOffers(menuItemType: menuItemType, bannerType: bannerType, categoryId: categoryId, bannerSubType: bannerSubType, isGuestUser: isGuestUser, baseUrl: AppCommonMethods.serviceBaseUrl))
                
            case .getStories(let categoryId):
                SmilesStoriesHandler.shared.getStories(categoryId: categoryId, baseURL: Environment.UAT.serviceBaseUrl, isGuestUser: isGuestUser) { storiesResponse in
                    self?.output.send(.fetchStoriesDidSucceed(response: storiesResponse))
                } failure: { error in
                    self?.output.send(.fetchDidFail(error: error))
                }


            case .getRestaurantList(let pageNo, let filtersList, let selectedSortingTableViewCellModel):
                self?.selectedSortingTableViewCellModel = selectedSortingTableViewCellModel
                self?.bind(to: self?.restaurantListModel ?? RestaurantListViewModel())
                let filters = self?.getSavedFilters()
                self?.restaurantListUseCaseInput.send(.getRestaurantList(pageNo: pageNo, filtersList: (filtersList ?? []).isEmpty ? filters : filtersList))

            case .getPopularRestaurants(let menuItemType, let popularRestaurantType, let popularRestaurantRequest):
                self?.popularRestaurantType = popularRestaurantType
                self?.bind(to: self?.popularRestaurantsViewModel ?? PopularRestaurantsViewModel())
                self?.popularRestaurantsUseCaseInput.send(.getPopularRestaurants(menuItemType: menuItemType, type: popularRestaurantRequest))
                
            case .getPopupPopularRestaurants(let menuItemType, let popularRestaurantType, let popularRestaurantRequest):
                self?.popularRestaurantType = popularRestaurantType
                self?.bind(to: self?.popularRestaurantsViewModel ?? PopularRestaurantsViewModel())
                self?.popularRestaurantsUseCaseInput.send(.getPopupPopularRestaurants(menuItemType: menuItemType, type: popularRestaurantRequest))
                
            case .getSubscriptionBanner(let menuItemType):
                self?.bind(to: self?.subscriptionBannerViewModel ?? SubscriptionBannerViewModel())
                self?.subscriptionBannerUseCaseInput.send(.getSubscriptionBanner(menuItemType: menuItemType))
                
            case .getFiltersData(let filtersSavedList, let isFilterAllowed, let isSortAllowed):
                self?.createFiltersData(filtersSavedList: filtersSavedList, isFilterAllowed: isFilterAllowed, isSortAllowed: isSortAllowed)

            case .removeAndSaveFilters(let filter):
                self?.removeAndSaveFilters(filter: filter)
                
            case .getSortingList(let menuItemType):
                self?.bind(to: self?.sortingListViewModel ?? SortingListViewModel())
                self?.sortingsUseCaseInput.send(.getSortingList(menuItemType: menuItemType))
                
            case .generateActionContentForSortingItems(let restaurantSortingResponseModel):
                self?.generateActionContentForSortingItems(restaurantSortingResponseModel: restaurantSortingResponseModel)
                
            case .updateRestaurantWishlistStatus(let operation, let restaurantId):
                self?.bind(to: self?.wishListViewModel ?? WishListViewModel())
                self?.wishListUseCaseInput.send(.updateRestaurantWishlistStatus(operation: operation, restaurantId: restaurantId, baseUrl: AppCommonMethods.serviceBaseUrl))
                
            case .didTapSearch:
                self?.output.send(.didTapSearchSucceed)

            case .getVideoTutorial(let sectionKey):
                self?.bind(to: self?.videoTutorialViewModel ?? VideoTutorialViewModel())
                self?.videoTutorialUseCaseInput.send(.getVideoTutorial(operationName: FoodOrderHomeEndPoints.videoTutorial.rawValue, sectionKey: sectionKey))
                
            case .getAbandonedCart:
                self?.bind(to: self?.abandonedCartViewModel ?? AbandonedCartViewModel())
                self?.abandonedCartUseCaseInput.send(.getAbandonedCart)
                
            case .routeToRestaurantDetail(let restaurant, let isViewCart):
                self?.output.send(.routeToRestaurantDetailDidSucceed(
                    selectedRestaurant: restaurant,
                    isViewCart: isViewCart)
                )
                
            case .removeAbandonedCart(let abandonedCart):
                self?.bind(to: self?.abandonedCartViewModel ?? AbandonedCartViewModel())
                self?.abandonedCartUseCaseInput.send(.removeCart(abandonedCart: abandonedCart))
                
            case .viewCartDetail(let restaurantId):
                self?.output.send(.viewCartDetailDidSucceed(restaurantId: restaurantId))
                
            case .setOrderStatus(let orderId):
                self?.bind(to: self?.abandonedCartViewModel ?? AbandonedCartViewModel())
                self?.abandonedCartUseCaseInput.send(.setOrderStatus(orderId: orderId))
                
            case .getLiveChatUrl(let orderId, let orderNumber):
                self?.bind(to: self?.abandonedCartViewModel ?? AbandonedCartViewModel())
                self?.abandonedCartUseCaseInput.send(.getLiveChatUrl(
                    orderId: orderId.asStringOrEmpty(),
                    orderNumber: orderNumber.asStringOrEmpty())
                )
                
            case .getOrderRating(let orderId, let trackingStatus, let restaurantId, let ratingType, let contentType):
                self?.bind(to: self?.abandonedCartViewModel ?? AbandonedCartViewModel())
                self?.abandonedCartUseCaseInput.send(.getOrderRating(
                    orderId: orderId,
                    trackingStatus: trackingStatus,
                    restaurantId: restaurantId,
                    ratingType: ratingType,
                    contentType: contentType)
                )
                
            case .emptyRestaurantList:
                self?.output.send(.emptyRestaurantListDidSucceed)
         
            case .getTopAds(let menuItemType):
                self?.bind(to: self?.topAdsViewModel ?? TopAdsViewModel())
                self?.topAdsUseCaseInput.send(.getTopAds(menuItemType: menuItemType))
                
            case .getReOrderAbandonedCart:
                self?.bind(to: self?.abandonedCartViewModel ?? AbandonedCartViewModel())
                self?.abandonedCartUseCaseInput.send(.getReOrderAbandonedCart)
                
            case .reOrderFood(let orderId):
                self?.bind(to: self?.foodReorderViewModel ?? FoodReorderViewModel())
                self?.reOrderFoodUseCaseInput.send(.reOrderFood(orderId: orderId))
            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
    
    // MARK: -- Binding
    
    // Cuisine ViewModel Binding
    func bind(to cuisinesViewModel: CuisinesViewModel) {
        cuisinesUseCaseinput = PassthroughSubject<CuisinesViewModel.Input, Never>()
        let output = cuisinesViewModel.transform(input: cuisinesUseCaseinput.eraseToAnyPublisher())
        output
            .sink { [weak self] event in
                switch event {
                case .fetchCuisinesDidSucceed(let cuisinesResponse):
                    debugPrint(cuisinesResponse)
                    self?.output.send(.fetchCuisinesDidSucceed(response: cuisinesResponse))
                case .fetchCuisinesDidFail(let error):
                    self?.output.send(.fetchCuisinesDidFail(error: error))
                }
            }.store(in: &cancellables)
    }
    
    
    func bind(to orderHistoryViewModel: OrderHistroyViewModel) {
        inputOrderHistory = PassthroughSubject<OrderHistroyViewModel.Input, Never>()
        let output = orderHistoryViewModel.transform(input: inputOrderHistory.eraseToAnyPublisher())
        output
            .sink { [weak self] event in
                switch event {
                case .fetchOrderHistoryDidSucceed(let orderHistoryResponse):
                    debugPrint(orderHistoryResponse)
                    self?.output.send(.fetchOrderHistoryDidSucceed(response: orderHistoryResponse))
                case .fetchOrderHistoryDidFail(let error):
                    self?.output.send(.fetchOrderHistoryDidFail(error: error))
                }
            }.store(in: &cancellables)
    }
                    
    // TopBrands ViewModel Binding
    func bind(to topBrandsViewModel: TopBrandsViewModel) {
        topBrandsUseCaseInput = PassthroughSubject<TopBrandsViewModel.Input, Never>()
        let output = topBrandsViewModel.transform(input: topBrandsUseCaseInput.eraseToAnyPublisher())
        output
            .sink { [weak self] event in
                switch event {
                case .fetchTopBrandsDidSucceed(let topBrandsResponse):
                    debugPrint(topBrandsResponse)
                    self?.output.send(.fetchTopBrandsDidSucceed(response: topBrandsResponse))
                case .fetchTopBrandsDidFail(let error):
                    self?.output.send(.fetchTopBrandsDidFail(error: error))
                }
            }.store(in: &cancellables)
    }
    
    // Collections ViewModel Binding
    func bind(to collectionsViewModel: CollectionsViewModel) {
        collectionsUseCaseInput = PassthroughSubject<CollectionsViewModel.Input, Never>()
        let output = collectionsViewModel.transform(input: collectionsUseCaseInput.eraseToAnyPublisher())
        output
            .sink { [weak self] event in
                switch event {
                case .fetchCollectionsDidSucceed(let collectionResponse):
                    debugPrint(collectionResponse)
                    self?.output.send(.fetchCollectionsDidSucceed(response: collectionResponse))
                case .fetchCollectionsDidFail(let error):
                    self?.output.send(.fetchCollectionDidFail(error: error))
                }
            }.store(in: &cancellables)
    }
    
    // Sections ViewModel Binding
    func bind(to sectionsViewModel: SectionsViewModel) {
        sectionsUseCaseInput = PassthroughSubject<SectionsViewModel.Input, Never>()
        let output = sectionsViewModel.transform(input: sectionsUseCaseInput.eraseToAnyPublisher())
        output
            .sink { [weak self] event in
                switch event {
                case .fetchSectionsDidSucceed(let sectionsResponse):
                    debugPrint(sectionsResponse)
                    self?.output.send(.fetchSectionsDidSucceed(response: sectionsResponse))
                case .fetchSectionsDidFail(let error):
                    self?.output.send(.fetchTopBrandsDidFail(error: error))
                }
            }.store(in: &cancellables)
    }
    
    // TopOffers ViewModel Binding
    func bind(to topOffersViewModel: TopOffersViewModel) {
        topOffersUseCaseInput = PassthroughSubject<TopOffersViewModel.Input, Never>()
        let output = topOffersViewModel.transform(input: topOffersUseCaseInput.eraseToAnyPublisher())
        output
            .sink { [weak self] event in
                switch event {
                case .fetchTopOffersDidSucceed(let topOffersResponse):
                    debugPrint(topOffersResponse)
                    self?.output.send(.fetchTopOffersDidSucceed(response: topOffersResponse))
                case .fetchTopOffersDidFail(let error):
                    self?.output.send(.fetchTopOffersDidFail(error: error))
                }
            }.store(in: &cancellables)
    }
    
    // Popular Restaurants ViewModel Binding
    func bind(to popularRestaurantsViewModel: PopularRestaurantsViewModel) {
        popularRestaurantsUseCaseInput = PassthroughSubject<PopularRestaurantsViewModel.Input, Never>()
        let output = popularRestaurantsViewModel.transform(input: popularRestaurantsUseCaseInput.eraseToAnyPublisher())
        output
            .sink { [weak self] event in
                switch event {
                case .fetchPopularRestaurantsDidSucceed(let popularRestaurantsResponse, let menuItemType):
                    self?.output.send(.fetchPopularRestaurantsDidSucceed(response: popularRestaurantsResponse, menuItemType: menuItemType, popularRestaurantType: self?.popularRestaurantType ?? .foodOrder))
                case .fetchPopularRestaurantsDidFail(let error):
                    self?.output.send(.fetchPopularRestaurantsDidFail(error: error))
                    
                case .fetchPopupPopularRestaurantsDidSucceed(let popularRestaurantsResponse, let menuItemType):
                    self?.output.send(.fetchPopupPopularRestaurantsDidSucceed(response: popularRestaurantsResponse, menuItemType: menuItemType, popularRestaurantType: self?.popularRestaurantType ?? .foodOrder))
                case .fetchPopupPopularRestaurantsDidFail(let error):
                    self?.output.send(.fetchPopupPopularRestaurantsDidFail(error: error))

                case .updateWishlistStatusDidSucceed(response: let response):
                    self?.output.send(.updateWishlistStatusDidSucceed(response: response))
                }
            }.store(in: &cancellables)
    }
    
    // SubscriptionBanner ViewModel Binding
    func bind(to subscriptionBannerViewModel: SubscriptionBannerViewModel) {
        subscriptionBannerUseCaseInput = PassthroughSubject<SubscriptionBannerViewModel.Input, Never>()
        let output = subscriptionBannerViewModel.transform(input: subscriptionBannerUseCaseInput.eraseToAnyPublisher())
        output
            .sink { [weak self] event in
                switch event {
                case .fetchSubscriptionBannerDidSucceed(let subscriptionBannerResponse):
                    debugPrint(subscriptionBannerResponse)
                    self?.output.send(.fetchSubscriptionBannerDidSucceed(response: subscriptionBannerResponse))
                case .fetchSubscriptionBannerDidFail(let error):
                    self?.output.send(.fetchSubscriptionBannerDidFail(error: error))
                }
            }.store(in: &cancellables)
    }
    
    
    //Restaurant Listing Binding
    func bind(to restaurantListingViewModel: RestaurantListViewModel) {
        restaurantListUseCaseInput = PassthroughSubject<RestaurantListViewModel.Input, Never>()
        let output = restaurantListingViewModel.transform(input: restaurantListUseCaseInput.eraseToAnyPublisher())
        output
            .sink { [weak self] event in
                switch event {
                case .fetchRestaurantListDidSucceed(let restaurantListingDOResponse):
                    debugPrint(restaurantListingDOResponse)
                    self?.output.send(.fetchRestaurantListDidSucceed(response: restaurantListingDOResponse))
                case .fetchRestaurantListDidFail(let error):
                    self?.output.send(.fetchRestaurantListDidFail(error: error))
                }
            }.store(in: &cancellables)
    }
    
    //Sorting List Binding
    func bind(to sortingListViewModel: SortingListViewModel) {
        sortingsUseCaseInput = PassthroughSubject<SortingListViewModel.Input, Never>()
        let output = sortingListViewModel.transform(input: sortingsUseCaseInput.eraseToAnyPublisher())
        output
            .sink { [weak self] event in
                switch event {
                case .fetchSortingListDidSucceed(let sortingListResponse):
                    debugPrint(sortingListResponse)
                    self?.output.send(.fetchSortingListDidSucceed(response: sortingListResponse))
                case .fetchSortingListDidFail(let error):
                    self?.output.send(.fetchSortingListDidFail(error: error))
                }
            }.store(in: &cancellables)
    }
    
    //Video Tutorial Binding
    func bind(to videoTutorialViewModel: VideoTutorialViewModel) {
        videoTutorialUseCaseInput = PassthroughSubject<VideoTutorialViewModel.Input, Never>()
        let output = videoTutorialViewModel.transform(input: videoTutorialUseCaseInput.eraseToAnyPublisher())
        output
            .sink { [weak self] event in
                switch event {
                case .fetchVideoTutorialDidSucceed(let videoTutorialResponse):
                    debugPrint(videoTutorialResponse)
                    self?.output.send(.fetchVideoTutorialDidSucceed(response: videoTutorialResponse))
                case .fetchVideoTutorialDidFail(let error):
                    self?.output.send(.fetchVideoTutorialDidFail(error: error))
                }
            }.store(in: &cancellables)
    }
    
    func bind(to abandonedCartViewModel: AbandonedCartViewModel) {
        abandonedCartUseCaseInput = PassthroughSubject<AbandonedCartViewModel.Input, Never>()
        let output = abandonedCartViewModel.transform(input: abandonedCartUseCaseInput.eraseToAnyPublisher())
        output
            .sink { [weak self] event in
                switch event {
                case .didUpdateAbandonedCartAndOrderTracking(let cart, let trackingDetails, let timeout):
                    self?.output.send(.didUpdateAbandonedCartAndOrderTracking(
                        cart: cart,
                        trackingDetails: trackingDetails,
                        timeout: timeout)
                    )
                    
                case .removeAbandonedCartDidSucceed:
                    self?.output.send(.removeAbandonedCartDidSucceed)
                    
                case .setOrderStatusDidSucceed:
                    self?.output.send(.setOrderStatusDidSucceed)
                    
                case .getLiveChatUrlDidSucceed(let chatbotUrl):
                    self?.output.send(.getLiveChatUrlDidSucceed(chatbotUrl: chatbotUrl))
                    
                case .getOrderRatingDidSucceed(let response, let restaurantId):
                    self?.output.send(.getOrderRatingDidSucceed(response: response, restaurantId: restaurantId))
                    
                case .fetchAbandonedCartDidSucceed(let response):
                    self?.output.send(.fetchAbandonedCartDidSucceed(response: response))
                    
                case .fetchDidFail(let error):
                    self?.output.send(.fetchDidFail(error: error))
                    
                case .fetchAbandonedCartDidFail(let error):
                    self?.output.send(.fetchAbandonedCartDidFail(error: error))
                }
            }.store(in: &cancellables)
    }
    
    // TopBrands ViewModel Binding
    func bind(to topAdsViewModel: TopAdsViewModel) {
        topAdsUseCaseInput = PassthroughSubject<TopAdsViewModel.Input, Never>()
        let output = topAdsViewModel.transform(input: topAdsUseCaseInput.eraseToAnyPublisher())
        output
            .sink { [weak self] event in
                switch event {
                case .getTopAdsDidSucceed(let topAdsResponse):
                    debugPrint(topAdsResponse)
                    self?.output.send(.getTopAdsDidSucceed(response: topAdsResponse))
                case .getTopAdsDidFail(let error):
                    self?.output.send(.getTopAdsDidFail(error: error))
                }
            }.store(in: &cancellables)
    }
    
    // Reorder ViewModel Binding
    func bind(to reOrderFoodViewModel: FoodReorderViewModel) {
        reOrderFoodUseCaseInput = PassthroughSubject<FoodReorderViewModel.Input, Never>()
        let output = foodReorderViewModel.transform(input: reOrderFoodUseCaseInput.eraseToAnyPublisher())
        output
            .sink { [weak self] event in
                switch event {
                case .fetchReOrderDidSucceed(let reOrderResponse):
                    debugPrint(reOrderResponse)
                    self?.output.send(.fetchReOrderDidSucceed(response: reOrderResponse))
                case .fetchReOrderDidFail(let error):
                    self?.output.send(.fetchReOrderDidFail(error: error))
                }
            }.store(in: &cancellables)
    }
    
    // WishList ViewModel Binding
    func bind(to wishListViewModel: WishListViewModel) {
        wishListUseCaseInput = PassthroughSubject<WishListViewModel.Input, Never>()
        let output = wishListViewModel.transform(input: wishListUseCaseInput.eraseToAnyPublisher())
        output
            .sink { [weak self] event in
                switch event {
                case .updateWishlistStatusDidSucceed(response: let response):
                    self?.output.send(.updateWishlistStatusDidSucceed(response: response))
                case .updateWishlistDidFail(error: let error):
                    debugPrint(error)
                    break
                }
            }.store(in: &cancellables)
    }
    
    // Create Filters Data
    func createFiltersData(filtersSavedList: [RestaurantRequestWithNameFilter]?, isFilterAllowed: Int?, isSortAllowed: Int?) {
        var filters = [FiltersCollectionViewCellRevampModel]()
        
        // Filter List
        var firstFilter = FiltersCollectionViewCellRevampModel(name: "Filters".localizedString, leftImage: "", rightImage: "filter-revamp", filterCount: filtersSavedList?.count ?? 0)
        
        let firstFilterRowWidth = AppCommonMethods.getAutoWidthWith(firstFilter.name, font: .circularXXTTBookFont(size: 14), additionalWidth: 60)
        firstFilter.rowWidth = firstFilterRowWidth

        var secondFilter = FiltersCollectionViewCellRevampModel(name: "\("SortbyTitle".localizedString): \(selectedSortingTableViewCellModel?.name ?? "")", leftImage: "", rightImage: "sortby-chevron-down", rightImageWidth: 0, rightImageHeight: 4, tag: RestaurantFiltersType.deliveryTime.rawValue)
        
        let secondFilterRowWidth = AppCommonMethods.getAutoWidthWith(secondFilter.name, font: .circularXXTTBookFont(size: 14), additionalWidth: 40)
        secondFilter.rowWidth = secondFilterRowWidth
        
        if isFilterAllowed != 0 {
            filters.append(firstFilter)
        }
        
        if isSortAllowed != 0 {
            filters.append(secondFilter)
        }
        
        if let appliedFilters = filtersSavedList, appliedFilters.count > 0 {
            for filter in appliedFilters {
                
                let width = AppCommonMethods.getAutoWidthWith(filter.filterName.asStringOrEmpty(), font: .circularXXTTMediumFont(size: 22), additionalWidth: 30)
                
                let model = FiltersCollectionViewCellRevampModel(name: filter.filterName.asStringOrEmpty(), leftImage: "", rightImage: "filters-cross", isFilterSelected: true, filterValue: filter.filterValue.asStringOrEmpty(), tag: 0, rowWidth: width)

                filters.append(model)

            }
        }
        
        self.output.send(.fetchFiltersDataSuccess(filters: filters)) // Send filters back to VC
    }
    
    // Get saved filters
    func getSavedFilters() -> [RestaurantRequestFilter] {
        if let savedFilters = UserDefaults.standard.object([RestaurantRequestWithNameFilter].self, with: FilterDictTags.FiltersDict.rawValue) {
            if savedFilters.count > 0 {
                let uniqueUnordered = Array(Set(savedFilters))
                
                filtersSavedList = uniqueUnordered
                
                filtersList = [RestaurantRequestFilter]()
                
                if let savedFilters = filtersSavedList {
                    for filter in savedFilters {
                        let restaurantRequestFilter = RestaurantRequestFilter()
                        restaurantRequestFilter.filterKey = filter.filterKey
                        restaurantRequestFilter.filterValue = filter.filterValue
                        
                        filtersList?.append(restaurantRequestFilter)
                    }
                }
                
                defer {
                    self.output.send(.fetchSavedFiltersAfterSuccess(filtersSavedList: filtersSavedList ?? []))
                }

                return filtersList ?? []
                
            }
        }
        return []
    }
    
    func removeAndSaveFilters(filter: FiltersCollectionViewCellRevampModel) {
        // Remove all saved Filters
        let isFilteredIndex = filtersSavedList?.firstIndex(where: { (restaurantRequestWithNameFilter) -> Bool in
            filter.name.lowercased() == restaurantRequestWithNameFilter.filterName?.lowercased()
        })
        
        if let isFilteredIndex = isFilteredIndex {
            filtersSavedList?.remove(at: isFilteredIndex)
        }
        
        // Remove Names for filters
        let isFilteredNameIndex = filtersList?.firstIndex(where: { (restaurantRequestWithNameFilter) -> Bool in
            filter.filterValue.lowercased() == restaurantRequestWithNameFilter.filterValue?.lowercased()
        })
        
        if let isFilteredNameIndex = isFilteredNameIndex {
            filtersList?.remove(at: isFilteredNameIndex)
        }
        
        let userDefaults = UserDefaults.standard
        
        userDefaults.removeObject(forKey: FilterDictTags.FiltersDict.rawValue)
        
        userDefaults.set(object: filtersSavedList, forKey: FilterDictTags.FiltersDict.rawValue)
        
        self.output.send(.fetchAllSavedFiltersSuccess(filtersList: filtersList ?? [], filtersSavedList: filtersSavedList ?? []))
    }
    
    func generateActionContentForSortingItems(restaurantSortingResponseModel: GetSortingListResponseModel?){
        var items = [BaseRowModel]()
        
        if let sortingList = restaurantSortingResponseModel?.sortingList, sortingList.count > 0 {
            for (index, sorting) in sortingList.enumerated() {
                if let sortingModel = selectedSortingTableViewCellModel {
                    if sortingModel.name?.lowercased() == sorting.name?.lowercased() {
                        if index == sortingList.count - 1 {
                            addSortingItems(items: &items, sorting: sorting, isSelected: true, isBottomLineHidden: true)
                        } else {
                            addSortingItems(items: &items, sorting: sorting, isSelected: true, isBottomLineHidden: false)
                        }
                    } else {
                        if index == sortingList.count - 1 {
                            addSortingItems(items: &items, sorting: sorting, isSelected: false, isBottomLineHidden: true)
                        } else {
                            addSortingItems(items: &items, sorting: sorting, isSelected: false, isBottomLineHidden: false)
                        }
                    }
                } else {
                    selectedSortingTableViewCellModel = FilterDO()
                    selectedSortingTableViewCellModel = sorting
                    if index == sortingList.count - 1 {
                        addSortingItems(items: &items, sorting: sorting, isSelected: true, isBottomLineHidden: true)
                    } else {
                        addSortingItems(items: &items, sorting: sorting, isSelected: true, isBottomLineHidden: false)
                    }
                }
            }
        }
        
        self.output.send(.fetchContentForSortingItems(baseRowModels: items))
    }
    
    func addSortingItems(items: inout [BaseRowModel], sorting: FilterDO, isSelected: Bool, isBottomLineHidden: Bool) {
        items.append(SortingTableViewCell.rowModel(model: SortingTableViewCellModel(title: sorting.name.asStringOrEmpty(), mode: .SingleSelection, isSelected: isSelected, multiChoiceUpTo: 1, isSelectionMandatory: true, sortingModel: sorting, bottomLineHidden: isBottomLineHidden)))
    }
}

// MARK: - RestaurantFiltersDelegate

extension FoodOrderHomeViewModel: RestaurantFiltersDelegate {
    func didReturnRestaurantFilters(_ restaurantFilters: [RestaurantRequestWithNameFilter]) {
        
        self.filtersSavedList = []
        
        self.filtersSavedList = restaurantFilters
        
        var restaurantFiltersObjects = [RestaurantRequestFilter]()
        for filter in restaurantFilters {
            let restaurantRequestFilter = RestaurantRequestFilter()
            restaurantRequestFilter.filterKey = filter.filterKey
            restaurantRequestFilter.filterValue = filter.filterValue
            restaurantFiltersObjects.append(restaurantRequestFilter)
        }
        
        if let sort = self.selectedSortingTableViewCellModel {
            let restaurantRequestFilter = RestaurantRequestFilter()
            restaurantRequestFilter.filterKey = sort.filterKey
            restaurantRequestFilter.filterValue = sort.filterValue
            restaurantFiltersObjects.append(restaurantRequestFilter)
        }
       
        self.output.send(.didSelectFilterOrSort)
        self.output.send(.fetchSavedFiltersAfterSuccess(filtersSavedList: self.filtersSavedList ?? []))
        self.output.send(.emptyRestaurantListDidSucceed)
        self.output.send(.showShimmer(identifier: .RESTAURANTLISTING))
        self.restaurantListUseCaseInput.send(.getRestaurantList(pageNo: 0, filtersList: restaurantFiltersObjects))
        
    }
}

extension FoodOrderHomeViewModel: RestaurantSortingChoicesDelegate {
    func didReturnSortParam(_ sortBy: FilterDO) {
        setSelectedSortingParam(sort: sortBy)
    }
    
    func setSelectedSortingParam(sort: FilterDO) {
        selectedSortingTableViewCellModel = sort
        
        var restaurantFiltersObjects = [RestaurantRequestFilter]()

        if let filters = self.filtersSavedList {
            for filter in filters {
                let restaurantRequestFilter = RestaurantRequestFilter()
                restaurantRequestFilter.filterKey = filter.filterKey
                restaurantRequestFilter.filterValue = filter.filterValue
                restaurantFiltersObjects.append(restaurantRequestFilter)
            }
        }
        
        let restaurantRequestFilter = RestaurantRequestFilter()
        restaurantRequestFilter.filterKey = sort.filterKey
        restaurantRequestFilter.filterValue = sort.filterValue
        restaurantFiltersObjects.append(restaurantRequestFilter)
        
        self.output.send(.didSelectFilterOrSort)
        self.output.send(.emptyRestaurantListDidSucceed)
        self.output.send(.showShimmer(identifier: .RESTAURANTLISTING))
        self.restaurantListUseCaseInput.send(.getRestaurantList(pageNo: 0, filtersList: restaurantFiltersObjects))
    }
}

// MARK: - FoodCartDelegate
extension FoodOrderHomeViewModel: FoodCartDelegate {
    func didNavigateToPaymentViewController() {
        self.output.send(.returnFromFoodCart)
    }
    
    func didNavigateToFoodHomeViewController() {
        self.output.send(.updateHeaderView)
    }
    func didNavigateToRestaurantDetailViewController(restaurantId: String?) {
        let restaurantObj = Restaurant()
        restaurantObj.restaurantId = restaurantId
        self.output.send(.navigateToRestaurantFromAbandonedCart(restaurantObject: restaurantObj))
    }
}
