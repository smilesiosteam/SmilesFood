//
//  PopularRestaurantsViewModel.swift
//  House
//
//  Created by Hanan Ahmed on 11/3/22.
//  Copyright © 2022 Ahmed samir ali. All rights reserved.
//

import Foundation
import Combine
import NetworkingLayer
import SmilesSharedServices
import SmilesUtilities
import SmilesSharedModels

class PopularRestaurantsViewModel: NSObject {
    
    // MARK: - INPUT. View event methods
    enum Input {
        case getPopularRestaurants(menuItemType: String?, type: PopularRestaurantRequest = .recommended)
        case getPopupPopularRestaurants(menuItemType: String?, type: PopularRestaurantRequest = .popup)
        case updateRestaurantWishlistStatus(operation: Int, restaurantId: String)
    }
    
    enum Output {
        case fetchPopularRestaurantsDidSucceed(response: GetPopularRestaurantsResponseModel, menuItemType: String?)
        case fetchPopularRestaurantsDidFail(error: Error)
        
        case fetchPopupPopularRestaurantsDidSucceed(response: GetPopularRestaurantsResponseModel, menuItemType: String?)
        case fetchPopupPopularRestaurantsDidFail(error: Error)
        
        case updateWishlistStatusDidSucceed(response: WishListResponseModel)
    }
    
    // MARK: -- Variables
    private var output: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    
    private let wishListViewModel = WishListViewModel()
    private var wishListUseCaseInput: PassthroughSubject<WishListViewModel.Input, Never> = .init()
    
}

// MARK: - INPUT. View event methods
extension PopularRestaurantsViewModel {
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        output = PassthroughSubject<Output, Never>()
        input.sink { [weak self] event in
            switch event {
            case .getPopularRestaurants(let menuItemType, let type):
                self?.getAllPopularRestaurants(for: menuItemType, type: type)
            case .getPopupPopularRestaurants(let menuItemType, let type):
                self?.getAllPopupPopularRestaurants(for: menuItemType, type: type)
            case .updateRestaurantWishlistStatus(operation: let operation, restaurantId: let restaurantId):
                self?.bind(to: self?.wishListViewModel ?? WishListViewModel())
                self?.wishListUseCaseInput.send(.updateRestaurantWishlistStatus(operation: operation, restaurantId: restaurantId, baseUrl: AppCommonMethods.serviceBaseUrl))
            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
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
    
    // Get All Popular Restaurants
    func getAllPopularRestaurants(for menuItemType: String?, type: PopularRestaurantRequest) {

        let getPopularRestaurantsRequest = GetPopularRestaurantsRequestModel(
            menuItemType: menuItemType,
            isGuestUser: isGuestUser,
            type: type
        )
        
        let service = GetPopularRestaurantsRepository(
            networkRequest: NetworkingLayerRequestable(requestTimeOut: 60),
            endPoint: .popularRestaurants
        )
        
        service.getAllPopularRestaurantsService(request: getPopularRestaurantsRequest)
            .sink { [weak self] completion in
                debugPrint(completion)
                switch completion {
                case .failure(let error):
                    self?.output.send(.fetchPopularRestaurantsDidFail(error: error))
                case .finished:
                    debugPrint("nothing much to do here")
                }
            } receiveValue: { [weak self] response in
                debugPrint("got my response here \(response)")
                self?.output.send(.fetchPopularRestaurantsDidSucceed(response: response, menuItemType: menuItemType))
            }
        .store(in: &cancellables)
    }
    
    // Get All Popup Popular Restaurants
    func getAllPopupPopularRestaurants(for menuItemType: String?, type: PopularRestaurantRequest) {

        let getPopularRestaurantsRequest = GetPopularRestaurantsRequestModel(
            menuItemType: menuItemType,
            isGuestUser: isGuestUser,
            type: type
        )
        
        let service = GetPopularRestaurantsRepository(
            networkRequest: NetworkingLayerRequestable(requestTimeOut: 60),
            endPoint: .popularRestaurants
        )
        
        service.getAllPopularRestaurantsService(request: getPopularRestaurantsRequest)
            .sink { [weak self] completion in
                debugPrint(completion)
                switch completion {
                case .failure(let error):
                    self?.output.send(.fetchPopupPopularRestaurantsDidFail(error: error))
                case .finished:
                    debugPrint("nothing much to do here")
                }
            } receiveValue: { [weak self] response in
                debugPrint("got my response here \(response)")
                self?.output.send(.fetchPopupPopularRestaurantsDidSucceed(response: response, menuItemType: menuItemType))
            }
        .store(in: &cancellables)
    }
}
