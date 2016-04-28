//
//  PAUListStore.swift
//  Pause
//
//  Created by Thomas Elliott on 4/17/16.
//  Copyright © 2016 Pause. All rights reserved.
//

import Foundation

class PAUListStore {
    
    private static var checkLists: [PAUCheckList] = []

    private static var checkedItems: [String : [String : Bool]] = [:]
    
    static func isChecked(item: String, checkList: PAUCheckList) -> Bool {
        if let items = checkedItems[checkList.name], let checked = items[item] {
                return checked
        }
        return false
    }
    
    static func setItemChecked(checked: Bool, item: String, checkList: PAUCheckList) {
        if let items = checkedItems[checkList.name] {
            var updatedItems = items
            updatedItems[item] = checked
            checkedItems[checkList.name] = updatedItems
        } else {
            checkedItems[checkList.name] = [item : checked]
        }
    }
    
    static func getLists() -> [PAUCheckList] {
        return checkLists
    }
    
    // Save the provided list against it's name
    static func putList(checkList: PAUCheckList){
        checkLists.append(checkList)
    }
    
    // MARK: NSCoding

    static func saveLists(){
        var isSuccessfulSave = NSKeyedArchiver.archiveRootObject(checkLists, toFile: ChecklistArchiveURL.path!)
        if !isSuccessfulSave {
            print("Failed to save checklists...")
        }
        isSuccessfulSave = NSKeyedArchiver.archiveRootObject(checkedItems, toFile: CheckedItemArchiveURL.path!)
        if !isSuccessfulSave {
            print("Failed to save checked items..")
        }
    }
    
    static func loadLists() {
        checkLists = []
        if let loadedLists = loadListsHelper() {
            for list in loadedLists {
                putList(list)
            }
        }
        
        if let ci = NSKeyedUnarchiver.unarchiveObjectWithFile(CheckedItemArchiveURL.path!) as? [String: [String : Bool]] {
            checkedItems = ci
        }
    }
    
    static func loadListsHelper() -> [PAUCheckList]? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(ChecklistArchiveURL.path!) as? [PAUCheckList]
    }
    
    // MARK: Archiving Paths
    
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ChecklistArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("checklists")
    static let CheckedItemArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("checkeditems")
}