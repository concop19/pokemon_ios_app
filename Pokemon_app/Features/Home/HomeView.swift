//
//  HomeView.swift
//  Pokemon_app
//
//  Created by ManhLe on 10/21/26.
//

import SwiftUI
import ComposableArchitecture

struct HomeView: View {
    @Bindable var store: StoreOf<HomeReducer>
    @State private var selectedTab: Int = 1 // 0: Notifications, 1: Home, 2: User
    
    private var currentUserName: String {
        store.userName
    }
    
    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            ZStack(alignment: .bottom) {
                // Background tối chuẩn như ảnh mẫu
                Color(red: 0.07, green: 0.08, blue: 0.10)
                    .ignoresSafeArea()
                
                // Nội dung chính
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        // 1. Top Header (Menu + Avatar)
                        topHeaderView
                        
                        // 2. Lời chào (Hi! [Name] 👋 + Welcome Back)
                        greetingView
                        
                        // 3. 4 Nút danh mục từ Asset (Pokedex, Moves, Evolution, Locations)
                        categoriesGridView
                        
                        Spacer()
                            .frame(height: 120)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
                
                // 4. Thanh TabBar với Quả cầu Pokeball ở giữa
                customBottomTabBar
            }
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden, for: .navigationBar)
        } destination: { store in
            switch store.case {
            case let .pokedex(pokedexStore):
                PokedexView(store: pokedexStore)
                
            case let .pokeDetail(detailStore):
                PokeDetailView(store: detailStore)
                
            case let .favorite(favoriteStore):
                FavoriteView(store: favoriteStore)
            }
        }
    }
    
    // MARK: - 1. Top Header View
    private var topHeaderView: some View {
        HStack {
            // Nút Menu 3 gạch
            Button {
                // Action mở menu
            } label: {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 42, height: 42)
                    .background(Color.white.opacity(0.06))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            // Nút Yêu thích (Favorites)
            Button {
                store.send(.favoriteButtonTapped)
            } label: {
                Image(systemName: "heart.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.red)
                    .frame(width: 42, height: 42)
                    .background(Color.white.opacity(0.06))
                    .clipShape(Circle())
            }
            
            // Avatar người dùng có viền sáng
            Button {
                selectedTab = 2
            } label: {
                ZStack {
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [Color.yellow, Color.orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 46, height: 46)
                    
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 42, height: 42)
                        .foregroundStyle(.gray.opacity(0.8), .yellow.opacity(0.9))
                        .clipShape(Circle())
                }
            }
        }
    }
    
    // MARK: - 2. Lời chào
    private var greetingView: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Text("Hi! \(currentUserName.capitalized)")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.white)
                
                Text("👋")
                    .font(.system(size: 28))
            }
            
            Text("Welcome Back")
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(.gray)
        }
        .padding(.top, 4)
    }
    
    // MARK: - 3. 4 Nút danh mục sử dụng Component Button & Asset
    private var categoriesGridView: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 14),
                GridItem(.flexible(), spacing: 14)
            ],
            spacing: 14
        ) {
            // 1. Pokedex (Nút Đỏ)
            CategoryButton(
                title: "Pokedex",
                imageName: "red_button",
                tintColor: Color(red: 0.95, green: 0.32, blue: 0.32)
            ) {
                store.send(.pokedexButtonTapped)
            }
            
            // 2. Moves (Nút Vàng/Cam)
            CategoryButton(
                title: "Moves",
                imageName: "yellow_button",
                tintColor: Color(red: 0.98, green: 0.62, blue: 0.15)
            ) {
                store.send(.movesButtonTapped)
            }
            
            // 3. Evolution (Nút Xanh Dương)
            CategoryButton(
                title: "Evolution",
                imageName: "blue_button",
                tintColor: Color(red: 0.25, green: 0.55, blue: 0.98)
            ) {
                store.send(.evaluationButtonTapped)
            }
            
            // 4. Locations (Nút Xanh Lá)
            CategoryButton(
                title: "Locations",
                imageName: "green_button",
                tintColor: Color(red: 0.22, green: 0.75, blue: 0.55)
            ) {
                store.send(.locationButtonTapped)
            }
        }
    }
    
    // MARK: - 4. Custom Bottom TabBar với Quả cầu Pokeball nổi ở giữa
    private var customBottomTabBar: some View {
        ZStack(alignment: .top) {
            // Thanh bar nền mờ
            HStack {
                // Tab 1: Notifications
                tabBarItem(
                    title: "Notifications",
                    icon: "bell.fill",
                    tabIndex: 0
                )
                
                Spacer()
                
                // Chỗ trống cho Pokeball ở giữa
                VStack(spacing: 4) {
                    Spacer()
                        .frame(height: 38)
                    Text("Home")
                        .font(.system(size: 11, weight: selectedTab == 1 ? .bold : .medium))
                        .foregroundStyle(selectedTab == 1 ? .white : .gray)
                }
                .frame(width: 70)
                
                Spacer()
                
                // Tab 3: User
                tabBarItem(
                    title: "User",
                    icon: "person.fill",
                    tabIndex: 2
                )
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(Color(red: 0.12, green: 0.13, blue: 0.16).opacity(0.95))
                    .overlay(
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.6), radius: 20, x: 0, y: 10)
            )
            .padding(.horizontal, 24)
            
            // Quả cầu Pokeball nhô lên cao ở chính giữa
            Button {
                selectedTab = 1
            } label: {
                ZStack {
                    Circle()
                        .fill(Color(red: 0.12, green: 0.13, blue: 0.16))
                        .frame(width: 66, height: 66)
                        .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 4)
                    
                    Image("pokemon_ball")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 58, height: 58)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(selectedTab == 1 ? Color.white.opacity(0.4) : Color.clear, lineWidth: 2)
                        )
                }
            }
            .offset(y: -22)
        }
        .padding(.bottom, 12)
    }
    
    // Nút item cho Bottom Bar
    private func tabBarItem(title: String, icon: String, tabIndex: Int) -> some View {
        Button {
            selectedTab = tabIndex
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: selectedTab == tabIndex ? .bold : .regular))
                    .foregroundStyle(selectedTab == tabIndex ? .white : .gray)
                
                Text(title)
                    .font(.system(size: 11, weight: selectedTab == tabIndex ? .bold : .medium))
                    .foregroundStyle(selectedTab == tabIndex ? .white : .gray)
            }
            .frame(width: 70)
        }
    }
}

// MARK: - Hiệu ứng nhấn nút mượt mà
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    HomeView(
        store: Store(initialState: HomeReducer.State()) {
            HomeReducer()
        }
    )
}
