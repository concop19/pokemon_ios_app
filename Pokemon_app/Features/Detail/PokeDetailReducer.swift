//
//  PokeDetailReducer.swift
//  Pokemon_app
//
//  Created by ManhLe on 10/26/26.
//

import Foundation
import ComposableArchitecture

@Reducer
struct PokeDetailReducer {
    
    // MARK: - Tab Selection Enum
    enum Tab: String, CaseIterable, Sendable {
        case about = "About"
        case status = "Base Stats"
        case evolution = "Evolution"
        case moves = "Moves"
    }
    
    // MARK: - State
    @ObservableState
    struct State: Equatable {
        let pokemonRaw: PokemonRaw
        
        // Dữ liệu API
        var pokemon: SpecificPokemon?
        var species: SpeciesPokemon?
        var evolutionChain: EvolutionChain?
        
        // Trạng thái tải
        var isPokemonLoading: Bool = true
        var isEvolutionLoading: Bool = false
        var errorMessage: String?
        
        // Quản lý Tab & Hero
        var selectedTab: Tab = .about
        var isFavorite: Bool = false
        
        // Tiện ích lấy màu chủ đạo (theo species.color hoặc fallback màu trung tính)
        var themeColorName: String? {
            species?.color?.name
        }
        
        var idOrName: String {
            if let id = pokemonRaw.id {
                return "\(id)"
            }
            return pokemonRaw.name
        }
    }
    
    // MARK: - Action
    enum Action {
        case onAppear
        case initialDataResponse(Result<(SpecificPokemon, SpeciesPokemon), Error>)
        case evolutionResponse(Result<EvolutionChain, Error>)
        
        case tabSelected(Tab)
        case toggleFavorite
        case retryButtonTapped
        
        // Delegate action cho điều hướng tới Pokemon khác (trong cây tiến hoá)
        case openEvolutionPokemon(NamedAPIResource)
    }
    
    @Dependency(\.apiClient) var apiClient
    
    // MARK: - Reducer Body
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
                
            // MARK: - 1. Mở màn hình: Bắn song song Detail & Species
            case .onAppear:
                guard state.pokemon == nil else { return .none }
                state.isPokemonLoading = true
                state.errorMessage = nil
                
                let targetId = state.idOrName
                return .run { send in
                    do {
                        async let fetchDetail = apiClient.pokemon(targetId)
                        async let fetchSpecies = apiClient.pokemonSpecies(targetId)
                        
                        let result = try await (fetchDetail, fetchSpecies)
                        await send(.initialDataResponse(.success(result)))
                    } catch {
                        await send(.initialDataResponse(.failure(error)))
                    }
                }
                
            // MARK: - 2. Nhận kết quả Detail + Species -> Gọi tiếp Evolution Chain
            case let .initialDataResponse(.success((detail, species))):
                state.isPokemonLoading = false
                state.pokemon = detail
                state.species = species
                
                // Trích xuất chainId từ URL loài để tải cây tiến hoá
                guard let chainId = species.evolutionChain.id else {
                    return .none
                }
                
                state.isEvolutionLoading = true
                return .run { send in
                    await send(.evolutionResponse(
                        Result { try await apiClient.evolutionChain(chainId) }
                    ))
                }
                
            case let .initialDataResponse(.failure(error)):
                state.isPokemonLoading = false
                state.errorMessage = error.localizedDescription
                return .none
                
            // MARK: - 3. Nhận kết quả cây tiến hoá
            case let .evolutionResponse(.success(chain)):
                state.isEvolutionLoading = false
                state.evolutionChain = chain
                return .none
                
            case .evolutionResponse(.failure):
                state.isEvolutionLoading = false
                return .none
                
            // MARK: - 4. Tab & Tương tác
            case let .tabSelected(tab):
                state.selectedTab = tab
                return .none
                
            case .toggleFavorite:
                state.isFavorite.toggle()
                return .none
                
            case .retryButtonTapped:
                state.isPokemonLoading = true
                state.errorMessage = nil
                return .send(.onAppear)
                
            case .openEvolutionPokemon:
                // Parent / NavigationStack sẽ bắt action này để push sang màn tiếp theo
                return .none
            }
        }
    }
}
