//
//  PokedexReducer.swift
//  Pokemon_app
//
//  Created by ManhLe on 10/21/26.
//
import ComposableArchitecture
import Foundation

@Reducer
struct PokedexReducer {
    @ObservableState
    struct State: Equatable {
        var pokemons: [PokemonRaw] = []
        var isLoading: Bool = false
    }
    
    enum Action {
        case onAppear
        case specificButtonTapped
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
            case .specificButtonTapped:
                return .none
            }
        }
    }
}
