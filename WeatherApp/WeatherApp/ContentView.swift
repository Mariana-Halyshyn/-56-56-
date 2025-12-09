//
//  ContentView.swift
//  WeatherApp
//
//  Created by ІПЗ-31/1 on 09.12.2025.
//


import SwiftUI

struct ContentView: View {
    @StateObject private var favorites = FavoritesStore() // Ініціалізація безпосередньо
    @StateObject private var vm: WeatherViewModel
    @State private var inputCity: String = ""

    // Ініціалізація WeatherViewModel через StateObject в ContentView
    init() {
        _vm = StateObject(wrappedValue: WeatherViewModel(favorites: favorites))
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                HStack {
                    TextField("Введіть місто", text: $inputCity)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit {
                            setCityAndReload()
                        }

                    Button(action: {
                        setCityAndReload()
                    }) {
                        Image(systemName: "magnifyingglass.circle.fill")
                            .font(.title2)
                    }
                }
                .padding(.horizontal)

                if vm.isLoading {
                    ProgressView().padding()
                }

                if let current = vm.current {
                    WeatherCardView(current: current, isFavorite: vm.isFavorite(), toggleFavorite: {
                        vm.toggleFavorite()
                    })
                    .padding(.horizontal)
                } else {
                    VStack {
                        Text("Поточна погода недоступна")
                        if let err = vm.errorMessage {
                            Text(err).foregroundColor(.red).font(.caption)
                        }
                    }
                    .padding()
                }

                HourlyView(items: vm.hourly)

                Text("Улюблені міста")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading)

                List {
                    ForEach(favorites.favorites, id: \.self) { city in
                        HStack {
                            Button(action: {
                                vm.city = city
                                Task { await vm.loadAll() }
                            }) {
                                Text(city)
                            }
                            Spacer()
                            Button(action: {
                                favorites.remove(city)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .onDelete { idx in
                        for i in idx { favorites.remove(favorites.favorites[i]) }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Погода")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { vm.refresh() }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { vm.toggleFavorite() }) {
                        Image(systemName: vm.isFavorite() ? "heart.fill" : "heart")
                    }
                }
            }
        }
    }

    func setCityAndReload() {
        let trimmed = inputCity.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        vm.city = trimmed
        inputCity = ""
        Task { await vm.loadAll() }
    }
}


