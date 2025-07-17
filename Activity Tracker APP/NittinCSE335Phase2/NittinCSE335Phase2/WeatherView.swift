import SwiftUI
import Foundation


struct Weather: Codable {
    let description: String
    let temperature: Double
    let icon: String

    enum CodingKeys: String, CodingKey {
        case description = "description"
        case temperature = "temp"
        case icon = "icon"
    }
}

// API response model
struct WeatherAPIResponse: Codable {
    let main: Main
    let weather: [WeatherInfo]
}

struct Main: Codable {
    let temperature: Double

    enum CodingKeys: String, CodingKey {
        case temperature = "temp"
    }
}

struct WeatherInfo: Codable {
    let id: Int
    let description: String
    let iconCode: String

    enum CodingKeys: String, CodingKey {
        case id
        case description
        case iconCode = "icon"
    }
}

func fetchWeatherData(city: String, completion: @escaping (Weather?) -> Void) {
    let apiKey = "API KEY"
    let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(encodedCity)&appid=\(apiKey)&units=metric")!
    
    URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            print("Network error: \(error.localizedDescription)")
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }

        guard let data = data else {
            print("No data received")
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }

        do {
            let response = try JSONDecoder().decode(WeatherAPIResponse.self, from: data)
            if let weatherInfo = response.weather.first {
                let weatherData = Weather(
                    description: weatherInfo.description,
                    temperature: response.main.temperature,
                    icon: weatherInfo.iconCode
                )
                DispatchQueue.main.async {
                    completion(weatherData)
                }
            } else {
                print("Weather data not found")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        } catch {
            print("Decoding error: \(error)")
            DispatchQueue.main.async {
                completion(nil)
            }
        }
    }.resume()
}


struct WeatherView: View {
    let cityName:String
    @State private var weather: Weather?
    @State private var message: String = ""
    @State private var isFetching = false

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.8), Color.blue.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)

            VStack {
                Text("Check Weather Forecast")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                    .padding()


                if isFetching {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                } else {
                    Button(action: {
                        fetchWeatherData(city: cityName) { weather in
                            self.weather = weather
                            
                            isFetching = false
                        }
                        isFetching = true
                    }) {
                        Text("Get Suggestions")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue.opacity(0.8))
                            .cornerRadius(10)
                    }
                }

                if let weather = self.weather {
                    WeatherDetailView(weather: weather, message: message)
                }

                Spacer()
            }
            .padding()
        }
    }

   
    struct WeatherDetailView: View {
        let weather: Weather
        let message: String

        var body: some View {
            VStack(spacing: 15) {
                HStack {
                    AsyncImage(url: URL(string: "https://openweathermap.org/img/wn/\(weather.icon)@2x.png"))
                        .frame(width: 80, height: 80)
                    Text("\(weather.temperature, specifier: "%.1f")°C")
                        .font(.largeTitle)
                        .bold()
                }
                .foregroundColor(.white)

                Text(weather.description.capitalized)
                    .font(.title3)
                    .italic()
                    .foregroundColor(.white)
                Text(message)
                    .font(.body)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .background(Color.black.opacity(0.5))
            .cornerRadius(15)
        }
    }
}

// Preview for SwiftUI Canvas
//struct WeatherView_Previews: PreviewProvider {
//    static var previews: some View {
//        WeatherView()
//    }
//}
