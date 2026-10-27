//
//  PokeDetailView.swift
//  Pokemon_app
//
//  Created by ManhLe on 10/26/26.
//

import SwiftUI
import ComposableArchitecture

struct PokeDetailView: View {
    @Bindable var store: StoreOf<PokeDetailReducer>
    @Environment(\.dismiss) private var dismiss
    @Namespace private var tabAnimation
    
    // Màu chủ đạo theo loài hoặc mặc định
    private var themeColor: Color {
        PokemonTheme.cardColor(from: store.themeColorName)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            // 1. Màu nền toàn màn hình ăn theo Theme Color của Pokémon
            themeColor
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.35), value: themeColor)
            
            // 2. Hình trang trí Pokéball mờ khổng lồ phía sau Header
            GeometryReader { proxy in
                Image(systemName: "circle.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: proxy.size.width * 0.7)
                    .foregroundStyle(.white.opacity(0.12))
                    .position(x: proxy.size.width * 0.75, y: proxy.size.height * 0.22)
            }
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 3. Top Navigation Bar (Nút Back & Nút Yêu thích)
                topNavigationBar
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                
                // 4. Hero Information (Tên, Mã số, Type Chips)
                heroInfoSection
                    .padding(.horizontal, 24)
                    .padding(.top, 4)
                
                // 5. Hero 3D Artwork Image
                heroImageSection
                    .zIndex(1) // Đảm bảo ảnh Pokémon nổi lên trên mép của Bottom Sheet
                
                // 6. Bottom Sheet màu trắng chứa các Tab
                bottomSheetTabsSection
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            store.send(.onAppear)
        }
    }
    
    // MARK: - 1. Top Navigation Bar
    private var topNavigationBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 42, height: 42)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            Button {
                store.send(.toggleFavorite)
            } label: {
                Image(systemName: store.isFavorite ? "heart.fill" : "heart")
                    .font(.system(size: 19, weight: .bold))
                    .foregroundStyle(store.isFavorite ? Color.red : Color.white)
                    .frame(width: 42, height: 42)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Circle())
                    .scaleEffect(store.isFavorite ? 1.15 : 1.0)
                    .animation(.spring(response: 0.25, dampingFraction: 0.5), value: store.isFavorite)
            }
        }
    }
    
    // MARK: - 2. Hero Info (Tên, ID & Types)
    private var heroInfoSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text(store.pokemonRaw.name.capitalized)
                    .font(.system(size: 32, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                
                Spacer()
                
                if let id = store.pokemonRaw.id {
                    Text(String(format: "#%03d", id))
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.85))
                }
            }
            
            // Danh sách hệ (Type Badges)
            if let types = store.pokemon?.types {
                HStack(spacing: 8) {
                    ForEach(types, id: \.type.name) { typeEntry in
                        Text(typeEntry.type.name.capitalized)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 5)
                            .background(Color.white.opacity(0.25))
                            .clipShape(Capsule())
                    }
                }
                .padding(.top, 2)
            }
        }
    }
    
    // MARK: - 3. Hero 3D Artwork Image
    private var heroImageSection: some View {
        ZStack {
            if let imageUrl = store.pokemonRaw.imageUrl {
                AsyncImage(url: imageUrl) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .tint(.white)
                            .frame(height: 200)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(height: 210)
                            .shadow(color: Color.black.opacity(0.35), radius: 16, x: 0, y: 10)
                    case .failure:
                        Image(systemName: "photo")
                            .font(.system(size: 60))
                            .foregroundStyle(.white.opacity(0.5))
                            .frame(height: 200)
                    @unknown default:
                        EmptyView()
                    }
                }
            }
        }
        .frame(height: 210)
        .padding(.bottom, -35) // Đẩy ảnh Pokémon ăn sâu xuống nửa trên của Bottom Sheet tạo hiệu ứng 3D
    }
    
    // MARK: - 4. Bottom Sheet chứa Tab Main
    private var bottomSheetTabsSection: some View {
        VStack(spacing: 0) {
            // Thanh Tab Bar luân phiên
            tabBarHeader
                .padding(.top, 40) // Chừa khoảng trống cho ảnh Hero đè lên
                .padding(.horizontal, 20)
                .padding(.bottom, 14)
            
            Divider()
            
            // Nội dung tab được chọn
            ScrollView(showsIndicators: false) {
                tabContentView
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Color(.systemBackground)
                .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
                .ignoresSafeArea(edges: .bottom)
        )
    }
    
    // MARK: - 5. Segmented Tab Bar Header
    private var tabBarHeader: some View {
        HStack(spacing: 0) {
            ForEach(PokeDetailReducer.Tab.allCases, id: \.self) { tab in
                let isSelected = store.selectedTab == tab
                
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        store.send(.tabSelected(tab))
                    }
                } label: {
                    VStack(spacing: 8) {
                        Text(tab.rawValue)
                            .font(.system(size: 14, weight: isSelected ? .bold : .medium))
                            .foregroundStyle(isSelected ? Color.primary : Color.secondary)
                        
                        // Thanh gạch chân indicator trượt mượt mà
                        ZStack {
                            if isSelected {
                                Capsule()
                                    .fill(themeColor)
                                    .frame(height: 3)
                                    .matchedGeometryEffect(id: "activeTabIndicator", in: tabAnimation)
                            } else {
                                Capsule()
                                    .fill(Color.clear)
                                    .frame(height: 3)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    // MARK: - 6. Nội dung Tab
    @ViewBuilder
    private var tabContentView: some View {
        if store.isPokemonLoading {
            VStack(spacing: 12) {
                ProgressView()
                    .scaleEffect(1.2)
                    .tint(themeColor)
                Text("Đang tải thông tin Pokémon...")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 50)
        } else if let error = store.errorMessage {
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.orange)
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                Button {
                    store.send(.retryButtonTapped)
                } label: {
                    Label("Thử lại", systemImage: "arrow.clockwise")
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(themeColor)
                        .clipShape(Capsule())
                }
            }
            .padding(.top, 40)
        } else if let pokemon = store.pokemon {
            switch store.selectedTab {
            case .about:
                AboutView(
                    pokemon: pokemon,
                    species: store.species,
                    themeColor: themeColor
                )
                
            case .status:
                StatusView(
                    pokemon: pokemon,
                    themeColor: themeColor
                )
                
            case .evolution:
                EvaluationView(evolutionChain: store.evolutionChain,
                               currentPokemonName: store.pokemonRaw.name,
                               themeColor: themeColor,
                               isLoading: store.isEvolutionLoading,
                               onSelectPokemon: { selectedSpecies in
                    // Gửi action mở Pokémon này lên Navigation Stack!
                    store.send(.openEvolutionPokemon(selectedSpecies))})
                
            case .moves:
                MovesView()
            }
        }
    }
}

// MARK: - Preview
#Preview("Bulbasaur - Loaded") {
    PokeDetailView(
        store: Store(
            initialState: PokeDetailReducer.State(
                pokemonRaw: PokemonRaw(
                    name: "bulbasaur",
                    url: "https://pokeapi.co/api/v2/pokemon/1/"
                ),
                pokemon: SpecificPokemon(
                    id: 1,
                    name: "bulbasaur",
                    height: 7.0,
                    weight: 69.0,
                    types: [
                        PokemonTypeEntry(slot: 1, type: NamedAPIResource(name: "grass", url: "https://pokeapi.co/api/v2/type/12/")),
                        PokemonTypeEntry(slot: 2, type: NamedAPIResource(name: "poison", url: "https://pokeapi.co/api/v2/type/4/"))
                    ],
                    abilities: [
                        PokemonAbilityEntry(isHidden: false, slot: 1, ability: NamedAPIResource(name: "overgrow", url: "")),
                        PokemonAbilityEntry(isHidden: true, slot: 3, ability: NamedAPIResource(name: "chlorophyll", url: ""))
                    ],
                    stats: [
                        PokemonStatEntry(baseStat: 45, effort: 0, stat: NamedAPIResource(name: "hp", url: "")),
                        PokemonStatEntry(baseStat: 49, effort: 0, stat: NamedAPIResource(name: "attack", url: "")),
                        PokemonStatEntry(baseStat: 49, effort: 0, stat: NamedAPIResource(name: "defense", url: "")),
                        PokemonStatEntry(baseStat: 65, effort: 1, stat: NamedAPIResource(name: "special-attack", url: "")),
                        PokemonStatEntry(baseStat: 65, effort: 0, stat: NamedAPIResource(name: "special-defense", url: "")),
                        PokemonStatEntry(baseStat: 45, effort: 0, stat: NamedAPIResource(name: "speed", url: ""))
                    ],
                    moves: [
                        PokemonMoveEntry(move: NamedAPIResource(name: "vine-whip", url: "")),
                        PokemonMoveEntry(move: NamedAPIResource(name: "tackle", url: "")),
                        PokemonMoveEntry(move: NamedAPIResource(name: "razor-leaf", url: "")),
                        PokemonMoveEntry(move: NamedAPIResource(name: "solar-beam", url: ""))
                    ],
                    sprites: PokemonSprites(frontDefault: nil, frontShiny: nil, other: nil)
                ),
                species: SpeciesPokemon(
                    name: "bulbasaur",
                    color: NamedAPIResource(name: "green", url: ""),
                    flavorTextEntries: [
                        FlavorTextEntry(
                            flavorText: "A strange seed was planted on its back at birth. The plant sprouts and grows with this POKéMON.",
                            language: NamedAPIResource(name: "en", url: "")
                        )
                    ],
                    genera: [
                        GenusEntry(genus: "Seed Pokémon", language: NamedAPIResource(name: "en", url: ""))
                    ],
                    genderRate: 1,
                    eggGroups: [
                        NamedAPIResource(name: "monster", url: ""),
                        NamedAPIResource(name: "grass", url: "")
                    ],
                    habitat: NamedAPIResource(name: "grassland", url: ""),
                    captureRate: 45,
                    evolutionChain: EvolutionChainUrl(url: "https://pokeapi.co/api/v2/evolution-chain/1/")
                ),
                evolutionChain: EvolutionChain(
                    id: 1,
                    chain: ChainLink(
                        species: NamedAPIResource(name: "bulbasaur", url: "https://pokeapi.co/api/v2/pokemon/1/"),
                        evolutionDetails: [],
                        evolvesTo: [
                            ChainLink(
                                species: NamedAPIResource(name: "ivysaur", url: "https://pokeapi.co/api/v2/pokemon/2/"),
                                evolutionDetails: [EvolutionDetail(minLevel: 16, item: nil, trigger: nil)],
                                evolvesTo: [
                                    ChainLink(
                                        species: NamedAPIResource(name: "venusaur", url: "https://pokeapi.co/api/v2/pokemon/3/"),
                                        evolutionDetails: [EvolutionDetail(minLevel: 32, item: nil, trigger: nil)],
                                        evolvesTo: []
                                    )
                                ]
                            )
                        ]
                    )
                ),
                isPokemonLoading: false,
                isEvolutionLoading: false,
                selectedTab: .about
            )
        ) {
            PokeDetailReducer()
        }
    )
}

#Preview("Loading State") {
    PokeDetailView(
        store: Store(
            initialState: PokeDetailReducer.State(
                pokemonRaw: PokemonRaw(
                    name: "charmander",
                    url: "https://pokeapi.co/api/v2/pokemon/4/"
                ),
                isPokemonLoading: true
            )
        ) {
            PokeDetailReducer()
        }
    )
}

