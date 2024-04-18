//
//  SettingsView.swift
//  GroceryPlanner
//
//  Created by Ivana Soric Strize on 21.03.2024..
//
//  Displays SettingsModel data. Contains functionality for dark/light mode change, accent color change and shows most purchased products in graph.

import SwiftUI

struct SettingsView: View {
    // SettingsModel instance
    @StateObject private var settings = Settings.shared
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                Form {
                    // Dark/Light mode toggle
                    Section {
                        Toggle("Dark mode", isOn: $settings.darkModeEnabled)
                    }
                    
                    // Accent color change
                    Section {
                        HStack {
                            Text("Accent color")
                            Spacer()
                            HStack(spacing: 10) {
                                ForEach(settings.accentColors.sorted(by: {$0.key < $1.key}), id:\.key) { key, value in
                                    Circle()
                                        .fill(value)
                                        .frame(width: 20, height: 20)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.primary, lineWidth: settings.accentColor == value ? 3 : 0)
                                        )
                                        .onTapGesture {
                                            settings.accentColor = value
                                            print("COLOR CLICKED \(key)")
                                        }
                                }
                            }
                        }
                    }
                    
                    // Graph section
                    Section {
                        ChartViewController()
                    }
                    .frame(height: geometry.size.height * 0.6)
                    .cornerRadius(10)
                }
                .padding(.top, 50)
                .frame(height: geometry.size.height)
                .navigationTitle("Settings")
                
            }
        }
    }

}

#Preview {
    SettingsView()
}
