//
//  PokemonTheme.swift
//  Pokemon_app
//
//  Created by ManhLe on 10/21/26.
//

import SwiftUI

enum PokemonTheme {
    // 1. Màu trung tính mặc định khi đang tải hoặc lỗi
    static let neutralCard = Color(red: 0.16, green: 0.18, blue: 0.22)
    
    // 2. Bảng ánh xạ 10 màu chuẩn của PokeAPI sang màu sắc hài hoà cho Card (chuẩn theo thiết kế)
    static func cardColor(from name: String?) -> Color {
        guard let name = name?.lowercased() else {
            return neutralCard
        }
        
        switch name {
        case "green":
            return Color(red: 0.30, green: 0.72, blue: 0.60) // Xanh lục ngọc (như Bulbasaur trong thiết kế)
        case "red":
            return Color(red: 0.92, green: 0.42, blue: 0.36) // Đỏ san hô ấm (như Charmander)
        case "blue":
            return Color(red: 0.32, green: 0.68, blue: 0.90) // Xanh lam sáng (như Poliwag)
        case "yellow":
            return Color(red: 0.96, green: 0.78, blue: 0.28) // Vàng tươi (như Pikachu)
        case "pink":
            return Color(red: 0.94, green: 0.50, blue: 0.65) // Hồng phấn ngọt (như Jigglypuff)
        case "purple":
            return Color(red: 0.58, green: 0.38, blue: 0.70) // Tím lavender
        case "brown":
            return Color(red: 0.62, green: 0.46, blue: 0.36) // Nâu đất
        case "gray":
            return Color(red: 0.42, green: 0.48, blue: 0.54) // Xám đá
        case "white":
            return Color(red: 0.68, green: 0.74, blue: 0.78) // Bạc kim loại
        case "black":
            return Color(red: 0.25, green: 0.27, blue: 0.32) // Đen than
        default:
            return neutralCard
        }
    }
    
    // 3. Màu cho thanh chỉ số Stats theo ngưỡng (Đỏ khi thấp, Cam khi trung bình, Xanh khi cao)
    static func statBarColor(for value: Int) -> Color {
        if value < 50 {
            return Color(red: 0.95, green: 0.35, blue: 0.35) // Đỏ (< 50)
        } else if value < 90 {
            return Color(red: 0.98, green: 0.72, blue: 0.28) // Cam / Vàng (50...89)
        } else {
            return Color(red: 0.30, green: 0.78, blue: 0.45) // Xanh lá (>= 90)
        }
    }
}
