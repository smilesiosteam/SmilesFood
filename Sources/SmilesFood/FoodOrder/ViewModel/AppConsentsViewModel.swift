//
//  AppConsentsViewModel.swift
//  House
//
//  Created by Hanan Ahmed on 12/13/22.
//  Copyright © 2022 Ahmed samir ali. All rights reserved.
//

import Foundation
import Combine
import NetworkingLayer

class AppConsentsViewModel: NSObject {
    
    // MARK: - INPUT. View event methods
    enum Input {
        case getAppConsents(consentType: [String]?)
        case verifyEmail(token: String)
    }
    
    enum Output {
        case fetchAppConsentsDidSucceed(response: GetConsentsResponseModel?)
        case verifyEmailDidSucceed(response: EmailVerificationResonse)
        case fetchAppConsentsDidFail(error: Error)
    }
    
    // MARK: -- Variables
    private var output: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    
}

// MARK: - INPUT. View event methods
extension AppConsentsViewModel {
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        output = PassthroughSubject<Output, Never>()
        input.sink { [weak self] event in
            switch event {
            case .getAppConsents(let consentType):
                self?.getAppConsents(with: consentType)
            case .verifyEmail(token: let token):
                self?.verifyEmail(token: token)
            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
    
    // Get App Consents
    func getAppConsents(with consentType: [String]?) {
        
        let getAppConsentsRequestModel = AppConsentsRequestModel()
        getAppConsentsRequestModel.consentType = consentType
        
        let service = GetConsentsRepository(
            networkRequest: NetworkingLayerRequestable(requestTimeOut: 60),
            endPoint: .consentsForApp
        )
        
        service.getGetConsentsService(request: getAppConsentsRequestModel)
            .sink { [weak self] completion in
                debugPrint(completion)
                switch completion {
                case .failure(let error):
                    self?.output.send(.fetchAppConsentsDidFail(error: error))
                case .finished:
                    debugPrint("nothing much to do here")
                }
            } receiveValue: { [weak self] response in
                debugPrint("got my response here \(response)")
                self?.output.send(.fetchAppConsentsDidSucceed(response: response))
            }
        .store(in: &cancellables)
    }
    // Verify Email
    func verifyEmail(token: String) {
        
        let request = VerifyEmailRequest()
        request.emailVerificationToken = token
        
        let service = GetConsentsRepository(
            networkRequest: NetworkingLayerRequestable(requestTimeOut: 60),
            endPoint: .verifyEmail
        )
        
        service.getVerifyEmailService(request: request)
            .sink { [weak self] completion in
                debugPrint(completion)
                switch completion {
                case .failure(let error):
                    self?.output.send(.fetchAppConsentsDidFail(error: error))
                case .finished:
                    debugPrint("nothing much to do here")
                }
            } receiveValue: { [weak self] response in
                debugPrint("got my response here \(response)")
                self?.output.send(.verifyEmailDidSucceed(response: response))
            }
        .store(in: &cancellables)
    }
}

