//
//  ContentView.swift
//  GroceryPlanner
//
//  Created by Ivana Soric Strize on 12.03.2024..
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var settings = Settings.shared

    var body: some View {
        
        TabView {
            GroceryListsController()
                .tabItem {
                    Label("Lists", systemImage: "list.dash")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
        .accentColor(settings.accentColor)
        .tint(settings.accentColor)
        .preferredColorScheme(settings.darkModeEnabled ? .dark : .light)
    }
}

#Preview {
    ContentView()
}
