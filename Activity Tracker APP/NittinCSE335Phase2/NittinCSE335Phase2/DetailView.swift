import SwiftUI
import MapKit
import CoreLocation

struct DetailView: View {
    let userInfo: UserInfo
    @State private var showMapView = false
    @State private var mapRegion = MKCoordinateRegion()
    @State private var mapCoordinates = CLLocationCoordinate2D()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Group {
                Text(" Date of the Actvity: \(formatDate(userInfo.startdate))")
                    .font(.headline)
                Text("Start Time: \(formatTime(userInfo.starttime))")
                Text("End Time: \(formatTime(userInfo.endtime))")
                Text("City: \(userInfo.city ?? "Unknown")")
                Text("Important Place: \(userInfo.importantplace ?? "N/A")")
                Text("Activity Info: \(userInfo.activityinfo ?? "N/A")")
                Text("Activity Type: \(userInfo.activitytype ?? "N/A")")
            }
            .font(.subheadline)
            .padding(.vertical, 2)

            HStack {
                NavigationLink(destination: MapView(cityname: userInfo.city ?? "Unknown")) {
                    Text("Hotel Suggestions")
                        .foregroundColor(.white)
                        .padding()
                }
                .background(Color.blue)
                .cornerRadius(8)

                NavigationLink(destination: WeatherView(cityName: userInfo.city ?? "Chennai")) {
                    Text("Check weather!")
                        .foregroundColor(.white)
                        .padding()
                }
                .background(Color.green)
                .cornerRadius(8)
            }
            .padding()
        }
        .padding()
        .navigationBarTitle("Activity Details", displayMode: .inline)
        .background(Color(.systemBackground)) 
    }

    private func formatTime(_ date: Date?) -> String {
        guard let date = date else { return "Unknown" }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    private func formatDate(_ date: Date?) -> String {
            guard let date = date else { return "Unknown" }
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: date)
        }
}
    

   
