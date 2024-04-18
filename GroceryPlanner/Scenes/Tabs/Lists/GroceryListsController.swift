//
//  GroceryListsController.swift
//  GroceryPlanner
//
//  Created by Ivana Soric Strize on 14.03.2024..
//
//  Struct that controls GroceryListView. Controls to sorting of GroceryLists and has functionality for adding a new list. Takes care of uploading and downloading lists from server.

import SwiftData
import SwiftUI

struct GroceryListsController: View {
    @Environment(\.modelContext) var modelContext
    
    // SortDescriptors for app GroceryLists
    @State private var sortOrder = [
        SortDescriptor(\GroceryList.name),
        SortDescriptor(\GroceryList.date),
    ]
    // Server communication
    @State private var serverDataRetrieval = ServerDataRetrieval()
    // Settings this variable opens the sheet with view with DetailGroceryListView
    @State private var showAddNewListView = false
    // Settings this variable opens the alert window
    @State var alertModel: AlertModel?
        
    var body: some View {
        NavigationStack() {
            GroceryListsView(sortOrder: sortOrder)
            .navigationTitle("Grocery Planner")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    
                    // Toolbar button for adding new list
                    Button("Add new list", systemImage: "plus") {
                        showAddNewListView.toggle()
                    }
                    
                    Menu("Sort", systemImage: "ellipsis.circle") {
                        // Sorting list
                        Section() {
                            Picker("Sort", selection: $sortOrder) {
                                Text("Sort by Name")
                                    .tag([
                                        SortDescriptor(\GroceryList.name),
                                        SortDescriptor(\GroceryList.date),
                                    ])
                                Text("Sort by Date Added")
                                    .tag([
                                        SortDescriptor(\GroceryList.date),
                                        SortDescriptor(\GroceryList.name),
                                    ])
                            }
                        }
                        
                        // Server upload/download
                        Section() {
                            Button(action: {
                                alertModel = AlertModel(type: .upload,
                                                        message: "Do you really want to upload current lists to server?")
                            }, label: {
                                Text("Upload to Server")
                                //Label("Upload to Server", systemImage: "square.and.arrow.up")
                            })
                            
                            Button(action: {
                                alertModel = AlertModel(type: .download,
                                                        message: "Do you really want to download lists from server?")
                            }, label: {
                                Text("Download from Server")
                                //Label("Download from Server", systemImage: "square.and.arrow.down")
                            })
                        }
                    }// menu
                }
            }
            // Opens view for creating a new list
            .sheet(isPresented: $showAddNewListView) {
                DetailGroceryListView()
                    .presentationDetents([.medium])
            }
            
            .alert(item: $alertModel) { alert in
                let primaryButton = Alert.Button.default(Text("OK")) {
                    if (alert.type == .upload) {
                        Task {
                            await upload()
                        }
                    } else if (alert.type == .download) {
                        Task {
                            await download()
                        }
                    }
                }
 
                var secondaryButton: Alert.Button? = nil
                if alert.hasCancelButton {
                    secondaryButton = Alert.Button.cancel(Text("Cancel")) {}
                    return Alert(title: Text(alert.title), message: Text(alert.message), primaryButton: primaryButton, secondaryButton: secondaryButton ?? .cancel())
                }
                return Alert(title: Text(alert.title), message: Text(alert.message), dismissButton: primaryButton)
            }
        }
    }
    
    
    func upload() async {
        var groceryLists = [GroceryList]()
        let fetchDescriptor = FetchDescriptor<GroceryList>(sortBy: [SortDescriptor(\GroceryList.date)])
        
        do {
            groceryLists = try modelContext.fetch(fetchDescriptor)
        } catch {
            alertModel = AlertModel(type: .uploadError, message: error.localizedDescription)
            return
        }
        
        if (groceryLists.isEmpty) {
            alertModel = AlertModel(type: .uploadError, message: "There are no lists for upload.")
            return
        }
        
        let errorString = await serverDataRetrieval.pushToServer(newList: groceryLists)
        alertModel = AlertModel(type: errorString.isEmpty ? .uploadComplete : .uploadError,
                                message: errorString.isEmpty ? "Your lists were successfully uploaded!" : errorString)
    }
    
    func download() async {
        let data = await serverDataRetrieval.getFromServer()
        
        if (data.list.isEmpty) {
            alertModel = AlertModel(type: .downloadError, message: data.infoMsg)
            return
        }
        
        print("downloaded lists count: \(data.list.count)")
        for list in data.list {
            modelContext.insert(list)
        }
        alertModel = AlertModel(type: .downloadComplete, message: data.infoMsg)
    }
}



#Preview {
    GroceryListsController()
}
