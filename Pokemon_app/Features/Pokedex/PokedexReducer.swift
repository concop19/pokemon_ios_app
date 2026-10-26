//
//  PokedexReducer.swift
//  Pokemon_app
//
//  Created by ManhLe on 10/21/26.
//

import ComposableArchitecture
import Foundation

@Reducer
struct PokedexReducer {
    // 💡 Tiêu chí nghiệm thu: Giới hạn tối đa 4 request lấy màu cùng lúc
    static let maxConcurrentColorRequests = 4
    
    @ObservableState
    struct State: Equatable {
        // MARK: - 1. Danh sách & Phân trang
        var pokemons: [PokemonRaw] = []
        var isLoading: Bool = false                  // Loading lần đầu (màn hình chính)
        var isLoadingMore: Bool = false              // Loading khi cuộn tới cuối trang
        var canLoadMore: Bool = true                 // Dừng khi next == nil
        var currentOffset: Int = 0                   // Offset hiện tại (0, 20, 40...)
        
        // MARK: - 2. Màu sắc thẻ (Lazy + Queue)
        var pokemonColor: [Int: String] = [:]        // Cache màu: [ID: "colorName"]
        var inFlightColorRequest: Set<Int> = []      // Các ID đang gửi request (tối đa 4)
        var pendingColorQueue: [Int] = []            // Hàng đợi ID chờ tới lượt
        
        // MARK: - 3. Tìm kiếm
        var searchQuery: String = ""                 // Từ khoá người dùng gõ
        var allPokemonCache: [PokemonRaw]? = nil     // Cache 100k con (chỉ gọi API 1 lần)
        var filteredPokemons: [PokemonRaw] = []      // Danh sách kết quả lọc
        var isSearching: Bool {
            !searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        
        // MARK: - 4. Quản lý lỗi
        var initialError: String? = nil              // Lỗi trang đầu
        var loadMoreError: String? = nil             // Lỗi khi cuộn tải thêm
        
        // MARK: - 5. Detail Selection
        var selectedPokemon: PokemonRaw? = nil       // Pokemon được chọn để mở Detail
    }
    
    enum Action {
        // 1. Danh sách & Phân trang
        case onAppear
        case loadMore
        case pokemonListResponse(Result<PokemonList, Error>)
        
        // 2. Tải màu Lazy cho thẻ
        case cardAppeared(id: Int)
        case colorResponse(id: Int, colorName: String?)
        
        // 3. Tìm kiếm
        case searchQueryChanged(String)
        case searchDatabaseResponse(Result<PokemonList, Error>)
        
        // 4. Mở chi tiết
        case pokemonTapped(PokemonRaw)
    }
    
    // Inject API Client và ContinuousClock
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.continuousClock) var clock
    
    private nonisolated enum CancelID: Hashable, Sendable {
        case search
        case list
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
                
            // MARK: - 1. Vào màn hình / Thử lại trang đầu
            case .onAppear:
                // Nếu đã có data hoặc đang loading thì không gọi lại
                guard state.pokemons.isEmpty, !state.isLoading else { return .none }
                
                state.isLoading = true
                state.initialError = nil
                state.currentOffset = 0
                state.canLoadMore = true
                //  run ở đây chính là. chạy. 1 task vụ ngầm --> ko ảnh hưởng đến giao diện
                //  và đc định dang bằng 1 task. cancel. chính là hủy khi nào ->. khi cùng có task dag chạy r
                /* private nonisolated enum CancelID: Hashable, Sendable {
                 case search
                 case list
             }*/
                return .run { send in
                    await send(.pokemonListResponse(
                        Result { try await apiClient.pokemons(20, 0) }
                    ))
                }
                .cancellable(id: CancelID.list, cancelInFlight: true)
                // thuc hien viec goi  ham co the dc huy trong luc thuc hien
            // MARK: - 2. Cuộn tới cuối trang / Thử lại tải thêm
            case .loadMore:
                // Không tải thêm nếu: đang tìm kiếm, đã hết danh sách, hoặc đang bận loading
                guard !state.isSearching,
                      state.canLoadMore,
                      !state.isLoading,
                      !state.isLoadingMore else {
                    return .none
                }
                
                state.isLoadingMore = true
                state.loadMoreError = nil
                let nextOffset = state.currentOffset + 20
                
                return .run { send in
                    await send(.pokemonListResponse(
                        Result { try await apiClient.pokemons(20, nextOffset) }
                    ))
                }
                
            // MARK: - 3. Nhận phản hồi Danh sách Pokémon (Chung cho trang đầu & tải thêm)
            case let .pokemonListResponse(.success(list)):
                state.isLoading = false
                state.isLoadingMore = false
                state.initialError = nil
                state.loadMoreError = nil
                
                // Tiêu chí đề bài: Dừng khi next == null
                state.canLoadMore = (list.next != nil)
                
                if state.currentOffset == 0 && state.pokemons.isEmpty {
                    // Trang đầu tiên
                    state.pokemons = list.results
                } else {
                    // Tải thêm trang tiếp theo -> nối thêm vào mảng
                    state.pokemons.append(contentsOf: list.results)
                    state.currentOffset += 20
                }
                return .none
                
            case let .pokemonListResponse(.failure(error)):
                state.isLoading = false
                state.isLoadingMore = false
                
                if state.pokemons.isEmpty {
                    state.initialError = error.localizedDescription
                } else {
                    state.loadMoreError = error.localizedDescription
                }
                return .none
                
            // MARK: - 4. Thẻ hiện ra (Lazy Color + Queue tối đa 4)
            case let .cardAppeared(id):
                // Đã có màu trong cache -> Không gọi
                guard state.pokemonColor[id] == nil else { return .none }
                
                // Tiêu chí đề bài: Cuộn nhanh không tạo request trùng cho cùng 1 id
                // chỉ  thực hiện việc hiển thị nếu request cho colỏr id này ch tồn tại
                //  hang doi mau sac. ko ton tai id nay
                guard !state.inFlightColorRequest.contains(id),
                      !state.pendingColorQueue.contains(id) else {
                    return .none
                }
                
                // Nếu chưa đủ 4 request -> Bắn ngay
                if state.inFlightColorRequest.count < Self.maxConcurrentColorRequests {
                    state.inFlightColorRequest.insert(id)
                    return fetchSpeciesColorEffect(id: id)
                } else {
                    // Đã đủ 4 slot -> Xếp vào hàng đợi chờ
                    state.pendingColorQueue.append(id)
                    return .none
                }
                
            case let .colorResponse(id, colorName):
                // Giải phóng slot vừa hoàn thành
                state.inFlightColorRequest.remove(id)
                
                // Lưu vào cache màu
                if let colorName = colorName {
                    state.pokemonColor[id] = colorName
                }
                
                // Lấy thẻ tiếp theo trong hàng đợi ra chạy (nếu có)
                if !state.pendingColorQueue.isEmpty {
                    let nextId = state.pendingColorQueue.removeFirst()
                    state.inFlightColorRequest.insert(nextId)
                    return fetchSpeciesColorEffect(id: nextId)
                }
                return .none
                
            // MARK: - 5. Tìm kiếm (Debounce 300ms + Cache 100k)
            case let .searchQueryChanged(query):
                state.searchQuery = query
                let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
                
                // Bấm nút xoá hoặc xoá hết từ khoá -> Tắt lọc, quay về danh sách phân trang
                guard !trimmed.isEmpty else {
                    state.filteredPokemons = []
                    return .cancel(id: CancelID.search)
                }
                
                // Nếu đã có Cache 100k con trong RAM -> Lọc trực tiếp local siêu tốc
                if let cache = state.allPokemonCache {
                    state.filteredPokemons = cache.filter {
                        $0.name.localizedCaseInsensitiveContains(trimmed)
                    }
                    return .none
                }
                
                // Nếu chưa có Cache -> Debounce 300ms rồi gọi API 1 lần duy nhất
                return .run { send in
                    try await clock.sleep(for: .milliseconds(300))
                    await send(.searchDatabaseResponse(
                        Result { try await apiClient.pokemons(100000, 0) }
                    ))
                }
                .cancellable(id: CancelID.search, cancelInFlight: true)
                
            case let .searchDatabaseResponse(.success(list)):
                // Lưu vào RAM
                state.allPokemonCache = list.results
                
                // Lọc ngay theo từ khoá hiện tại
                let trimmed = state.searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty {
                    state.filteredPokemons = list.results.filter {
                        $0.name.localizedCaseInsensitiveContains(trimmed)
                    }
                }
                return .none
                
            case .searchDatabaseResponse(.failure):
                state.filteredPokemons = []
                return .none
                
            // MARK: - 6. Nhấn vào Thẻ mở Detail
            case let .pokemonTapped(pokemon):
                state.selectedPokemon = pokemon
                return .none
            }
        }
    }
    
    // MARK: - Helper Effect Tải Màu Species
    private func fetchSpeciesColorEffect(id: Int) -> Effect<Action> {
        .run { send in
            let species = try? await apiClient.pokemonSpecies("\(id)")
            await send(.colorResponse(id: id, colorName: species?.color?.name))
        }
    }
}
