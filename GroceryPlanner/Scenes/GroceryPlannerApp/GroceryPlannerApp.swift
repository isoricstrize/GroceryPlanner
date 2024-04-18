//
//  GroceryPlannerApp.swift
//  GroceryPlanner
//
//  Created by Ivana Soric Strize on 12.03.2024..
//

import SwiftData
import SwiftUI

@main
struct GroceryPlannerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [ GroceryList.self, PurchasedItem.self])
    }
}
