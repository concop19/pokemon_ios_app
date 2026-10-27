//
//  FavoriteView.swift
//  Pokemon_app
//
//  Created by ManhLe on 10/27/26.
//

import SwiftUI
import ComposableArchitecture

struct FavoriteView: View {
    @Bindable var store: StoreOf<FavoriteReducer>
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // 1. Nền tối bao phủ toàn màn hình chuẩn như Pokedex
            Color(red: 0.08, green: 0.09, blue: 0.11)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 2. Custom Top Header (Nút Back + Tiêu đề)
                topHeaderView
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 12)
                
                // 3. Thanh tìm kiếm (Search Bar)
                searchBarView
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                
                // 4. Khu vực nội dung chính
                mainContentView
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            store.send(.onAppear)
        }
    }
    
    // MARK: - 1. Top Header View (Giống Pokedex)
    private var topHeaderView: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 42, height: 42)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Yêu thích")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Text(store.isSearching ? "Tìm kiếm trong mục yêu thích" : "\(store.favorites.count) Pokémon đã lưu")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
            }
            .padding(.leading, 8)
            
            Spacer()
        }
    }
    
    // MARK: - 2. Search Bar View (Giống Pokedex)
    private var searchBarView: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.gray)
            
            TextField(
                "Tìm kiếm theo tên hoặc ID...",
                text: $store.searchQuery.sending(\.searchQueryChanged)
            )
            .foregroundStyle(.white)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            
            if !store.searchQuery.isEmpty {
                Button {
                    store.send(.searchQueryChanged(""))
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.gray)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
    
    // MARK: - 3. Main Content View
    @ViewBuilder
    private var mainContentView: some View {
        if store.isLoading && store.favorites.isEmpty {
            loadingStateView
        } else if store.favorites.isEmpty {
            emptyFavoritesView
        } else {
            let displayList = store.filteredFavorites
            
            if store.isSearching && displayList.isEmpty {
                emptySearchResultView
            } else {
                favoriteListView(displayList: displayList)
            }
        }
    }
    
    // MARK: - 4. Loading State View
    private var loadingStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            ProgressView()
                .tint(.white)
                .scaleEffect(1.2)
            
            Text("Đang tải danh sách yêu thích...")
                .font(.subheadline)
                .foregroundStyle(.gray)
            Spacer()
        }
    }
    
    // MARK: - 5. Empty Favorites View (Khi chưa lưu con nào)
    private var emptyFavoritesView: some View {
        VStack(spacing: 14) {
            Spacer()
            Image(systemName: "heart.slash.fill")
                .font(.system(size: 52))
                .foregroundStyle(.red.opacity(0.6))
            
            Text("Chưa có Pokémon yêu thích")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            
            Text("Nhấn vào biểu tượng trái tim ở màn hình chi tiết để lưu Pokémon vào đây nhé!")
                .font(.subheadline)
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 36)
            Spacer()
        }
    }
    
    // MARK: - 6. Empty Search Result View
    private var emptySearchResultView: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 44))
                .foregroundStyle(.gray.opacity(0.6))
            
            Text("Không tìm thấy Pokémon")
                .font(.headline)
                .foregroundStyle(.white)
            
            Text("Không có Pokémon nào khớp với \"\(store.searchQuery)\"")
                .font(.subheadline)
                .foregroundStyle(.gray)
                .padding(.horizontal, 32)
                .multilineTextAlignment(.center)
            Spacer()
        }
    }
    
    // MARK: - 7. Danh sách có hỗ trợ Quẹt để Xóa (Swipe to Delete)
    private func favoriteListView(displayList: [favoritePoke]) -> some View {
        List {
            ForEach(displayList) { poke in
                favoriteCardRow(poke: poke)
                    .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        store.send(.pokemonTapped(poke))
                    }
                    // 🔥 QUẸT ĐỂ XÓA (Swipe to Delete)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            store.send(.deleteFavorite(id: poke.id))
                        } label: {
                            Label("Xóa", systemImage: "trash.fill")
                        }
                    }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
    
    // MARK: - 8. Card Pokémon trong danh sách
    private func favoriteCardRow(poke: favoritePoke) -> some View {
        let cardBg = PokemonTheme.cardColor(from: poke.color)
        
        return ZStack(alignment: .trailing) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    // Mã số ID
                    Text("#\(poke.id)")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.85))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(Color.black.opacity(0.15)))
                    
                    // Tên Pokémon
                    Text(poke.name.capitalized)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    // Hướng dẫn vuốt nhẹ
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 10, weight: .bold))
                        Text("Vuốt sang trái để xóa")
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundStyle(.white.opacity(0.6))
                }
                
                Spacer()
            }
            .padding(16)
            
            // Hào quang mờ Pokeball phía sau ảnh
            Circle()
                .fill(Color.white.opacity(0.18))
                .frame(width: 90, height: 90)
                .offset(x: 10, y: 0)
            
            // Ảnh Pokémon 3D
            if let url = URL(string: poke.imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .tint(.white)
                            .frame(width: 85, height: 85)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 95, height: 95)
                            .shadow(color: .black.opacity(0.35), radius: 6, x: 0, y: 4)
                    case .failure:
                        Image(systemName: "questionmark")
                            .font(.title)
                            .foregroundStyle(.white.opacity(0.5))
                            .frame(width: 85, height: 85)
                    @unknown default:
                        EmptyView()
                    }
                }
                .offset(x: -8)
            }
        }
        .frame(height: 110)
        .background(cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: cardBg.opacity(0.35), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        FavoriteView(
            store: Store(
                initialState: FavoriteReducer.State(
                    favorites: [
                        favoritePoke(
                            id: "1",
                            name: "bulbasaur",
                            color: "green",
                            imageUrl: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/1.png"
                        ),
                        favoritePoke(
                            id: "4",
                            name: "charmander",
                            color: "red",
                            imageUrl: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/4.png"
                        ),
                        favoritePoke(
                            id: "25",
                            name: "pikachu",
                            color: "yellow",
                            imageUrl: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/25.png"
                        )
                    ]
                )
            ) {
                FavoriteReducer()
            }
        )
    }
}
