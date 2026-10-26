//
//  AboutView.swift
//  Pokemon_app
//
//  Created by ManhLe on 10/26/26.
//

import SwiftUI

struct AboutView: View {
    let pokemon: SpecificPokemon
    let species: SpeciesPokemon?
    let themeColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // 1. Mô tả loài (Flavor Text sạch sẽ)
            if let species = species, !species.cleanFlavorText.isEmpty {
                Text(species.cleanFlavorText)
                    .font(.subheadline)
                    .lineSpacing(4)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                    .padding(.top, 4)
            }
            
            // 2. Thẻ Kích thước & Cân nặng (Height & Weight Card)
            HStack(spacing: 16) {
                // Chiều cao
                VStack(spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: "ruler")
                            .font(.subheadline)
                            .foregroundStyle(themeColor)
                        Text(pokemon.heightInMeters)
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    Text("Chiều cao")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color(.systemGray6).opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                
                // Cân nặng
                VStack(spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: "scalemass.fill")
                            .font(.subheadline)
                            .foregroundStyle(themeColor)
                        Text(pokemon.weightInKilograms)
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    Text("Cân nặng")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color(.systemGray6).opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            
            // 3. Khả năng đặc biệt (Abilities)
            VStack(alignment: .leading, spacing: 10) {
                Text("Khả năng (Abilities)")
                    .font(.footnote)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                
                HStack(spacing: 8) {
                    ForEach(pokemon.abilities, id: \.ability.name) { item in
                        HStack(spacing: 4) {
                            Text(item.ability.name.replacingOccurrences(of: "-", with: " ").capitalized)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            if item.isHidden == true {
                                Text("Ẩn")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 2)
                                    .background(Color.purple.opacity(0.85))
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .clipShape(Capsule())
                    }
                }
            }
            
            Divider()
                .padding(.vertical, 2)
            
            // 4. Sinh sản & Huấn luyện (Breeding & Training)
            VStack(alignment: .leading, spacing: 14) {
                Text("Thông tin sinh sản & Huấn luyện")
                    .font(.footnote)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                
                // Phân loại (Species Genus)
                if let species = species {
                    aboutRow(title: "Phân loại") {
                        Text(species.englishGenus)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
                
                // Tỷ lệ giới tính
                if let species = species {
                    aboutRow(title: "Giới tính") {
                        if let ratio = species.genderRatio {
                            HStack(spacing: 12) {
                                HStack(spacing: 4) {
                                    Text("♂")
                                        .font(.subheadline.bold())
                                        .foregroundStyle(.blue)
                                    Text(String(format: "%.1f%%", ratio.male))
                                        .font(.subheadline)
                                }
                                HStack(spacing: 4) {
                                    Text("♀")
                                        .font(.subheadline.bold())
                                        .foregroundStyle(.pink)
                                    Text(String(format: "%.1f%%", ratio.female))
                                        .font(.subheadline)
                                }
                            }
                        } else {
                            Text("Không có giới tính (Genderless)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                // Nhóm trứng (Egg Groups)
                if let species = species, !species.eggGroups.isEmpty {
                    aboutRow(title: "Nhóm trứng") {
                        Text(species.eggGroups.map { $0.name.capitalized }.joined(separator: ", "))
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
                
                // Nơi sống (Habitat)
                if let habitat = species?.habitat {
                    aboutRow(title: "Nơi sống") {
                        Text(habitat.name.capitalized)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
                
                // Tỷ lệ bắt (Capture Rate)
                if let species = species {
                    aboutRow(title: "Tỷ lệ bắt") {
                        Text("\(species.captureRate) / 255")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
            }
        }
    }
    
    // Helper dòng thông tin 2 cột cân đối
    @ViewBuilder
    private func aboutRow<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        HStack(alignment: .top) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(width: 100, alignment: .leading)
            
            content()
            
            Spacer()
        }
    }
}

#Preview {
    ScrollView {
        AboutView(
            pokemon: SpecificPokemon(
                id: 1,
                name: "bulbasaur",
                height: 7.0,
                weight: 69.0,
                types: [],
                abilities: [
                    PokemonAbilityEntry(isHidden: false, slot: 1, ability: NamedAPIResource(name: "overgrow", url: "")),
                    PokemonAbilityEntry(isHidden: true, slot: 3, ability: NamedAPIResource(name: "chlorophyll", url: ""))
                ],
                stats: [],
                moves: [],
                sprites: PokemonSprites(frontDefault: nil, frontShiny: nil, other: nil)
            ),
            species: SpeciesPokemon(
                name: "bulbasaur",
                color: NamedAPIResource(name: "green", url: ""),
                flavorTextEntries: [
                    FlavorTextEntry(
                        flavorText: "A strange seed was planted on its back at birth. The plant sprouts and grows with this POKéMON.",
                        language: NamedAPIResource(name: "en", url: "")
                    )
                ],
                genera: [
                    GenusEntry(genus: "Seed Pokémon", language: NamedAPIResource(name: "en", url: ""))
                ],
                genderRate: 1,
                eggGroups: [
                    NamedAPIResource(name: "monster", url: ""),
                    NamedAPIResource(name: "grass", url: "")
                ],
                habitat: NamedAPIResource(name: "grassland", url: ""),
                captureRate: 45,
                evolutionChain: EvolutionChainUrl(url: "")
            ),
            themeColor: Color.green
        )
        .padding(20)
    }
}
