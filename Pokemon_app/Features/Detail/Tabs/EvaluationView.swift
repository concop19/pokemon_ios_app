//
//  EvaluationView.swift
//  Pokemon_app
//
//  Created by ManhLe on 10/26/26.
//

import SwiftUI

struct EvaluationView: View {
    // Dữ liệu mẫu cố định (Fixed Data) để tự triển khai logic sau
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Cây tiến hoá (Fixed Data)")
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
            
            // Mock UI cố định mô phỏng cặp tiến hoá
            VStack(spacing: 12) {
                HStack(spacing: 16) {
                    VStack(spacing: 4) {
                        Circle()
                            .fill(Color(.systemGray5))
                            .frame(width: 54, height: 54)
                            .overlay(Text("🌱").font(.title2))
                        Text("Dạng 1")
                            .font(.caption.bold())
                    }
                    
                    VStack(spacing: 4) {
                        Text("Lv. 16")
                            .font(.caption2.bold())
                            .foregroundStyle(.secondary)
                        Image(systemName: "arrow.right")
                            .font(.caption.bold())
                            .foregroundStyle(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    
                    VStack(spacing: 4) {
                        Circle()
                            .fill(Color(.systemGray5))
                            .frame(width: 54, height: 54)
                            .overlay(Text("🌿").font(.title2))
                        Text("Dạng 2")
                            .font(.caption.bold())
                    }
                }
                .padding(16)
                .background(Color(.systemGray6).opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
    }
}

#Preview {
    EvaluationView()
        .padding(20)
}
