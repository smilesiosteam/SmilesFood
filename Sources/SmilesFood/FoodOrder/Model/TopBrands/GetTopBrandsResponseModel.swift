//
//  GetTopBrandsResponse.swift
//  House
//
//  Created by Hanan Ahmed on 10/31/22.
//  Copyright © 2022 Ahmed samir ali. All rights reserved.
//

import Foundation
import SmilesReusableComponents

struct GetTopBrandsResponseModel: Codable {
    let brands: [BrandDO]?
}
