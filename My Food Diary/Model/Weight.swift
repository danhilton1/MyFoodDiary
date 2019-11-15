//
//  Weight.swift
//  My Food Diary
//
//  Created by Daniel Hilton on 15/11/2019.
//  Copyright © 2019 Daniel Hilton. All rights reserved.
//

import RealmSwift


class Weight: Object {
    
    @objc dynamic var weight: Double = 0
    @objc dynamic var date: Date = Date()
    
    
}
