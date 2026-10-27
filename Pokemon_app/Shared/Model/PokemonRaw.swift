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
nonisolated struct NamedAPIResource: Sendable, Codable, Hashable ,Equatable{
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
nonisolated struct SpecificPokemon: Sendable, Codable, Equatable {
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

nonisolated struct PokemonTypeEntry: Sendable, Codable, Equatable {
    let slot: Int
    let type: NamedAPIResource
}

nonisolated struct PokemonAbilityEntry: Sendable, Codable, Equatable {
    let isHidden: Bool?
    let slot: Int?
    let ability: NamedAPIResource
    
    enum CodingKeys: String, CodingKey {
        case isHidden = "is_hidden"
        case slot, ability
    }
}

nonisolated struct PokemonStatEntry: Sendable, Codable, Equatable {
    let baseStat: Int
    let effort: Int?
    let stat: NamedAPIResource
    
    enum CodingKeys: String, CodingKey {
        case baseStat = "base_stat"
        case effort, stat
    }
}

nonisolated struct PokemonMoveEntry: Sendable, Codable, Equatable {
    let move: NamedAPIResource
}

nonisolated struct PokemonSprites: Sendable, Codable, Equatable {
    let frontDefault: String?
    let frontShiny: String?
    let other: OtherSprites?
    
    enum CodingKeys: String, CodingKey {
        case frontDefault = "front_default"
        case frontShiny = "front_shiny"
        case other
    }
    
    nonisolated struct OtherSprites: Sendable, Codable, Equatable {
        let officialArtwork: OfficialArtwork?
        
        enum CodingKeys: String, CodingKey {
            case officialArtwork = "official-artwork"
        }
    }
    
    nonisolated struct OfficialArtwork: Sendable, Codable, Equatable {
        let frontDefault: String?
        
        enum CodingKeys: String, CodingKey {
            case frontDefault = "front_default"
        }
    }
}

// MARK: - 4. Thông tin loài (GET /pokemon-species/{id|name})
nonisolated struct SpeciesPokemon: Sendable, Codable, Equatable {
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

nonisolated struct FlavorTextEntry: Sendable, Codable, Equatable {
    let flavorText: String
    let language: NamedAPIResource
    
    enum CodingKeys: String, CodingKey {
        case flavorText = "flavor_text"
        case language
    }
}

nonisolated struct GenusEntry: Sendable, Codable, Equatable {
    let genus: String
    let language: NamedAPIResource
}

nonisolated struct EvolutionChainUrl: Sendable, Codable, Equatable {
    let url: String
    
    /// Trích xuất chainId từ URL (VD: "https://pokeapi.co/api/v2/evolution-chain/10/" -> 10)
    var id: Int? {
        let components = url.trimmingCharacters(in: CharacterSet(charactersIn: "/")).split(separator: "/")
        if let last = components.last, let idVal = Int(last) {
            return idVal
        }
        return nil
    }
}
// giải thik 
// MARK: - 5. Cây tiến hoá (GET /evolution-chain/{id})
nonisolated struct EvolutionChain: Sendable, Codable, Equatable {
    let id: Int
    let chain: ChainLink
}

nonisolated struct ChainLink: Sendable, Codable, Equatable {
    let species: NamedAPIResource
    let evolutionDetails: [EvolutionDetail]
    let evolvesTo: [ChainLink]
    
    enum CodingKeys: String, CodingKey {
        case species
        case evolutionDetails = "evolution_details"
        case evolvesTo = "evolves_to"
    }
}

nonisolated struct EvolutionDetail: Sendable, Codable, Equatable {
    let minLevel: Int?
    let item: NamedAPIResource?
    let trigger: NamedAPIResource?
    
    enum CodingKeys: String, CodingKey {
        case minLevel = "min_level"
        case item, trigger
    }
    
    /// Diễn giải điều kiện tiến hoá thành chuỗi thân thiện cho UI (VD: "Lv. 36", "Water Stone", "Trade"...)
    var conditionText: String {
        if let minLevel = minLevel {
            return "Lv. \(minLevel)"
        }
        if let item = item {
            return item.name.replacingOccurrences(of: "-", with: " ").capitalized
        }
        if let trigger = trigger, trigger.name != "level-up" {
            return trigger.name.replacingOccurrences(of: "-", with: " ").capitalized
        }
        return "Tiến hoá"
    }
}

// MARK: - Bước chuyển đổi tiến hoá phục vụ UI (From -> To kèm điều kiện & ảnh)
nonisolated struct EvolutionTransition: Sendable, Identifiable, Equatable {
    var id: String { "\(from.name)->\(to.name)" }
    let from: NamedAPIResource
    let to: NamedAPIResource
    let condition: String
}

// MARK: - Helper duyệt cây tiến hoá bằng đệ quy (Recursive Evolution)
nonisolated struct EvolutionStage: Sendable, Equatable {
    let species: NamedAPIResource
    let minLevel: Int?
    
    var name: String { species.name }
    var id: Int? { species.id }
    var imageUrl: URL? { species.imageUrl }
}

extension ChainLink {
    /// 1. Duyệt đệ quy chuỗi tiến hoá tuyến tính:
    /// Ở mỗi cấp lấy thông tin node hiện tại, tiếp tục đệ quy với con đầu tiên (`evolvesTo.first`)
    /// cho tới khi gặp node cuối cùng không còn cấp tiến hoá nào nữa (`evolvesTo.isEmpty`).
    func linearEvolutionChain() -> [EvolutionStage] {
        // tra ve 1 array cac pokemon tien hoa
        let current = EvolutionStage(
            species: species,
            minLevel: evolutionDetails.first?.minLevel
        )
        guard let nextLink = evolvesTo.first else {
            // Điều kiện dừng đệ quy: khi gặp thằng cuối cùng không còn evolvesTo
            return [current]
        }
        return [current] + nextLink.linearEvolutionChain()
    }
    
    /// 2. Đệ quy tìm kiếm: dừng lại ngay khi gặp được Pokemon đầu tiên khớp với tên
    func findFirst(name: String) -> ChainLink? {
        if species.name.caseInsensitiveCompare(name) == .orderedSame {
            return self
        }
        for child in evolvesTo {
            if let found = child.findFirst(name: name) {
                return found
            }
        }
        return nil
    }
    
    /// 3. Đệ quy tìm đường dẫn tiến hoá từ gốc cho tới khi gặp được Pokemon chỉ định
    func pathTo(name: String) -> [EvolutionStage]? {
        let current = EvolutionStage(
            species: species,
            minLevel: evolutionDetails.first?.minLevel
        )
        if species.name.caseInsensitiveCompare(name) == .orderedSame {
            return [current]
        }
        for child in evolvesTo {
            if let subPath = child.pathTo(name: name) {
                return [current] + subPath
            }
        }
        return nil
    }
    
    /// 4. Đệ quy lấy toàn bộ các Pokemon trong cây (hỗ trợ cả các nhánh phân nhánh như Eevee)
    func allEvolutionSpecies() -> [NamedAPIResource] {
        // 🛑 Điều kiện dừng đệ quy: Khi là node lá (không còn cấp tiến hoá nào nữa)
        guard !evolvesTo.isEmpty else {
            return [species]
        }
        return [species] + evolvesTo.flatMap { $0.allEvolutionSpecies() }
    }
    
    /// 5. Đệ quy sinh danh sách các cặp tiến hoá (From -> To kèm điều kiện) để vẽ UI
    /// Xử lý mượt mà cả chuỗi thẳng (Bulbasaur) và chuỗi phân nhánh (Eevee)
    func allTransitions() -> [EvolutionTransition] {
        guard !evolvesTo.isEmpty else { return [] }
        var result: [EvolutionTransition] = []
        for child in evolvesTo {
            let condition = child.evolutionDetails.first?.conditionText ?? "Tiến hoá"
            result.append(EvolutionTransition(from: species, to: child.species, condition: condition))
            result.append(contentsOf: child.allTransitions())
        }
        return result
    }
}

extension EvolutionChain {
    /// Kiểm tra xem Pokemon có tiến hoá hay không (nếu evolvesTo rỗng như Ditto -> false)
    var hasEvolution: Bool {
        !chain.evolvesTo.isEmpty
    }
    
    /// Danh sách các cặp tiến hoá phục vụ vẽ UI (From -> To kèm điều kiện)
    var transitions: [EvolutionTransition] {
        chain.allTransitions()
    }
    
    /// Danh sách các cấp tiến hoá tuyến tính (duyệt bằng đệ quy)
    var linearChain: [EvolutionStage] {
        chain.linearEvolutionChain()
    }
    
    /// Chuỗi hiển thị trực quan: "bulbasaur -> ivysaur (Lv.16) -> venusaur (Lv.32)"
    var displayChain: String {
        linearChain.enumerated().map { index, stage in
            if index == 0 {
                return stage.name
            } else if let level = stage.minLevel {
                return "\(stage.name) (Lv.\(level))"
            } else {
                return stage.name
            }
        }.joined(separator: " -> ")
    }
}

// MARK: - 6. Chi tiết Move (GET /move/{name}) - Bonus
nonisolated struct MoveDetail: Sendable, Codable, Equatable {
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

nonisolated struct MoveEffectEntry: Sendable, Codable, Equatable {
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
nonisolated struct TypeDetail: Sendable, Codable, Equatable {
    let id: Int
    let name: String
    let pokemon: [TypePokemonEntry]
}

nonisolated struct TypePokemonEntry: Sendable, Codable, Equatable {
    let slot: Int
    let pokemon: NamedAPIResource
}

// MARK: - Extension tiện ích cho SpecificPokemon (Tab Stats & Tab About)
extension SpecificPokemon {
    /// Chiều cao đổi sang mét (VD: "0.7 m")
    var heightInMeters: String { String(format: "%.1f m", height / 10.0) }
    
    /// Cân nặng đổi sang kg (VD: "6.9 kg")
    var weightInKilograms: String { String(format: "%.1f kg", weight / 10.0) }
    
    /// Tổng 6 chỉ số Stats
    var totalStats: Int {
        stats.map(\.baseStat).reduce(0, +)
    }
}

// MARK: - Extension tiện ích cho SpeciesPokemon (Tab About)
extension SpeciesPokemon {
    /// Mô tả tiếng Anh đã được làm sạch ký tự xuống dòng \n và ký tự ngắt trang \f
    var cleanFlavorText: String {
        flavorTextEntries
            .first(where: { $0.language.name == "en" })?
            .flavorText
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\u{0C}", with: " ") ?? ""
    }
    
    /// Phân loại Genus tiếng Anh (VD: "Seed Pokémon")
    var englishGenus: String {
        genera.first(where: { $0.language.name == "en" })?.genus ?? "Pokémon"
    }
    
    /// Tỉ lệ giới tính (Đực / Cái): nil là vô tính
    var genderRatio: (male: Double, female: Double)? {
        guard genderRate != -1 else { return nil }
        let femalePercent = (Double(genderRate) / 8.0) * 100.0
        return (male: 100.0 - femalePercent, female: femalePercent)
    }
}
