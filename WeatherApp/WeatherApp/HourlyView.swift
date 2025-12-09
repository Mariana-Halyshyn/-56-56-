//
//  HourlyView.swift
//  WeatherApp
//
//  Created by ІПЗ-31/1 on 09.12.2025.
//

import SwiftUI

struct HourlyView: View {
    let items: [ForecastItem]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(items, id: \.dt) { item in
                    VStack(spacing: 8) {
                        Text(hourString(from: item.dt))
                            .font(.caption)
                        AsyncImage(url: iconURL(code: item.weather.first?.icon ?? "01d")) { phase in
                            if let img = phase.image {
                                img.resizable().aspectRatio(contentMode: .fit)
                            } else {
                                Image(systemName: "cloud")
                            }
                        }
                        .frame(width: 44, height: 44)

                        Text("\(Int(item.main.temp))°C")
                            .bold()
                            .font(.subheadline)
                    }
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color(.tertiarySystemBackground)))
                }
            }
            .padding(.horizontal)
        }
        .frame(height: 140)
    }

    func hourString(from unix: TimeInterval) -> String {
        let d = Date(timeIntervalSince1970: unix)
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: d)
    }

    func iconURL(code: String) -> URL? {
        URL(string: "https://openweathermap.org/img/wn/\(code)@2x.png")
    }
}
