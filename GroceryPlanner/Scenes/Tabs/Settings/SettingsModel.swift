//
//  SettingsModel.swift
//  GroceryPlanner
//
//  Created by Ivana Soric Strize on 31.03.2024..
//
//  Contains random settings app data that can be retrieved from all parts of the app. Data is stored in UserDefaults.

import Foundation
import SwiftData
import SwiftUI


// Class that controls the saving of user settings data (from SettingsView) in the UserDefaults
class Settings: ObservableObject {
    public static let shared = Settings()
    
    let defaults = UserDefaults.standard
    let accentColors = ["mint": Color.mint,
                        "cyan": Color.cyan,
                        "purple": Color.purple,
                        "orange": Color.orange,
                        "yellow": Color.yellow]
    
    @Published var darkModeEnabled: Bool {
        didSet {
            defaults.set(darkModeEnabled, forKey: "darkModeEnabled")
        }
    }
    
    @Published var accentColor: Color {
        didSet {
            let colorString = findColorString(for: accentColor)
            defaults.set(colorString, forKey: "accentColor")
        }
    }
        
    init() {
        if defaults.object(forKey: "darkModeEnabled") == nil {
            defaults.set(true, forKey: "darkModeEnabled")
        }
        self.darkModeEnabled = defaults.bool(forKey: "darkModeEnabled")
        
        var defaultColor = Color.mint
        if let colorString = defaults.string(forKey: "accentColor") {
            if let color = accentColors[colorString] {
                defaultColor = color
            }
        }
        self.accentColor = defaultColor
    }
    
    func findColorString(for color: Color) -> String {
        for (key, value) in accentColors {
          if value == color {
             return key
          }
       }
       return ""
    }
}
