//
//  FavoritesStore.swift
//  WeatherApp
//
//  Created by ІПЗ-31/1 on 09.12.2025.
//

import SwiftUI // або Combine, якщо немає SwiftUI
import Foundation
internal import Combine

class FavoritesStore: ObservableObject {
    // Властивість, за якою буде спостерігати SwiftUI
    @Published private(set) var favorites: [String]

    private let key = "favoriteCities_v1"

    // Ініціалізація з UserDefaults
    init() {
        self.favorites = UserDefaults.standard.stringArray(forKey: key) ?? []
    }

    // Метод додавання міста до списку
    func add(_ city: String) {
        let trimmed = city.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty,
              !favorites.contains(where: { $0.caseInsensitiveCompare(trimmed) == .orderedSame }) else { return }
        favorites.append(trimmed)
        save()
    }

    // Метод видалення міста
    func remove(_ city: String) {
        favorites.removeAll { $0.caseInsensitiveCompare(city) == .orderedSame }
        save()
    }

    // Збереження в UserDefaults
    private func save() {
        UserDefaults.standard.set(favorites, forKey: key)
    }
}

