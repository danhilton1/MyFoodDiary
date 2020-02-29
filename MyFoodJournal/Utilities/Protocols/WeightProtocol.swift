//
//  WeightProtocol.swift
//  MyFoodJournal
//
//  Created by Daniel Hilton on 29/02/2020.
//  Copyright © 2020 Daniel Hilton. All rights reserved.
//

import Foundation

protocol WeightDelegate: class {
    func reloadData(weightEntry: Weight, date: Date?)
}
