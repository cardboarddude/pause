//
//  ViewController.swift
//  Pause
//
//  Created by Thomas Elliott on 4/17/16.
//  Copyright © 2016 Pause. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, UITableViewDataSource {
    
    var fenceManager: PAUFenceManager?
    
    var locationManager: CLLocationManager?
    
    var checkList: PAUCheckList?
    
    @IBOutlet var latLabel: UILabel?
    @IBOutlet var lngLabel: UILabel?
    
    @IBOutlet var nameField: UITextField?
    
    var newItemName = ""
    
    @IBOutlet var itemTable: UITableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        checkList = PAUCheckList()
        
        fenceManager = PAUFenceManager()
        do {
            try self.fenceManager?.setup()
        } catch _ {
            NSLog("Fail!")
            return
        }
        
        // Get current location
        self.locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.startUpdatingLocation()
    }
    
    func showLocation(){
        dispatch_async(dispatch_get_main_queue()) {
            if let cl = self.checkList {
                self.latLabel?.text = String(cl.coordinates.latitude)
                self.lngLabel?.text = String(cl.coordinates.longitude)
            }
        }
    }
    
    func saveName(){
        if let nf = self.nameField, let name = nf.text {
            checkList?.name = name
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        checkList?.coordinates = newLocation.coordinate
        showLocation()
    }
    
    @IBAction func addFence(){
        saveName()
        if let cl = self.checkList {
            self.fenceManager?.addFence(cl)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func itemCount() -> Int {
        if let c = checkList {
            return c.items.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemCount() + 1
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cellIdentifier = "AddItem"
        if indexPath.row < itemCount(){
            cellIdentifier = "Item"
        }
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        if let itemCell = cell as? PAUItemCell {
            itemCell.nameLabel?.text = checkList?.items[indexPath.row]
        }
        if let addCell = cell as? PAUAddItemCell {
            addCell.nameField?.text = ""
        }
        return cell
    }
    
    @IBAction func addItem(){
        if newItemName == "" {
            return
        }
        checkList?.items.append(newItemName)
        newItemName = ""
        itemTable?.reloadData()
    }
    
    @IBAction func textFieldDidChange(textField: UITextField) {
        if let text = textField.text {
            newItemName = text
        }
    }

}

class PAUAddItemCell: UITableViewCell {
    
    @IBOutlet var nameField: UITextField?
    
}

class PAUItemCell: UITableViewCell {
    
    @IBOutlet var nameLabel: UILabel?
    
}

