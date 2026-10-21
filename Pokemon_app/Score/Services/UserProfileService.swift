//
//  UserProfileService.swift
//  Pokemon_app
//
//  Created by ManhLe on 10/21/26.
//
import Foundation
@Observable
class UserProfileStore {
    var currentProfile : UserProfile?
    init (){
        self.currentProfile = UserProfile(
                    userName: "le viet manh",
                    favouritePokemons: []
                )
        
    }
    func addNewFavo(_ name: String, _ url: String) {
        if isFavorite(name: name) { return }
        let newPoke = PokemonRaw(name: name, url: url)
        currentProfile?.favouritePokemons.append(newPoke)
    }
    
    func deleteFavo(_ name: String) {
        currentProfile?.favouritePokemons.removeAll { $0.name.lowercased() == name.lowercased() }
    }
    
    func isFavorite(name: String) -> Bool {
        guard let list = currentProfile?.favouritePokemons else { return false }
        return list.contains { $0.name.lowercased() == name.lowercased() }
    }
    
    func toggleFavourite(name: String, url: String) {
        if isFavorite(name: name) {
            deleteFavo(name)
        } else {
            addNewFavo(name, url)
        }
    }
    
}
