//
//  ApiMapping.swift
//  Pokemon_app
//
//  Created by ManhLe on 10/20/26.
//
import Foundation

public enum ApiError: LocalizedError, Sendable {
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
    
    public var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Phản hồi từ server không hợp lệ."
        case let .httpError(statusCode):
            return "Lỗi server với mã lỗi: \(statusCode)."
        case let .decodingError(error):
            return "Lỗi giải mã dữ liệu: \(error.localizedDescription)"
        }
    }
}

public enum ApiMapping {
    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        // Cấu hình decoder nếu cần (ví dụ: keyDecodingStrategy, dateDecodingStrategy...)
        return decoder
    }()
    
    /// Giải mã Data sang bất kỳ Model nào thoả mãn Decodable
    public static func decode<T: Decodable>(_ type: T.Type = T.self, from data: Data) throws -> T {
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            // Ném lỗi giải mã rõ ràng
            throw ApiError.decodingError(error)
        }
    }
}

