//
//  PokedexReducer.swift
//  Pokemon_app
//
//  Created by ManhLe on 10/21/26.
//
/* xử lí khi thực hiện việc vào màn hình thực hiện 2 request xog xog , check loading nếu loading thì thc hien viec goi api lay 20*/
// moi lan load 4 specie
// luu cache
//check loading status
//thuc hien goi
// scroll-> thuc hien viec goi lay db va update current t doan v
// còn cache co the chi can xu ly luu tru trong thuc the hoac la luu tru trong gi d
// array chinh la luu tru cache o day

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
