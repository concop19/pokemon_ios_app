//
//  FavoriteReducer.swift
//  Pokemon_app
//
//  Created by ManhLe on 10/27/26.
//

import Foundation
import ComposableArchitecture

@Reducer
struct FavoriteReducer {
    @ObservableState
    struct State: Equatable {
        var favorites: [favoritePoke] = []
        var isLoading: Bool = false
        var searchQuery: String = ""
        
        var isSearching: Bool {
            !searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        
        var filteredFavorites: [favoritePoke] {
            guard isSearching else { return favorites }
            let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            return favorites.filter { poke in
                poke.name.lowercased().contains(query) || poke.id.lowercased().contains(query)
            }
        }
    }
    
    enum Action {
        case onAppear
        case favoritesLoaded([favoritePoke])
        case searchQueryChanged(String)
        case deleteFavorite(id: String)
        case pokemonTapped(favoritePoke)
    }
    
    @Dependency(\.favoriteClient) var favoriteClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .run { send in
                    let list = (try? await favoriteClient.loadFavorites()) ?? []
                    await send(.favoritesLoaded(list))
                }
                
            case let .favoritesLoaded(list):
                state.isLoading = false
                state.favorites = list
                return .none
                
            case let .searchQueryChanged(query):
                state.searchQuery = query
                return .none
                
            case let .deleteFavorite(id):
                state.favorites.removeAll { $0.id == id }
                return .run { _ in
                    try? await favoriteClient.deleteFavorite(id)
                }
                
            case .pokemonTapped:
                return .none
            }
        }
    }
}
