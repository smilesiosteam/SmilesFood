//
//  AbandonedCartViewModel.swift
//  House
//
//  Created by Shmeel Ahmed on 11/11/2022.
//  Copyright © 2022 Ahmed samir ali. All rights reserved.
//

import Foundation
import Combine
import NetworkingLayer

class AbandonedCartViewModel: NSObject {
    
    // MARK: - INPUT. View event methods
    enum Input {
        case getAbandonedCart
        case removeCart(abandonedCart: Abandoned?)
        case setOrderStatus(orderId: String)
        case getLiveChatUrl(orderId: String, orderNumber: String)
        case getOrderRating(
            orderId: String,
            trackingStatus: Bool,
            restaurantId: String,
            ratingType: String,
            contentType: String
        )
        case getReOrderAbandonedCart
    }
    
    enum Output {
        case didUpdateAbandonedCartAndOrderTracking(cart: Abandoned?, trackingDetails: [TrackOrderOnMapResponseModelOrderTrackingDetail]?, timeout: Int?)
        case removeAbandonedCartDidSucceed
        case setOrderStatusDidSucceed
        case getLiveChatUrlDidSucceed(chatbotUrl: String?)
        case getOrderRatingDidSucceed(response: OrderRatingResponse, restaurantId: String)
        
        case fetchAbandonedCartDidSucceed(response: AbandonedListResponseModel)
        
        case fetchAbandonedCartDidFail(error: Error)
        case fetchDidFail(error: Error)
    }
    
    // MARK: -- Variables
    private var output: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    private var stories: AbandonedList?
    
}

// MARK: - INPUT. View event methods
extension AbandonedCartViewModel {
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        output = PassthroughSubject<Output, Never>()
        input.sink { [weak self] event in
            switch event {
            case .getAbandonedCart:
                self?.getAbandonedCart()
            case .removeCart(let abandonedCart):
                self?.removeCart(abandonedCart: abandonedCart)
            case .setOrderStatus(let orderId):
                self?.setOrderStatus(orderId: orderId)
            case .getLiveChatUrl(let orderId, let orderNumber):
                self?.getLiveChatUrl(orderId: orderId, orderNumber: orderNumber)
            case .getOrderRating(let orderId, let trackingStatus, let restaurantId, let ratingType, let contentType):
                self?.getOrderRating(
                    orderId: orderId,
                    trackingStatus: trackingStatus,
                    restaurantId: restaurantId,
                    ratingType: ratingType,
                    contentType: contentType
                )
                
            case .getReOrderAbandonedCart:
                self?.getAbandonedCartForReordering()
            }
        }.store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
    
    func getAbandonedCartForReordering() {
        let registerLocationRequestModel = RegisterLocationRequestModel()
        
        let service = GetAbandonedCartRepository(
            networkRequest: NetworkingLayerRequestable(requestTimeOut: 60),
            endPoint: .abandonedCart
        )
        
        service.getAbandonedCartService(request: registerLocationRequestModel)
            .sink { [weak self] completion in
                debugPrint(completion)
                switch completion {
                case .failure(let error):
                    self?.output.send(.fetchAbandonedCartDidFail(error: error))
                case .finished:
                    debugPrint("nothing much to do here")
                }
            } receiveValue: { [weak self] response in
                debugPrint("got my response here \(response)")
                self?.output.send(.fetchAbandonedCartDidSucceed(response: response))
            }
        .store(in: &cancellables)
    }
    
    
    func getAbandonedCart() {
        let registerLocationRequestModel = RegisterLocationRequestModel()
        
        let service = GetAbandonedCartRepository(
            networkRequest: NetworkingLayerRequestable(requestTimeOut: 60),
            endPoint: .abandonedCart
        )
        
        service.getAbandonedCartService(request: registerLocationRequestModel)
            .sink { [weak self] completion in
                debugPrint(completion)
                switch completion {
                case .failure(let error):
                    self?.output.send(.fetchDidFail(error: error))
                    self?.getOrderStatus(cart: nil)
                case .finished:
                    debugPrint("nothing much to do here")
                }
            } receiveValue: { [weak self] response in
                debugPrint("got my response here \(response)")
                if let abandonedCarts = response.abandonedList, !abandonedCarts.isEmpty {
                    // Abandoned Carts
                    self?.getOrderStatus(cart: abandonedCarts[safe: 0])
                } else {
                    self?.getOrderStatus(cart: nil)
                }
            }
        .store(in: &cancellables)
    }

    func getOrderStatus(cart: Abandoned?) {
        let confirmOrderRequestModel = ConfirmOrderRequestModel(orderId: "")
        
        let service = GetAbandonedCartRepository(
            networkRequest: NetworkingLayerRequestable(requestTimeOut: 60),
            endPoint: .orderStatus
        )
        
        service.getOrderStatusService(request: confirmOrderRequestModel)
            .sink { [weak self] completion in
                debugPrint(completion)
                switch completion {
                case .failure(let error):
                    self?.output.send(.fetchDidFail(error: error))
                    self?.output.send(.didUpdateAbandonedCartAndOrderTracking(
                        cart: cart,
                        trackingDetails: nil,
                        timeout: nil)
                    )
                case .finished:
                    debugPrint("nothing much to do here")
                }
            } receiveValue: { [weak self] response in
                debugPrint("got my response here \(response)")
                if let responseArray = response.orderTrackingDetails, responseArray.count > 0 {
                    self?.output.send(.didUpdateAbandonedCartAndOrderTracking(
                        cart: cart,
                        trackingDetails: responseArray,
                        timeout: response.orderTimeOut)
                    )
                } else {
                    self?.output.send(.didUpdateAbandonedCartAndOrderTracking(
                        cart: cart,
                        trackingDetails: nil,
                        timeout: nil)
                    )
                }
            }
        .store(in: &cancellables)
    }
    
    func removeCart(abandonedCart: Abandoned?) {
        let removeCartRequestModel = RemoveCartRequestModel(
            restaurantId: abandonedCart?.restaurantID
        )
                
        let service = GetAbandonedCartRepository(
            networkRequest: NetworkingLayerRequestable(requestTimeOut: 60),
            endPoint: .removeCart
        )
        
        service.removeCartService(request: removeCartRequestModel)
            .sink { [weak self] completion in
                debugPrint(completion)
                switch completion {
                case .failure(let error):
                    self?.output.send(.fetchDidFail(error: error))
                case .finished:
                    debugPrint("nothing much to do here")
                }
            } receiveValue: { [weak self] response in
                debugPrint("got my response here \(response)")
                self?.output.send(.removeAbandonedCartDidSucceed)
            }
        .store(in: &cancellables)
    }
    
    func setOrderStatus(orderId: String) {
        let confirmOrderRequestModel = ConfirmOrderRequestModel(
            orderId: orderId,
            orderStatus: 1
        )
        
        let service = GetAbandonedCartRepository(
            networkRequest: NetworkingLayerRequestable(requestTimeOut: 60),
            endPoint: .orderConfirmStatus
        )
        
        service.setOrderStatusService(request: confirmOrderRequestModel)
            .sink { [weak self] completion in
                debugPrint(completion)
                switch completion {
                case .failure(let error):
                    self?.output.send(.fetchDidFail(error: error))
                case .finished:
                    debugPrint("nothing much to do here")
                }
            } receiveValue: { [weak self] response in
                debugPrint("got my response here \(response)")
                self?.output.send(.setOrderStatusDidSucceed)
            }
        .store(in: &cancellables)
    }
    
    func getLiveChatUrl(orderId: String, orderNumber: String) {
        var chatbotType: String?

        if let onAppStartObjectResponse = getUserProfileResponse.sharedClient().onAppStartObjectResponse,
            let  foodLiveChatbotType = onAppStartObjectResponse.foodLiveChatbotType,
            !foodLiveChatbotType.isEmpty
        {
            chatbotType = foodLiveChatbotType
        }
        
        let foodOrderChatRevampRequestModel = FoodOrderChatRevampRequestModel(
            orderId: orderId,
            chatbotType: chatbotType,
            orderNumber: orderNumber
        )
        
        let service = GetAbandonedCartRepository(
            networkRequest: NetworkingLayerRequestable(requestTimeOut: 60),
            endPoint: .liveChatDetails
        )
        
        service.getLiveChatUrlService(request: foodOrderChatRevampRequestModel)
            .sink { [weak self] completion in
                debugPrint(completion)
                switch completion {
                case .failure(let error):
                    self?.output.send(.fetchDidFail(error: error))
                case .finished:
                    debugPrint("nothing much to do here")
                }
            } receiveValue: { [weak self] response in
                debugPrint("got my response here \(response)")
                self?.output.send(.getLiveChatUrlDidSucceed(chatbotUrl: response.chatbotUrl))
            }
        .store(in: &cancellables)
    }
    
    func getOrderRating(
        orderId: String,
        trackingStatus: Bool,
        restaurantId: String,
        ratingType: String,
        contentType: String
    ) {
        let orderRatingRevampRequestModel = OrderRatingRevampRequestModel(
            ratingType: ratingType,
            contentType: contentType,
            isLiveTracking: trackingStatus,
            orderId: orderId
        )
        
        let service = GetAbandonedCartRepository(
            networkRequest: NetworkingLayerRequestable(requestTimeOut: 60),
            endPoint: .orderRating
        )
        
        service.getOrderRatingService(request: orderRatingRevampRequestModel)
            .sink { [weak self] completion in
                debugPrint(completion)
                switch completion {
                case .failure(let error):
                    self?.output.send(.fetchDidFail(error: error))
                case .finished:
                    debugPrint("nothing much to do here")
                }
            } receiveValue: { [weak self] response in
                debugPrint("got my response here \(response)")
                self?.output.send(.getOrderRatingDidSucceed(response: response, restaurantId: restaurantId))
            }
        .store(in: &cancellables)
    }
}
