//
//  PokedexView.swift
//  Pokemon_app
//
//  Created by ManhLe on 10/21/26.
//

import SwiftUI
import ComposableArchitecture

struct PokedexView: View {
    let store: StoreOf<PokedexReducer>
    @Environment(UserProfileStore.self) private var userProfileStore: UserProfileStore?
    
    var body: some View {
        ZStack {
            Color(red: 0.08, green: 0.09, blue: 0.11)
                .ignoresSafeArea()
            
            VStack {
                Text("Pokédex")
                    .font(.title.bold())
                    .foregroundStyle(.white)
                
                Text("Khám phá danh sách Pokémon")
                    .foregroundStyle(.gray)
            }
        }
        .navigationTitle("Pokédex")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        PokedexView(
            store: Store(initialState: PokedexReducer.State()) {
                PokedexReducer()
            }
        )
    }
}
