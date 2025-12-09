//
//  WeatherService.swift
//  WeatherApp
//
//  Created by ІПЗ-31/1 on 09.12.2025.
//

import Foundation

actor WeatherService {
    static let shared = WeatherService()
    private let apiKey = "480936d07fc6be7125e719a8597b7135" // ваш ключ
    private let session = URLSession.shared
    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .secondsSince1970
        return d
    }()

    enum ServiceError: Error {
        case badURL, httpError(Int), noData, decodeError
    }

    func fetchCurrent(for city: String, units: String = "metric") async throws -> CurrentWeatherResponse {
        guard let cityEncoded = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { throw ServiceError.badURL }
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(cityEncoded)&appid=\(apiKey)&units=\(units)"
        guard let url = URL(string: urlString) else { throw ServiceError.badURL }
        let (data, resp) = try await session.data(from: url)
        if let http = resp as? HTTPURLResponse, !(200...299).contains(http.statusCode) { throw ServiceError.httpError(http.statusCode) }
        do {
            return try decoder.decode(CurrentWeatherResponse.self, from: data)
        } catch {
            throw ServiceError.decodeError
        }
    }

    func fetchForecast(for city: String, units: String = "metric") async throws -> [ForecastItem] {
        guard let cityEncoded = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { throw ServiceError.badURL }
        let urlString = "https://api.openweathermap.org/data/2.5/forecast?q=\(cityEncoded)&appid=\(apiKey)&units=\(units)"
        guard let url = URL(string: urlString) else { throw ServiceError.badURL }
        let (data, resp) = try await session.data(from: url)
        if let http = resp as? HTTPURLResponse, !(200...299).contains(http.statusCode) { throw ServiceError.httpError(http.statusCode) }
        do {
            let decoded = try decoder.decode(ForecastResponse.self, from: data)
            return decoded.list
        } catch {
            throw ServiceError.decodeError
        }
    }
}
