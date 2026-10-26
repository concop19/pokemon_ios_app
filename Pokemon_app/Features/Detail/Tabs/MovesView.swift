//
//  MovesView.swift
//  Pokemon_app
//
//  Created by ManhLe on 10/26/26.
//

import SwiftUI

struct MovesView: View {
    // Dữ liệu mẫu cố định (Fixed Data) để tự triển khai logic sau
    private let fixedMoves = [
        "Tackle", "Vine Whip", "Razor Leaf", "Solar Beam",
        "Leech Seed", "Poison Powder", "Sleep Powder", "Growth"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Chiêu thức (Fixed Data)")
                    .font(.footnote)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                
                Spacer()
                
                Text("Chưa triển khai")
                    .font(.caption2.bold())
                    .foregroundStyle(.orange)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.orange.opacity(0.15))
                    .clipShape(Capsule())
            }
            .padding(.top, 4)
            
            // Lưới mẫu chiêu thức cố định
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(fixedMoves, id: \.self) { move in
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color.gray.opacity(0.6))
                            .frame(width: 6, height: 6)
                        
                        Text(move)
                            .font(.system(size: 13, weight: .medium))
                            .lineLimit(1)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color(.systemGray6).opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
        }
    }
}

#Preview {
    ScrollView {
        MovesView()
            .padding(20)
    }
}
