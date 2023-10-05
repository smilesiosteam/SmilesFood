//
//  GetCuisinesResponseModel.swift
//  House
//
//  Created by Hanan Ahmed on 10/31/22.
//  Copyright © 2022 Ahmed samir ali. All rights reserved.
//

import Foundation

struct GetCuisinesResponseModel: Codable {
    
    let cuisines: [CuisineDO]?
    
    struct CuisineDO: Codable {
        // MARK: - Model Variables
        
        let title: String?
        let description: String?
        let imageUrl: String?
        let iconUrl: String?
        let redirectionUrl: String?
        
    }
}
