//
//  AlertModel.swift
//  GroceryPlanner
//
//  Created by Ivana Soric Strize on 03.04.2024..
//

import Foundation

struct AlertModel: Identifiable {
    enum AlertType {
        case upload
        case uploadError
        case uploadComplete
        case download
        case downloadError
        case downloadComplete
    }
    
    var id = UUID()
    var type: AlertType
    var message: String
    
    var title: String {
        switch type {
        case .upload:
            return "Upload to Server"
        case .uploadError:
            return "Upload Error"
        case .uploadComplete:
            return "Upload Complete"
        case .download:
            return "Download from Server"
        case .downloadError:
            return "Download Error"
        case .downloadComplete:
            return "Download Complete"
        }
    }
    
    var hasCancelButton: Bool {
        switch type {
        case .upload, .download:
            return true
        default:
            return false
        }
    }
}
