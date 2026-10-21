//
//  Pokemon_appApp.swift
//  Pokemon_app
//
//  Created by ManhLe on 10/20/26.
//

import SwiftUI
import ComposableArchitecture

@main
struct Pokemon_appApp: App {
    @State private var profileStore = UserProfileStore()
    
    var body: some Scene {
        WindowGroup {
            HomeView(
                store: Store(initialState: HomeReducer.State()) {
                    HomeReducer()
                }
            )
            .environment(profileStore)
        }
    }
}
