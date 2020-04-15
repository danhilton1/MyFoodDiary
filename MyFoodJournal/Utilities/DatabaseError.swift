//
//  DatabaseError.swift
//  MyFoodJournal
//
//  Created by Daniel Hilton on 06/04/2020.
//  Copyright © 2020 Daniel Hilton. All rights reserved.
//

import Foundation

enum DatabaseError: String, Error {
    case invalidBarcode = "Unable to retrieve information for this barcode. Please try again or try searching for the item."
    case unableToComplete = "Unable to complete your request. Please check your internet connection."
    case invalidResponse = "Invalid response from the server. Please try again."
    case unableToFindItem = "Unable to find any matching items. Please try broadening your keywords or enter the details manually."
    case unableToDownloadItems = "There was an error retrieving your data. Please check your internet connection and try again."
}
