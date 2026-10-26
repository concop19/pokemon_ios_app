//
//  PokeCard.swift
//  Pokemon_app
//
//  Created by ManhLe on 10/21/26.
//

import SwiftUI

struct PokeCard: View {
    let name: String
    let id: Int?
    let imageUrl: URL?
    var backgroundColor: Color = PokemonTheme.neutralCard
    var onTap: (() -> Void)? = nil
    
    // Khởi tạo trực tiếp từ PokemonRaw
    init(
        pokemon: PokemonRaw,
        backgroundColor: Color = PokemonTheme.neutralCard,
        onTap: (() -> Void)? = nil
    ) {
        self.name = pokemon.name
        self.id = pokemon.id
        self.imageUrl = pokemon.imageUrl
        self.backgroundColor = backgroundColor
        self.onTap = onTap
    }
    
    // Khởi tạo linh hoạt từ các tham số riêng lẻ (name, id, image, color)
    init(
        name: String,
        id: Int? = nil,
        imageUrl: URL? = nil,
        backgroundColor: Color = PokemonTheme.neutralCard,
        onTap: (() -> Void)? = nil
    ) {
        self.name = name
        self.id = id
        self.imageUrl = imageUrl
        self.backgroundColor = backgroundColor
        self.onTap = onTap
    }
    
    var body: some View {
        Button {
            onTap?()
        } label: {
            VStack(spacing: 6) {
                // 1. Hàng trên: Mã số (#001) và Nút mũi tên mở màn Detail
                HStack {
                    if let id = id {
                        Text(String(format: "#%03d", id))
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.85))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(Color.black.opacity(0.12))
                            )
                    }
                    
                    Spacer()
                    
                    // Nút mũi tên tinh tế theo yêu cầu đề bài
                    Image(systemName: "arrow.right")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white.opacity(0.9))
                        .frame(width: 24, height: 24)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.22))
                        )
                }
                .padding(.horizontal, 4)
                
                // 2. Khu vực trung tâm: Hiệu ứng 3D Pokémon nổi bật tràn ra ngoài vòng tròn
                ZStack {
                    // Vòng tròn hào quang chìm phía sau
                    Circle()
                        .fill(Color.white.opacity(0.18))
                        .frame(width: 95, height: 95)
                    
                    // Ảnh Pokémon 3D phóng lớn (125pt) tràn ra khỏi vòng tròn hào quang -> Tạo hiệu ứng 3D nổi khối
                    if let imageUrl = imageUrl {
                        AsyncImage(url: imageUrl) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .tint(.white)
                                    .frame(height: 120)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 120, height: 120)
                                    // Đổ bóng mềm tạo chiều sâu 3D bay lên khỏi nền thẻ
                                    .shadow(color: .black.opacity(0.35), radius: 10, x: 0, y: 8)
                            case .failure:
                                Image(systemName: "photo")
                                    .font(.title)
                                    .foregroundStyle(.white.opacity(0.5))
                                    .frame(height: 120)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        Image(systemName: "photo")
                            .font(.title)
                            .foregroundStyle(.white.opacity(0.5))
                            .frame(height: 120)
                    }
                }
                .frame(height: 125)
                .padding(.vertical, 2)
                
                // 3. Tên Pokémon: Nổi bật, căn giữa, chữ rõ nét như thiết kế
                Text(name.capitalized)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 1)
                    .padding(.bottom, 4)
            }
            .padding(14)
            .frame(maxWidth: .infinity)
            // Màu nền thẻ chuẩn theo thiết kế Figma (bo tròn góc 22pt, có bóng mờ)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(backgroundColor)
                    .shadow(color: backgroundColor.opacity(0.4), radius: 12, x: 0, y: 6)
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.35), value: backgroundColor)
        .accessibilityLabel("\(name.capitalized), mở chi tiết")
    }
}

#Preview {
    ZStack {
        Color(red: 0.08, green: 0.09, blue: 0.11).ignoresSafeArea()
        
        HStack(spacing: 16) {
            // Thẻ Bulbasaur (xanh lá) chuẩn 3D như hình thiết kế
            PokeCard(
                name: "bulbasaur",
                id: 1,
                imageUrl: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/1.png"),
                backgroundColor: Color(red: 0.28, green: 0.72, blue: 0.60)
            )
            
            // Thẻ Charmander (đỏ san hô) chuẩn 3D như hình thiết kế
            PokeCard(
                name: "charmander",
                id: 4,
                imageUrl: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/4.png"),
                backgroundColor: Color(red: 0.94, green: 0.42, blue: 0.38)
            )
        }
        .padding(.horizontal, 20)
    }
}
