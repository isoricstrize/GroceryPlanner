//
//  DetailGroceryItemView.swift
//  GroceryPlanner
//
//  Created by Ivana Soric Strize on 12.03.2024..
//
//  View that is called for adding new GroceryItem in list or to edit an existing.

import SwiftData
import SwiftUI

struct DetailGroceryItemView: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var groceryItem: GroceryItem
        
    var body: some View {
        Form {
            Section("Name") {
                TextField("Grocery name", text: $groceryItem.name)
                    .overlay(
                        RoundedRectangle(cornerRadius: 0)
                            .stroke(Color.red, lineWidth: groceryItem.name.isEmptyOrWhitespace() ? 2 : 0)
                    )
            }
            
            Section("Category") {
                Picker("Select category", selection: $groceryItem.category) {
                    ForEach(GroceryCategory.allCases, id:\.self) { category in
                        Text("\(category.rawValue)")
                    }
                }
            }
        
            Section("Quantity") {
                TextField("Quantity", value: $groceryItem.quantity, format: .number)
                    .keyboardType(.decimalPad)
            }
            
            Section("Unit") {
                Picker("Select unit", selection: $groceryItem.unit) {
                    ForEach(GroceryUnit.allCases, id:\.self) { unit in
                        Text("\(unit.rawValue)")
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            Section("Tag") {
                TextField("Tag", text: $groceryItem.tag)
            }
            
            Section {
                Button {
                    dismiss()
                } label: {
                    Text("Close")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(groceryItem.name.isEmptyOrWhitespace())
            }
            .listRowBackground(Color.clear)
            
        }
        
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: GroceryItem.self, configurations: config)
        let groceryItem = GroceryItem(name: "", category: .Other, isActive: true, quantity: 1, unit: .none, dateAdded: .now, tag: "")
        
        return DetailGroceryItemView(groceryItem: groceryItem)
            .modelContainer(container)
    } catch {
        return Text("Failed to create container: \(error.localizedDescription)")
    }
    
}
