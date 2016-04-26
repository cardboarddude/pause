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
    
    static func getLists() -> [PAUCheckList] {
        return checkLists
    }
    
    // Save the provided list against it's name
    static func putList(checkList: PAUCheckList){
        checkLists.append(checkList)
    }
    
    // MARK: NSCoding

    static func saveLists(){
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(checkLists, toFile: PAUCheckList.ArchiveURL.path!)
        if !isSuccessfulSave {
            print("Failed to save checklists...")
        }
    }
    
    static func loadLists() {
        checkLists = []
        if let loadedLists = loadListsHelper() {
            for list in loadedLists {
                putList(list)
            }
        }
    }
    
    static func loadListsHelper() -> [PAUCheckList]? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(PAUCheckList.ArchiveURL.path!) as? [PAUCheckList]
    }
}