//
//  ContentView.swift
//  Pokemon_app
//
//  Created by ManhLe on 10/20/26.
//

import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    var body: some View {
        HomeView(
            store: Store(initialState: HomeReducer.State()) {
                HomeReducer()
            }
        )
    }
}

#Preview {
    ContentView()
}
