//
//  StatusView.swift
//  Pokemon_app
//
//  Created by ManhLe on 10/26/26.
//

import SwiftUI

struct StatusView: View {
    let pokemon: SpecificPokemon
    let themeColor: Color
    
    // State để tạo hiệu ứng thanh chạy từ 0 đến giá trị thật khi mở tab
    @State private var isAnimated: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Chỉ số cơ bản (Base Stats)")
                .font(.footnote)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .padding(.top, 4)
            
            // 1. Danh sách 6 thanh chỉ số
            VStack(spacing: 14) {
                ForEach(pokemon.stats, id: \.stat.name) { statEntry in
                    statRow(
                        name: formatStatName(statEntry.stat.name),
                        fullName: statEntry.stat.name.capitalized,
                        value: statEntry.baseStat
                    )
                }
                
                Divider()
                    .padding(.vertical, 4)
                
                // 2. Dòng Tổng chỉ số (Total Stats)
                HStack(spacing: 12) {
                    Text("Tổng (Total)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                        .frame(width: 80, alignment: .leading)
                    
                    Text("\(pokemon.totalStats)")
                        .font(.headline)
                        .fontWeight(.heavy)
                        .foregroundStyle(themeColor)
                        .frame(width: 45, alignment: .trailing)
                    
                    Spacer()
                    
                    Text("Min 1 - Max 255")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            
            // 3. Giải thích chú thích (Footnote)
            Text("Mỗi chỉ số được đo trên thang đo tối đa 255 điểm chuẩn của PokeAPI. Màu sắc thể hiện mức độ mạnh yếu của chỉ số: Đỏ (<50), Cam (50-89), Xanh (≥90).")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineSpacing(3)
                .padding(.top, 8)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.65)) {
                isAnimated = true
            }
        }
    }
    
    // MARK: - Row hiển thị 1 chỉ số kèm thanh ngang
    @ViewBuilder
    private func statRow(name: String, fullName: String, value: Int) -> some View {
        let maxStat: Double = 255.0
        let progress = isAnimated ? min(max(Double(value) / maxStat, 0.0), 1.0) : 0.0
        let barColor = PokemonTheme.statBarColor(for: value)
        
        HStack(spacing: 12) {
            // Tên viết tắt
            Text(name)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.secondary)
                .frame(width: 70, alignment: .leading)
            
            // Giá trị số
            Text("\(value)")
                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                .foregroundStyle(.primary)
                .frame(width: 35, alignment: .trailing)
            
            // Thanh tiến trình ngang (Horizontal Progress Bar)
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Nền xám mờ của thanh
                    Capsule()
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                    
                    // Thanh màu chỉ số
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [barColor.opacity(0.85), barColor],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(geometry.size.width * progress, 8), height: 8)
                }
            }
            .frame(height: 8)
        }
        // Accessibility Label đầy đủ thông tin chuẩn yêu cầu đề bài
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(fullName), \(value) trên 255")
        .accessibilityValue("\(value)")
    }
    
    // Chuẩn hoá tên viết tắt các chỉ số quen thuộc của Pokemon
    private func formatStatName(_ name: String) -> String {
        switch name.lowercased() {
        case "hp": return "HP"
        case "attack": return "Attack"
        case "defense": return "Defense"
        case "special-attack": return "Sp. Atk"
        case "special-defense": return "Sp. Def"
        case "speed": return "Speed"
        default: return name.capitalized
        }
    }
}

#Preview {
    StatusView(
        pokemon: SpecificPokemon(
            id: 1,
            name: "bulbasaur",
            height: 7.0,
            weight: 69.0,
            types: [],
            abilities: [],
            stats: [
                PokemonStatEntry(baseStat: 45, effort: 0, stat: NamedAPIResource(name: "hp", url: "")),
                PokemonStatEntry(baseStat: 49, effort: 0, stat: NamedAPIResource(name: "attack", url: "")),
                PokemonStatEntry(baseStat: 49, effort: 0, stat: NamedAPIResource(name: "defense", url: "")),
                PokemonStatEntry(baseStat: 65, effort: 1, stat: NamedAPIResource(name: "special-attack", url: "")),
                PokemonStatEntry(baseStat: 65, effort: 0, stat: NamedAPIResource(name: "special-defense", url: "")),
                PokemonStatEntry(baseStat: 45, effort: 0, stat: NamedAPIResource(name: "speed", url: ""))
            ],
            moves: [],
            sprites: PokemonSprites(frontDefault: nil, frontShiny: nil, other: nil)
        ),
        themeColor: Color(red: 0.30, green: 0.72, blue: 0.60)
    )
    .padding(20)
}
