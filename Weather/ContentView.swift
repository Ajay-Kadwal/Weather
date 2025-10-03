//
//  ContentView.swift
//  Weather
//
//  Created by AJAY KADWAL on 29/09/25.
//

import SwiftUI
import Combine

struct WeatherResponse {
    let main: Main
    let weather: [Weather]
    let wind: Wind
    let clouds: Clouds
    let sys: Sys
}
nonisolated extension WeatherResponse: Decodable {}

struct Main: Codable {
    let temp: Double
}

struct Weather: Codable {
    let description: String
}

struct Wind: Codable {
    let speed: Double
    let deg: Int
}

struct Clouds: Codable {
    let all: Int
}

struct Sys: Codable {
    let country: String
    let sunrise: Int
    let sunset: Int
}


class WeatherViewModel : ObservableObject{
    @Published var temperature: String = ""
    @Published var condition: String = ""
    @Published var Cityname: String = ""
    @Published var windSpeed: String = "--"
    @Published var cloudiness: String = "--"
    @Published var country: String = "--"
    @Published var sunrise: String = "--"
    @Published var sunset: String = "--"

    func FetchData(city: String) {
        let apiKey = "7778f413febf3f799c831e9e9415d94e"
        let url = "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(apiKey)&units=metric"
        guard let Url = URL(string: url) else {return}
        
        URLSession.shared.dataTask(with: Url) { data, response, error in
            if let data = data {
                let decoder = JSONDecoder()
                do {
                    let response = try decoder.decode(WeatherResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.temperature = String(format: "%.1f", response.main.temp)
                        self.condition = response.weather.first?.description ?? "--"
                        self.Cityname = city
                        self.windSpeed = String(format: "%.1f m/s", response.wind.speed)
                        self.cloudiness = "\(response.clouds.all)%"
                        self.country = response.sys.country
                                                
                        // Convert sunrise/sunset (Unix → human time)
                        let sunriseDate = Date(timeIntervalSince1970: TimeInterval(response.sys.sunrise))
                        let sunsetDate = Date(timeIntervalSince1970: TimeInterval(response.sys.sunset))
                        let formatter = DateFormatter()
                        formatter.timeStyle = .short
                                                
                        self.sunrise = formatter.string(from: sunriseDate)
                        self.sunset = formatter.string(from: sunsetDate)
                    }
                } catch {
                    print("Decoding is Fail!!!")
                }
            }
        }.resume()
    }
}

struct ContentView: View {
    @State var cityName: String = ""
    @State var tempereture: Double = 0
    @State var weather: String = ""
    @StateObject var vm = WeatherViewModel()
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [.blue, .white], startPoint: .topLeading, endPoint: .bottomLeading).ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 40){
                    
                    Text("Weather For : \(cityName)")
                        .font(.title)
                        .bold()
                    
                    TextField("Enter City hear...", text: $cityName)
                        .padding()
                        .background(.white.opacity(0.3))
                        .cornerRadius(10)
                    
                    Button("Get Weather Conditions") {
                        vm.FetchData(city: cityName)
                    }
                    .font(.title2)
                    .foregroundStyle(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.blue)
                    .cornerRadius(10)
                    
                    HStack (spacing: 20) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(LinearGradient(colors: [.green.opacity(0.3), .white], startPoint: .bottom, endPoint: .top))
                            .frame(width: 150, height: 150)
                            .overlay(alignment: .top) {
                                VStack (alignment: .leading, spacing: 10){
                                    Text("Tempreture: \(vm.temperature)")
                                        .font(.headline)
                                        .foregroundStyle(.red)
                                        .lineLimit(2)
                                    Text("Weather: \(vm.condition)")
                                        .font(.headline)
                                        .foregroundStyle(.blue)
                                }
                                .padding(.top, 39)
                                
                            }
                        
                        
                        RoundedRectangle(cornerRadius: 10)
                            .fill(LinearGradient(colors: [.green.opacity(0.3), .white], startPoint: .bottom, endPoint: .top))
                            .frame(width: 150, height: 150)
                            .overlay(alignment: .top) {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("💨 Wind: \(vm.windSpeed)")
                                        .font(.headline)
                                        .foregroundStyle(.cyan)
                                    Text("☁️ Clouds: \(vm.cloudiness)")
                                        .font(.headline)
                                }
                                .padding(.top, 39)
                            }
                    }
                    
                    Text("Country: \(vm.country)")
                        .font(.title)
                        .bold()
                    
                    Text("Sunset At: \(vm.sunset)")
                        .font(.title)
                        .bold()
                    
                    Text("Sunrise At: \(vm.sunrise)")
                        .font(.title)
                        .bold()
                }
                .padding(.top, 60)
                .frame(maxHeight: .infinity, alignment: .top)
                .padding()
            }
        }
    }
}

#Preview {
    ContentView()
}

/*
 self.temperature = String(format: "%.1f", response.main.temp)
 self.condition = response.weather.first?.description ?? "--"
 nonisolated extension WeatherResponse: Decodable {}
 */
