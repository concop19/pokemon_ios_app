//
//  PokedexView.swift
//  Pokemon_app
//
//  Created by ManhLe on 10/21/26.
//

import SwiftUI
import ComposableArchitecture

struct PokedexView: View {
    @Bindable var store: StoreOf<PokedexReducer>
    @Environment(\.dismiss) private var dismiss
    @Environment(UserProfileStore.self) private var userProfileStore: UserProfileStore?
    
    // Cấu hình lưới 2 cột: Trên màn hình điện thoại hiển thị vừa vặn ~4 thẻ (2x2)
    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]
    
    var body: some View {
        ZStack {
            // 1. Nền tối bao phủ toàn màn hình
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
    
    // MARK: - 1. Top Header View
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
                Text("Pokédex")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Text(store.isSearching ? "Tìm kiếm Pokémon" : "Khám phá danh sách Pokémon")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
            }
            .padding(.leading, 8)
            
            Spacer()
        }
    }
    
    // MARK: - 2. Search Bar View
    private var searchBarView: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.gray)
            
            TextField(
                "Tìm kiếm theo tên...",
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
        if store.isLoading && store.pokemons.isEmpty {
            // Đang tải trang đầu tiên
            loadingStateView
        } else if let error = store.initialError, store.pokemons.isEmpty {
            // Lỗi khi tải trang đầu tiên
            initialErrorView(error: error)
        } else {
            let displayList = store.isSearching ? store.filteredPokemons : store.pokemons
            
            if store.isSearching && displayList.isEmpty {
                // Không tìm thấy kết quả phù hợp
                emptySearchResultView
            } else {
                // Danh sách Grid thẻ Pokémon
                pokemonGridView(displayList: displayList)
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
            
            Text("Đang tải dữ liệu Pokédex...")
                .font(.subheadline)
                .foregroundStyle(.gray)
            Spacer()
        }
    }
    
    // MARK: - 5. Initial Error View
    private func initialErrorView(error: String) -> some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundStyle(.orange)
            
            Text("Không thể tải danh sách Pokémon")
                .font(.headline)
                .foregroundStyle(.white)
            
            Text(error)
                .font(.caption)
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Button {
                store.send(.onAppear)
            } label: {
                Text("Thử lại")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .clipShape(Capsule())
            }
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
            
            Text("Không có kết quả nào khớp với \"\(store.searchQuery)\"")
                .font(.subheadline)
                .foregroundStyle(.gray)
                .padding(.horizontal, 32)
                .multilineTextAlignment(.center)
            Spacer()
        }
    }
    
    // MARK: - 7. Pokémon Grid View
    private func pokemonGridView(displayList: [PokemonRaw]) -> some View {
        ScrollView(showsIndicators: false) {
            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(displayList, id: \.url) { pokemon in
                    let colorName = pokemon.id.flatMap { store.pokemonColor[$0] }
                    let cardBg = PokemonTheme.cardColor(from: colorName)
                    
                    PokeCard(
                        pokemon: pokemon,
                        backgroundColor: cardBg,
                        onTap: {
                            store.send(.pokemonTapped(pokemon))
                        }
                    )
                    // 🔥 Thẻ vừa xuất hiện vào tầm nhìn -> Gửi action lấy màu
                    .onAppear {
                        if let id = pokemon.id {
                            store.send(.cardAppeared(id: id))
                        }
                        
                        // 🔥 Nếu cuộn tới con cuối cùng và không trong chế độ search -> Tải thêm
                        if !store.isSearching && pokemon == store.pokemons.last {
                            store.send(.loadMore)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 4)
            .padding(.bottom, 24)
            
            // Loading Spinner khi tải thêm (Load More)
            if store.isLoadingMore {
                HStack(spacing: 8) {
                    ProgressView()
                        .tint(.white)
                    Text("Đang tải thêm Pokémon...")
                        .font(.footnote)
                        .foregroundStyle(.gray)
                }
                .frame(maxWidth: .infinity)
            } else if store.loadMoreError != nil {
                // Nút thử lại nếu load more bị lỗi mạng
                Button {
                    store.send(.loadMore)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.clockwise")
                        Text("Tải thêm thất bại. Nhấn để thử lại")
                    }
                    .font(.footnote.bold())
                    .foregroundStyle(.orange)
                    .padding(.vertical, 12)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        PokedexView(
            store: Store(
                initialState: PokedexReducer.State(
                    pokemons: [
                        PokemonRaw(name: "bulbasaur", url: "https://pokeapi.co/api/v2/pokemon/1/"),
                        PokemonRaw(name: "charmander", url: "https://pokeapi.co/api/v2/pokemon/4/"),
                        PokemonRaw(name: "squirtle", url: "https://pokeapi.co/api/v2/pokemon/7/"),
                        PokemonRaw(name: "pikachu", url: "https://pokeapi.co/api/v2/pokemon/25/")
                    ],
                    pokemonColor: [
                        1: "green",
                        4: "red",
                        7: "blue",
                        25: "yellow"
                    ]
                )
            ) {
                PokedexReducer()
            } withDependencies: {
                $0.apiClient = .liveValue
            }
        )
    }
    .environment(UserProfileStore())
}

