//
//  GroceryItem.swift
//  GroceryPlanner
//
//  Created by Ivana Soric Strize on 12.03.2024..
//

import Foundation
import SwiftData

enum GroceryCategory: String, Codable, Equatable, CaseIterable {
    case Baby = "Baby"
    case BeautyAndPersonalHygiene = "Beauty & Personal Hygiene"
    case Bakery = "Bakery"
    case Beverages = "Beverages"
    case CerealAndMuesli = "Cereal & Muesli"
    case DairyAndEggs = "Dairy & Eggs"
    case FishAndSeafood = "Fish & Seafood"
    case Frozen = "Frozen"
    case FruitsAndVegetables = "Fruits & Vegetables"
    case GrainsAndPasta = "Grains & Pasta"
    case Health = "Health"
    case HomeBaking = "Home Baking"
    case HouseCleaningProducts = "House Cleaning Products"
    case Meat = "Meat"
    case OilsSpicesAndSauces = "Oils, Spices & Sauces"
    case Pets = "Pets"
    case SnacksAndSweets = "Snacks & Sweets"
    case Other = "Other"
}

enum GroceryUnit: String, Codable, Equatable, CaseIterable {
    case none = "No."
    case kilogram = "kg"
    case gram = "g"
    case liter = "l"
    case mililiter = "ml"
}

@Model
class GroceryItem: Identifiable, Codable, Hashable {
    enum CodingKeys: CodingKey {
        case id, name, category, isActive, quantity, unit, dateAdded, dateChecked, tag
    }
    
    var id = UUID()
    var name: String
    var category: GroceryCategory
    var isActive: Bool
    var quantity: Int
    var unit: GroceryUnit
    var dateAdded: Date
    var tag: String
    
    init(id: UUID = UUID(), name: String, category: GroceryCategory, isActive: Bool, quantity: Int, unit: GroceryUnit, dateAdded: Date, tag: String) {
        self.id = id
        self.name = name
        self.category = category
        self.isActive = isActive
        self.quantity = quantity
        self.unit = unit
        self.dateAdded = dateAdded
        self.tag = tag
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(UUID.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.category = try container.decode(GroceryCategory.self, forKey: .category)
        self.isActive = try container.decode(Bool.self, forKey: .isActive)
        self.quantity = try container.decode(Int.self, forKey: .quantity)
        self.unit = try container.decode(GroceryUnit.self, forKey: .unit)
        self.dateAdded = try container.decode(Date.self, forKey: .dateAdded)
        self.tag = try container.decode(String.self, forKey: .tag)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.id, forKey: .id)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.category, forKey: .category)
        try container.encode(self.isActive, forKey: .isActive)
        try container.encode(self.quantity, forKey: .quantity)
        try container.encode(self.unit, forKey: .unit)
        try container.encode(self.dateAdded, forKey: .dateAdded)
        try container.encode(self.tag, forKey: .tag)
    }
}

