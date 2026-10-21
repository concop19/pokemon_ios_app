//
//  ContentView.swift
//  Pokemon_app
//
//  Created by ManhLe on 10/20/26.
//

import SwiftUI

struct ContentView: View {
    @State private var pokemonList: PokemonList?
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            VStack {
                if isLoading {
                    ProgressView("Đang tải dữ liệu từ PokeAPI...")
                        .padding()
                } else if let error = errorMessage {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.red)
                        Text("Gọi API thất bại!")
                            .font(.headline)
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Button("Thử lại") {
                            Task { await testFetchPokemons() }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else if let list = pokemonList {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tổng số Pokémon: \(list.count)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                        
                        List(list.results, id: \.name) { pokemon in
                            HStack {
                                Image(systemName: "circle.circle.fill")
                                    .foregroundStyle(.blue)
                                Text(pokemon.name.capitalized)
                                    .font(.body)
                                Spacer()
                                Text(pokemon.url)
                                    .font(.caption2)
                                    .foregroundStyle(.gray)
                                    .lineLimit(1)
                            }
                        }
                    }
                } else {
                    ContentUnavailableView(
                        "Chưa có dữ liệu",
                        systemImage: "network",
                        description: Text("Bấm nút bên dưới để test gọi ApiService")
                    )
                }
            }
            .navigationTitle("Test PokeAPI")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        Task { await testFetchPokemons() }
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .task {
                // Tự động test gọi API khi vừa mở màn hình
                await testFetchPokemons()
            }
        }
    }
    
    private func testFetchPokemons() async {
        isLoading = true
        errorMessage = nil
        do {
            let result = try await ApiService.request(PokemonList.self, from: .listPokemons(limit: 20, offset: 0))
            print("✅ Đã lấy thành công \(result.results.count) Pokemon:")
            for p in result.results {
                print("- \(p.name): \(p.url)")
            }
            pokemonList = result
        } catch {
            print("❌ Lỗi khi gọi API: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

#Preview {
    ContentView()
}

