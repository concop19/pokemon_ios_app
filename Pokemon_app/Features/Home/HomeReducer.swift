//
//  HomeReducer.swift
//  Pokemon_app
//
//  Created by ManhLe on 10/21/26.
//

// tạo  4 ảnh.  tương đương 4 trạng thái
import ComposableArchitecture
import Foundation
@Reducer
struct HomeReducer {
    @ObservableState
    struct State: Equatable {
        var userName: String = "le viet manh"
        var path = StackState<Path.State>()
    }
    
        
    
enum Action {

case pokedexButtonTapped
case movesButtonTapped
case evaluationButtonTapped
case locationButtonTapped
case path (StackAction< Path.State , Path.Action>)
}
    @Reducer
    enum Path {
        case pokedex(PokedexReducer)
        // case moves(MovesFeature)
        case pokeDetail(PokeDetailReducer)
    }
    var body: some Reducer<State, Action>{
        Reduce { state, action in
            switch action {
          
            case .pokedexButtonTapped:
                state.path.append(.pokedex(PokedexReducer.State()))
                return .none
                
            case .movesButtonTapped, .evaluationButtonTapped, .locationButtonTapped:
                return .none
            case let .path(.element(id: _, action: .pokedex(.pokemonTapped(pokemon)))):
                                state.path.append(.pokeDetail(PokeDetailReducer.State(pokemonRaw: pokemon)))
                                return .none
            
            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}

extension HomeReducer.Path.State: Equatable {}
