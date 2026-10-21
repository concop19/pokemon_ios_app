//
//  UrlConfiguration.swift
//  Pokemon_app
//
//  Created by ManhLe on 10/20/26.
// dinh hinh url va thuc hien cau hinh cac duong dan
import Foundation
nonisolated enum AppConfig {
    static let appName = "Pokemon"
    static let appVersion = "1.0.0"
    // dinh hinh backended url
    static var defaultBackendedUrl : URL {
        if let  backendedUrl = ProcessInfo.processInfo.environment["BACKENDED_URL"]?.trimmingCharacters(in: .whitespacesAndNewlines) , !backendedUrl.isEmpty ,  let url = URL(string: backendedUrl) {
            return url
        }
        return URL(string: "https://pokeapi.co/api/v2/")!
    }
    /*define all url : GET/pokemon?limit=&offset=    Danh sách phân trang    count, next, results[].name, results[].url
     GET/pokemon/{id|name}    Detail: ảnh, chỉ số, ability, move    id, height (dm), weight (hg), types[], abilities[], stats[], moves[], sprites
     GET/pokemon-species/{id|name}    Mô tả, màu, giới tính, trứng, link evolution    color.name, flavor_text_entries[], genera[], gender_rate, egg_groups[], habitat, capture_rate, evolution_chain.url
     GET/evolution-chain/{id}    Cây tiến hoá    chain.species, chain.evolves_to[] (đệ quy), evolution_details[].min_level
     GET/move/{name} bonus    Chi tiết move    power, accuracy, pp, type, damage_class, effect_entries[]
     GET/type/{name} bonus    Lọc theo hệ    pokemon[].pokemon
*/
    
    /*ppending(queryItems: [
     URLQueryItem(name: "limit", value: "\(limit)"),
     URLQueryItem(name: "offset", value: "\(offset)")
 ])*/
    
}
import Foundation

enum Endpoint: Sendable {
    case listPokemons(limit: Int = 20, offset: Int = 0)
    case pokemonDetail(idOrName: String)
    case pokemonSpecies(idOrName: String)
    case evolutionChain(id: Int)
    case moveDetail(name: String)
    case typeDetail(name: String)
    
    var url: URL {
        let baseUrl = AppConfig.defaultBackendedUrl
        switch self {
        case let .listPokemons(limit, offset):
            return baseUrl
                .appending(path: "pokemon")
                .appending(queryItems: [
                    URLQueryItem(name: "limit", value: "\(limit)"),
                    URLQueryItem(name: "offset", value: "\(offset)")
                ])
                
        case let .pokemonDetail(idOrName):
            let formatted = idOrName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            return baseUrl
                .appending(path: "pokemon")
                .appending(path: formatted)
                
        case let .pokemonSpecies(idOrName):
            let formatted = idOrName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            return baseUrl
                .appending(path: "pokemon-species")
                .appending(path: formatted)
                
        case let .evolutionChain(id):
            return baseUrl
                .appending(path: "evolution-chain")
                .appending(path: "\(id)")
                
        case let .moveDetail(name):
            let formatted = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            return baseUrl
                .appending(path: "move")
                .appending(path: formatted)
                
        case let .typeDetail(name):
            let formatted = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            return baseUrl
                .appending(path: "type")
                .appending(path: formatted)
        }
    }
}
