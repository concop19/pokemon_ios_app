//
//  ApiClient.swift
//  Pokemon_app
//
//  Created by ManhLe on 10/20/26.
//

import Foundation
import ComposableArchitecture

@DependencyClient
nonisolated struct ApiClient: Sendable {
    /// GET /pokemon?limit=&offset= : Danh sách phân trang
    var pokemons: @Sendable (_ limit: Int, _ offset: Int) async throws -> PokemonList
    
    /// GET /pokemon/{id|name} : Detail: ảnh, chỉ số, ability, move
    var pokemon: @Sendable (_ idOrName: String) async throws -> SpecificPokemon
    
    /// GET /pokemon-species/{id|name} : Mô tả, màu, giới tính, trứng, link evolution
    var pokemonSpecies: @Sendable (_ idOrName: String) async throws -> SpeciesPokemon
    
    /// GET /evolution-chain/{id} : Cây tiến hoá
    var evolutionChain: @Sendable (_ id: Int) async throws -> EvolutionChain
    
    /// GET /move/{name} (bonus) : Chi tiết move
    var move: @Sendable (_ name: String) async throws -> MoveDetail
    
    /// GET /type/{name} (bonus) : Lọc theo hệ
    var type: @Sendable (_ name: String) async throws -> TypeDetail
}
extension ApiClient: DependencyKey {
    static let liveValue = Self(
        pokemons: { limit, offset in
            try await ApiService.request(PokemonList.self, from: .listPokemons(limit: limit, offset: offset))
        },
        pokemon: { idOrName in
            try await ApiService.request(SpecificPokemon.self, from: .pokemonDetail(idOrName: idOrName))
        },
        pokemonSpecies: { idOrName in
            try await ApiService.request(SpeciesPokemon.self, from: .pokemonSpecies(idOrName: idOrName))
        },
        evolutionChain: { id in
            try await ApiService.request(EvolutionChain.self, from: .evolutionChain(id: id))
        },
        move: { name in
            try await ApiService.request(MoveDetail.self, from: .moveDetail(name: name))
        },
        type: { name in
            try await ApiService.request(TypeDetail.self, from: .typeDetail(name: name))
        }
    )
}

// MARK: - Dependency Values (TCA)
extension DependencyValues {
    var apiClient: ApiClient {
        get { self[ApiClient.self] }
        set { self[ApiClient.self] = newValue }
    }
}

extension ApiClient: TestDependencyKey {
    static let previewValue = Self()
    static let testValue = Self()
}
