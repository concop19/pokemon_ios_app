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
    
    // MARK: - 3. Test lấy thông tin loài Pokemon (Species)
    @Test("Kiểm tra lấy thông tin loài Pokemon (Species): mô tả, màu sắc, cây tiến hoá")
    func testFetchPokemonSpecies() async throws {
        // Given & When: Lấy thông tin loài của Pikachu
        let species = try await ApiService.request(
            SpeciesPokemon.self,
            from: .pokemonSpecies(idOrName: "pikachu")
        )
        
        // Then: Kiểm tra các trường dữ liệu của Species
        #expect(species.name == "pikachu", "Tên loài phải là pikachu")
        #expect(species.color?.name == "yellow", "Màu sắc của Pikachu phải là yellow")
        #expect(species.captureRate > 0, "Tỷ lệ bắt phải lớn hơn 0")
        #expect(!species.evolutionChain.url.isEmpty, "URL cây tiến hoá không được để trống")
        #expect(!species.flavorTextEntries.isEmpty, "Phải có danh sách mô tả loài")
        #expect(!species.genera.isEmpty, "Phải có phân loại genus")
        #expect(!species.eggGroups.isEmpty, "Phải có danh sách nhóm trứng")
        
        let englishFlavorText = species.flavorTextEntries
            .first(where: { $0.language.name == "en" })?
            .flavorText
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\u{0C}", with: " ") ?? "Không có mô tả"
        let genus = species.genera.first(where: { $0.language.name == "en" })?.genus ?? "N/A"
        let eggGroups = species.eggGroups.map(\.name).joined(separator: ", ")
        
        print("""
        ------------------------------------------------------------
        🐾 [POKEMON SPECIES]: \(species.name.uppercased())
        • Màu sắc: \(species.color?.name ?? "N/A")
        • Phân loại: \(genus)
        • Tỷ lệ bắt (Capture rate): \(species.captureRate)
        • Tỷ lệ giới tính (Gender rate): \(species.genderRate)
        • Nhóm trứng (Egg groups): [\(eggGroups)]
        • Link Evolution Chain: \(species.evolutionChain.url)
        • Mô tả: \(englishFlavorText)
        ------------------------------------------------------------
        """)
    }
    
    // MARK: - 4. Test lấy cây tiến hoá (Evolution Chain) bằng đệ quy
    @Test("Kiểm tra duyệt cây tiến hoá bằng đệ quy (Recursive Evolution Chain)")
    func testFetchEvolutionChain() async throws {
        // Given & When: Gọi cây tiến hoá ID 1 (Bulbasaur -> Ivysaur -> Venusaur)
        let evolution = try await ApiService.request(
            EvolutionChain.self,
            from: .evolutionChain(id: 1)
        )
        
        // Then: Kiểm tra ID cây tiến hoá
        #expect(evolution.id == 1, "ID cây tiến hoá phải là 1")
        #expect(evolution.chain.species.name == "bulbasaur", "Cấp cơ bản phải là bulbasaur")
        
        // 1. Duyệt đệ quy chuỗi tiến hoá tuyến tính (ở mỗi bước lấy evolvesTo.first cho tới khi hết)
        let stages = evolution.chain.linearEvolutionChain()
        #expect(stages.count == 3, "Bulbasaur có đúng 3 cấp tiến hoá")
        #expect(stages[0].name == "bulbasaur")
        #expect(stages[1].name == "ivysaur")
        #expect(stages[1].minLevel == 16)
        #expect(stages[2].name == "venusaur")
        #expect(stages[2].minLevel == 32)
        
        // 2. Kiểm tra đệ quy tìm kiếm: dừng lại ngay khi gặp được Pokemon đầu tiên khớp tên ("ivysaur")
        let foundIvysaur = evolution.chain.findFirst(name: "ivysaur")
        #expect(foundIvysaur != nil, "Đệ quy phải tìm thấy ivysaur trong cây")
        #expect(foundIvysaur?.species.name == "ivysaur")
        
        // 3. Kiểm tra đệ quy tìm đường dẫn tiến hoá từ gốc cho tới khi gặp "venusaur"
        let pathToVenusaur = evolution.chain.pathTo(name: "venusaur")
        #expect(pathToVenusaur?.count == 3)
        #expect(pathToVenusaur?.map(\.name) == ["bulbasaur", "ivysaur", "venusaur"])
        
        // 4. Kiểm tra các bước chuyển đổi tiến hoá (From -> To kèm điều kiện) cho UI
        let transitions = evolution.transitions
        #expect(transitions.count == 2, "Bulbasaur có 2 bước chuyển đổi: Bulbasaur -> Ivysaur và Ivysaur -> Venusaur")
        #expect(transitions[0].from.name == "bulbasaur" && transitions[0].to.name == "ivysaur")
        #expect(transitions[0].condition == "Lv. 16")
        #expect(transitions[1].from.name == "ivysaur" && transitions[1].to.name == "venusaur")
        #expect(transitions[1].condition == "Lv. 32")
        
        print("""
        ------------------------------------------------------------
        🧬 [EVOLUTION CHAIN ID: \(evolution.id)] (Duyệt bằng hàm đệ quy)
        • Có tiến hoá không: \(evolution.hasEvolution ? "Có" : "Không")
        • Tổng số cấp tiến hoá: \(stages.count)
        • Các bước chuyển đổi UI:
        \(transitions.map { "  • \($0.from.name) ---[\($0.condition)]---> \($0.to.name)" }.joined(separator: "\n"))
        • Sơ đồ tiến hoá: \(evolution.displayChain)
        ------------------------------------------------------------
        """)
    }
    
    // MARK: - 5. Test chi tiết chiêu thức (Move Detail)
    @Test("Kiểm tra lấy chi tiết chiêu thức (Move) theo tên")
    func testFetchMoveDetail() async throws {
        // Given & When: Lấy chi tiết chiêu "thunderbolt"
        let move = try await ApiService.request(
            MoveDetail.self,
            from: .moveDetail(name: "thunderbolt")
        )
        
        // Then: Kiểm tra thông tin chiêu thức
        #expect(move.name == "thunderbolt", "Tên chiêu phải là thunderbolt")
        #expect(move.type.name == "electric", "Hệ của chiêu phải là electric")
        #expect(move.power == 90, "Sức mạnh của thunderbolt phải là 90")
        #expect(move.accuracy == 100, "Độ chính xác phải là 100")
        #expect(move.pp == 15, "Số lần sử dụng (PP) phải là 15")
        #expect(move.damageClass?.name == "special", "Lớp sát thương phải là special")
        #expect(!move.effectEntries.isEmpty, "Phải có thông tin hiệu ứng")
        
        let shortEffect = move.effectEntries
            .first(where: { $0.language.name == "en" })?
            .shortEffect ?? move.effectEntries.first?.effect ?? "N/A"
            
        print("""
        ------------------------------------------------------------
        ⚡️ [MOVE DETAIL]: \(move.name.uppercased()) (ID: \(move.id))
        • Hệ (Type): \(move.type.name)
        • Sức mạnh (Power): \(move.power.map(String.init) ?? "N/A")
        • Độ chính xác (Accuracy): \(move.accuracy.map { "\($0)%" } ?? "N/A")
        • Điểm kỹ năng (PP): \(move.pp.map(String.init) ?? "N/A")
        • Phân loại sát thương: \(move.damageClass?.name ?? "N/A")
        • Hiệu ứng: \(shortEffect)
        ------------------------------------------------------------
        """)
    }
    
    // MARK: - 6. Test chi tiết hệ Pokemon (Type Detail)
    @Test("Kiểm tra lấy danh sách Pokemon theo hệ (Type)")
    func testFetchTypeDetail() async throws {
        // Given & When: Lấy chi tiết hệ "electric"
        let type = try await ApiService.request(
            TypeDetail.self,
            from: .typeDetail(name: "electric")
        )
        
        // Then: Kiểm tra thông tin hệ
        #expect(type.name == "electric", "Tên hệ phải là electric")
        #expect(!type.pokemon.isEmpty, "Danh sách Pokemon thuộc hệ electric không được rỗng")
        #expect(type.pokemon.contains(where: { $0.pokemon.name == "pikachu" }), "Hệ electric phải chứa pikachu")
        
        let samplePokemons = type.pokemon.prefix(8).map(\.pokemon.name).joined(separator: ", ")
        
        print("""
        ------------------------------------------------------------
        ⚡️ [TYPE DETAIL]: \(type.name.uppercased()) (ID: \(type.id))
        • Tổng số Pokemon thuộc hệ: \(type.pokemon.count)
        • Danh sách một số Pokemon tiêu biểu: \(samplePokemons)...
        ------------------------------------------------------------
        """)
    }
    
    // MARK: - 7. Test qua Dependency ApiClient.liveValue (TCA) cho toàn bộ closures
    @Test("Kiểm tra gọi ApiClient.liveValue (pokemons, pokemon, pokemonSpecies, evolutionChain, move, type)")
    func testApiClientLiveValue() async throws {
        let client = ApiClient.liveValue
        
        // 1. pokemons closure
        let list = try await client.pokemons(5, 0)
        #expect(list.results.count == 5, "ApiClient phải trả về 5 Pokemon")
        
        // 2. pokemon closure
        let ditto = try await client.pokemon("ditto")
        #expect(ditto.name == "ditto")
        #expect(ditto.id == 132)
        
        // 3. pokemonSpecies closure
        let species = try await client.pokemonSpecies("charizard")
        #expect(species.name == "charizard")
        #expect(species.color?.name == "red")
        
        // 4. evolutionChain closure (Charmander chain ID: 2)
        let chain = try await client.evolutionChain(2)
        #expect(chain.id == 2)
        let charmanderStages = chain.linearChain
        #expect(charmanderStages.count == 3)
        #expect(charmanderStages.map(\.name) == ["charmander", "charmeleon", "charizard"])
        
        // 5. move closure
        let move = try await client.move("flamethrower")
        #expect(move.name == "flamethrower")
        #expect(move.type.name == "fire")
        #expect(move.power == 90)
        
        // 6. type closure
        let type = try await client.type("fire")
        #expect(type.name == "fire")
        #expect(type.pokemon.contains(where: { $0.pokemon.name == "charizard" }))
        
        print("""
        ------------------------------------------------------------
        ✅ Kiểm tra thành công toàn bộ closure của ApiClient.liveValue:
        • client.pokemons(5, 0) -> \(list.results.map(\.name))
        • client.pokemon(\"ditto\") -> ID: \(ditto.id), Name: \(ditto.name)
        • client.pokemonSpecies(\"charizard\") -> \(species.name) (Màu: \(species.color?.name ?? ""))
        • client.evolutionChain(2) -> \(chain.chain.species.name)
        • client.move(\"flamethrower\") -> \(move.name) (Power: \(move.power ?? 0), PP: \(move.pp ?? 0))
        • client.type(\"fire\") -> \(type.name) (\(type.pokemon.count) Pokemon)
        ------------------------------------------------------------
        """)
    }
    
    // MARK: - 8. Test trường hợp URL lỗi (404 Not Found)
    @Test("Kiểm tra xử lý lỗi khi tìm tài nguyên không tồn tại")
    func testFetchNonExistentResources() async {
        let client = ApiClient.liveValue
        
        // 1. Pokemon không tồn tại
        do {
            _ = try await client.pokemon("pokemon_khong_ton_tai_123456")
            Issue.record("Đáng lẽ phải ném lỗi 404 cho Pokemon không tồn tại")
        } catch {
            print("✅ Bắt đúng lỗi khi Pokemon không tồn tại: \(error.localizedDescription)")
            #expect(true)
        }
        
        // 2. Move không tồn tại
        do {
            _ = try await client.move("move_khong_ton_tai_9999")
            Issue.record("Đáng lẽ phải ném lỗi 404 cho Move không tồn tại")
        } catch {
            print("✅ Bắt đúng lỗi khi Move không tồn tại: \(error.localizedDescription)")
            #expect(true)
        }
        
        // 3. Species không tồn tại
        do {
            _ = try await client.pokemonSpecies("species_khong_ton_tai_9999")
            Issue.record("Đáng lẽ phải ném lỗi 404 cho Species không tồn tại")
        } catch {
            print("✅ Bắt đúng lỗi khi Species không tồn tại: \(error.localizedDescription)")
            #expect(true)
        }
        
        // 4. Type không tồn tại
        do {
            _ = try await client.type("type_khong_ton_tai_9999")
            Issue.record("Đáng lẽ phải ném lỗi 404 cho Type không tồn tại")
        } catch {
            print("✅ Bắt đúng lỗi khi Type không tồn tại: \(error.localizedDescription)")
            #expect(true)
        }
    }
}
