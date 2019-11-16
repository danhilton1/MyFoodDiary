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
    @objc dynamic var dateString: String? //{
//        let formatter = DateFormatter()
//        formatter.dateFormat = "dd MMM YYYY"
//        return formatter.string(from: date)
//    }
    
}
