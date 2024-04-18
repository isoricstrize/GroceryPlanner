//
//  GroceryList.swift
//  GroceryPlanner
//
//  Created by Ivana Soric Strize on 12.03.2024..
//

import Foundation
import SwiftData

@Model
class GroceryList: Identifiable, Codable, Hashable, Equatable {
    enum CodingKeys: CodingKey {
        case id, name, date, groceryItems
    }
    
    var id = UUID()
    var name: String
    var date: Date
    @Relationship(deleteRule: .cascade) var groceryItems: [GroceryItem]
    
    init(id: UUID = UUID(), name: String, date: Date, groceryItems: [GroceryItem]) {
        self.id = id
        self.name = name
        self.date = date
        self.groceryItems = groceryItems
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(UUID.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.date = try container.decode(Date.self, forKey: .date)
        self.groceryItems = try container.decode([GroceryItem].self, forKey: .groceryItems)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.id, forKey: .id)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.date, forKey: .date)
        try container.encode(self.groceryItems, forKey: .groceryItems)
    }
}

// Used for checking if string is empty or contains only whitespaces
extension String {
    func isEmptyOrWhitespace() -> Bool {
        if (self.isEmpty) {
            return true
        }
        if (self.trimmingCharacters(in: .whitespaces).isEmpty){
            return true
        }
        return false
    }
}

// Used for app database path
// print(modelContext.sqliteCommand)
extension ModelContext {
    var sqliteCommand: String {
        if let url = container.configurations.first?.url.path(percentEncoded: false) {
            "sqlite3 \"\(url)\""
        } else {
            "No SQLite database found."
        }
    }
}
