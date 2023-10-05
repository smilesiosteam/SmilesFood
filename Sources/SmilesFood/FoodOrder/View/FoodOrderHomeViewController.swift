//
//  FoodOrderHomeViewController.swift
//  House
//
//  Created by Shahroze Zaheer on 10/26/22.
//  Copyright (c) 2022 All rights reserved.
//

import UIKit
import Combine
import SkeletonView
import AnalyticsSmiles
import SmilesStoriesManager
import CoreLocation
import SmilesLocationHandler
import SmilesUtilities
import SmilesSharedModels
import SmilesSharedServices
import SmilesLoader
import SmilesOffers
import SmilesBanners
import SmilesReusableComponents

class FoodOrderHomeViewController: UIViewController, SmilesCoordinatorBoard {
    
    //MARK: IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topHeaderView: AppHeaderView!
    @IBOutlet weak var ytPopUpView: YoutubePopUpView!
    @IBOutlet weak var videoPlayerWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var videoPlayerHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var pageControllBottomView: UIView!
    @IBOutlet weak var stickyBottomView: UIView!
    @IBOutlet weak var stickyBottomCollectionView: UICollectionView!
    @IBOutlet var pageControl: CHIPageControlJaloro!
    
    var stickyCollectionData = [BaseRowModel]()
    var selectedAbandonedCart: Abandoned?
    var abandonedCartActionType: AbandonedCartActionType? = .VIEW
    var statusUpdateTimer: Timer?
    var anotherRestaurantSelected: Restaurant?
    var actionSheet: CustomizableActionSheet?
    
    // MARK: -- Variables
    weak var foodOrderHomeCoordinator : FoodHomeCoordinator? // Child Coordinator handling
    var locationToolTipPosition: UIImageView?

    var input: PassthroughSubject<FoodOrderHomeViewModel.Input, Never> = .init()
    let viewModel = FoodOrderHomeViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    var dataSource: SectionedTableViewDataSource?
    
    var foodSections: GetSectionsResponseModel?
    var sections = [SectionData]()
    var orderIndex = -1
    
    var filtersSavedList: [RestaurantRequestWithNameFilter]?
    var filtersData: [FiltersCollectionViewCellRevampModel]?
    var savedFilters: [RestaurantRequestFilter]?
    var restaurantSortingResponseModel: GetSortingListResponseModel?
//    var selectedSortingTableViewCellModel: FilterDO?
    var restaurantListing: GetRestaurantListingDOResponse?
    
    var restaurants = [Restaurant]()
    
    var restaurantPage = 0 // For restaurant list pagination
    private var selectedIndexPath: IndexPath?
    private var restaurantFavoriteOperation = 0 // Operation = 1 for and add Operation 2 = remove
    var sortingListRowModels: [BaseRowModel]?
    var videoPlayerObj: VideoTutorialDO?
    
    var hasOrderHistory = false
    
    var selectedLocation: String? = nil
    var backToRootView: Bool?

    var videoPlayerBackgroundView: UIView?
    private var didTapMenuTypeTab = false
    var isYTVideoLoadedOnce = false
    var lastContentOffset = CGPoint.zero
    var selectedFavoriteRestaurantIndexPath: IndexPath?

    var categoryId: Int?
    var isPickUpFood = false {
        didSet {
            orderTypeLocalVariable = isPickUpFood ? .PICK_UP : .DELIVERY
        }
    }
    var didSelectFilterOrSort = false
    
    var headerTitle: String?
    var orderTypeLocalVariable :RestaurantMenuType = .DELIVERY
    var isHeaderExpanding = false
    
    var reOrderID: String?
    var reOrderRestaurantID: String?
    var reOrderAbandonedCart: Abandoned?
    
    var personalizationEventSource: String?

    // MARK: -- View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserDefaults.standard.removeObject(forKey: FilterDictTags.FiltersDict.rawValue)
        setPersonalizationEventSource()
        registerEvent()
        bind(to: viewModel)
        setupTableView()
        initialSetup()
        callFoodOrderServices()
        if !isPickUpFood {
            input.send(.getPopupPopularRestaurants(menuItemType: OrderInfoModel.shared.orderTypeDefaultValue.rawValue, popularRestaurantType: .popularRestaurantPopup, popularRestaurantRequest: .popup))
        }
        // ----- Tableview section header hide in case of tableview mode Plain ---
        let dummyViewHeight = CGFloat(150 )
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: dummyViewHeight))
        self.tableView.contentInset = UIEdgeInsets(top: -dummyViewHeight, left: 0, bottom: 0, right: 0)
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateFavourite), name: NSNotification.Name("UpdateFavouriteRestaurant"), object: nil)
        selectedLocation = LocationStateSaver.getLocationInfo()?.locationId
        // ----- Tableview section header hide in case of tableview mode Plain ---
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.delegte().currentPresentedViewController = self
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupHeaderView()
        setupMenuItemType()
        if !isGuestUser {
            callAbandonCartService()
            reloadStickyCollection()
        }
        if let currentLocationId = LocationStateSaver.getLocationInfo()?.locationId, let locationId = self.selectedLocation, currentLocationId != locationId {
            self.input.send(.emptyRestaurantList)
            self.callFoodOrderServices()
            selectedLocation = LocationStateSaver.getLocationInfo()?.locationId
        }
    }
    
    @objc private func didUpdateFavourite(_ notification: Notification) {
        if let restaurant = notification.userInfo?["restaurant"] as? Restaurant, let selectedFavoriteRestaurantIndexPath {
            (self.dataSource?.dataSources?[safe: selectedFavoriteRestaurantIndexPath.section] as? TableViewDataSource<Restaurant>)?.models?[safe: selectedFavoriteRestaurantIndexPath.row]?.isFavoriteRestaurant = restaurant.isFavoriteRestaurant
            
            if let cell = tableView.cellForRow(at: selectedFavoriteRestaurantIndexPath) as? RestaurantsRevampTableViewCell {
                cell.restaurantData?.isFavoriteRestaurant = restaurant.isFavoriteRestaurant
                cell.showFavouriteAnimation()
            }
         }
    }
    
    func setupMenuItemType() {
        if self.orderTypeLocalVariable == .DELIVERY {
            OrderInfoModel.shared.orderType = .DELIVERY
            OrderInfoModel.shared.orderTypeDefaultValue = .DELIVERY
        } else {
            OrderInfoModel.shared.orderType = .PICK_UP
            OrderInfoModel.shared.orderTypeDefaultValue = .PICK_UP
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        navigationController?.setNavigationBarHidden(false, animated: false)
        timerInvalidate()
        if !isGuestUser {
            bottomStickView(isHide: true)
            reloadStickyCollection()
        }
    }
    
    private func setupHeaderView() {
        topHeaderView.delegate = self
        topHeaderView.setupHeaderView(backgroundColor: .appRevampEnableStateColor, searchBarColor: .white, pointsViewColor: nil, titleColor: .black, headerTitle: self.headerTitle.asStringOrEmpty(), showHeaderNavigaton: true, haveSearchBorder: true, shouldShowBag: true)
        topHeaderView.setBottomSegmentForFood(title1: "Delivery".localizedString, icon1: UIImage(named: "foodDelivery"), title2: "Pickup".localizedString, icon2: UIImage(named: "foodPickup"), shouldShowSegment: true, isFromPickup: isPickUpFood)
    }

    
    // MARK: -- Binding
    
    func bind(to viewModel: FoodOrderHomeViewModel) {
        input = PassthroughSubject<FoodOrderHomeViewModel.Input, Never>()
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        output
            .sink { [weak self] event in
                switch event {
                    
                    //MARK: - Success cases
                    // Section Details Success
                case .fetchSectionsDidSucceed(let sectionsResponse):
                    self?.configureSectionsData(with: sectionsResponse)
                    
                    // Cuisines Success
                case .fetchCuisinesDidSucceed(let cuisinesResponse):
                    self?.configureCuisinesData(with: cuisinesResponse)
                    
                    // Order History Success
                case .fetchOrderHistoryDidSucceed(let orderHistoryResponse):
                    self?.configureOrderHistoryData(with: orderHistoryResponse)
                    
                    // Top Brands Success
                case .fetchTopBrandsDidSucceed(let topBrandsResponse):
                    self?.configureTopBrandsData(with: topBrandsResponse)
                    
                    // Collections Success
                case .fetchCollectionsDidSucceed(let collectionsResponse):
                    self?.configureCollectionsData(with: collectionsResponse)
                    
                    // Top Offers Success
                case .fetchTopOffersDidSucceed(let topOffersResponse):
                    self?.configureTopOffersData(with: topOffersResponse)
                    
                    // Stories Success
                case .fetchStoriesDidSucceed(let storiesResponse):
                    self?.configureStoriesData(with: storiesResponse)
                    
                    // Restaurant List Success
                case .fetchRestaurantListDidSucceed(response: let restaurantResponse):
                    self?.configureRestaurantsData(with: restaurantResponse)
                    
                case .emptyRestaurantListDidSucceed:
                    self?.restaurantPage = 0
                    self?.restaurants.removeAll()
                    self?.configureDataSource()
                    
                    // Popular Restaurants Success
                case .showShimmer(let identifier):
                    self?.showShimmer(identifier: identifier)
                    
                case .fetchPopularRestaurantsDidSucceed(let popularRestaurantsResponse, _, _):
                    self?.configurePopularRestaurantsData(with: popularRestaurantsResponse)
                    
                case .fetchPopupPopularRestaurantsDidSucceed(let popularRestaurantsResponse, _, _):
                    self?.configurePopularRestaurantsPopup(with: popularRestaurantsResponse)
                    
                    // Subscription Success
                case .fetchSubscriptionBannerDidSucceed(let subscriptionBannerResponse):
                    self?.configureSubscriptionBannerData(with: subscriptionBannerResponse)
                    
                    // Filters Data Binding
                case .fetchFiltersDataSuccess(let filters):
                    self?.filtersData = filters
                    
                case .fetchAllSavedFiltersSuccess(let filtersList, let savedFilters):
                    self?.savedFilters = filtersList
                    self?.filtersSavedList = savedFilters
                    self?.restaurants.removeAll()
                    self?.configureDataSource()
                    self?.configureFiltersData()
                    
                case .fetchSavedFiltersAfterSuccess(let filtersSavedList):
                    self?.filtersSavedList = filtersSavedList
                    
                    //Sorting List Binding
                case .fetchSortingListDidSucceed(let response):
                    self?.configureSortingData(with: response)
                    
                case .fetchContentForSortingItems(let baseRowModels):
                    self?.sortingListRowModels = baseRowModels
                    
                case .updateWishlistStatusDidSucceed(let updateWishlistResponse):
                    self?.configureWishListData(with: updateWishlistResponse)
                    
                case .didTapSearchSucceed:
                    self?.redirectToSearch()
                    
                case .fetchVideoTutorialDidSucceed(let videoTutorialResponse):
                    self?.configureVideoTutorialData(with: videoTutorialResponse)
                    
                case .didUpdateAbandonedCartAndOrderTracking(let cart, let trackingDetails, let timeout):
                    self?.updateAbandonedCartAndOrderTrackingView(withAbandonedCart: cart, andTrackingDetails: trackingDetails, timeout: timeout)
                    
                case .routeToRestaurantDetailDidSucceed(let selectedRestarant, let isViewCart):
                    self?.redirectToRestaurantDetailController(restaurant: selectedRestarant, isViewCart: isViewCart ?? false)
                    
                case .removeAbandonedCartDidSucceed:
                    self?.abandonedCartRemoved()
                    
                case .viewCartDetailDidSucceed(let restaurantId):
                    self?.redirectToFoodCart(restaurantId: restaurantId ?? "")
                    
                case .setOrderStatusDidSucceed:
                    self?.input.send(.getAbandonedCart)
                    
                case .getLiveChatUrlDidSucceed(let chatbotUrl):
                    self?.redirectToLiveChat(with: chatbotUrl)
                    
                case .getOrderRatingDidSucceed(let response, let restaurantId):
                    self?.configureOrderRatingData(with: response, restaurantId)
                    
                case .returnFromFoodCart:
                    self?.redirectToSelectPayment()
                    
                case .getTopAdsDidSucceed(let topAdsResponse):
                    self?.configureTopAds(with: topAdsResponse)
                    
                case .didSelectFilterOrSort:
                    self?.didSelectFilterOrSort = true
                    
                case .updateHeaderView:
                    if !isGuestUser {
                        self?.topHeaderView.setLocation(locationName: LocationStateSaver.getLocationInfo()?.location ?? "", locationNickName: LocationStateSaver.getLocationInfo()?.nickName ?? "SetLocationKey".localizedString)
                        
                        self?.input.send(.emptyRestaurantList)
                        self?.callFoodOrderServices()
                    }
                    
                case .fetchReOrderDidSucceed(let reOrderFoodResponse):
                    SmilesLoader.dismiss(from: self?.view ?? UIView())
                    self?.configureReOrderFood(with: reOrderFoodResponse)
                    
                case .fetchAbandonedCartDidSucceed(let abandonedCartResponse):
                    SmilesLoader.dismiss(from: self?.view ?? UIView())
                    self?.configureAbandonedCart(with: abandonedCartResponse)
                    
                    //MARK: - Failure cases
                case .fetchSectionsDidFail(error: let error):
                    debugPrint(error.localizedDescription)
                    self?.topHeaderView.hideSkeleton()
                    
                case .fetchCuisinesDidFail(let error):
                    debugPrint(error.localizedDescription)
                    self?.configureHideSection(for: .TOPCUISINE, dataSource: GetCuisinesResponseModel.self)
                    
                case .fetchOrderHistoryDidFail(let error):
                    debugPrint(error)
                    self?.configureHideSection(for: .ORDERHISTORY, dataSource: GetOrderHistoryDOResponse.self)
                    
                case .fetchTopBrandsDidFail(let error):
                    debugPrint(error.localizedDescription)
                    self?.configureHideSection(for: .TOPBRANDS, dataSource: GetTopBrandsResponseModel.self)
                    
                case .fetchCollectionDidFail(error: let error):
                    debugPrint(error.localizedDescription)
                    self?.configureHideSection(for: .TOPCOLLECTIONS, dataSource: GetCollectionsResponseModel.self)
                    
                case .fetchTopOffersDidFail(error: let error):
                    debugPrint(error.localizedDescription)
                    self?.configureHideSection(for: .TOPBANNERS, dataSource: GetTopOffersResponseModel.self)
                    
                case .fetchDidFail(let error):
                    debugPrint(error.localizedDescription)
                    self?.configureHideSection(for: .STORIES, dataSource: Stories.self)
                    
                case .fetchRestaurantListDidFail(error: let error):
                    debugPrint(error.localizedDescription)
                    self?.configureHideSection(for: .RESTAURANTLISTING, dataSource: Restaurant.self)
                    
                case .fetchPopularRestaurantsDidFail(let error):
                    debugPrint(error.localizedDescription)
//                    self?.configureHideSection(for: .RECOMMENDEDLISTING, dataSource: GetPopularRestaurantsResponseModel.self)
                    
                case .fetchPopupPopularRestaurantsDidFail(let error):
                    debugPrint(error.localizedDescription)
                    self?.configureHideSection(for: .RECOMMENDEDLISTING, dataSource: GetPopularRestaurantsResponseModel.self)
                    
                case .fetchSubscriptionBannerDidFail(let error):
                    debugPrint(error.localizedDescription)
                    self?.configureHideSection(for: .SUBSCRIPTIONBANNERS, dataSource: GetSubscriptionBannerResponseModel.self)
                    
                case .fetchSortingListDidFail(let error):
                    debugPrint(error.localizedDescription)
                    
                case .fetchVideoTutorialDidFail(let error):
                    debugPrint(error.localizedDescription)
                    
                case .getTopAdsDidFail(let error):
                    debugPrint(error.localizedDescription)
                    
                case .fetchAbandonedCartDidFail(let error):
                    SmilesLoader.dismiss(from: self?.view ?? UIView())
                    debugPrint(error.localizedDescription)
                    
                case .fetchReOrderDidFail(let error):
                    SmilesLoader.dismiss(from: self?.view ?? UIView())
                    debugPrint(error.localizedDescription)
                                        
                case .navigateToRestaurantFromAbandonedCart(restaurantObject: let restaurantObject):
                    self?.redirectToRestaurantDetailController(restaurant: restaurantObject)
                }
            }.store(in: &cancellables)
    }
    
    // MARK: - Helping Functions
    
    func getSectionIndex(for identifier: SectionIdentifier) -> Int? {
        
        return sections.first(where: { obj in
            return obj.identifier == identifier
        })?.index
        
    }
    
    fileprivate func initialSetup() {
        // Call api services
        bottomStickView(isHide: true)
        setupHeaderView()
        setupTutorialView()
        addShadowToAbandonedCart()
        setupVideoPlayerBackgroundView()
        
        OrderInfoModel.shared.orderTypeDefaultValue = .DELIVERY
    }
    
    func callAbandonCartService(){
        self.input.send(.getAbandonedCart)
    }
    
    
    func callFoodOrderServices() {
        self.input.send(.getSections(categoryID: categoryId.asIntOrEmpty()))
    }
    
    func foodHomeAPICalls() {
        if let sectionDetails = self.foodSections?.sectionDetails, !sectionDetails.isEmpty {
            sections.removeAll()
            for (index, element) in sectionDetails.enumerated() {
                
                guard let sectionIdentifier = element.sectionIdentifier, !sectionIdentifier.isEmpty else {
                    return
                }
                
                if let section = SectionIdentifier(rawValue: sectionIdentifier), section  != .TOPPLACEHOLDER {
                    sections.append(SectionData(index: index, identifier: section))
                }
                switch SectionIdentifier(rawValue: sectionIdentifier) {
                case .ORDERHISTORY:
                    if !isGuestUser {
                        if let history = GetOrderHistoryDOResponse.fromFile() {
                            self.dataSource?.dataSources?[index] = TableViewDataSource.make(fororders: history, data:"#FFFFFF", isDummy:true, completion: nil)
                        }
                        self.input.send(.getOrderHistory(orderType: isPickUpFood ? .PICK_UP : .DELIVERY))
                    }
                case .TOPBANNERS:
                    if let response = GetTopAdsResponseModel.fromFile() {
                        self.dataSource?.dataSources?[index] = TableViewDataSource.make(forTopAds: response, data:"#FFFFFF", isDummy: true, completion: nil)
                    }
                    self.input.send(.getTopAds(menuItemType: OrderInfoModel.shared.orderTypeDefaultValue))
                case .TOPCUISINE:
                    if let response = GetCuisinesResponseModel.fromFile() {
                        self.dataSource?.dataSources?[index] = TableViewDataSource.make(forCuisines: response, data:"#FFFFFF", isDummy: true, completion: nil)
                    }
                    self.input.send(.getCuisines(categoryID: categoryId.asIntOrEmpty(), menuItemType: OrderInfoModel.shared.orderTypeDefaultValue.rawValue))
                case .RECOMMENDEDLISTING:
                    if isPickUpFood {
                        break
                    }
                    if let response = GetPopularRestaurantsResponseModel.fromFile() {
                        self.dataSource?.dataSources?[index] = TableViewDataSource.make(forPopularResturants: response, data:"#FFFFFF", isDummy: true, completion: nil)
                    }
                    self.input.send(.getPopularRestaurants(menuItemType: OrderInfoModel.shared.orderTypeDefaultValue.rawValue, popularRestaurantType: .foodOrder, popularRestaurantRequest: .recommended))
                case .TOPCOLLECTIONS:
                    if let response = GetCollectionsResponseModel.fromFile() {
                        self.dataSource?.dataSources?[index] = TableViewDataSource.make(forCollections: response, data:"#FFFFFF", isDummy: true, completion: nil)
                    }
                    self.input.send(.getCollections(categoryID: categoryId.asIntOrEmpty(), menuItemType: OrderInfoModel.shared.orderTypeDefaultValue.rawValue))
                case .STORIES:
                    if let stories = Stories.fromFile() {
                        self.dataSource?.dataSources?[index] = TableViewDataSource.make(forStories: stories, data:"#FFFFFF", isDummy:true, onClick: nil)
                    }
                    self.input.send(.getStories(categoryId: element.categoryId ?? -1))
                case .TOPBRANDS:
                    if let response = GetTopBrandsResponseModel.fromFile() {
                        self.dataSource?.dataSources?[index] = TableViewDataSource.make(forBrands: response, data:"#FFFFFF", isDummy: true, topBrandsType: .foodOrder, completion: nil)
                    }
                    self.input.send(.getTopBrands(categoryID: categoryId.asIntOrEmpty(), menuItemType: OrderInfoModel.shared.orderTypeDefaultValue.rawValue))
                case .SUBSCRIPTIONBANNERS:
                    if let response = GetSubscriptionBannerResponseModel.fromFile() {
                        self.dataSource?.dataSources?[index] = TableViewDataSource.make(forSubscription: response, data:"#FFFFFF", isDummy: true)
                    }
                    self.input.send(.getSubscriptionBanner(menuItemType: OrderInfoModel.shared.orderTypeDefaultValue.rawValue))
                case .RESTAURANTLISTING:
                    showShimmer(identifier: .RESTAURANTLISTING)
                    self.input.send(.getRestaurantList(pageNo: 0, filtersList: [], selectedSortingTableViewCellModel: self.viewModel.selectedSortingTableViewCellModel))
                    self.input.send(.getSortingList(menuItemType: OrderInfoModel.shared.orderTypeDefaultValue.rawValue))
                    if !isGuestUser {
                        self.input.send(.getVideoTutorial(sectionKey: VideoTutorialSection.FoodOrder))
                    }
                    
                default:
                    break
                }
            }
            OperationQueue.main.addOperation{
                self.tableView.reloadData()
            }
        }
    }
    
    func setupTableView() {
        self.tableView.sectionFooterHeight = .leastNormalMagnitude
        if #available(iOS 15.0, *) {
            self.tableView.sectionHeaderTopPadding = CGFloat(0)
        }
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 1
        
        let customizable: CellRegisterable? = FoodOrderHomeCellRegistration()
        customizable?.register(for: self.tableView)
    }
    
    func displayRewardPoints() {
        if let rewardPoints = SwiftUtli.shared.getValueFromUserDefaults(key: .rewardPoints) as? Int {
            self.topHeaderView.setPointsOfUser(with: rewardPoints.numberWithCommas())
        }
        
        if let rewardPointsIcon = SwiftUtli.shared.getValueFromUserDefaults(key: .rewardPointsIcon) as? String {
            self.topHeaderView.setPointsIcon(with: rewardPointsIcon, shouldShowAnimation: false)
        }
    }
    
    // MARK: - Configurations
    fileprivate func configureSectionsData(with sectionsResponse: GetSectionsResponseModel) {
        self.foodSections = sectionsResponse
        if let sectionDetailsArray = sectionsResponse.sectionDetails, !sectionDetailsArray.isEmpty {
            self.dataSource = SectionedTableViewDataSource(dataSources: Array(repeating: [], count: sectionDetailsArray.count))
        }
        
        let topPlaceholderSection = sectionsResponse.sectionDetails?.first(where: { $0.sectionIdentifier == SectionIdentifier.TOPPLACEHOLDER.rawValue })
        
        if let title = topPlaceholderSection?.title {
            self.headerTitle = title
            self.topHeaderView.setHeaderTitle(title: title)
        }
        
        if let iconURL = topPlaceholderSection?.iconUrl {
            self.topHeaderView.headerTitleImageView.isHidden = false
            self.topHeaderView.setHeaderTitleIcon(iconURL: iconURL)
        }
        
        if let searchTag = topPlaceholderSection?.searchTag {
            self.topHeaderView.setSearchText(with: searchTag)
        }
        
        if let ribbonText = topPlaceholderSection?.pickupRibbonText {
            topHeaderView.promotionLabel.text = ribbonText
            topHeaderView.promotionContainer.isHidden = ribbonText.isEmpty
        }
        
        _ = TableViewDataSource.make(forSections: sectionsResponse, data: "", completion: nil)
        self.configureDataSource()
        self.topHeaderView.hideSkeleton()
        self.displayRewardPoints()
        self.foodHomeAPICalls()
    }
    
    fileprivate func configureCuisinesData(with cuisinesResponse: GetCuisinesResponseModel) {
        if let cuisines = cuisinesResponse.cuisines, !cuisines.isEmpty {
            if let cuisineIndex = getSectionIndex(for: .TOPCUISINE) {
                self.dataSource?.dataSources?[cuisineIndex] = TableViewDataSource.make(forCuisines: cuisinesResponse, data: self.foodSections?.sectionDetails?[cuisineIndex].backgroundColor ?? "#FFFFFF", completion: { [weak self] data in
                    
                    if let eventName = self?.foodSections?.getEventName(for: SectionIdentifier.TOPCUISINE.rawValue), !eventName.isEmpty {
                        SmilesCommonMethods.registerPersonalizationEvent(for: eventName, urlScheme: data.redirectionUrl.asStringOrEmpty(), cuisineName: data.title, source: self?.personalizationEventSource)
                    }
                    self?.handleBannerDeepLinkRedirections(url: data.redirectionUrl.asStringOrEmpty())
                })
                self.configureDataSource()
            }
        } else {
            self.configureHideSection(for: .TOPCUISINE, dataSource: GetCuisinesResponseModel.self)
        }
    }
    
    fileprivate func configureOrderHistoryData(with orderHistoryResponse: GetOrderHistoryDOResponse) {
        if let activeOrders = orderHistoryResponse.inActiveOrders, !activeOrders.isEmpty {
            if let orderHistoryIndex = getSectionIndex(for: .ORDERHISTORY) {
                self.orderIndex = orderHistoryIndex
                self.hasOrderHistory = true
                self.dataSource?.dataSources?[orderHistoryIndex] = TableViewDataSource.make(fororders: orderHistoryResponse, data: self.foodSections?.sectionDetails?[orderHistoryIndex].backgroundColor ?? "#FFFFFF",completion: { [weak self] data in
                    self?.reOrderRestaurantID = data.restaurantID ?? ""
                    self?.reOrderID = data.orderID ?? ""
                    SmilesLoader.show(on: self?.view ?? UIView())
                    self?.input.send(.getReOrderAbandonedCart)
                    
                    if let eventName = self?.foodSections?.getEventName(for: SectionIdentifier.ORDERHISTORY.rawValue), !eventName.isEmpty {
                        SmilesCommonMethods.registerPersonalizationEvent(for: eventName, restaurantId: data.restaurantID.asStringOrEmpty(), source: self?.personalizationEventSource)
                    }
                    let analyticsSmiles = AnalyticsSmiles(service: FirebaseAnalyticsService())
                    analyticsSmiles.sendAnalyticTracker(trackerData: Tracker(eventType: AnalyticsEvent.firebaseEvent(.OrderAgain).name, parameters: [:]))
                })
                self.configureDataSource()
            }
        } else {
            self.hasOrderHistory = false
            self.configureHideSection(for: .ORDERHISTORY, dataSource: GetOrderHistoryDOResponse.self)
        }
    }
    
    fileprivate func configureTopBrandsData(with topBrandsResponse: GetTopBrandsResponseModel) {
        if let brands = topBrandsResponse.brands, !brands.isEmpty {
            if let topBrandsIndex = getSectionIndex(for: .TOPBRANDS) {
                self.dataSource?.dataSources?[topBrandsIndex] = TableViewDataSource.make(forBrands: topBrandsResponse, data: self.foodSections?.sectionDetails?[topBrandsIndex].backgroundColor ?? "#FFFFFF", topBrandsType: .foodOrder, completion: { [weak self] data in
                    let analyticsSmiles = AnalyticsSmiles(service: FirebaseAnalyticsService())
                    analyticsSmiles.sendAnalyticTracker(trackerData: Tracker(eventType: AnalyticsEvent.firebaseEvent(.ClickOnTopBrands).name, parameters: [:]))
                    
                    if let eventName = self?.foodSections?.getEventName(for: SectionIdentifier.TOPBRANDS.rawValue), !eventName.isEmpty {
                        SmilesCommonMethods.registerPersonalizationEvent(for: eventName, urlScheme: data.redirectionUrl.asStringOrEmpty(), offerId: data.id, source: self?.personalizationEventSource)
                    }
                    self?.handleBannerDeepLinkRedirections(url: data.redirectionUrl.asStringOrEmpty())
                })
                self.configureDataSource()
            }
        } else {
            self.configureHideSection(for: .TOPBRANDS, dataSource: GetTopBrandsResponseModel.self)
        }
    }
    
    fileprivate func configureCollectionsData(with collectionsResponse: GetCollectionsResponseModel) {
        if let collections = collectionsResponse.collections, !collections.isEmpty {
            if let topCollectionsIndex = getSectionIndex(for: .TOPCOLLECTIONS) {
                self.dataSource?.dataSources?[topCollectionsIndex] = TableViewDataSource.make(forCollections: collectionsResponse, data: self.foodSections?.sectionDetails?[topCollectionsIndex].backgroundColor ?? "#FFFFFF", completion: { [weak self] data in
                    
                    if let eventName = self?.foodSections?.getEventName(for: SectionIdentifier.TOPCOLLECTIONS.rawValue), !eventName.isEmpty {
                        SmilesCommonMethods.registerPersonalizationEvent(for: eventName, urlScheme: data.redirectionUrl.asStringOrEmpty(), offerId: data.id, source: self?.personalizationEventSource)
                    }
                    self?.handleBannerDeepLinkRedirections(url: data.redirectionUrl.asStringOrEmpty())
                })
                self.configureDataSource()
            }
        } else {
            self.configureHideSection(for: .TOPCOLLECTIONS, dataSource: GetCollectionsResponseModel.self)
        }
    }
    
    fileprivate func configureTopOffersData(with topOffersResponse: GetTopOffersResponseModel) {
        if let topOffers = topOffersResponse.ads, !topOffers.isEmpty {
            if let topOffersIndex = getSectionIndex(for: .TOPBANNERS) {
                self.dataSource?.dataSources?[topOffersIndex] = TableViewDataSource.make(forTopOffers: topOffersResponse, data: self.foodSections?.sectionDetails?[topOffersIndex].backgroundColor ?? "#FFFFFF", completion:{ [weak self] data in
                    
                    if let eventName = self?.foodSections?.getEventName(for: SectionIdentifier.TOPBANNERS.rawValue), !eventName.isEmpty {
                        self?.registerBannerEvent(eventName: eventName, bannerType: "top", urlScheme: data.externalWebUrl.asStringOrEmpty(), id: String(data.adId ?? 0))
                    }
                    
                    self?.handleBannerDeepLinkRedirections(url: data.externalWebUrl.asStringOrEmpty())
                })
                configureDataSource()
            }
        } else {
            self.configureHideSection(for: .TOPBANNERS, dataSource: GetTopOffersResponseModel.self)
        }
    }
    
    fileprivate func configureStoriesData(with storiesResponse: Stories) {
        if let stories = storiesResponse.stories, !stories.isEmpty {
            if let storiesIndex = getSectionIndex(for: .STORIES) {
                self.dataSource?.dataSources?[storiesIndex] = TableViewDataSource.make(forStories: storiesResponse, data: self.foodSections?.sectionDetails?[storiesIndex].backgroundColor ?? "#FFFFFF", onClick: { [weak self] story in
                    if var stories = ((self?.dataSource?.dataSources?[safe: storiesIndex] as? TableViewDataSource<Stories>)?.models)?.first {
                        let analyticsSmiles = AnalyticsSmiles(service: FirebaseAnalyticsService())
                        analyticsSmiles.sendAnalyticTracker(trackerData: Tracker(eventType: AnalyticsEvent.firebaseEvent(.ClickOnStory).name, parameters: [:]))
                        
                        if let eventName = self?.foodSections?.getEventName(for: SectionIdentifier.STORIES.rawValue), !eventName.isEmpty {
                            SmilesCommonMethods.registerPersonalizationEvent(for: eventName, offerId: story.storyID ?? "", source: self?.personalizationEventSource)
                        }
                        self?.openStories(stories: stories.stories ?? [], storyIndex: stories.stories?.firstIndex(of: story) ?? 0){storyIndex,snapIndex,isFavorite in
                            stories.setFavourite(isFavorite: isFavorite, storyIndex: storyIndex, snapIndex: snapIndex)
                            (self?.dataSource?.dataSources?[safe: storiesIndex] as? TableViewDataSource<Stories>)?.models = [stories]
                        }
                    }
                })
                self.configureDataSource()
            }
        } else {
            self.configureHideSection(for: .STORIES, dataSource: Stories.self)
        }
    }
    
    fileprivate func configureRestaurantsData(with restaurantResponse: GetRestaurantListingDOResponse) {
        self.restaurantListing = restaurantResponse
        if let restaurants = restaurantResponse.restaurants, !restaurants.isEmpty {
            self.restaurants.append(contentsOf: restaurants)
            if let restaurantIndex = getSectionIndex(for: .RESTAURANTLISTING) {
                self.dataSource?.dataSources?[restaurantIndex] = TableViewDataSource.make(
                    forRestaurants: self.restaurants,
                    data: self.foodSections?.sectionDetails?[restaurantIndex].backgroundColor ?? "#FFFFFF"
                ) { [weak self] isFavorite, restaurantId, indexPath in
                    self?.selectedIndexPath = indexPath
                    if !isGuestUser {
                        self?.updateWishlistStatus(isFavorite: isFavorite, restaurantId: restaurantId)
                    } else {
                        let guestVC = GuestUserLoginPopupRouter.setupModule()
                        guestVC.prevNavigation = self?.navigationController
                        guestVC.modalPresentationStyle = .overFullScreen
                        self?.navigationController?.present(guestVC, animated: true)
                    }
                }
                
                if let defaultSortName = restaurantResponse.defaultSortedName, !defaultSortName.isEmpty {
                    let sortObj = FilterDO()
                    sortObj.name = defaultSortName
                    if let _ = self.viewModel.selectedSortingTableViewCellModel {
                    } else {
                        self.viewModel.selectedSortingTableViewCellModel = sortObj
                    }
                }
                
                self.configureDataSource()
            }
        } else {
            if self.restaurants.isEmpty {
                self.configureHideSection(for: .RESTAURANTLISTING, dataSource: Restaurant.self)
            }
        }
    }
    
    fileprivate func configurePopularRestaurantsData(with popularRestaurantsResponse: GetPopularRestaurantsResponseModel) {
        if let popularRestaurants = popularRestaurantsResponse.restaurants, !popularRestaurants.isEmpty {
            if let popularResturantsIndex = getSectionIndex(for: .RECOMMENDEDLISTING) {
                if let eventName = popularRestaurantsResponse.eventName, !eventName.isEmpty {
                    SmilesCommonMethods.registerPersonalizationEvent(for: eventName, menuItemType: self.orderTypeLocalVariable.rawValue, source: self.personalizationEventSource)
                }
                
                self.dataSource?.dataSources?[popularResturantsIndex] = TableViewDataSource.make(forPopularResturants: popularRestaurantsResponse, data: self.foodSections?.sectionDetails?[popularResturantsIndex].backgroundColor ?? "#FFFFFF", completion: { [weak self] data, indexPath in
                    
                    if let eventName = self?.foodSections?.getEventName(for: SectionIdentifier.RECOMMENDEDLISTING.rawValue), !eventName.isEmpty {
                        SmilesCommonMethods.registerPersonalizationEvent(for: eventName, restaurantId: data.restaurantId.asStringOrEmpty(), menuItemType: self?.orderTypeLocalVariable.rawValue, recommendationModelEvent: data.recommendationModelEvent.asStringOrEmpty(), source: self?.personalizationEventSource)
                    }
                    self?.selectedFavoriteRestaurantIndexPath = indexPath
                    self?.redirectToRestaurantDetailController(restaurant: data)
                })
                self.configureDataSource()
            }
        } else {
            self.configureHideSection(for: .RECOMMENDEDLISTING, dataSource: GetPopularRestaurantsResponseModel.self)
        }
    }
    
    fileprivate func configurePopularRestaurantsPopup(with popularRestaurantsResponse: GetPopularRestaurantsResponseModel) {
        if let topViewController = UIApplication.getTopViewController(),
           topViewController is FoodOrderHomeViewController,
           let popularRestaurants = popularRestaurantsResponse.restaurants,
           !popularRestaurants.isEmpty {
            let headerTitle = popularRestaurantsResponse.sectionName ?? ""
            let headerSubTitle = popularRestaurantsResponse.sectionDescription ?? ""
            
            self.foodOrderHomeCoordinator?.presentRestaurantsList(response: popularRestaurantsResponse, headerTitle: headerTitle, headerSubTitle: headerSubTitle, personalizationEventSource: self.personalizationEventSource, onRestaurantPicked: { restaurant in
                self.redirectToRestaurantDetailController(restaurant: restaurant)
                self.registerEventForOpeningPopularRestaurant(restaurantID: restaurant.restaurantId ?? "", menuItemType: "DELIVERY", recommendationModelEvent: restaurant.recommendationModelEvent)
            })
        }
    }
    
    fileprivate func configureSubscriptionBannerData(with subscriptionBannerResponse: GetSubscriptionBannerResponseModel) {
        if let subscriptionBanner = subscriptionBannerResponse.subscriptionBanner, let imageUrl = subscriptionBanner.subscriptionImage, !imageUrl.isEmpty {
            if let index = getSectionIndex(for: .SUBSCRIPTIONBANNERS) {
                self.dataSource?.dataSources?[index] = TableViewDataSource.make(forSubscription: subscriptionBannerResponse, data: self.foodSections?.sectionDetails?[index].backgroundColor ?? "#FFFFFF")
                self.configureDataSource()
            }
        } else {
            self.configureHideSection(for: .SUBSCRIPTIONBANNERS, dataSource: GetSubscriptionBannerResponseModel.self)
        }
    }
    
    fileprivate func configureFiltersData() {
        showShimmer(identifier: .RESTAURANTLISTING)
        self.input.send(.getRestaurantList(pageNo: 0, filtersList: self.savedFilters, selectedSortingTableViewCellModel: self.viewModel.selectedSortingTableViewCellModel))
    }
    func showShimmer(identifier:SectionIdentifier){
        if let sectionDetails = self.foodSections?.sectionDetails, !sectionDetails.isEmpty {
            for (index, element) in sectionDetails.enumerated() {
                if let sectionIdentifier = element.sectionIdentifier, !sectionIdentifier.isEmpty {
                    if SectionIdentifier(rawValue: sectionIdentifier) == identifier {
                        switch identifier{
                        case .RESTAURANTLISTING:
                            if let response = [Restaurant].fromFile() {
                                self.dataSource?.dataSources?[index] = TableViewDataSource.make(forRestaurants: response, data:"#FFFFFF", isDummy: true, completion: nil)
                            }
                            break
                        default:break//handle other cases if needed later
                        }
                    }
                }
            }
        }
    }
    fileprivate func configureSortingData(with response: GetSortingListResponseModel) {
        self.restaurantSortingResponseModel = response
        self.input.send(.generateActionContentForSortingItems(restaurantSortingResponseModel: self.restaurantSortingResponseModel))
    }
    
    fileprivate func configureWishListData(with updateWishlistResponse: WishListResponseModel) {
        var isFavoriteRestaurant = false
        
        if let favoriteIndexPath = self.selectedIndexPath {
            if let responseCode = updateWishlistResponse.responseCode, responseCode == "204" {
                isFavoriteRestaurant = self.restaurantFavoriteOperation == 1 ? true : false
            } else {
                isFavoriteRestaurant = false
            }
            
            (self.dataSource?.dataSources?[safe: favoriteIndexPath.section] as? TableViewDataSource<Restaurant>)?.models?[safe: favoriteIndexPath.row]?.isFavoriteRestaurant = isFavoriteRestaurant
            
            if let cell = tableView.cellForRow(at: favoriteIndexPath) as? RestaurantsRevampTableViewCell {
                cell.restaurantData?.isFavoriteRestaurant = isFavoriteRestaurant
                cell.showFavouriteAnimation()
            }
            
        }
    }
    
    fileprivate func configureVideoTutorialData(with videoTutorialResponse: GetVideoTutorialResponseModel) {
        if let videoTutorial = videoTutorialResponse.videoTutorial {
            if !self.isYTVideoLoadedOnce {
                self.showTutorialView(with: videoTutorial)
            }
        }
    }
    
    fileprivate func configureOrderRatingData(with response: OrderRatingResponse, _ restaurantId: String) {
        if let _ = response.orderRating {
            if let ratingSatatus = response.ratingStatus, !ratingSatatus {
                self.redirectToRateOrder(response: response)
            } else {
                self.redirectToOrderHistory(restaurantId, orderId: "\(response.orderDetails?.orderId ?? 0)")
            }
        }
    }
    
    fileprivate func configureAbandonedCart(with response: AbandonedListResponseModel) {
        self.reOrderAbandonedCart = response.abandonedList?[safe: 0]
        self.redirectToReOrderRestaurantMenu(self.reOrderRestaurantID ?? "noRestaurantId" , orderId: self.reOrderID ?? "noOrderId", abandonedCart: self.reOrderAbandonedCart)
    }
    
    fileprivate func configureReOrderFood(with response: ReOrderResponseModel) {
        if response.reOrderStatus ?? false {
            let restaurantObj = Restaurant()
            restaurantObj.restaurantId = response.restaurentId
            
            self.redirectToRestaurantDetailController(restaurant: restaurantObj, isFromReOrder: true)
        } else {
            if response.reOrderStatusCode == "101" {
                self.showRestaurantClosedStatusPopup()
            } else if response.reOrderStatusCode == "103" {
                self.showRestaurantPriceChangedStatusPopup()
            } else {
                self.navigateToItemUnavailableViewController(code: response.reOrderStatusCode ?? "", restaurantId: response.restaurentId ?? "", orderId: self.reOrderID ?? "")
            }
        }
    }
    
    fileprivate func setUpRestaurantClosedStatusPopup() -> [BaseRowModel] {
        var items = [BaseRowModel]()
        
        items.append(SheetTitleHeaderTableViewCell.rowModel(model: SheetTitleHeaderTableViewCellModel(title: "Restaurant is closed".localizedString.capitalizingFirstLetter(), font: UIFont.montserratSemiBoldFont(size: 17))))
        let title = "Sorry, this restaurant isn’t accepting orders at this time.".localizedString
        
        let subTitle = "Closed".localizedString + "."
        
        let sheetValueModel1 = SheetValuesTableViewCellModel(title1: title, title2: subTitle, title1Font: .latoMediumFont(size: 13.0), title2Font: .latoMediumFont(size: 13.0), title1Color: .appGreyColor_128, title2Color: .appGreenSecondaryColor, isAttributedText: false)
        items.append(SheetValuesTableViewCell.rowModel(model: sheetValueModel1))
        
        return items
    }
    
    fileprivate func setUpRestaurantPriceChangedStatusPopup() -> [BaseRowModel] {
        var items = [BaseRowModel]()
        
        items.append(SheetTitleHeaderTableViewCell.rowModel(model: SheetTitleHeaderTableViewCellModel(title: "PriceChangeAlert".localizedString.capitalizingFirstLetter(), font: UIFont.montserratSemiBoldFont(size: 17))))
        let title = "PriceChangeSubTitle".localizedString
        
        let subTitle = ""
        
        let sheetValueModel1 = SheetValuesTableViewCellModel(title1: title, title2: subTitle, title1Font: .latoMediumFont(size: 13.0), title2Font: .latoMediumFont(size: 13.0), title1Color: .appGreyColor_128, title2Color: .appGreenSecondaryColor, isAttributedText: false)
        items.append(SheetValuesTableViewCell.rowModel(model: sheetValueModel1))
        
        return items
    }
    
    fileprivate func showRestaurantClosedStatusPopup() {
        var items = [CustomizableActionSheetItem]()
        let vc = UIStoryboard.actionSheetStoryboard.instantiateViewController(ofType: ActionSheetFoodViewController.self)
        
        vc.buttonsModel = BottomButtonsModel(lefttButtonTitle: "", rightButtonTitle: "Okay".localizedString.uppercased(), rightButtonFont: .montserratSemiBoldFont(size: 14))
        
        vc.rowModels = setUpRestaurantClosedStatusPopup()
        vc.buttonDelegate = self
        
        let sampleViewItem = CustomizableActionSheetItem(type: .view, height: 207)
        sampleViewItem.view = vc.view
        items.append(sampleViewItem)
        
        let actionSheet = CustomizableActionSheet()
        actionSheet.tag = cartActionSheetTag.closedStatus.rawValue
        actionSheet.defaultCornerRadius = 0
        self.actionSheet = actionSheet
        
        actionSheet.showInView(view, items: items)
    }
    
    fileprivate func showRestaurantPriceChangedStatusPopup() {
        var items = [CustomizableActionSheetItem]()
        let vc = UIStoryboard.actionSheetStoryboard.instantiateViewController(ofType: ActionSheetFoodViewController.self)
        
        vc.buttonsModel = BottomButtonsModel(lefttButtonTitle: "backToMenu".localizedString, rightButtonTitle: "review".localizedString.uppercased(), rightButtonFont: .montserratSemiBoldFont(size: 14))
        
        vc.rowModels = setUpRestaurantPriceChangedStatusPopup()
        vc.buttonDelegate = self
        
        let sampleViewItem = CustomizableActionSheetItem(type: .view, height: 207)
        sampleViewItem.view = vc.view
        items.append(sampleViewItem)
        
        let actionSheet = CustomizableActionSheet()
        actionSheet.tag = cartActionSheetTag.orderPriceChanged.rawValue
        actionSheet.defaultCornerRadius = 0
        self.actionSheet = actionSheet
        
        actionSheet.showInView(view, items: items)
    }
    
    fileprivate func configureTopAds(with topAdsResponse: GetTopAdsResponseModel) {
        if let adsDto = topAdsResponse.adsDto, !adsDto.isEmpty {
            if let index = getSectionIndex(for: .TOPBANNERS) {
                let sortedAds = adsDto.sorted(by: { $0.position ?? 0 < $1.position ?? 0 })
                
                var topAdsResponseModel = GetTopAdsResponseModel()
                topAdsResponseModel.extTransactionId = topAdsResponse.extTransactionId
                topAdsResponseModel.sliderTimeout = topAdsResponse.sliderTimeout
                topAdsResponseModel.adsDto = sortedAds
                
                self.dataSource?.dataSources?[index] = TableViewDataSource.make(forTopAds: topAdsResponseModel, data: self.foodSections?.sectionDetails?[index].backgroundColor ?? "#FFFFFF") { [weak self] data in
                    if data.externalWebUrl?.contains("smilessubscription") == true {
                        SmilesCommonMethods.registerPersonalizationEvent(for: PersonalizationEvent.foodOrderSmilesSubscriptionUnlimited.rawValue, source: self?.personalizationEventSource)
                    } else {
                        if let eventName = self?.foodSections?.getEventName(for: SectionIdentifier.TOPBANNERS.rawValue), !eventName.isEmpty {
                            SmilesCommonMethods.registerPersonalizationEvent(for: eventName, urlScheme: data.externalWebUrl.asStringOrEmpty(), offerId: String(data.adId ?? 0), source: self?.personalizationEventSource)
                        }
                    }
                    self?.handleBannerDeepLinkRedirections(url: data.externalWebUrl.asStringOrEmpty())
                }
                self.configureDataSource()
            }
        } else {
            self.configureHideSection(for: .TOPBANNERS, dataSource: GetTopAdsResponseModel.self)
        }
    }
    
    fileprivate func configureDataSource() {
        self.tableView.dataSource = self.dataSource
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    fileprivate func configureOrderType(with index: Int) {
        let menuItemType: RestaurantMenuType = (index == 0) ? .DELIVERY : .PICK_UP
        isPickUpFood = menuItemType == .PICK_UP
        self.viewModel.selectedSortingTableViewCellModel = nil
        OrderInfoModel.shared.orderTypeDefaultValue = menuItemType
        OrderInfoModel.shared.orderType = menuItemType
        self.orderTypeLocalVariable = menuItemType
        self.input.send(.emptyRestaurantList)
        self.callFoodOrderServices()
    }
    
    fileprivate func configureHideSection<T>(for section: SectionIdentifier, dataSource: T.Type) {
        if let index = getSectionIndex(for: section) {
            (self.dataSource?.dataSources?[index] as? TableViewDataSource<T>)?.models = []
            (self.dataSource?.dataSources?[index] as? TableViewDataSource<T>)?.isDummy = false
            
            self.configureDataSource()
        }
    }
    
    private func registerBannerEvent(eventName: String, bannerType: String, urlScheme: String, id: String) {
        SmilesCommonMethods.registerPersonalizationEvent(for: eventName, urlScheme: urlScheme, offerId: id, bannerType: bannerType, source: self.personalizationEventSource)
    }
}

// MARK: - Redirections
extension FoodOrderHomeViewController {
    
    func redirectToTrackingScreen(with orderId: String, orderNumber: String, isLiveTracking: Bool) {
        if isLiveTracking {
            self.foodOrderHomeCoordinator?.navigateToTrackOrderVC(orderID: orderId, orderNumber: orderNumber, isCameFromMyOrder: true)
        } else {
            self.foodOrderHomeCoordinator?.navigateToNoTrackingVC(orderID: orderId, orderNumber: orderNumber, isCameFromMyOrder: true, personalizationEventSource: self.personalizationEventSource)
        }
    }
    
    func redirectToLiveChat(with url: String?) {
        self.foodOrderHomeCoordinator?.navigateToLiveChatVC(liveChatURL: url)
    }
    
    func redirectToRateOrder(response: OrderRatingResponse) {
        self.foodOrderHomeCoordinator?.navigateToOrderRatingVC(orderRatingResponse: response)
    }
    
    func redirectToFoodCart(restaurantId: String) {
//        self.foodOrderHomeCoordinator?.navigateToFoodCartVC(restaurantID: restaurantId, viewModel: self.viewModel)
        let foodCartViewController = FoodCartRouter.setupModule()
        foodCartViewController.restaurantId = restaurantId
        foodCartViewController.delegate = self.viewModel
        foodCartViewController.personalizationEventSource = self.personalizationEventSource
        let navigationController = UINavigationController(rootViewController: foodCartViewController)
        navigationController.modalPresentationStyle = .overCurrentContext
        self.navigationController?.present(navigationController)
    }
    
    func redirectToSelectPayment() {
        self.foodOrderHomeCoordinator?.navigateToSelectPaymentVC()
    }
    
    func redirectToOrderHistory(_ restaurantId: String, orderId: String) {
        self.foodOrderHomeCoordinator?.navigateToOrderHistoryVC(restaurantId: restaurantId, orderId: orderId, personalizationEventSource: self.personalizationEventSource)
    }
    
    func redirectToReOrderRestaurantMenu(_ restaurantId: String, orderId: String, abandonedCart: Abandoned?) {
        if let abandonedCart = abandonedCart, abandonedCart.restaurantID == restaurantId  {
            self.abandonedCartActionType = .REORDER
            self.showPickupPopUp(abandonedCartActionType: .REORDER, abandonedObj: abandonedCart)
        }else{
            self.callReOrderService(with: orderId)
        }
    }
    
    func callReOrderService(with orderID: String) {
        SmilesLoader.show(on: self.view ?? UIView())
        self.input.send(.reOrderFood(orderId: orderID))
    }
    
    func orderHistorViewAll(){
        self.foodOrderHomeCoordinator?.navigateToMyOrdersVC(personalizationEventSource: self.personalizationEventSource)
    }
    
    func redirectToRestaurantDetailController(restaurant: Restaurant, isViewCart: Bool = false, isFromReOrder: Bool = false, sourceClick: String? = nil) {
        self.foodOrderHomeCoordinator?.navigateToRestaurantDetailVC(restaurant: restaurant, isViewCart: isViewCart, isFromReorder: isFromReOrder, personalizationEventSource: self.personalizationEventSource, sourceClick: sourceClick)
    }
    
    func navigateToItemUnavailableViewController(code: String, restaurantId: String, orderId: String) {
        self.foodOrderHomeCoordinator?.navigateToReOrderItemUnavailableView(code: code, restaurantID: restaurantId, orderID: orderId, personalizationEventSource: self.personalizationEventSource)
    }
    
    func handleBannerDeepLinkRedirections(url: String) {
        HouseConfig.handleBannerDeepLinkRedirections(url, with: navigationController, additionalInfo: nil)
    }
    
    func redirectToRestaurantFilters() {
        self.foodOrderHomeCoordinator?.navigateToFiltersVC(filterType: .All, menuType: RestaurantMenuType.DELIVERY, viewModel: self.viewModel)
    }
    
    func redirectToSortingPopUp(rowModels: [BaseRowModel]) {
        self.foodOrderHomeCoordinator?.navigateToSortingVC(rowModels: rowModels, viewModel: self.viewModel)
    }
    
    func updateWishlistStatus(isFavorite: Bool, restaurantId: String) {
        restaurantFavoriteOperation = isFavorite ? 1 : 2
        input.send(.updateRestaurantWishlistStatus(operation: restaurantFavoriteOperation, restaurantId: restaurantId))
    }
    
    func openStories(stories: [Story], storyIndex:Int, favouriteUpdatedCallback: ((_ storyIndex:Int,_ snapIndex:Int,_ isFavourite:Bool) -> Void)? = nil) {
        self.foodOrderHomeCoordinator?.navigateToStoriesDetailVC(stories: stories, storyIndex: storyIndex,favouriteUpdatedCallback: favouriteUpdatedCallback)
    }
    
    func redirectToSearch() {
        self.foodOrderHomeCoordinator?.navigateToSearchCategoriesVC(personalizationEventSource: self.personalizationEventSource)
    }
    
    func redirectToSetUserLocation() {
        self.foodOrderHomeCoordinator?.navigateToSetUserLocation(confirmLocationRedirection: .toFoodOrder)
    }
}

extension FoodOrderHomeViewController: AppHeaderDelegate {
    func didTapOnBackButton() {
        if let backToRoot = backToRootView, backToRoot {
            navigationController?.popToRootViewController(animated: false)
        } else {
            navigationController?.popViewController()
        }
    }
    
    func didTapOnSearch() {
        self.input.send(.didTapSearch)
        let analyticsSmiles = AnalyticsSmiles(service: FirebaseAnalyticsService())
        analyticsSmiles.sendAnalyticTracker(trackerData: Tracker(eventType: AnalyticsEvent.firebaseEvent(.SearchBrandDirectly).name, parameters: [:]))
    }
    
    func didTapOnLocation() {
        self.foodOrderHomeCoordinator?.navigateToUpdateLocationVC(confirmLocationRedirection: .toFoodOrder)
    }
    
    func showPopupForLocationSetting() {
        LocationManager.shared.showPopupForSettings()
    }
    
    func didTapOnToolTipSearch() {
        redirectToSetUserLocation()
    }
    
    func segmentLeftBtnTapped(index: Int) {
        configureOrderType(with: index)
    }
    
    func segmentRightBtnTapped(index: Int) {
        configureOrderType(with: index)
    }
    
    func rewardPointsBtnTapped() {
        self.foodOrderHomeCoordinator?.navigateToTransactionsListViewController(personalizationEventSource: self.personalizationEventSource)
    }
    
    func didTapOnBagButton() {
        self.orderHistorViewAll()
    }
}

//extension FoodOrderHomeViewController: UpdateLocationProtocol {
//    func didUpdateLocation() {
//        self.input.send(.emptyRestaurantList)
//        self.callFoodOrderServices()
//        self.selectedLocation = nil
//    }
//}


// MARK: - Personalization Event -
extension FoodOrderHomeViewController {
    
    func registerEvent() {
        SmilesCommonMethods.registerPersonalizationEvent(for: "food_platform", urlScheme: "smiles://orderfood", source: self.personalizationEventSource)
    }
    
    func registerEventForOpeningPopularRestaurant(restaurantID: String?, menuItemType: String?, recommendationModelEvent: String?) {
        SmilesCommonMethods.registerPersonalizationEvent(for: "popular_restaurant", restaurantId: restaurantID ?? "", menuItemType: menuItemType ?? "", recommendationModelEvent: recommendationModelEvent, source: self.personalizationEventSource)
        
        CommonMethods.fireEvent(withTag: "popular_restaurant")
    }
    
    fileprivate func setPersonalizationEventSource() {
        if let source = SharedConstants.personalizationEventSource {
            self.personalizationEventSource = source
            SharedConstants.personalizationEventSource = nil
        }
    }
}
