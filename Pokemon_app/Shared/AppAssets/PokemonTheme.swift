//
//  PokemonTheme.swift
//  Pokemon_app
//
//  Created by ManhLe on 10/21/26.
// định hình pokemon co 10 màu nên ta cần  app theme chỉ có tác dụng với từng case
// ánh xạ dc màu tương ứng


import SwiftUI

enum PokemonTheme {
    // 1. Màu trung tính mặc định khi đang tải hoặc lỗi
    static let neutralCard = Color(red: 0.16, green: 0.18, blue: 0.22)
    
    // 2. Bảng ánh xạ 10 màu chuẩn của PokeAPI sang màu sắc hài hoà cho Card
    static func cardColor(from name: String?) -> Color {
        guard let name = name?.lowercased() else {
            return neutralCard
        }
        
        switch name {
        case "green":
            return Color(red: 0.22, green: 0.58, blue: 0.42) // Xanh lục bảo dịu
        case "red":
            return Color(red: 0.85, green: 0.35, blue: 0.35) // Đỏ san hô
        case "blue":
            return Color(red: 0.28, green: 0.52, blue: 0.82) // Xanh dương đại dương
        case "yellow":
            return Color(red: 0.88, green: 0.70, blue: 0.22) // Vàng ấm (dễ đọc chữ)
        case "purple":
            return Color(red: 0.55, green: 0.35, blue: 0.65) // Tím lavender
        case "brown":
            return Color(red: 0.58, green: 0.42, blue: 0.32) // Nâu đất
        case "pink":
            return Color(red: 0.88, green: 0.48, blue: 0.62) // Hồng phấn
        case "gray":
            return Color(red: 0.40, green: 0.45, blue: 0.50) // Xám đá
        case "white":
            return Color(red: 0.65, green: 0.70, blue: 0.75) // Bạc ánh kim (không bị chìm chữ trắng)
        case "black":
            return Color(red: 0.24, green: 0.26, blue: 0.30) // Đen than (nổi bật trên nền app)
        default:
            return neutralCard
        }
    }
}
