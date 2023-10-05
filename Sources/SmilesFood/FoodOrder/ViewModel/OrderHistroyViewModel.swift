//
//  OrderHistroyViewModel.swift
//  House
//
//  Created by Faraz Haider on 10/31/22.
//  Copyright © 2022 Ahmed samir ali. All rights reserved.
//

import Foundation
import Combine
import NetworkingLayer
import SmilesOffers

class OrderHistroyViewModel: NSObject {
    
    var subscriptions = Set<AnyCancellable>()

    // MARK: - INPUT. View event methods
    enum Input {
        case getOrderHistory(pageNo : Int = 0, filterKey : String = "filter", filterValue: String = "reorder", orderType: RestaurantMenuType)
    }
    
    enum Output {
        case fetchOrderHistoryDidSucceed(response: GetOrderHistoryDOResponse)
        case fetchOrderHistoryDidFail(error: Error)
    }
    
    // MARK: -- Variables
    private var output: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    
}

// MARK: - INPUT. View event methods
extension OrderHistroyViewModel {
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        output = PassthroughSubject<Output, Never>() // Initialize output
        input.sink { [weak self] event in
            switch event {
            case .getOrderHistory(let pageNo, let filterKey, let filterValue, let orderType ):
                self?.getOrderHistory(with: pageNo, filterKey: filterKey, filterValue: filterValue, orderType: orderType)
            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
    
    // Get All cuisines
    func getOrderHistory(with pageNo: Int, filterKey: String, filterValue:String, orderType: RestaurantMenuType) {
        var filter = [FilterDO]()
        
        let restaurantRequestFilter = FilterDO()
        restaurantRequestFilter.filterKey = filterKey
        restaurantRequestFilter.filterValue = filterValue
        filter.append(restaurantRequestFilter)
        
        let orderHistoryDORequest = GetOrderHistoryDORequest(
            filters: filter,
            pageNo: pageNo,
            orderType: orderType
        )
        
        let service = GetOrderHistoryRepository(
            networkRequest: NetworkingLayerRequestable(requestTimeOut: 60),
            endPoint: .orderHistory
        )
        
        service.getOrderHistoryService(request: orderHistoryDORequest)
            .sink { [weak self] completion in
                debugPrint(completion)
                switch completion {
                case .failure(let error):
                    self?.output.send(.fetchOrderHistoryDidFail(error: error))
                case .finished:
                    debugPrint("nothing much to do here")
                }
            } receiveValue: { [weak self] response in
                debugPrint("got my response here \(response)")
                self?.output.send(.fetchOrderHistoryDidSucceed(response: response))
            }
        .store(in: &subscriptions)
    }
}
