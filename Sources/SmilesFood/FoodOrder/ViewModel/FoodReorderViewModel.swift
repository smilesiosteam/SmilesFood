//
//  FoodReorderViewModel.swift
//  House
//
//  Created by Hanan Ahmed on 7/18/23.
//  Copyright © 2023 Ahmed samir ali. All rights reserved.
//

import Foundation
import Combine
import NetworkingLayer
import SmilesUtilities
import SmilesSharedModels
import SmilesLocationHandler

class FoodReorderViewModel: NSObject {
    
    var subscriptions = Set<AnyCancellable>()

    // MARK: - INPUT. View event methods
    enum Input {
        case reOrderFood(orderId : String?)
    }
    
    enum Output {
        case fetchReOrderDidSucceed(response: ReOrderResponseModel)
        case fetchReOrderDidFail(error: Error)
    }
    
    // MARK: -- Variables
    private var output: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    
}

// MARK: - INPUT. View event methods
extension FoodReorderViewModel {
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        output = PassthroughSubject<Output, Never>() // Initialize output
        input.sink { [weak self] event in
            switch event {
            case .reOrderFood(let orderId):
                self?.reOrderFoodCall(with: orderId ?? "")
            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
    
    // Re Order Food
    func reOrderFoodCall(with orderId: String) {
        
        let reOrderRequestModel = ReOrderFoodRequestModel(orderId: orderId)
        
        let service = ReOrderFoodRespository(
            networkRequest: NetworkingLayerRequestable(requestTimeOut: 60),
            endPoint: .reOrderFood
        )
        
        service.reOrderFoodService(request: reOrderRequestModel)
            .sink { [weak self] completion in
                debugPrint(completion)
                switch completion {
                case .failure(let error):
                    self?.output.send(.fetchReOrderDidFail(error: error))
                case .finished:
                    debugPrint("nothing much to do here")
                }
            } receiveValue: { [weak self] response in
                debugPrint("got my response here \(response)")
                self?.output.send(.fetchReOrderDidSucceed(response: response))
            }
        .store(in: &subscriptions)
    }
}


//func callReOrderService(){
//
//    self.view?.showHud()
//    let request = ReOrderRequestModel()
//    request.orderId = orderIdObj
//
//    if let userInfo = LocationStateSaver.getLocationInfo() {
//        let requestUserInfo = SmilesUserInfo()
//        requestUserInfo.mambaId = userInfo.mambaId
//        requestUserInfo.locationId = userInfo.locationId
//        request.userInfo = requestUserInfo
//    }
//
//    restaurantServices.reOrderWith(request: request, completionHandler: { (response) in
//        self.view?.hideHud()
//        if response.reOrderStatus ?? false{
//            let restaurantDetailsViewController = RestaurantDetailRevampRouter.setupModule()
//            let restaurantObj = Restaurant()
//            restaurantObj.restaurantId = response.restaurentId
//            restaurantDetailsViewController.selectedRestaurantObj = restaurantObj
//            restaurantDetailsViewController.isReorderingFromOrderSummary = true
//            self.router?.navigateToViewController(viewController: restaurantDetailsViewController)
//
//
//        }else{
//            let vc = ReOrderItemUnavailableRouter.setupModule()
//            vc.restaurantId = response.restaurentId.asStringOrEmpty()
//            vc.orderId = self.orderIdObj
//            self.router?.navigateToViewController(viewController: vc)
//        }
//    }) { (error) in
//        self.view?.hideHud()
//    }
//}
