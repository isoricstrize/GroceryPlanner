//
//  ChartViewController.swift
//  GroceryPlanner
//
//  Created by Ivana Soric Strize on 20.03.2024..
//
//  View that controls displaying purchased items in bar chart and pie chart view.

import Charts
import SwiftData
import SwiftUI

struct ChartViewController: View {
    enum ChartType {
        case barChart
        case pieChart
    }
    
    @ObservedObject private var settings = Settings.shared

    // Used for fetching 10 most purchased products from DB
    public static var purchasedItemsDescriptor: FetchDescriptor<PurchasedItem> {
        var descriptor = FetchDescriptor<PurchasedItem>(sortBy: [SortDescriptor(\.purchaseCount, order: .reverse)])
        descriptor.fetchLimit = 10
        return descriptor
    }
    // Charts data (10 most purchased products)
    @Query(purchasedItemsDescriptor) var purchasedItems: [PurchasedItem]
    // Current chart type
    @State private var chartType: ChartType = .barChart
        
    var body: some View {
        VStack {
            // Title
            Text("Most purchased products")
                .padding(.bottom)
            
            // Chart change picker
            Picker("Select Chart", selection: $chartType) {
                Text("Bar Chart").tag(ChartType.barChart)
                Text("Pie Chart").tag(ChartType.pieChart)
            }
            .pickerStyle(SegmentedPickerStyle())
            .colorMultiply(settings.accentColor)
            
            // Chart view
            switch chartType {
            case .barChart:
                BarChartView(purchasedItems: purchasedItems)
            case .pieChart:
                PieChartView(purchasedItems: purchasedItems)
            }
            
        }
        .padding()
    }
    
    // Bar chart view
    struct BarChartView: View {
        var purchasedItems: [PurchasedItem]
                
        var body: some View {
            VStack {
                Chart {
                    ForEach(purchasedItems, id: \.self) { item in
                        BarMark(
                            x: .value("Name", item.name),
                            y: .value("Count", item.purchaseCount)
                        )
                        .foregroundStyle(by: .value("Name", item.name))
                    }
                }
                .chartXAxis(.hidden)
                .chartLegend(spacing: 30.0)
            }
        }
    }
    
    // Pie chart view
    struct PieChartView: View {
        var purchasedItems: [PurchasedItem]
        
        @State private var selectedCount: Int?
        @State private var selectedSector: String?
                
        var body: some View {
            
            Chart(purchasedItems, id: \.name) { item in
                SectorMark(
                    angle: .value("Count", item.purchaseCount),
                    outerRadius: (selectedSector == item.name ? 140 : 120),
                    angularInset: 1
                )
                .cornerRadius(5)
                .foregroundStyle(by: .value("Name", item.name))
                .annotation(position: .overlay) {
                    Text(selectedSector == item.name ? "\(item.purchaseCount)" : "")
                        .font(.headline)
                        .foregroundStyle(.black)
                }
                .opacity(selectedSector == nil ? 1.0 : (selectedSector == item.name ? 1.0 : 0.5))
            }
            .chartAngleSelection(value: $selectedCount)
            .onChange(of: selectedCount) { oldValue, newValue in
                if let newValue {
                    selectedSector = findSelectedSector(value: newValue)
                } else {
                    selectedSector = nil
                }
            }
        }
        
        // Used for selecting pie chart parts
        func findSelectedSector(value: Int) -> String? {
            var accumulatedCount = 0
            let item = purchasedItems.first { purchasedItem in
                accumulatedCount += purchasedItem.purchaseCount
                return value <= accumulatedCount
            }
            return item?.name
        }
    }
    
    
    
}

#Preview {
    ChartViewController()
}
