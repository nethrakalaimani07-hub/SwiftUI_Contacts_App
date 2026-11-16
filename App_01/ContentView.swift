//
//  ContentView.swift
//  App_01
//
//  Created by Nethra Kalaimani on 23/10/26.
//
//
import SwiftUI

struct ContentView: View {

    @Environment(ContactViewModel.self) private var viewModel: ContactViewModel

    private enum AppTab: Hashable {
        case all
        case favourites
    }

    @State private var selectedTab: AppTab = .all
    
    @State private var allTabID = UUID()
    @State private var favouritesTabID = UUID()

    var body: some View {

        TabView(selection: $selectedTab) {
            
            Tab("All", systemImage: "person.fill", value: AppTab.all) {
                NavigationStack {
                    AllContactsView()
                }
                .tint(Color.appPrimary)
                .id(allTabID)
            }
            
            Tab("Favourites", systemImage: "star.fill", value: AppTab.favourites) {
                NavigationStack {
                    FavouritesView()
                }
                .tint(Color.appPrimary)
                .id(favouritesTabID)
            }
            
        }
        .tabBarMinimizeBehavior(.never)
        .tint(Color.appPrimary)
        .onChange(of: selectedTab) { oldTab, newTab in
            switch oldTab {
            case .all:
                allTabID = UUID()
            case .favourites:
                favouritesTabID = UUID()
            }
        }
    }
}


#Preview {
    ContentView()
}



//
//struct ContentView: View {
//    let viewModel: ContactViewModel
//    @State private var selectedTab: Int = 0
//
//    var body: some View {
//        TabView(selection: $selectedTab) {
//
//            Tab("All", systemImage: "person.fill", value: 1) {
//                NavigationStack {
//                    ContactsView(viewModel: viewModel)
//                }
//            }
//
//            Tab("Favourites", systemImage: "heart.fill", value: 0) {
//                NavigationStack {
//                    FavouritesView(viewModel: viewModel)
//                }
//            }
//        }
//        .tabBarMinimizeBehavior(.never)
//    }
//}



// Deprecated :
/*
TabView {
    ContactsView()
        .tabItem {
            Label("Contacts", systemImage: "person")
        }
    
    FavouritesView()
        .tabItem{
            Label("Favourites", systemImage: "heart.fill")
        }
}
*/
