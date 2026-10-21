//
//  ApiClientTests.swift
//  Pokemon_appTests
//
//  Created by ManhLe on 10/21/26.
//

import Testing
import Foundation
@testable import Pokemon_app

struct ApiClientTests {
    
    // MARK: - 1. Test gọi danh sách Pokemon phân trang
    @Test("Kiểm tra lấy danh sách 20 Pokemon đầu tiên từ PokeAPI")
    func testFetchPokemonList() async throws {
        // Given & When: Gọi API lấy 20 Pokemon đầu tiên
        let list = try await ApiService.request(
            PokemonList.self,
            from: .listPokemons(limit: 20, offset: 0)
        )
        
        // Then: Kiểm tra kết quả trả về
        #expect(list.count > 0, "Tổng số lượng Pokemon trên server phải lớn hơn 0")
        #expect(list.results.count == 20, "Danh sách trả về phải có đúng 20 Pokemon")
        #expect(list.results.first?.name == "bulbasaur", "Pokemon đầu tiên phải là bulbasaur")
        
        print("✅ Lấy thành công danh sách 20 Pokemon đầu tiên: \(list.results.map(\.name))")
    }
    
    // MARK: - 2. Test gọi chi tiết 1 Pokemon cụ thể (Ditto / Pikachu)
    @Test("Kiểm tra lấy chi tiết Pokemon theo tên hoặc ID")
    func testFetchPokemonDetail() async throws {
        // Given & When: Gọi chi tiết Pikachu (ID: 25)
        let pokemon = try await ApiService.request(
            SpecificPokemon.self,
            from: .pokemonDetail(idOrName: "pikachu")
        )
        
        // Then: Kiểm tra thông tin chi tiết
        #expect(pokemon.id == 25, "ID của Pikachu phải là 25")
        #expect(pokemon.name == "pikachu", "Tên Pokemon phải là pikachu")
        #expect(!pokemon.types.isEmpty, "Pikachu phải có ít nhất 1 hệ")
        #expect(pokemon.height > 0, "Chiều cao phải lớn hơn 0")
        #expect(pokemon.weight > 0, "Cân nặng phải lớn hơn 0")
        
        print("✅ Lấy thành công chi tiết: \(pokemon.name), ID: \(pokemon.id), Chiều cao: \(pokemon.height), Cân nặng: \(pokemon.weight)")
    }
    
    // MARK: - 3. Test gọi thông qua Dependency ApiClient (TCA)
    @Test("Kiểm tra gọi API thông qua Dependency ApiClient (TCA)")
    func testApiClientLiveValue() async throws {
        let client = ApiClient.liveValue
        
        // Gọi danh sách 5 Pokemon qua closure của ApiClient
        let list = try await client.pokemons(5, 0)
        #expect(list.results.count == 5, "ApiClient phải trả về 5 Pokemon")
        
        // Gọi chi tiết Ditto qua closure của ApiClient
        let ditto = try await client.pokemon("ditto")
        #expect(ditto.name == "ditto")
        #expect(ditto.id == 132)
        
        print("✅ Test thành công ApiClient.liveValue cho cả pokemons và pokemon detail")
    }
    
    // MARK: - 4. Test trường hợp URL lỗi (404 Not Found)
    @Test("Kiểm tra xử lý lỗi khi tìm Pokemon không tồn tại")
    func testFetchNonExistentPokemon() async {
        do {
            _ = try await ApiService.request(
                SpecificPokemon.self,
                from: .pokemonDetail(idOrName: "pokemon_khong_ton_tai_123456")
            )
            Issue.record("Đáng lẽ phải ném lỗi 404 nhưng lại thành công")
        } catch {
            print("✅ Đã bắt được lỗi đúng mong muốn: \(error.localizedDescription)")
            #expect(true)
        }
    }
}
