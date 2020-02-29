//
//  DoubleExtension.swift
//  MyFoodJournal
//
//  Created by Daniel Hilton on 29/02/2020.
//  Copyright © 2020 Daniel Hilton. All rights reserved.
//

import Foundation

extension Double {
    
    mutating func roundToXDecimalPoints(decimalPoints: Int?) -> Double {
        switch decimalPoints {
        case 1:
            return Darwin.round(10 * self) / 10
        case 2:
            return Darwin.round(100 * self) / 100
        case 3:
            return Darwin.round(1000 * self) / 1000
        case 4:
            return Darwin.round(10000 * self) / 10000
        case 5:
            return Darwin.round(100000 * self) / 100000
        case 6:
            return Darwin.round(1000000 * self) / 1000000
        case 7:
            return Darwin.round(10000000 * self) / 10000000
        case 8:
            return Darwin.round(100000000 * self) / 100000000
        case 9:
            return Darwin.round(1000000000 * self) / 1000000000
        case 10:
            return Darwin.round(10000000000 * self) / 10000000000
        default:
            return Darwin.round(self)
            
        }
    }
    
    mutating func removePointZeroEndingAndConvertToString() -> String {
        var numberString = String(self.roundToXDecimalPoints(decimalPoints: 1))

        if numberString.hasSuffix(".0") {
            numberString.removeLast(2)
        }
        return numberString
    }
    
    mutating func roundWholeAndRemovePointZero() -> String {
        let value = Darwin.round(self)
        var valueString = String(value)
        
        if valueString.hasSuffix(".0") {
            valueString.removeLast(2)
        }
        return valueString
    }
}
