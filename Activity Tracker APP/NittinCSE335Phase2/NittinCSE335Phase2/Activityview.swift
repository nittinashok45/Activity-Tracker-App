
import SwiftUI
import CoreData

struct Activityview: View {
    @ObservedObject var userInfomanage: Userinfomanage
    @State private var selectedDate = Date()

    var body: some View {
        NavigationView {
            VStack {
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(8)
                    .padding(.horizontal)

         
                Button("Load Activities") {
                    userInfomanage.loadActivities(for: selectedDate)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding(.horizontal)

               
                List(userInfomanage.userInfos, id: \.self) { userInfo in
                    NavigationLink(destination: DetailView(userInfo: userInfo)) {
                        ActivityListItemView(userInfo: userInfo)
                    }
                }
            }
            .navigationTitle("User Activities")
            .onAppear {
                userInfomanage.userInfos = []
            }
        }
    }
}


struct ActivityListItemView: View {
    let userInfo: UserInfo

    var body: some View {
        ScrollView{
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    if let startTime = userInfo.starttime, let endTime = userInfo.endtime {
                        Text("\(startTime.formatted(date: .omitted, time: .shortened)) to \(endTime.formatted(date: .omitted, time: .shortened))")
                            .font(.subheadline)
                    }
                    Text("\(userInfo.activitytype ?? "Unknown") Activity")
                        .foregroundColor(userInfo.activitytype == "Indoor" ? Color.red : Color.green)
                        .bold()
                }
                Spacer()
            }
            .padding()
            .background(Color.white.opacity(0.9))
            .cornerRadius(8)
        }
        
    }
}
