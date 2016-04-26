//
//  CheckList.swift
//  Pause
//
//  Created by Thomas Elliott on 4/17/16.
//  Copyright © 2016 Pause. All rights reserved.
//

import Foundation
import CoreLocation

struct PAUChecklistPropertyKey {
    static let nameKey = "name"
    static let radiusKey = "radius"
    static let lngKey = "lng"
    static let latKey = "lat"
    static let itemsKey = "items"
}

class PAUCheckList : NSObject, NSCoding {
    
    var name: String
    var coordinates: CLLocationCoordinate2D
    var radius: CLLocationDistance
    var items: [String]
    
    override init(){
        self.name = ""
        self.coordinates = CLLocationCoordinate2DMake(0, 0)
        self.radius = 50
        self.items = []
        
        super.init()
    }
    
    init(name: String, coordinates: CLLocationCoordinate2D, radius: CLLocationDistance, items: [String]){
        self.name = name
        self.coordinates = coordinates
        self.radius = radius
        self.items = items
        
        super.init()
    }
    
    // MARK: NSCoding
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: PAUChecklistPropertyKey.nameKey)
        aCoder.encodeDouble(radius, forKey: PAUChecklistPropertyKey.radiusKey)
        aCoder.encodeDouble(coordinates.latitude, forKey: PAUChecklistPropertyKey.latKey)
        aCoder.encodeDouble(coordinates.longitude, forKey: PAUChecklistPropertyKey.lngKey)
        aCoder.encodeObject(items, forKey: PAUChecklistPropertyKey.itemsKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObjectForKey(PAUChecklistPropertyKey.nameKey) as! String
        let items = aDecoder.decodeObjectForKey(PAUChecklistPropertyKey.itemsKey) as! [String]
        let lat = aDecoder.decodeDoubleForKey(PAUChecklistPropertyKey.latKey)
        let lng = aDecoder.decodeDoubleForKey(PAUChecklistPropertyKey.lngKey)
        let radius = aDecoder.decodeDoubleForKey(PAUChecklistPropertyKey.radiusKey)
        
        self.init(name: name, coordinates: CLLocationCoordinate2DMake(lat, lng), radius: radius, items:items)
    }
    
    // MARK: Archiving Paths
    
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("checklists")
}
