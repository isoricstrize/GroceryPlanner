//
//  GroceryListsView.swift
//  GroceryPlanner
//
//  Created by Ivana Soric Strize on 12.03.2024..
//
//  This view displays a list of GroceryList files. Controls the deletion of the lists and navigates each list to the GroceryItemsView

import SwiftData
import SwiftUI

// Top part of list row (icon, name and checkedItems status)
struct TopListRowView: View {
    @ObservedObject private var settings = Settings.shared

    var listName: String
    var progressBarFilled: Bool
    var checkedStatusText: String
    var longPressedName: Bool
    
    var body: some View {
        let selectedColor = longPressedName ? settings.accentColor : Color.primary
        HStack {
            // List icon
            Image(systemName: "list.bullet.clipboard")
                .foregroundColor(progressBarFilled ? selectedColor.opacity(0.3) : selectedColor)
            
            // List name
            Text(listName)
                .font(.title3)
                .bold()
                .foregroundColor(progressBarFilled ? selectedColor.opacity(0.3) : selectedColor)
                .padding(10)
            
            // Checked/Unchecked items
            Text(checkedStatusText)
                .foregroundColor(progressBarFilled ? selectedColor.opacity(0.3) : selectedColor)
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .trailing)
        }
    }
}

struct GroceryListsView: View {
            
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) var modelContext
    
    @ObservedObject private var settings = Settings.shared
    
    // Contains app GroceryLists
    @Query var groceryLists: [GroceryList]
    
    // Number of checked items in list (groceryItem.isActive = false) connected to the list name
    @State private var checkedStatusValues = [String:Int]()
    // ProgressView values(calculate: checkedItems/items) connected to the list name.
    @State private var progressViewValues = [String:Double]()
    
    // Variables used on long press functionality
    @State private var listNameEditMode = false
    @State private var longPressedindex = -1
    @State private var editableName = ""
        
    init(sortOrder: [SortDescriptor<GroceryList>]) {
        _groceryLists = Query(sort: sortOrder)
    }
    
    var body: some View {
        ZStack {
            List {
                ForEach(groceryLists, id: \.id) { groceryList in
                    let listName = groceryList.name
                    let progressBarValue = getProgressValue(listName: listName)
                    NavigationLink(value: groceryList) {
                        VStack {
                            // Top part of list row (icon, name and checkedItems status)
                            TopListRowView( listName: listName,
                                        progressBarFilled: (progressBarValue == 1.0),
                                        checkedStatusText: getCheckedStatusText(listName: listName,
                                                                                itemsCount: groceryList.groceryItems.count),
                                        longPressedName: (listName == editableName)
                            )
                            .onLongPressGesture {
                                if let index = groceryLists.firstIndex(of: groceryList) {
                                    onLongPressed(listIndex: index)
                                }
                            }
                            
                            // Bottom part of list row (Progress bar)
                            ProgressView(value: progressBarValue)
                                .padding(.bottom)
                                .padding(.top)
                                //.tint(appSettings.accentColor)
                        }
                    }
                }
                .onDelete(perform: removeItems)
                .listRowBackground(colorScheme == .dark ? settings.accentColor.opacity(0.3) : .white)
            }
            .listRowSpacing(10.0)
            
        }
            
        .navigationDestination(for: GroceryList.self) { groceryList in
            GroceryItemsView(groceryList: groceryList)
        }
        .onAppear {
            initializeListView()
        }
        // Used in case when adding new list element (onAppear is not called in that case)
        // Force update progressBarView and checkedItems in list rows
        .onChange(of: groceryLists) { oldLists, newLists in
            if (!oldLists.isEmpty) {
                return
            }
            if (newLists.count != progressViewValues.count) {
                initializeListView()
            }
        }
        // Displayed on Edit button click (from LongPressedView)
        .sheet(isPresented: $listNameEditMode, onDismiss: {
             editableName = ""
         }){
            DetailGroceryListView(editMode: true, editableName: editableName, changeName: { newName in
                if (longPressedindex > -1) {
                    groceryLists[longPressedindex].name = newName
                    initializeListView()
                }
            })
            .presentationDetents([.medium])
        }
    }
    
    // Called on longPressed TopListRowView in list row -> edit list name
    func onLongPressed(listIndex: Int) {
        longPressedindex = listIndex
        editableName = groceryLists[listIndex].name
        if (!editableName.isEmpty) {
            listNameEditMode = true
        }
    }
    
    func removeItems(at offsets: IndexSet) {
        for index in offsets {
            let item = groceryLists[index]
            modelContext.delete(item)
        }
    }
    
    // Controls progressBarViews and checked items count displayed in each list row
    // Force update progressBarView and checkedItems in list rows
    func initializeListView() {
        checkedStatusValues.removeAll()
        progressViewValues.removeAll()
        
        var checked = 0
        var progressValue = Double(0)
        
        for list in groceryLists {
            checked = 0
            for item in list.groceryItems {
                if (!item.isActive) {
                    checked += 1
                }
            }
            checkedStatusValues.updateValue(checked, forKey: list.name)
            
            progressValue = Double(checked) / Double(list.groceryItems.count)
            if (progressValue.isNaN) {
                progressValue = 0.0
            }
            progressViewValues.updateValue(progressValue, forKey: list.name)
        }
    }
    
    func getProgressValue(listName: String) -> Double {
        return progressViewValues[listName] ?? 0.0
    }
    func getCheckedStatusText(listName: String, itemsCount: Int) -> String {
        return "\(checkedStatusValues[listName] ?? 0) / \(itemsCount)"
    }
}


#Preview {
    GroceryListsView(sortOrder: [SortDescriptor(\GroceryList.name)])
}
