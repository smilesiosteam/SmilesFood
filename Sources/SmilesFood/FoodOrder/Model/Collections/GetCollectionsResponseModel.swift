//
//  GetCollectionsResponseModel.swift
//  House
//
//  Created by Shahroze Zaheer on 10/31/22.
//  Copyright © 2022 Ahmed samir ali. All rights reserved.
//

import Foundation
import SmilesReusableComponents

struct GetCollectionsResponseModel: Codable {
    let collections: [CollectionDO]?
}
