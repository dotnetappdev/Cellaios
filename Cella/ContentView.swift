//
//  ContentView.swift
//  Cella
//
//  Created by david on 13/04/2025.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
       
        TabView {
            // Home Tab – Your existing icon grid menu
            NavigationStack {
                MainMenuView()
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }        .navigationTitle("Dashboard") // <- This adds the title bar


         

            // Customers Tab
            NavigationStack {
                CustomersView()
            }
            .tabItem {
                Label("Profile", systemImage: "person")
            }
            // Customers Tab
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
            // Add more tabs as needed...
        } .preferredColorScheme(.dark)
    }
}

#Preview {
    MainTabView()
}
 
