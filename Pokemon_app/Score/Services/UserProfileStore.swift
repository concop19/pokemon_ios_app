//
//  UserProfileService.swift
//  Pokemon_app
//
//  Created by ManhLe on 10/21/26.
//
import Observation
import Foundation
@Observable
class UserProfileStore {
    var currentProfile: UserProfile?
    
    // Tên file JSON lưu ở Documents
    private let fileName = "FavoritePoke.json"
    
    // Đường dẫn thực tế tới file trong thư mục Documents của App
    private var fileURL: URL {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentDirectory.appendingPathComponent(fileName)
    }
    
    init() {
        self.currentProfile = UserProfile(
            userName: "le viet manh",
            favouritePokemons: []
        )
        
        // Khi mở app, tự động load danh sách từ JSON lên RAM
        loadFavoritesFromFile()
    }
    
    // MARK: - READ: Đọc từ JSON
    func loadFavoritesFromFile() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("File JSON chưa tồn tại, bắt đầu với danh sách rỗng.")
            return
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decodedList = try JSONDecoder().decode([favoritePoke].self, from: data)
            self.currentProfile?.favouritePokemons = decodedList
            print("Đã load thành công \(decodedList.count) pokemon yêu thích từ JSON")
        } catch {
            print(" Lỗi khi đọc file JSON: \(error.localizedDescription)")
        }
    }
    
    // MARK: - CREATE / ADD: Thêm Pokemon mới
    func addNewFavo(id: String, name: String, color: String, imageUrl: String) {
        // Kiểm tra tránh trùng lặp
        if isFavorite(id: id) { return }
        
        let newPoke = favoritePoke(id: id, name: name, color: color, imageUrl: imageUrl)
        
        // 1. Cập nhật trên RAM để giao diện hiển thị ngay lập tức
        currentProfile?.favouritePokemons.append(newPoke)
        
        // 2. Ghi đè lại xuống ổ đĩa
        saveFavoritesToFile()
    }
    
    // MARK: - DELETE: Xóa Pokemon theo ID
    func deleteFavo(id: String) {
        // 1. Cập nhật trên RAM
        currentProfile?.favouritePokemons.removeAll { $0.id == id }
        
        // 2. Ghi đè lại xuống ổ đĩa
        saveFavoritesToFile()
    }
    
    // MARK: - CHECK & TOGGLE
    func isFavorite(id: String) -> Bool {
        guard let list = currentProfile?.favouritePokemons else { return false }
        return list.contains { $0.id == id }
    }
    
    func toggleFavourite(id: String, name: String, color: String, imageUrl: String) {
        if isFavorite(id: id) {
            deleteFavo(id: id)
        } else {
            addNewFavo(id: id, name: name, color: color, imageUrl: imageUrl)
        }
    }
    
    // MARK: - HELPER: Ghi toàn bộ danh sách hiện tại xuống File JSON
    private func saveFavoritesToFile() {
        guard let list = currentProfile?.favouritePokemons else { return }
        
        // Chạy ngầm bằng Task để không bao giờ làm giật/đơ giao diện
        Task(priority: .background) { [fileURL] in
            do {
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted // Định dạng JSON thụt lề đẹp
                let data = try encoder.encode(list)
                
                // options: .atomic giúp tránh hỏng dữ liệu nếu app bị tắt ngang
                try data.write(to: fileURL, options: .atomic)
                print(" Đã lưu thành công danh sách xuống: \(fileURL.lastPathComponent)")
            } catch {
                print("Lỗi khi ghi file JSON: \(error.localizedDescription)")
            }
        }
    }
}
