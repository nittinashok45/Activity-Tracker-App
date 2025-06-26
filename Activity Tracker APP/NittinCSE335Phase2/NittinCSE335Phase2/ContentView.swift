import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject private var userInfomanage = Userinfomanage()
    @State private var startDate = Date()
    @State private var startTime = Date()
    @State private var endTime = Date()
    @State private var city = ""
    @State private var activityInfo = ""
    @State private var activityType = "Indoor"
    @State private var importantPlace = ""
    let activityTypes = ["Indoor", "Outdoor"]
    @State private var showingInfoSheet=false
    
    private var isFormValid: Bool {
        !city.isEmpty && !importantPlace.isEmpty && !activityInfo.isEmpty
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Text("User Form for Activities")
                    .font(.title)
                    .padding()
                
                Form {
                    Section(header: Text("Date & Time")) {
                        DatePicker("Activty Date", selection: $startDate, displayedComponents: .date)
                        DatePicker("Start Time", selection: $startTime, displayedComponents: .hourAndMinute)
                        DatePicker("End Time", selection: $endTime, displayedComponents: .hourAndMinute)
                    }
                    
                    Section(header: Text("Activity Details")) {
                        TextField("City", text: $city)
                        TextField("Important Places?", text: $importantPlace)
                        TextField("Activity Info", text: $activityInfo)
                        
                        Picker("Activity Type", selection: $activityType) {
                            ForEach(activityTypes, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }
                
                HStack {
                    Button("Add") {
                        if !userInfomanage.isDuplicate(startDate: startDate, startTime: startTime) && isFormValid {
                            userInfomanage.addUserInfo(startDate: startDate, startTime: startTime, endTime: endTime, city: city, importantPlace: importantPlace, activityInfo: activityInfo, activityType: activityType)
                        }
                        else {
                            
                            showingInfoSheet = true
                            
                            
                        }
                    }
                    
                    
                    .padding()
                    .background( Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                    Button("Delete") {
                        if userInfomanage.isValidForDelete(startDate: startDate, startTime: startTime){
                            
                            userInfomanage.deleteUserInfo(startDate: startDate, startTime: startTime)
                        }
                        else{
                            showingInfoSheet = true

                            
                        }
                    }
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                    Button("Update") {
                        if userInfomanage.isValidForUpdate(startDate: startDate, startTime: startTime) && isFormValid {
                            userInfomanage.updateUserInfo(startDate: startDate, startTime: startTime, newEndTime: endTime, newCity: city, newImportantPlace: importantPlace, newActivityInfo: activityInfo, newActivityType: activityType)
                        }
                        else{
                            showingInfoSheet = true
                        }
                    }
                   
                    .padding()
                    .background( Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding()
                
                Spacer()
                
                NavigationLink(destination: Activityview(userInfomanage: userInfomanage)) {
                    Text("View All My Activities")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(8)
                }
                .padding()
                
                Button("Delete All") {
                    userInfomanage.deleteAllUserInfos()
                }
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .sheet(isPresented: $showingInfoSheet) {
                            InfoSheetView()
                        }
        }
    }
    
    
    struct InfoSheetView: View {
        var body: some View {
            VStack {
                Text("For Add")
                    .font(.headline)
                    .padding()
                    .foregroundColor(Color.red)
                Text(" All fields must be filled.")
                Text("No duplicate entries are allowed. Start Date and Start Time ahs to be unique")
                Text("For Delete")
                    .font(.headline)
                    .padding()
                    .foregroundColor(Color.red)
                Text(" Start Time and Start Date has to match with the record")
                Text("For Update")
                    .font(.headline)
                    .padding()
                    .foregroundColor(Color.red)
                Text(" All fields must be filled.")
                Text(" Start Time and Start Date has to match with the record")
                
                Spacer()
            }
            .padding()
        }
    }
    
}

