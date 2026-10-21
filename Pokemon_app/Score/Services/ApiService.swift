//
//  ApiService.swift
//  Pokemon_app
// xử lí việc ánh xạ từ 1 đối tượng data thành 1 đối tượng dto
//  Created by ManhLe on 10/20/26.
//
import Foundation
public enum ApiService {
    
    private static func sendRequest (_ url : URL,method : String) async throws -> Data{
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = 30
        
        let (data, response ) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw  URLError(.badServerResponse)
        }
        guard (200 ... 299).contains(http.statusCode) else {
            if http.statusCode == 404 {
                throw URLError(.fileDoesNotExist)
            }
            else {
                throw URLError( .badServerResponse)
            }
        }
        return data
        
    }
   
  
    /// 🚀 1 hàm static duy nhất nhận Kiểu đối tượng cần decode và Endpoint chứa đối số
     static func request<T: Decodable>(_ type: T.Type, from endpoint: Endpoint, method: HttpMethod = .get) async throws -> T {
        let data = try await sendRequest(endpoint.url, method: method.rawValue)
        return try ApiMapping.decode(type, from: data)
    }
}
nonisolated enum HttpMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}
