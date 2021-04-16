//
//  MapAnnotation.swift
//  PenPals
//
//  Created by Timmy Van Cauwenberge on 1/20/21.
//  Copyright © 2021 SeniorProject. All rights reserved.
//

import Foundation
import MapKit

class MapAnnotation: NSObject, MKAnnotation {
    
    let title: String?
    let coordinate: CLLocationCoordinate2D
    
    init(title: String?, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
    }
}
