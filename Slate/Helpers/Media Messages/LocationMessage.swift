//
//  LocationMessage.swift
//  PenPals
//
//  Created by Timmy Van Cauwenberge on 1/20/21.
//  Copyright © 2021 SeniorProject. All rights reserved.
//

import Foundation
import CoreLocation
import MessageKit

class LocationMessage: NSObject, LocationItem {
    
    var location: CLLocation
    var size: CGSize
    override init() {
        location = CLLocation.init()
        size = CGSize.init()
        super.init()

    }

    init(location: CLLocation) {
        self.location = location
        self.size = CGSize(width: 240, height: 240)
    } 
}
