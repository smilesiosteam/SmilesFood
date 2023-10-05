//
//  SortingListViewModel.swift
//  House
//
//  Created by Hanan Ahmed on 11/8/22.
//  Copyright © 2022 Ahmed samir ali. All rights reserved.
//

import Foundation
import Combine
import NetworkingLayer
import SmilesOffers

class SortingListViewModel: NSObject {
    
    // MARK: - INPUT. View event methods
    enum Input {
        case getSortingList(menuItemType: String)
    }
    
    enum Output {
        case fetchSortingListDidSucceed(response: GetSortingListResponseModel)
        case fetchSortingListDidFail(error: Error)
    }
    
    // MARK: -- Variables
    private var output: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    
}

// MARK: - INPUT. View event methods
extension SortingListViewModel {
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        output = PassthroughSubject<Output, Never>()
        input.sink { [weak self] event in
            switch event {
            case .getSortingList(let menuItemType):
                self?.getSortingList(for: menuItemType)
            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
    
    // Get Sorting List
    func getSortingList(for menuItemType: String) {
        let getSortingListRequest = GetSortingListRequestModel(
            menuItemType: menuItemType
        )
        
        let service = GetSortingListRepository(
            networkRequest: NetworkingLayerRequestable(requestTimeOut: 60),
            endPoint: .sortingList
        )
        
        service.getSortingListService(request: getSortingListRequest)
            .sink { [weak self] completion in
                debugPrint(completion)
                switch completion {
                case .failure(let error):
                    self?.output.send(.fetchSortingListDidFail(error: error))
                case .finished:
                    debugPrint("nothing much to do here")
                }
            } receiveValue: { [weak self] response in
                debugPrint("got my response here \(response)")
                self?.output.send(.fetchSortingListDidSucceed(response: response))
            }
        .store(in: &cancellables)
    }
}

