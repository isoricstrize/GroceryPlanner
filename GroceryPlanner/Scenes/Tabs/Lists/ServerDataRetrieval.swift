//
//  ServerDataRetrieval.swift
//  GroceryPlanner
//
//  Created by Ivana Soric Strize on 12.03.2024..
//
//  Struct that contains functions for upload all GroceryLists from app to server and for download uploaded GroceryLists from server.

import Foundation

struct ServerDataRetrieval: Codable {
    var serverUrlString = "https://prototip.online:8080/"
    
    // Returns [GroceryList] from server and status/error message -> if [GroceryList] is empty, error occured
    mutating func getFromServer() async -> (list: [GroceryList], infoMsg: String) {
        guard let url = URL(string: serverUrlString) else {
            return ([], "Invalid URL")
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
                        
            if let decodedData = try? JSONDecoder().decode([GroceryList].self, from: data) {
                return (decodedData, "Your lists were successfully downloaded!")

            }
        } catch {
            return([], error.localizedDescription)
        }
        return ([], "An unexpected error occurred while downloading from the server")
    }
    
    // Sends [GroceryList] to server and return status/error message
    mutating func pushToServer(newList: [GroceryList]) async -> String {
        guard let encoded = try?JSONEncoder().encode(newList) else {
            return "Failed to encode"
        }
        
        let url = URL(string: serverUrlString)!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        do {
            let (data, _) = try await URLSession.shared.upload(for: request, from: encoded)
            let decodedData = try JSONDecoder().decode([GroceryList].self, from: data)
                        
            if (decodedData.count == newList.count) {
                return ""
            }
            
        } catch {
            return error.localizedDescription
        }
        return "An unexpected error occurred while uploading to the server"
    }
    
    
    
}
