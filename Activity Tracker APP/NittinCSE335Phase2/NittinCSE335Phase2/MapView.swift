import SwiftUI
import MapKit
import CoreLocation


struct Positioning: Identifiable {
    let id = UUID()
    var name: String
    var coords: CLLocationCoordinate2D
}


struct HotelInfo {
    var rating: Double
    var reviewCount: Int
    var phone: String
    var url: String
}

struct HotelSearchResponse: Codable {
    let businesses: [HotelData]
}

struct HotelData: Codable {
    let rating: Double?
    let phone: String?
    let url: String?
    let reviewCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case rating, phone, url
        case reviewCount = "review_count"
    }
}


struct HotelDetailsView: View {
    var hotelInfo: HotelInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Rating: \(String(format: "%.1f", hotelInfo.rating)) ⭐️")
            Text("Reviews: \(hotelInfo.reviewCount)")
            Text("Phone: \(hotelInfo.phone)")
            if let url = URL(string: hotelInfo.url) {
                Link("Visit Website", destination: url)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}


struct CustomAnnotationView: View {
    var name: String
    var coords: CLLocationCoordinate2D
    var apiKey: String
    var fetchHotelRating: (String, Double, Double, String, @escaping (HotelInfo) -> Void) -> Void

    @State private var showingDetails = false
    @State private var hotelInfo = HotelInfo(rating: 0.0, reviewCount: 0, phone: "N/A", url: "N/A")

    var body: some View {
        VStack {
            Image(systemName: "building.fill")
                .foregroundColor(.blue)
                .font(.title)
            Text(name)
                .font(.caption)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .foregroundColor(.black)
                .padding(5)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 3)
        }
        .onTapGesture {
            fetchHotelRating(name, coords.latitude, coords.longitude, apiKey) { info in
                hotelInfo = info
                showingDetails = true
            }
        }
        .sheet(isPresented: $showingDetails) {
            HotelDetailsView(hotelInfo: hotelInfo)
        }
    }
}

struct MapView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var sector = MKCoordinateRegion()
    @State private var stater: [Positioning] = []
    let cityname: String
    let apiKey = "tXZjBbWctb9LtgWMjrmvdET6A7AMiTZXgOWe4phKNT5m1dkBRHvxnVFWbEShfJ09i4t4sptBwx9kpiC2hspJzqO78XhfYHXF7WAZodp10mui-8j7_0RlTtVmE29dZXYx"

    var body: some View {
        VStack {
            Map(coordinateRegion: $sector, interactionModes: .all, annotationItems: stater) { location in
                MapAnnotation(coordinate: location.coords) {
                    CustomAnnotationView(name: location.name, coords: location.coords, apiKey: apiKey, fetchHotelRating: fetchHotelRating)
                }
            }
            .ignoresSafeArea()
            .onAppear { positivegeotrack(temp_address: cityname) }

            VStack {
                Text("Hotels near \(cityname)")
                Text("Click on the Hotels to get more info.")
            }
        }
        .navigationTitle(cityname)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(role: .destructive) {
                    dismiss()
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
    }

    func positivegeotrack(temp_address: String) {
        CLGeocoder().geocodeAddressString(temp_address) { placemarks, error in
            guard let placemark = placemarks?.first, let location = placemark.location?.coordinate else {
                print("Geocode failed: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            DispatchQueue.main.async {
                stater = [Positioning(name: temp_address, coords: location)]
                sector = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
                findHotelsNearby()
            }
        }
    }

    func findHotelsNearby() {
        let hotelSearch = MKLocalSearch.Request()
        hotelSearch.region = sector
        hotelSearch.naturalLanguageQuery = "hotels"

        MKLocalSearch(request: hotelSearch).start { result, error in
            guard let outcome = result else {
                print("Error Finding Hotels: \(error?.localizedDescription ?? "Unknown error").")
                return
            }
            stater = outcome.mapItems.map { item in
                Positioning(name: item.name ?? "", coords: item.placemark.coordinate)
            }
        }
    }

    func fetchHotelRating(hotelName: String, latitude: Double, longitude: Double, apiKey: String, completion: @escaping (HotelInfo) -> Void) {
        let encodedName = hotelName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://api.yelp.com/v3/businesses/search?term=\(encodedName)&latitude=\(latitude)&longitude=\(longitude)"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "Unknown error")
                completion(HotelInfo(rating: 0.0, reviewCount: 0, phone: "N/A", url: "N/A"))
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(HotelSearchResponse.self, from: data)
                if let firstHotel = decodedResponse.businesses.first {
                    let hotelInfo = HotelInfo(
                        rating: firstHotel.rating ?? 0.0,
                        reviewCount: firstHotel.reviewCount ?? 0,
                        phone: firstHotel.phone ?? "N/A",
                        url: firstHotel.url ?? "N/A"
                    )
                    completion(hotelInfo)
                } else {
                    completion(HotelInfo(rating: 0.0, reviewCount: 0, phone: "N/A", url: "N/A"))
                }
            } catch {
                print("JSON decoding error: \(error)")
                completion(HotelInfo(rating: 0.0, reviewCount: 0, phone: "N/A", url: "N/A"))
            }
        }

        task.resume()
    }
    }

                       


