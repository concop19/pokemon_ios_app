//
//  FavoriteClient.swift
//  Pokemon_app
//
//  Created by ManhLe on 10/27/26.
//

import Foundation
import ComposableArchitecture

// MARK: - 1. TCA Dependency Client
@DependencyClient
nonisolated struct FavoriteClient: Sendable {
    /// Đọc toàn bộ danh sách Pokemon yêu thích từ file JSON
    var loadFavorites: @Sendable () async throws -> [favoritePoke]
    
    /// Kiểm tra xem Pokemon (theo ID hoặc Name) đã được yêu thích chưa
    var isFavorite: @Sendable (_ id: String) async -> Bool = { _ in false }
    
    /// Thêm Pokemon mới vào danh sách và lưu xuống JSON
    var addFavorite: @Sendable (_ poke: favoritePoke) async throws -> Void
    
    /// Xóa Pokemon khỏi danh sách theo ID và cập nhật file JSON
    var deleteFavorite: @Sendable (_ id: String) async throws -> Void
}

// MARK: - 2. Thread-Safe Internal Storage Actor
private actor FavoriteStorage {
    static let shared = FavoriteStorage()
    
    private let fileName = "FavoritePoke.json"
    
    private var fileURL: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsDirectory.appendingPathComponent(fileName)
    }
    
    func read() -> [favoritePoke] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return []
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode([favoritePoke].self, from: data)
        } catch {
            print("❌ [FavoriteClient] Lỗi đọc JSON: \(error.localizedDescription)")
            return []
        }
    }
    
    func write(_ list: [favoritePoke]) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(list)
        try data.write(to: fileURL, options: .atomic)
        print("💾 [FavoriteClient] Đã lưu thành công \(list.count) pokemon xuống file: \(fileURL.path)")
    }
    
    func isFavorite(id: String) -> Bool {
        let currentList = read()
        return currentList.contains { $0.id.lowercased() == id.lowercased() }
    }
    
    func add(_ poke: favoritePoke) throws {
        var currentList = read()
        if let index = currentList.firstIndex(where: { $0.id.lowercased() == poke.id.lowercased() }) {
            currentList[index] = poke
        } else {
            currentList.append(poke)
        }
        try write(currentList)
    }
    
    func delete(id: String) throws {
        var currentList = read()
        currentList.removeAll { $0.id.lowercased() == id.lowercased() }
        try write(currentList)
    }
}

// MARK: - 3. Dependency Key Registration
extension FavoriteClient: DependencyKey {
    static let liveValue = Self(
        loadFavorites: {
            await FavoriteStorage.shared.read()
        },
        isFavorite: { id in
            await FavoriteStorage.shared.isFavorite(id: id)
        },
        addFavorite: { poke in
            try await FavoriteStorage.shared.add(poke)
        },
        deleteFavorite: { id in
            try await FavoriteStorage.shared.delete(id: id)
        }
    )
    
    static var previewValue: Self {
        .liveValue
    }
    
    static let testValue = Self()
}

// MARK: - 4. Dependency Values (TCA)
extension DependencyValues {
    var favoriteClient: FavoriteClient {
        get { self[FavoriteClient.self] }
        set { self[FavoriteClient.self] = newValue }
    }
}
