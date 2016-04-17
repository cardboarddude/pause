//
//  PAUFenceManager.swift
//  Pause
//
//  Created by Thomas Elliott on 4/17/16.
//  Copyright © 2016 Pause. All rights reserved.
//

import UIKit
import CoreLocation

enum PAUFenceManagerError:ErrorType {
    case LocationServicesDisabled
    case AuthorizationDenied
    case AuthorizationRestricted
}

class PAUFenceManager : NSObject, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager
    
    override init(){
        locationManager = CLLocationManager()
    }
    
    func setup() throws {
        if !CLLocationManager.locationServicesEnabled() {
            throw PAUFenceManagerError.LocationServicesDisabled
        }

        switch CLLocationManager.authorizationStatus() {
        case CLAuthorizationStatus.NotDetermined, CLAuthorizationStatus.AuthorizedWhenInUse:
            self.locationManager.requestAlwaysAuthorization()
            // TODO: Should wait for the change in authorization
        case CLAuthorizationStatus.Denied:
            throw PAUFenceManagerError.AuthorizationDenied
        case CLAuthorizationStatus.Restricted:
            throw PAUFenceManagerError.AuthorizationRestricted
        default: break
        }

        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        // TODO: Find the sweet spot
        locationManager.distanceFilter = 10.0
        
        // TODO: Determine the impact that this has
        locationManager.pausesLocationUpdatesAutomatically = false
    }
    
    func addFence(checkList: PAUCheckList){
        let region: CLRegion = CLCircularRegion(center: checkList.coordinates, radius: checkList.radius, identifier:checkList.name)
        self.locationManager.startMonitoringForRegion(region)
    }

    func removeFence(name: String){
        let regions = self.locationManager.monitoredRegions
        for r: CLRegion in regions {
            if r.identifier == name {
                self.locationManager.stopMonitoringForRegion(r)
            }
        }
    }
    
    // Stop monitoring all regions
    func clearFences(){
        let regions = self.locationManager.monitoredRegions
        for r: CLRegion in regions {
            self.locationManager.stopMonitoringForRegion(r)
        }
    }
    
    // CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        NSLog("Entered region")
    }
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        NSLog("Exited region")
        let localNotification = UILocalNotification()
        localNotification.alertBody = String(format: "You just left region: %@", region.identifier)
        //localNotification.userInfo = ["Important":"Data"];
        localNotification.soundName = UILocalNotificationDefaultSoundName
        localNotification.applicationIconBadgeNumber = 1
        localNotification.category = "Message"
        UIApplication.sharedApplication().presentLocalNotificationNow(localNotification)
    }
    
}