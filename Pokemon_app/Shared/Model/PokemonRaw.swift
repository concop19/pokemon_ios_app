//
//  PokemonRaw.swift
//  Pokemon_app
//
//  Created by ManhLe on 10/20/26.
//

import Foundation

struct UserProfile :  Equatable , Sendable {
    var userName : String
    var favouritePokemons : [PokemonRaw]
    
}
// MARK: - 1. Model Resource chuẩn của PokeAPI ({ "name": "...", "url": "..." })
nonisolated struct NamedAPIResource: Sendable, Codable, Hashable {
    let name: String
    let url: String
}

/// Alias cho Pokemon cơ bản trong danh sách
typealias PokemonRaw = NamedAPIResource

extension NamedAPIResource {
    var id: Int? {
        let components = url.trimmingCharacters(in: CharacterSet(charactersIn: "/")).split(separator: "/")
        if let last = components.last, let idVal = Int(last) {
            return idVal
        }
        return nil
    }
    
    var imageUrl: URL? {
        guard let id = id else { return nil }
        return URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(id).png")
    }
}

// MARK: - 2. Danh sách phân trang (GET /pokemon?limit=&offset=)
nonisolated struct PokemonList: Sendable, Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [PokemonRaw]
    
    // Tiện ích alias nếu bạn muốn gọi pokemonRawArr
    var pokemonRawArr: [PokemonRaw] { results }
}

// MARK: - 3. Chi tiết Pokemon (GET /pokemon/{id|name})
nonisolated struct SpecificPokemon: Sendable, Codable {
    let id: Int
    let name: String
    let height: Double
    let weight: Double
    let types: [PokemonTypeEntry]
    let abilities: [PokemonAbilityEntry]
    let stats: [PokemonStatEntry]
    let moves: [PokemonMoveEntry]
    let sprites: PokemonSprites
}

nonisolated struct PokemonTypeEntry: Sendable, Codable {
    let slot: Int
    let type: NamedAPIResource
}

nonisolated struct PokemonAbilityEntry: Sendable, Codable {
    let isHidden: Bool?
    let slot: Int?
    let ability: NamedAPIResource
    
    enum CodingKeys: String, CodingKey {
        case isHidden = "is_hidden"
        case slot, ability
    }
}

nonisolated struct PokemonStatEntry: Sendable, Codable {
    let baseStat: Int
    let effort: Int?
    let stat: NamedAPIResource
    
    enum CodingKeys: String, CodingKey {
        case baseStat = "base_stat"
        case effort, stat
    }
}

nonisolated struct PokemonMoveEntry: Sendable, Codable {
    let move: NamedAPIResource
}

nonisolated struct PokemonSprites: Sendable, Codable {
    let frontDefault: String?
    let frontShiny: String?
    let other: OtherSprites?
    
    enum CodingKeys: String, CodingKey {
        case frontDefault = "front_default"
        case frontShiny = "front_shiny"
        case other
    }
    
    nonisolated struct OtherSprites: Sendable, Codable {
        let officialArtwork: OfficialArtwork?
        
        enum CodingKeys: String, CodingKey {
            case officialArtwork = "official-artwork"
        }
    }
    
    nonisolated struct OfficialArtwork: Sendable, Codable {
        let frontDefault: String?
        
        enum CodingKeys: String, CodingKey {
            case frontDefault = "front_default"
        }
    }
}

// MARK: - 4. Thông tin loài (GET /pokemon-species/{id|name})
nonisolated struct SpeciesPokemon: Sendable, Codable {
    let name: String
    let color: NamedAPIResource?
    let flavorTextEntries: [FlavorTextEntry]
    let genera: [GenusEntry]
    let genderRate: Int
    let eggGroups: [NamedAPIResource]
    let habitat: NamedAPIResource?
    let captureRate: Int
    let evolutionChain: EvolutionChainUrl
    
    enum CodingKeys: String, CodingKey {
        case name, color, genera, habitat
        case genderRate = "gender_rate"
        case captureRate = "capture_rate"
        case eggGroups = "egg_groups"
        case flavorTextEntries = "flavor_text_entries"
        case evolutionChain = "evolution_chain"
    }
}

nonisolated struct FlavorTextEntry: Sendable, Codable {
    let flavorText: String
    let language: NamedAPIResource
    
    enum CodingKeys: String, CodingKey {
        case flavorText = "flavor_text"
        case language
    }
}

nonisolated struct GenusEntry: Sendable, Codable {
    let genus: String
    let language: NamedAPIResource
}

nonisolated struct EvolutionChainUrl: Sendable, Codable {
    let url: String
}

// MARK: - 5. Cây tiến hoá (GET /evolution-chain/{id})
nonisolated struct EvolutionChain: Sendable, Codable {
    let id: Int
    let chain: ChainLink
}

nonisolated struct ChainLink: Sendable, Codable {
    let species: NamedAPIResource
    let evolutionDetails: [EvolutionDetail]
    let evolvesTo: [ChainLink]
    
    enum CodingKeys: String, CodingKey {
        case species
        case evolutionDetails = "evolution_details"
        case evolvesTo = "evolves_to"
    }
}

nonisolated struct EvolutionDetail: Sendable, Codable {
    let minLevel: Int?
    
    enum CodingKeys: String, CodingKey {
        case minLevel = "min_level"
    }
}

// MARK: - 6. Chi tiết Move (GET /move/{name}) - Bonus
nonisolated struct MoveDetail: Sendable, Codable {
    let id: Int
    let name: String
    let power: Int?
    let accuracy: Int?
    let pp: Int?
    let type: NamedAPIResource
    let damageClass: NamedAPIResource?
    let effectEntries: [MoveEffectEntry]
    
    enum CodingKeys: String, CodingKey {
        case id, name, power, accuracy, pp, type
        case damageClass = "damage_class"
        case effectEntries = "effect_entries"
    }
}

nonisolated struct MoveEffectEntry: Sendable, Codable {
    let effect: String
    let shortEffect: String?
    let language: NamedAPIResource
    
    enum CodingKeys: String, CodingKey {
        case effect
        case shortEffect = "short_effect"
        case language
    }
}

// MARK: - 7. Lọc theo Type (GET /type/{name}) - Bonus
nonisolated struct TypeDetail: Sendable, Codable {
    let id: Int
    let name: String
    let pokemon: [TypePokemonEntry]
}

nonisolated struct TypePokemonEntry: Sendable, Codable {
    let slot: Int
    let pokemon: NamedAPIResource
}
