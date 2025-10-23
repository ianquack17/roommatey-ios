//
//  ContentView.swift
//  RoomMatey
//
//  Created by Ian Quack on 10/20/25.
//

import SwiftUI

struct ContentView: View {
    
    enum Tab { case Home, Profile, Bulletin, Chores, Grocery }
    
    @State private var selectedTab: Tab = .Home
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ChoresView()
                .tabItem {
                    Label("Chores", systemImage: "dishwasher.fill")
                }
                .tag(Tab.Chores)
            BulletinView()
                .tabItem {
                    Label("Bulletin", systemImage: "note.text")
                }
                .tag(Tab.Bulletin)
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(Tab.Home)
            GroceryView()
                .tabItem {
                    Label("Grocery", systemImage: "carrot.fill")
                }
                .tag(Tab.Grocery)
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
    }
}

#Preview {
    ContentView()
}
