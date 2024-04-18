//
//  DetailGroceryListView.swift
//  GroceryPlanner
//
//  Created by Ivana Soric Strize on 12.03.2024..
//
//  View that is called for adding new GroceryList in list or to edit an existing.

import SwiftData
import SwiftUI

struct DetailGroceryListView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
        
    @State private var name = ""
    @State private var groceryItems = []
    
    var editMode = false
    var editableName = ""
    var changeName: (String) -> Void = { _ in  }
        
    var body: some View {
        NavigationStack {
            Form {
   
                Section {
                    TextField("Enter list name", text: $name)
                }
                Section {
                    Button {
                        if (editMode) {
                            changeName(name)
                        } else {
                            let newList = GroceryList(name: name, date: .now, groceryItems: [])
                            modelContext.insert(newList)
                        }
                        
                        dismiss()
                    } label: {
                        Text("Save")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(name.isEmptyOrWhitespace())
                }
                .listRowBackground(Color.clear)
                
            }
            .navigationTitle(editMode ? "Rename list" : "Add new list")
        }
        .onAppear {
            if (editMode) {
                name = editableName
            }
        }
    }
}

#Preview {
    DetailGroceryListView()
}
