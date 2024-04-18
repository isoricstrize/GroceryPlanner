//
//  PurchasedItem.swift
//  GroceryPlanner
//
//  Created by Ivana Soric Strize on 20.03.2024..
//

import Foundation
import SwiftData

@Model
class PurchasedItem: Identifiable, Equatable {
    
    var id = UUID()
    var name: String
    var purchaseDate: Date
    var purchaseCount: Int
    
    init(id: UUID = UUID(), name: String, purchaseDate: Date, purchaseCount: Int) {
        self.id = id
        self.name = name
        self.purchaseDate = purchaseDate
        self.purchaseCount = purchaseCount
    }
}
