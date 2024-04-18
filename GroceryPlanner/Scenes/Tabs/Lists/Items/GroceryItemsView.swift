//
//  GroceryItemsView.swift
//  GroceryPlanner
//
//  Created by Ivana Soric Strize on 12.03.2024..
//
//  This view displays a list of GroceryItems for each GroceryList.

import SwiftData
import SwiftUI

// Floating Plus Button used for adding new item in the GroceryItems list
struct FloatingButtonView: View {
    @ObservedObject private var settings = Settings.shared
    var onAddNewItem: (GroceryItem) -> Void
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    // Create new empty item and append it to the groceryList
                    onAddNewItem(GroceryItem(name: "New Item", category: .Other, isActive: true, quantity: 1, unit: .none, dateAdded: .now, tag: ""))
                }, label: {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .foregroundColor(settings.accentColor)
                })
                .padding()
            }
        }
    }
}

struct GroceryItemsView: View {
    @ObservedObject private var settings = Settings.shared
    @Environment(\.modelContext) var modelContext
    
    // Contains last tapped item from GroceryItems list or created empty item on new item click
    // Setting this variable triggers the opening of the sheet with DetailGroceryItemView
    @State private var lastTappedItem: GroceryItem? = nil
    // Used for switch between groups view and list view
    @State private var showGroups = true
    // Current sort option (when showGroups = false -> list view is on)
    @State private var sortOption: SortOption = .name
    // Reload list by updating reloadFlag
    @State private var reloadFlag = false
    
    // Main list that contains all GroceryItems
    var groceryList: GroceryList
    
    // Sort types
    enum SortOption: String, CaseIterable {
        case name = "Sort by Name"
        case dateAdded = "Sort by Date Added"
    }
    
    // Return items sorted by choosen sortOption
    var sortedItems: [GroceryItem] {
        let groceryItems = groceryList.groceryItems
        switch sortOption {
        case .name:
            return groceryItems.sorted(by: { $0.name < $1.name })
        case .dateAdded:
            return groceryItems.sorted(by: { $0.dateAdded > $1.dateAdded })
        }
    }
    
    // All GroceryCategory cases saved in String array
    var groups: [String] {
        if (showGroups) {
            return GroceryCategory.allCases.map { $0.rawValue }
        }
        // List mode view -> no groups, all items in one group "All items"
        return [""]
    }
    
    
    var body: some View {
        ZStack {
            List {
                // Loop for all groups cases (when list view, only one case- > all items)
                ForEach(groups, id: \.self) { groupName in
                    
                    // GroceryItems filtered by current group (group view) or sorted items (list view)
                    let filteredItems = showGroups ? groceryList.groceryItems.filter { $0.category.rawValue == groupName}
                                                    : sortedItems
                                        
                    if (filteredItems.count != 0) {
                        Section(showGroups ? "\(groupName)" : "All items") {
                            ForEach(filteredItems, id: \.self) { groceryItem in
                                let itemIsActive = groceryItem.isActive
                                VStack {
                                    HStack {
                                        // Checked/Unchecked image
                                        Image(systemName: itemIsActive ? "circle" : "circle.inset.filled")
                                            .foregroundColor(settings.accentColor)
                                            .onTapGesture {
                                                if (itemIsActive) {
                                                    // item is checked(or purchased) -> purchased items will be displayed in PurchasedItemsView
                                                    onItemPurchased(groceryItem: groceryItem)
                                                }
                                                groceryItem.isActive.toggle()
                                            }
                                        
                                        // GroceryItem name
                                        Text(groceryItem.name)
                                        
                                        Spacer()
                                        
                                        // GroceryItem quantity and unit
                                        Text("\(groceryItem.quantity) \(groceryItem.unit.rawValue)")
                                            .foregroundColor(Color.secondary)
                                    }
                                    if (!groceryItem.tag.isEmptyOrWhitespace()) {
                                        Text(groceryItem.tag)
                                            .foregroundColor(Color.secondary)
                                            .font(.caption)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.leading, 28)
                                    }
                                }
                                .opacity(itemIsActive ? 1.0 : 0.2)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    // When item is tapped save it in lastTappedItem for displaying in DetailGroceryItemView
                                    if let index = groceryList.groceryItems.firstIndex(of: groceryItem) {
                                        lastTappedItem = groceryList.groceryItems[index]
                                    } else {
                                        print("Index failed")
                                    }
                                }
                            }
                            .onDelete(perform: { indexSet in
                                self.deleteItems(at: indexSet, filtered: filteredItems)
                            })
                        }// section
                    }
                }
                .onChange(of: reloadFlag) { _ , _ in
                    // Reload list by updating reloadFlag
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle(groceryList.name)
            
            // Floating Plus Button used for adding new item in the GroceryItems list
            FloatingButtonView(onAddNewItem: { newItem in
                groceryList.groceryItems.append(newItem)
                if let index = groceryList.groceryItems.firstIndex(of: newItem) {
                    // Opens sheet with DetailGroceryItemView
                    lastTappedItem = groceryList.groceryItems[index]
                } else {
                    print("Index failed")
                }
            })
            
            // Toolbar view
            .toolbar {
                Spacer()
                Spacer()
                
                // Toggle between group and list mode
                Picker("Select items display", selection: $showGroups) {
                    Text("Groups").tag(true)
                    Text("List").tag(false)
                }
                .pickerStyle(SegmentedPickerStyle())
                .colorMultiply(settings.accentColor)
                        
                // Sorting options (only in list mode)
                Menu {
                    Picker("Sort by", selection: $sortOption) {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Text(option.rawValue)
                        }
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                        .foregroundColor(showGroups ? Color.primary : settings.accentColor)
                        .opacity(showGroups ? 0.2 : 1.0)
                }
                .disabled(showGroups)
            }

            // Opens DetailGroceryItemView for item saved in lastTappedItem variable
            .sheet(item: $lastTappedItem,
                   onDismiss: { reloadFlag.toggle()} )
            { item in
                DetailGroceryItemView(groceryItem: item)
            }
        }
    }
    
    func deleteItems(at offsets: IndexSet, filtered: [GroceryItem]) {
        for offset in offsets {
          if let index = groceryList.groceryItems.firstIndex(where: {$0.id == filtered[offset].id}) {
              let deletedItem = groceryList.groceryItems[index]
              modelContext.delete(deletedItem)
              groceryList.groceryItems.removeAll(where: { innerItem in
                  innerItem == deletedItem
              })
          }
        }
    }
    
    // Called when item is purchased (isActive = false) -> purchased items will be displayed in chart in settings
    func onItemPurchased(groceryItem: GroceryItem) {
        print("itemPurchased \(groceryItem.name)")
        var purchasedItems = [PurchasedItem]()
        let fetchDescriptor = FetchDescriptor<PurchasedItem>()
        
        do {
            purchasedItems = try modelContext.fetch(fetchDescriptor)
        } catch {
             print("itemPurchased. Cannot fetch data")
        }
        
        for item in purchasedItems {
            if (item.name.lowercased() == groceryItem.name.lowercased()) {
                let updateItem = PurchasedItem(name: item.name.lowercased(), purchaseDate: .now, purchaseCount: (item.purchaseCount + 1))
                
                modelContext.delete(item)
                modelContext.insert(updateItem)
                return
            }
        }
        // new item added
        modelContext.insert(PurchasedItem(name: groceryItem.name, purchaseDate: .now, purchaseCount: 1))
    }
    
    
    
}

#Preview {
    GroceryItemsView(groceryList: GroceryList(id: UUID(), name: "List name", date:.now, groceryItems: [GroceryItem(name: "", category: .Other, isActive: true, quantity: 1, unit: .none, dateAdded: .now, tag: "")]))
}

