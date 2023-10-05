//
//  RestaurantListViewModel.swift
//  House
//
//  Created by Syed Faraz Haider Zaidi on 03/11/2022.
//  Copyright © 2022 Ahmed samir ali. All rights reserved.
//

import Foundation
import Combine
import NetworkingLayer
import SmilesUtilities
import SmilesSharedModels

class RestaurantListViewModel: NSObject {
    
    var subscriptions = Set<AnyCancellable>()
    
    // MARK: - INPUT. View event methods
    enum Input {
        case getRestaurantList(pageNo : Int = 0, filtersList: [RestaurantRequestFilter]?)
    }
    
    enum Output {
        case fetchRestaurantListDidSucceed(response: GetRestaurantListingDOResponse)
        case fetchRestaurantListDidFail(error: Error)
    }
    
    // MARK: -- Variables
    private var output: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()

}

// MARK: - INPUT. View event methods
extension RestaurantListViewModel {
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        output = PassthroughSubject<Output, Never>() // Initialize output
        input.sink { [weak self] event in
            switch event {
            case .getRestaurantList(let pageNo, let filtersList ):
                self?.getRestaurantList(with: pageNo, filtersList: filtersList)
            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
    
    // Get All cuisines
    func getRestaurantList(with pageNo: Int, filtersList:  [RestaurantRequestFilter]?) {
        let restaurantListDORequest = GetRestaurantListingDORequest(
            filters: [],
            pageNo: pageNo,
            menuItemType: OrderInfoModel.shared.orderTypeDefaultValue.rawValue,
            isGuestUser: isGuestUser
        )
        
        if let filtersList = filtersList, !filtersList.isEmpty {
            var filterKeys = [String]()
            var appliedFilters = [RestaurantRequestFilter]()
            
            for item in filtersList {
                if let filterKey = item.filterKey {
                    filterKeys.append(filterKey)
                }
            }
            
            let uniqueUnordered = Array(Set(filterKeys))
            
            for item in uniqueUnordered {
                let retaurantFilter = RestaurantRequestFilter()
                
                retaurantFilter.filterKey = item
                var filterValues: String = ""
                
                for filter in filtersList {
                    if item == filter.filterKey {
                        filterValues.append(filter.filterValue ?? "")
                        retaurantFilter.filterValue = filterValues
                        filterValues.append(",")
                        CommonMethods.fireEvent(withName: FirebaseEventTags.kAppliedFilter.rawValue, parameters: [item: filter])
                    }
                }
                
                appliedFilters.append(retaurantFilter)
            }
            
            restaurantListDORequest.filters = [RestaurantRequestFilter]()
            restaurantListDORequest.filters = appliedFilters
        }

        let service = GetRestaurantListRepository(
            networkRequest: NetworkingLayerRequestable(requestTimeOut: 60),
            endPoint: .restaurantList
        )
        
        
        service.getRestaurantListService(request: restaurantListDORequest)
            .sink { [weak self] completion in
                debugPrint(completion)
                switch completion {
                case .failure(let error):
                    self?.output.send(.fetchRestaurantListDidFail(error: error))
                case .finished:
                    debugPrint("nothing much to do here")
                }
            } receiveValue: { [weak self] response in
                debugPrint("got my response here \(response)")
                self?.output.send(.fetchRestaurantListDidSucceed(response: response))
            }.store(in: &subscriptions)
    }
}





