//
//  EvaluationView.swift
//  Pokemon_app
//

import SwiftUI

struct EvaluationView: View {
    let evolutionChain: EvolutionChain?
    let currentPokemonName: String
    let themeColor: Color
    let isLoading: Bool
    var onSelectPokemon: ((NamedAPIResource) -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Cây tiến hoá")
                .font(.footnote)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .padding(.top, 4)
            
            if isLoading {
                // 1. TRẠNG THÁI ĐANG TẢI (Loading)
                HStack {
                    Spacer()
                    ProgressView("Đang tải cây tiến hoá...")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 30)
                    Spacer()
                }
            } else if let evolution = evolutionChain {
                if !evolution.hasEvolution {
                    // 2. CASE 1: KHÔNG CÓ TIẾN HOÁ (Ditto, Kangaskhan...)
                    emptyEvolutionView
                } else {
                    // 3. CASE 2 & 3: CÓ TIẾN HOÁ (Chuỗi thẳng Bulbasaur hoặc Phân nhánh Eevee)
                    VStack(spacing: 12) {
                        ForEach(evolution.transitions) { step in
                            transitionCard(step: step)
                        }
                    }
                }
            } else {
                // Không có dữ liệu
                Text("Không thể tải thông tin tiến hoá.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    // MARK: - Giao diện khi Pokémon không có tiến hoá
    private var emptyEvolutionView: some View {
        HStack {
            Spacer()
            VStack(spacing: 10) {
                Image(systemName: "circle.slash")
                    .font(.system(size: 36))
                    .foregroundStyle(.secondary.opacity(0.6))
                
                Text("Pokémon này không có dạng tiến hoá")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 36)
            Spacer()
        }
        .background(Color(.systemGray6).opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
    
    // MARK: - Thẻ cặp tiến hoá: [Form Trước] ──(Điều kiện)──> [Form Sau]
    @ViewBuilder
    private func transitionCard(step: EvolutionTransition) -> some View {
        HStack(spacing: 12) {
            // Pokémon trước
            pokemonItem(resource: step.from)
            
            // Mũi tên và điều kiện ở giữa (Lv. 16, Thunder Stone...)
            VStack(spacing: 4) {
                Text(step.condition)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(themeColor)
            }
            .frame(maxWidth: .infinity)
            
            // Pokémon sau
            pokemonItem(resource: step.to)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color(.systemGray6).opacity(0.55))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
    
    // MARK: - Nút bấm từng Pokémon (Avatar + Tên + Badge Đang xem)
    @ViewBuilder
    private func pokemonItem(resource: NamedAPIResource) -> some View {
        let isCurrent = resource.name.caseInsensitiveCompare(currentPokemonName) == .orderedSame
        
        Button {
            onSelectPokemon?(resource)
        } label: {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(isCurrent ? themeColor.opacity(0.18) : Color(.systemGray5).opacity(0.7))
                        .frame(width: 66, height: 66)
                    
                    if let imageUrl = resource.imageUrl {
                        AsyncImage(url: imageUrl) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 54, height: 54)
                        } placeholder: {
                            ProgressView().scaleEffect(0.6)
                        }
                    }
                }
                .overlay(
                    Circle()
                        .stroke(isCurrent ? themeColor : Color.clear, lineWidth: 2.5)
                )
                
                Text(resource.name.capitalized)
                    .font(.system(size: 12, weight: isCurrent ? .bold : .medium))
                    .foregroundStyle(isCurrent ? themeColor : .primary)
                
                if isCurrent {
                    Text("Đang xem")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(themeColor)
                        .clipShape(Capsule())
                }
            }
            .frame(width: 78)
        }
        .buttonStyle(.plain)
    }
}
