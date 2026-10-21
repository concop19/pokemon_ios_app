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
    struct State : Equatable {
       
        var path = StackState<Path.State>()}
    
        
    
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
    }
    var body: some Reducer<State, Action>{
        Reduce { state, action in
            switch action {
          
            case .pokedexButtonTapped:
                state.path.append(.pokedex(PokedexReducer.State()))
                return .none
                
            case .movesButtonTapped, .evaluationButtonTapped, .locationButtonTapped:
                return .none
                
            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}

extension HomeReducer.Path.State: Equatable {}
