//
//  CheckList.swift
//  Pause
//
//  Created by Thomas Elliott on 4/17/16.
//  Copyright © 2016 Pause. All rights reserved.
//

import Foundation
import CoreLocation

struct PAUCheckList {
    var name: String = ""
    var coordinates: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0)
    var radius: CLLocationDistance = 50.0
    var items: [String] = []
}
